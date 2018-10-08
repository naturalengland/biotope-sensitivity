# assign the EUNIs level to the mapped habitats 
library(plyr)
library(tidyverse)
library(data.table)

setwd("F:/derived_data/Sensitivity_per_pressure")
#functions
source("./functions/match_eunis_to_biotope_fn.R") # function 

# input data

# SPATIAL data for join (y):
# y - from spatial data; all possible EUNIS codes per BGR
#in order to do so, define the EUNIs level of the hab.1 column
eunis.lvl.less.2 <- nchar(as.character(hab.types$hab.1), type = "chars", allowNA = T, keepNA = T)
eunis.lvl.more.2 <- nchar(as.character(hab.types$hab.1), type = "chars", allowNA = T, keepNA = T)-1
hab.types$level <- ifelse(nchar(as.character(hab.types$hab.1), type = "chars", allowNA = T, keepNA = T) > 2, eunis.lvl.more.2, eunis.lvl.less.2) #only using the first stated habitat, could be made to include others later on
rm(eunis.lvl.less.2, eunis.lvl.more.2) # housekeeping remove temporary vars


# Define (unique) benthic habitats to allow the join between the GIS spatial mapped data and the sensitivity assessments (by EUNIS codes)
distinct.mapped.habt.types <- hab.types %>%
  distinct(hab.1,bgr_subreg_id, level) %>% drop_na() # hab.1 contains the worked/processed HAB_TYPE data (1st column)

#generate multiple dataframes in a list, fo rthe various subBGRs
bgr.dfs.lst <- split(distinct.mapped.habt.types, distinct.mapped.habt.types$bgr_subreg_id)


# All EUNIS Biotopes that have been assessed 
# below is a for loop that count backwards, and then split the EUNIsAssessed in to a list of dataframes 1st being the most detailed biotope level (6), and then down to the braodest biotope level (4) that were assessed in the PD_AoO access database
x.dfs.lst <- split(EunisAssessed,f = EunisAssessed$level)


level.result.tbl <- vector("list", length(x.dfs.lst))
names(level.result.tbl) <- paste0("h.lvl_",names(x.dfs.lst))
#datalist <- list()
for (g in seq_along(x.dfs.lst)) {
  #determine the number of characters for substring limit to feed into substring statement
  sbstr.nchr <- unique(nchar(as.character(x.dfs.lst[[g]]$EUNISCode)))
  x <- substr(as.character(x.dfs.lst[[g]]$EUNISCode), 1,sbstr.nchr)
  #cbind.data.frame(x.dfs.lst[[g]], x)
  #datalist[[g]] <- x
  mx.lvl <- unique(x.dfs.lst[[g]]$level)
  
  #r obj to save results per level
  level.result.tbl[[g]] <- data.frame(matrix(ncol = length(x)+4), stringsAsFactors = FALSE) # +4 to cater for the added columns, sbgr, etc
  names(level.result.tbl[[g]]) <- c(as.character(x.dfs.lst[[g]][[1]]),"sbgr", "h.lvl", "l.lvl","eunis.code.gis") #names should be x (highest level assessed against) 
  
  
  # specify a large table into which results can be written outside of for loops
  match_eunis_to_biotopes_fn(x,bgr.dfs.lst,mx.lvl)
  level.result.tbl[[g]] <- out # this does not yet work...
}
