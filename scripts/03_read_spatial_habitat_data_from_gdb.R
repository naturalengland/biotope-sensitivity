#Read GIS habitat map file

#Libraries
library(rgdal)


# Read geodatabase from network, it it fails read a preprocessed file (a back-up copy that should not be changed unless certain that it is working)
#status: the current network file specified is the full file - this will have to be changed to a directory where the latest preprocessed file is saved.
read.network.geodatabase <- function(net.dir = "\\\\SAMVW3-GIREP02\\NEWorkingData\\GIS_Working_Data\\Marine\\Marine_Evidence_Geodatabase\\Marine_Evidence_Base_Internal.gdb",#\\SAMVW3-GIREP02\NEWorkingData\GIS_Working_Data\Marine\Marine_Evidence_Geodatabase\
                                     gis.layer = "Input_BSH_Polys_WGS84_Internal" ){
        require(rgdal)
        gdb <- try(readOGR(dsn = net.dir, layer = gis.layer))
        if("try-error" %in% class(gdb)) {
                cat("Caught an error during to read the network file, trying read a back up copy.\n")
                prep.gdb.dir <- "D:\\projects\\fishing_displacement\\2_subprojects_and_data\\2_GIS_DATA\\Marine habitat\\sbgr_input_poly_wgs84_internal_bgr_inside_12nm.gpkg"
                gis.layer <- "sbgr_input_poly_wgs84_internal_bgr_inside_12nm"
                gdb <- try(readOGR(dsn = prep.gdb.dir, layer = gis.layer))
                if("try-error" %in% class(gdb)) {
                        cat("Could not load back-up file, please specify the locality of the geodatabase./n")
                        gdb.path <- as.character(file.choose())
                        cat("Now specify the layer, e.g. Input_BSH_Polys_WGS84_Internal")
                        layer. <- basename(as.character(file.choose()))
                        gdb <- readOGR(dsn = gdb.path, layer = layer.)
                }
                gdb
        }
        gdb
}

hab.map <- read.network.geodatabase() # calls the function which will read the habitat file.

####ONLY RUN BELOW FOR TEST SMALL TEST FILE
#smaller test map
#hab.map <- readOGR(dsn = "\\\\SAMVW3-GIREP02\\NEWorkingData\\GIS_Working_Data\\Marine\\Phil_Haupt\\Fishing_effort_displacement\\2_Data\\1_QGIS\\test_habmap_for_R.gpkg", layer = "test_habmap_for_R")
#hab.map <- readOGR(dsn = "C:\\Users\\M996613\\Phil\\PROJECTS\\Fishing_effort_displacement\\2_subprojects_and_data\\2_GIS_DATA\\tmp_test\\test_habmap_for_R.gpkg", layer = "test_habmap_for_R")
#hab.map$SubReg_id <- "3a"