# Read geodatabase from network read a preprocessed file



#read.network.geodatabase <- function(net.dir = "\\\\SAMVW3-GIREP02\\NEWorkingData\\GIS_Working_Data\\Marine\\Marine_Evidence_Geodatabase.gdb",
#                                     gis.layer = "Input_BSH_Polys_WGS84_Internal" ){
#        require(rgdal)
#        gdb.n <- try(readOGR(dsn = net.dir, layer = gis.layer))
#        
#}

#read.preprocessed.geodatabase <- function(prep.gdb.dir = "F:/projects/biotope-sensitivity/copy_data/Marine_Evidence_Geodatabase.gdb",
#                                          gis.layer = "Input_BSH_Polys_WGS84_Internal" ){
#        require(rgdal)
#        gdb.n <- readOGR(dsn = net.dir, layer = gis.layer)
#        
#}



#r <- NULL
#attempt <- 1
#while( is.null(r) && attempt <= 3 ) {
#        attempt <- attempt + 1
read.network.geodatabase <- function(net.dir = "\\\\SAMVW3-GIREP02\\NEWorkingData\\GIS_Working_Data\\Marine\\Marine_Evidence_Geodatabase.gdb",
                                            gis.layer = "Input_BSH_Polys_WGS84_Internal" ){
        require(rgdal)
        gdb <- try(readOGR(dsn = net.dir, layer = gis.layer))
        if("try-error" %in% class(gdb)) {
                #cat(“Caught an error during to read the network file, trying read a back up copy.\n”)
                prep.gdb.dir <- "D:/projects/fishing_displacement/2_subprojects_and_data/2_GIS_DATA/Marine habitat/Marine_Evidence_Geodatabase.gdb"
                        #"F:/projects/biotope-sensitivity/copy_data/Marine_Evidence_Geodatabase.gdb"
                gis.layer <- "Input_BSH_Polys_WGS84_Internal"
                gdb <- readOGR(dsn = prep.gdb.dir, layer = gis.layer)
                
                }
        gdb
}

read.network.geodatabase()

readOGR(dsn = "F:/projects/biotope-sensitivity/copy_data/Marine_Evidence_Geodatabase.gdb", layer = "Input_BSH_Polys_WGS84_Internal")

#read.file <- function (file.name) {
#        require(data.table)
#        file <- try(fread(file.name))
 #       if (class(file) == “try-error”) {
 #               cat(“Caught an error during fread, trying read.table.\n”)
 #               file <- as.data.table(read.table(file.name, sep = ” “, quote = “”))
 #       }
 #       file
#}

        