#link the sbgr.BAP.min.max.sens to the GIS
library(RSQLite)
library(plyr)
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
#test code
#str(hab.types)
#str(sbgr.BAP.min.max.sens[[1]])
#sbgr.hab.gis <- left_join(hab.types,sbgr.BAP.min.max.sens[[1]], 
#                          by = c("bgr_subreg_id" = "sbgr", "hab.1" = "eunis.code.gis"))# e.g. composite join: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))

con.gis = DBI::dbConnect(RSQLite::SQLite(), "Phil_Fish_project_Input_Polys_WGS84_Internal_BGR.sqlite")

# List tables in your database
dbListTables(con.gis)

# List columns in a table
dbListFields(con.gis, "phil_fish_project_input_polys_wgs84_internal_bgr")



#make a newSQL lite table
dbSendQuery(conn=con.gis,
            "CREATE TABLE test
            (Date DATETIME,
            Station TEXT,
            Snowline TEXT,
            PRIMARY KEY (Date, Station))
            ")













dbWriteTable(conn=con.gis, name="phil_fish_project_input_polys_wgs84_internal_bgr", hab.types,sbgr.BAP.min.max.sens[[1]], row.names=F)

act.sbgr.bps.gis <- sbgr.BAP.min.max.sens %>%
        llply(function(x){
                sbgr.hab.gis <- left_join(hab.types,sbgr.BAP.min.max.sens[[1]], 
                                          by = c("bgr_subreg_id" = "sbgr", "hab.1" = "eunis.code.gis"))# e.g. composite join: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))
                
        }, .progress = "text")




