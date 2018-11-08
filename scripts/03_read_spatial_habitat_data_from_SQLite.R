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
#
#run cleaning script

##house kepping: close the connection: S3 method for class 'RODBC'
setwd(orig.d)
close(con = con.gis)
dbDisconnect(con.gis)
