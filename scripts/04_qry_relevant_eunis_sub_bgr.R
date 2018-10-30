##how to do
#Set BGR cross tabulation for EACH EUNIs level
# use hab level analysis to ID the levels
#then split into EUNIs 
###
#the rules will read something like

#add columns for PROXY habitats, one for each permutation per level, e.g. A1, will include A1.1, A1.2, and A1.3 
#pelvl4 (proxy eunis level 4), as fgdb$pelvl4.1 stands for EUNIS level 4, first subhabitat, second subhabitat...etc, in to which A1.1, A1.2 and A1.3 could be assigned
#FROM fgdb %>%> IF BGR == "X" AND HAB_TYPE == "Y" THEN assign a to pelvlN.n, 



# Rules for BGR assignement
# connect to access

#install a microsoft access driver if not already on machine, e.g. https://www.microsoft.com/en-us/download/details.aspx?id=54920
## The driver version (64/32) has to match the system and R version 64 bit or 32 bit

#install package RODBC if not already installed within R using the command: install.packages("RODBC")
# Load RODBC package
library(RODBC) 
library(dplyr)


# Connect to Access db
conn <- odbcDriverConnect("Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=D:/projects/fishing_displacement/2_subprojects_and_data/5_internal_data_copies/database/PD_AoO.accdb")

## Inspect data
## List of Tables
subset(sqlTables(conn), TABLE_TYPE == "VIEW") %>%
  arrange(TABLE_NAME)

#read biotope  EUNIS relevance
#tblEUNISBiogeoRegion <- sqlFetch(conn, "tblEUNISBiogeoRegion") 
#names(tblEUNISBiogeoRegion)
#inspect table
#names(tblEUNISBiogeoRegion)
#head(tblEUNISBiogeoRegion)
#tail(tblEUNISBiogeoRegion)
#tblEUNISBiogeoRegion[30:60,1:3]

#this reads the BGRs relevant to region, 
qrySeaRegion_relevant_biotopes <- sqlQuery(conn, paste("SELECT tblEUNISBiogeoRegion.EUNISCode, tblEUNISBiogeoRegion.BGRCode, tblEUNISBiogeoRegion.RelevantToRegion, qrySeaRegionLUT_relevant.RegionalSea
FROM tblEUNISBiogeoRegion INNER JOIN qrySeaRegionLUT_relevant ON tblEUNISBiogeoRegion.BGRCode = qrySeaRegionLUT_relevant.BGRCode
                                                       WHERE (((tblEUNISBiogeoRegion.RelevantToRegion)='Yes'));"))

#above can be improved to remove the next step

#read #tblBiogeoRegionLUT 
tblBiogeoRegionLUT<- sqlFetch(conn, "tblBiogeoRegionLUT") 
names(tblBiogeoRegionLUT)

#join bioregional details
tblBGR <- qrySeaRegion_relevant_biotopes %>%
  select(EUNISCode,
         BGRCode,
         RelevantToRegion) %>%
  left_join(tblBiogeoRegionLUT, by = "BGRCode") %>%
  collect()

tblBGR$EUNISCode <- as.character(tblBGR$EUNISCode)
###
#read #tblPressureLUT 
tblPressureLUT<- sqlFetch(conn, "tblPressureLUT") 
names(tblPressureLUT)

