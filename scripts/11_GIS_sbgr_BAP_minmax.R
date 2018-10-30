#link the sbgr.BAP.min.max.sens to the GIS
library(RSQLite)
library(plyr)
library(DBI)
library(tidyverse)
library(dbplyr)
library(stringr)

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



# TEST code-----------------------------
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
dbListFields(con_gis, "gis_hab_geom_test_2")
#select columns of interest from sql lite table of interest
test.sql.dat <- tbl(con_gis, sql("SELECT ogc_fid, GEOMETRY, hab_1, sbgr_id FROM gis_hab_geom_test_2"))
str(test.sql.dat)

# End test code----------------------------


#test code
#str(hab.types)
#str(sbgr.BAP.min.max.sens[[1]])
#sbgr.hab.gis <- left_join(hab.types,sbgr.BAP.min.max.sens[[1]], 
#                          by = c("bgr_subreg_id" = "sbgr", "hab.1" = "eunis.code.gis"))# e.g. composite join: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))






#dbWriteTable(conn=con_gis, name="gis_hab_geom_test", gis.hab.geom, overwrite = T,row.names=F)

act.sbgr.bps.gis <- sbgr.BAP.max.sens %>%
        llply(function(x){
                sbgr.hab.gis <- left_join(hab.types,x,#START HERE!!! this code is the test code and should be replaced to be suitable to loop through lists.1 
                                          by = c("hab.1" = "eunis.code.gis")) %>%# e.g. composite join: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))
                        select(ogc_fid, hab.1, eunis.match.assessed, ActivityCode, PressureCode, max.sens) %>%
                        spread(key = PressureCode, value = max.sens) #%>%
                        #distinct(ogc_fid,hab.1) %>%
                        #as.tibble()
                
                act.code <- unique(as.character(sbgr.hab.gis$ActivityCode))[1]
                #generate a single maximum value per column
                sbgr.hab.gis.2  <-  sbgr.hab.gis %>%
                        group_by(ogc_fid) %>%
                        summarise(max_B1 = max(B1),
                                  max_B3 = max(B3),
                                  max_B5 = max(B5),
                                  max_B6 = max(B6),
                                  max_D2 = max(D2),
                                  max_D6 = max(D6),
                                  max_O1 = max(O1),
                                  max_O3 = max(O3),
                                  max_O5 = max(O5),
                                  max_P1 = max(P1),
                                  max_P2 = max(P2),
                                  max_P3 = max(P3),
                                  max_P7 = max(P7),
                                  max_P8 = max(P8)
                                  )
                                 
                        
                
                sbgr.hab.gis.2 %>% spread(key = eunis.match, value = max.sens)
                
                #joinhabitat to geometry (if we cannot tie geometry to the geometry of a different tbl)
                gis.hab.geom <- dplyr::left_join(gis.geom.dat, sbgr.hab.gis, by = "ogc_fid") %>%
                        select(ogc_fid, GEOMETRY, hab_1 =hab.1 )
                
                #make unique filenames to be pasted into SQL
                #create.db <- paste0("CREATE TABLE sbgr_BAP_sens_minmax_",gsub(x =unique(x$ActivityCode),".","_", fixed = T),
                #                   "(ogc_fid INTEGER,
                #                   GEOMETRY BLOB,
                #                   hab_1 TEXT,
                #                   sbgr_id TEXT,
                #                   PRIMARY KEY(ogc_fid))
                #                   ")
                
                
                filename <- paste0("sbgr_BAP_sens_max_",gsub(x =unique(sbgr.hab.gis$ActivityCode),".","_", fixed = T))
                #make a empty newSQL lite table 
                #dbSendQuery(conn=con_gis,
                #            filename)
                #write into the table using the overwrite statement
                
                dbWriteTable(conn=con_gis, name=filename, gis.hab.geom, overwrite = T,row.names=F)
                
                
        }, .progress = "text") #%>%
        #spread result according to pressures, and drop non relevant columns




##house kepping: close the connection: S3 method for class 'RODBC'
close(con = conn)
dbDisconnect(con.gis)





