library("RSQLite")
library(DBI)
library(tidyverse)
library(dbplyr)

# connect to the sqlite file
orig.d <- getwd()
scratch.d <- "F:/scratch"
setwd(scratch.d)
con.gis = DBI::dbConnect(RSQLite::SQLite(), "Phil_Fish_project_Input_Polys_WGS84_Internal_BGR.sqlite")
src_dbi(con.gis) #show connection details, and list all tables

# get a list of all tables
dbListTables(con.gis) #phil_fish_project_input_polys_wgs84_internal_bgr

#select columns of interest from dql lite table of interest
gis.hab.bgr.con <- tbl(con.gis, sql("SELECT ogc_fid, HAB_TYPE, bgr_subreg_id FROM phil_fish_project_input_polys_wgs84_internal_bgr"))
head(gis.hab.bgr.con, n = 10)# inspect data, show first ten rows
show_query(head(gis.hab.bgr.con, n = 10)) # to see sql query that was sent to sqlite


#### NB! now collect the data in dataframe so that other functions can be applied
gis.hab.bgr.dat <- gis.hab.bgr.con %>% 
  select(ogc_fid, HAB_TYPE, bgr_subreg_id) %>%
  collect()

str(gis.hab.bgr.dat)

#----------
#clean data
#clean HAB_TYPE column from multiple entries
gis.hab.bgr.dat$HAB_TYPE <- gsub(" or ", "/", gis.hab.bgr.dat$HAB_TYPE) # replace ; with / to make consistent
gis.hab.bgr.dat$HAB_TYPE <- gsub(";", "/", gis.hab.bgr.dat$HAB_TYPE) # replace ; with / to make consistent
gis.hab.bgr.dat$HAB_TYPE <- gsub("(8)", "", gis.hab.bgr.dat$HAB_TYPE) # remove (8) to make consistent
gis.hab.bgr.dat$HAB_TYPE <- gsub(" #", "", gis.hab.bgr.dat$HAB_TYPE) # remove (8) to make consistent
# Separate HAB_TYPe into multiple columns where "/" appears to allow for the next step
hab.types <- gis.hab.bgr.dat %>%
        select(ogc_fid, HAB_TYPE, bgr_subreg_id) %>%
  tidyr::separate(HAB_TYPE, into = c("hab.1", "hab.2", "hab.3", "hab.4"), sep = "/", remove = F)
# Remove any leading or trailing white spaces which could cause problems when matching the eunis columns between gis and database.
hab.types <- purrr::map_df(hab.types, function(x) trimws(x, which = c("both")))
str(hab.types) # changed integer top char for all!
hab.types$ogc_fid <- as.integer(hab.types$ogc_fid)


#check if there are values in all columns, and drop columns with no values
hab.types %>%
  distinct(hab.4)
#remove column 5 hab.4
hab.types <- hab.types %>% 
        select(-hab.4)
#only na values - so can be removed
hab.types %>%
        distinct(hab.3)
#has multiple values - keep



#House keeping
#reset wd
setwd(orig.d)

#remove unused GIs files to free up memory
rm(gis.hab.bgr.con,gis.hab.bgr.dat)

##house kepping: close the connection: S3 method for class 'RODBC'
close(con = con.gis)
dbDisconnect(con.gis)
