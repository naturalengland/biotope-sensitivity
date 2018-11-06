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
#gis.hab.geom <- dplyr::left_join(gis.geom.dat, hab.types, by = "ogc_fid") %>%
#        select(ogc_fid, GEOMETRY, hab_1 =hab.1, sbgr_id = bgr_subreg_id )
#rm(hab.types,gis.geom.dat)
#names(gis.hab.geom)
#str(gis.hab.geom)


#make a newSQL lite table (empty)
#dbSendQuery(conn=con_gis,
#                "CREATE TABLE gis_hab_geom_test_2
#            (ogc_fid INTEGER, 
#            GEOMETRY BLOB, 
#            hab_1 TEXT, 
#            sbgr_id TEXT, 
#            PRIMARY KEY(ogc_fid)
#                )
#            ")



# List columns in a table
#dbListFields(con_gis, "gis_hab_geom_test_2")
#select columns of interest from sql lite table of interest
#test.sql.dat <- tbl(con_gis, sql("SELECT ogc_fid, GEOMETRY, hab_1, sbgr_id FROM gis_hab_geom_test_2"))
#str(test.sql.dat)

# End test code----------------------------


#test code
#str(hab.types)
#str(sbgr.BAP.min.max.sens[[1]])
#sbgr.hab.gis <- left_join(hab.types,sbgr.BAP.min.max.sens[[1]], 
#                          by = c("bgr_subreg_id" = "sbgr", "hab.1" = "eunis.code.gis"))# e.g. composite join: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))


pressure.test <- sbgr.BAP.max.sens %>%
        llply(function(x){
                test <- x$PressureCode %>%
                        unique()
        })



#dbWriteTable(conn=con_gis, name="gis_hab_geom_test", gis.hab.geom, overwrite = T,row.names=F)

act.sbgr.bps.gis <- sbgr.BAP.max.sens %>%
        llply(function(x){
                
                #TO TEST:
                act.code <- unique(as.character(x$ActivityCode[!is.na(x$ActivityCode)]))
                
                
                x <- sbgr.BAP.max.sens[[3]] #test code only - to test a single matrix at a time
                
                sbgr.hab.gis <- left_join(hab.types, x, by = c("bgr_subreg_id" = "sbgr", "hab.1" = "eunis.code.gis")) %>%# e.g. composite join: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))
                        select(ogc_fid, sbgr = bgr_subreg_id, eunis.code.gis = hab.1, eunis.match.assessed, ActivityCode, PressureCode, max.sens) %>%
                        spread(key = PressureCode, value = max.sens) #%>%
                        #distinct(ogc_fid,hab.1) %>%
                        #as.tibble()
                
                #drop columns with NA for name
                sbgr.hab.gis <- sbgr.hab.gis %>% select(-("<NA>"))
                
                # Determine the number of columns, to inform the number of columns to apply a function to
                n.cols <- ncol(sbgr.hab.gis)
                
                #paste0(act.code, "_B1_max")
                #generate a single maximum value per column
                sbgr.hab.gis.2  <-  sbgr.hab.gis %>%
                        select(-(2:6)) %>%
                        group_by(ogc_fid) %>%
                        summarise_all(max)#,
                                #max_B1 = max(B1, na.rm = T),
                                #max_B3 = max(B3, na.rm = T),
                                #max_B5 = max(B5, na.rm = T),
                                #max_B6 = max(B6, na.rm = T),
                                #max_D2 = max(D2, na.rm = T),
                                #max_D6 = max(D6, na.rm = T),
                                #max_O1 = max(O1, na.rm = T),
                                #max_O3 = max(O3, na.rm = T),
                                #max_O5 = max(O5, na.rm = T),#pressure O5 not available for all activities
                                #max_P1 = max(P1, na.rm = T),
                                #max_P2 = max(P2, na.rm = T),
                                #max_P3 = max(P3, na.rm = T),
                                #max_P7 = max(P7, na.rm = T),
                                #max_P8 = max(P8, na.rm = T),
                                
                                 #%>% plyr::rename(list(max_B1 = paste0(act.code,"_max_B1"),
                                                     #max_B3 = paste0(act.code,"_max_B3"),
                                                     #max_B5 = paste0(act.code,"_max_B5"),
                                                     #max_B6 = paste0(act.code,"_max_B6"),
                                                     #max_D2 = paste0(act.code,"_max_D2"),
                                                     #max_D6 = paste0(act.code,"_max_D6"),
                                                     #max_O1 = paste0(act.code,"_max_O1"),
                                                     #max_O3 = paste0(act.code,"_max_O3"),
                                                     #list(max_O5 = paste0(act.code,"_max_O5")),
                                                     #max_P1 = paste0(act.code,"_max_P1"),
                                                     #max_P3 = paste0(act.code,"_max_P3"),
                                                     #max_P7 = paste0(act.code,"_max_P7"),
                                                     #max_P8 = paste0(act.code,"_max_P8")
                                                     #)),
                            #silent = F)
                        
                        
                        
                        # START HERE:add activitiy to names
                        
                #This code was run to determinbe the maximum number of slices required, which informs the number of coolumns to gerneate to store the matches eunis.match.assessed values in
                #n.sclices  <-  sbgr.hab.gis %>%
                #        group_by(ogc_fid) %>%
                #        count() %>%
                #        arrange(desc(n))
                #genreate the table columns with the relevant eunis.match.assessed in each column
                #eunis.match  <-  sbgr.hab.gis %>%
                #        group_by(ogc_fid) %>%
                #        transmute(eunis.match.assessed.1 = slice(1),
                #                  eunis.match.assessed.2 = slice(2),
                #                  eunis.match.assessed.3 = slice(3),
                #                  eunis.match.assessed.4 = slice(4),
                #                  eunis.match.assessed.5 = slice(5)
                                  #eunis.match.assessed.6 = slice(6),
                                  #eunis.match.assessed.7 = slice(7),
                                  #eunis.match.assessed.8 = slice(8),
                                  #eunis.match.assessed.9 = slice(9),
                                  #eunis.match.assessed.10 = slice(10)
                 #                 )
                                 
                        
                
                
                
                #joinhabitat to geometry (if we cannot tie geometry to the geometry of a different tbl)
                #gis.hab.geom <- dplyr::left_join(gis.geom.dat, sbgr.hab.gis.2, by = "ogc_fid") #%>%
                        #select(ogc_fid, GEOMETRY, hab_1 =hab.1 )
                
                #make unique filenames to be pasted into SQL
                #create.db <- paste0("CREATE TABLE sbgr_BAP_sens_minmax_",gsub(x =unique(x$ActivityCode),".","_", fixed = T),
                #                   "(ogc_fid INTEGER,
                #                   GEOMETRY BLOB,
                #                   hab_1 TEXT,
                #                   sbgr_id TEXT,
                #                   PRIMARY KEY(ogc_fid))
                #                   ")
                
                
                #filename <- paste0("sbgr_BAP_sens_max_",gsub(x =unique(x$ActivityCode),".","_", fixed = T),"_",as.character(unique(x$sbgr[1])))
                #filename <- paste0("sbgr_BAP_sens_max_",gsub(x =unique(x$ActivityCode)[[1]],".","_", fixed = T))
                #make a empty newSQL lite table 
                #dbSendQuery(conn=con_gis,
                #            filename)
                #write into the table using the overwrite statement
                
                #dbWriteTable(conn=con_gis, name=filename, gis.hab.geom, overwrite = T,row.names=F)
                #dbSendQuery(conn=con_gis,
                #            "INSERT INTO geometry_columns (f_table_name,geometry_column, geometry_type,coord_dimension,srid,geometry_format) VALUES (filename, 'GEOMETRY', '6', '2', '', 'WKB')")
                #dbSendQuery(conn=con_gis,
                #        'INSERT INTO geometry_columns (
                #        f_table_name,
                #        geometry_column,
                #        geometry_type,
                #        coord_dimension,
                #        srid,
                #        geometry_format)
                #VALUES
                #(
                #        "filename", 
                #        GEOMETRY,
                #        6,
                #        2,
                #        ,
                #        WKB);'
                #)
                
        }, .progress = "text") 
#SPLIT list into dataframes, and recoine into singel dataframe using binding the dataframes horisontally.
#Then insert staements about saving to a database

#insert statement to bind the columns from each 

        #spread result according to pressures, and drop non relevant columns




##house kepping: close the connection: S3 method for class 'RODBC'
close(con = conn)
dbDisconnect(con.gis)





