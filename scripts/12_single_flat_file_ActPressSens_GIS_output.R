#read geospatial and habitat data, join that to (activity-pressure-sensitivity per subbiogeoregion per polygon = "act.sbgr.bps.gis"), and 
# and write to geopackage
library(rgdal)
#library(RSQLite)
#library(DBI)
#library(dbplyr)

#read GIs file to obtain geometry

#greyed out is SQLite format/attempt to use a geopackage
#cities <- readOGR(system.file("vectors", package = "rgdal")[1], "cities")

# connect to the sqlite file
#orig.d <- getwd()
#scratch.d <- "F:/scratch"
#setwd(scratch.d)
#con_gis = DBI::dbConnect(RSQLite::SQLite(), "Phil_Fish_project_Input_Polys_WGS84_Internal_BGR.sqlite")
#src_dbi(con_gis) #show connection details, and list all tables

# get a list of all tables
#dbListTables(con_gis) #phil_fish_project_input_polys_wgs84_internal_bgr

# List columns in a table
#dbListFields(con_gis, "phil_fish_project_input_polys_wgs84_internal_bgr")


#select columns of interest from sql lite table of interest
#gis.geom.bgr.con <- tbl(con_gis, sql("SELECT ogc_fid, GEOMETRY, objectid FROM phil_fish_project_input_polys_wgs84_internal_bgr"))

#saves the geomtry
#gis.geom.dat <- gis.geom.bgr.con %>% 
#        select(ogc_fid, GEOMETRY, objectid) %>%
#        collect()



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


#pressure.test <- sbgr.BAP.max.sens %>%
#        llply(function(x){
#                test <- x$PressureCode %>%
#                        unique()
#        })



#dbWriteTable(conn=con_gis, name="gis_hab_geom_test", gis.hab.geom, overwrite = T,row.names=F)

####
#join habitat to geometry (if we cannot tie geometry to the geometry of a different tbl)
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


##house kepping: close the connection: S3 method for class 'RODBC'
#close(con = conn)
#dbDisconnect(con.gis)

