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
con_gis = DBI::dbConnect(RSQLite::SQLite(), "Phil_Fish_project_Input_Polys_WGS84_Internal_BGR.sqlite")
src_dbi(con_gis) #show connection details, and list all tables

# get a list of all tables
dbListTables(con_gis) #phil_fish_project_input_polys_wgs84_internal_bgr

# List columns in a table
dbListFields(con_gis, "phil_fish_project_input_polys_wgs84_internal_bgr")


#select columns of interest from sql lite table of interest
gis.geom.bgr.con <- tbl(con_gis, sql("SELECT ogc_fid, GEOMETRY, objectid FROM phil_fish_project_input_polys_wgs84_internal_bgr"))

#saves the geomtry
gis.geom.dat <- gis.geom.bgr.con %>% 
        select(ogc_fid, GEOMETRY, objectid) %>%
        collect()




#joinhabitat to geometry
gis.hab.geom <- dplyr::left_join(gis.geom.dat, hab.types, by = "ogc_fid") %>%
        select(ogc_fid, GEOMETRY, hab_1 =hab.1, sbgr_id = bgr_subreg_id )
#rm(hab.types,gis.geom.dat)
names(gis.hab.geom)
str(gis.hab.geom)


#make a newSQL lite table (empty)
dbSendQuery(conn=con_gis,
                "CREATE TABLE gis_hab_geom_test_2
            (ogc_fid INTEGER, 
            GEOMETRY BLOB, 
            hab_1 TEXT, 
            sbgr_id TEXT, 
            PRIMARY KEY(ogc_fid)
                )
            ")



# List columns in a table
dbListFields(con_gis, "gis_hab_geom_test")
#select columns of interest from sql lite table of interest
test.sql.dat <- tbl(con_gis, sql("SELECT ogc_fid, GEOMETRY, hab_1, sbgr_id FROM gis_hab_geom_test"))
str(test.sql.dat)




#test code
#str(hab.types)
#str(sbgr.BAP.min.max.sens[[1]])
#sbgr.hab.gis <- left_join(hab.types,sbgr.BAP.min.max.sens[[1]], 
#                          by = c("bgr_subreg_id" = "sbgr", "hab.1" = "eunis.code.gis"))# e.g. composite join: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))






#dbWriteTable(conn=con_gis, name="gis_hab_geom_test", gis.hab.geom, overwrite = T,row.names=F)

act.sbgr.bps.gis <- sbgr.BAP.min.max.sens %>%
        llply(function(x){
                sbgr.hab.gis <- left_join(hab.types,sbgr.BAP.min.max.sens[[1]],#START HERE!!! this code is the test code and should be replaced to be suitable to loop through lists.1 
                                          by = c("bgr_subreg_id" = "sbgr", "hab.1" = "eunis.code.gis"))# e.g. composite join: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))
                
                
                #joinhabitat to geometry
                gis.hab.geom <- dplyr::left_join(gis.geom.dat, hab.types, by = "ogc_fid") %>%
                        select(ogc_fid, GEOMETRY, hab_1 =hab.1, sbgr_id = bgr_subreg_id )
                
                #make a newSQL lite table (empty?)
                dbSendQuery(conn=con_gis,
                            "CREATE TABLE gis_hab_geom_test_2
                            (ogc_fid INTEGER, 
                            GEOMETRY BLOB, 
                            hab_1 TEXT, 
                            sbgr_id TEXT, 
                            PRIMARY KEY(ogc_fid)
                            )
                            ")
                dbWriteTable(conn=con_gis, name="gis.hab.geom", gis.hab.geom, overwrite = T,row.names=F)
                
        }, .progress = "text")



##house kepping: close the connection: S3 method for class 'RODBC'
close(con = conn)
dbDisconnect(con.gis)
