library("RSQLite")
library(DBI)
library(tidyverse)
library(dbplyr)

# connect to the sqlite file
orig.d <- getwd()
scratch.d <- "F:/scratch"
setwd(scratch.d)
#connect to GIS file: Note that the file has geomotry errors, and therefore no further corrections to multi part polygons could be applied.
con.gis = DBI::dbConnect(RSQLite::SQLite(), "Phil_Fish_project_Input_Polys_WGS84_Internal_BGR.sqlite")
src_dbi(con.gis) #show connection details, and list all tables

# get a list of all tables
dbListTables(con.gis) #phil_fish_project_input_polys_wgs84_internal_bgr

#select columns of interest from dql lite table of interest
gis.hab.bgr.con <- tbl(con.gis, sql("SELECT HAB_TYPE, bgr_subreg_id FROM phil_fish_project_input_polys_wgs84_internal_bgr"))
head(gis.hab.bgr.con, n = 10)# inspect data, show first ten rows
show_query(head(gis.hab.bgr.con, n = 10)) # to see sql query that was sent to sqlite


#### NB! now collect the data in dataframe so that other functions can be applied
gis.hab.bgr.dat <- gis.hab.bgr.con %>% 
  select(HAB_TYPE, bgr_subreg_id) %>%
  collect()
#saveRDS(gis.hab.bgr.dat, "F:/derived_data/Sensitivity_per_pressure/output/gis_dat.rds") # saved this file, in case join is lost - so can be reread from this location in future

#----------
#clean data
#clean HAB_TYPE column from multiple entries
gis.hab.bgr.dat$HAB_TYPE <- gsub(" or ", "/", gis.hab.bgr.dat$HAB_TYPE) # replace ; with / to make consistent
gis.hab.bgr.dat$HAB_TYPE <- gsub(";", "/", gis.hab.bgr.dat$HAB_TYPE) # replace ; with / to make consistent
gis.hab.bgr.dat$HAB_TYPE <- gsub("(8)", "", gis.hab.bgr.dat$HAB_TYPE) # remove (8) to make consistent
gis.hab.bgr.dat$HAB_TYPE <- gsub(" #", "", gis.hab.bgr.dat$HAB_TYPE) # remove (8) to make consistent
# Separate HAB_TYPe into multiple columns where "/" appears to allow for the next step
hab.types <- gis.hab.bgr.dat %>%
  tidyr::separate(HAB_TYPE, into = c("hab.1", "hab.2", "hab.3", "hab.4"), sep = "/", remove = F)
# Remove any leading or trailing white spaces which could cause problems when matching the eunis columns between gis and database.
hab.types <- purrr::map_df(hab.types, function(x) trimws(x, which = c("both")))
#check if there are values in all columns, and drop columns with no values
hab.types %>%
  distinct(hab.4)
#remove column 5 hab.4
hab.types <- hab.types[,c(1:4, 6)]
#only na values - so can be removed
hab.types %>%
        distinct(hab.3)
#has multiple values - keep

#House keeping
#reset wd
setwd(orig.d)
#remove unused GIs files to free up memory
rm(gis.hab.bgr.con,gis.hab.bgr.dat)
