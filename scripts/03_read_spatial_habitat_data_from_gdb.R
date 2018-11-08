####NB NOTE

# NOT LATEST VERSION: SEE 06_readSQLite which contains a linnk to updated SQL file with BRG joined; but keep for the value of sums at the end giving values of number opf polygons and area etc.


#Aim: develop table with likely benthic biotopes (eunis level 6) that occur within EUNIS level 3 and 4

#require(rgdal)
library(sf)
library(sp)
library(tidyverse)
library(data.table)

# key variables
net.dir <- "\\SAMVW3-GIREP02\NEWorkingData\GIS_Working_Data\Marine\Marine_Evidence_Geodatabase.gdb" #network directory where the geodatabase is tored - change manually if it is moved.


getwd()




#read in geodatabase (it is large, so will take a couple of minutes) 

## two options:
## 1) ALL of UK
fgdb <- st_read(dsn="F:/copy_data/Marine_Evidence_Base_Internal.gdb", layer = "Input_BSH_Polys_WGS84_Internal")



## 2) English territorial waters/seas -> 12 NM waters
#fgdb <- st_read(dsn="D:/projects/fishing_displacement/2_subprojects_and_data/2_GIS_DATA/Marine habitat/Phil_Fish_Project.gdb", layer = "Input_BSH_Polys_WGS84_Internal_Selection_Clip")



names(fgdb)
#names(fgdb)

# isolate the fields of interest, to make the data frame smaller
hab.type.dat <- fgdb %>% select(HAB_TYPE, Shape_Area)


rm(fgdb) #frees up a lot of memory


#to allow for easy editing, convert to char
hab.type.dat$HAB_TYPE <- as.character(hab.type.dat$HAB_TYPE) # convert hab_type to character

#clean data

hab.type.dat$HAB_TYPE <- gsub(" or ", "/", hab.type.dat$HAB_TYPE) # replace ; with / to make consistent
hab.type.dat$HAB_TYPE <- gsub(";", "/", hab.type.dat$HAB_TYPE) # replace ; with / to make consistent
hab.type.dat$HAB_TYPE <- gsub("(8)", "", hab.type.dat$HAB_TYPE) # remove (8) to make consistent
hab.type.dat$HAB_TYPE <- gsub(" #", "", hab.type.dat$HAB_TYPE) # remove (8) to make consistent

# split HAB_TYPE into multiple columns, separating where or statements, or "/" appears to allow for the next step
#hab.type.dat.2 <- str_split(string = hab.type.dat$HAB_TYPE, pattern = " or ", n = Inf, simplify = FALSE) #split by" or "
hab.type.dat.2 <- str_split(string = hab.type.dat$HAB_TYPE, pattern = "/", n = Inf, simplify = FALSE) #split by" or "
hab.type.dat.2 <- tidyr::separate(hab.type.dat, HAB_TYPE,hab.type.1, hab.type.2, hab.type.3, hab.typ.4, sep = ",", remove = F)


# convert lists to data.table so that you can isolate a single row for counting (massive list, so will take  a while to run.)
n.obs <- sapply(hab.type.dat.2, length)
seq.max <- seq_len(max(n.obs))
mat <- t(sapply(hab.type.dat.2, "[", i = seq.max))
df.hab.type <- data.frame(mat)
df.hab.type <- df.hab.type %>% rename(eunis.code = X1, eunis.code.2 = X2, eunis.code.3 = X3)
rm(hab.type.dat.2, n.obs, seq.max, hab.type.dat)

