# connect to the MS Access Conservation Advice databse (PD_AoO), and query the sensitivity per Biotope 
# this is the first file in a series of files which has to be run.

#------
# System requirements
# Install a microsoft access driver if not already on PC/machine, available from e.g. https://www.microsoft.com/en-us/download/details.aspx?id=54920
# The driver version (64/32) has to match the system and R version 64 bit or 32 bit

#------
#Notes 
#Biotopes which have been assessed for sensitivity in the conservation Advice database only include Eunis levels 4 to 6 at this stage.



rm(list = ls())
#-----
# R libraries
library(RODBC)
library(DBI)# R library to harnass ODBC, # install package RODBC if not already installed within R using the command: install.packages("RODBC")
library(tidyverse) # to use piping and other data wrangling functions.



#TEST RUN: ONLY THIS LINE
qryEUNIS_ActPressSens <- read.csv("C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/3_Other/NE/Habitat_sensitivity/qryhabsens/qryEUNIS_ActPressSens.txt")



#cat("Type '1' to read Access database from file, and run sql queries to obtain EUNIS sensitivity data (recommended if the database has been updated).\n")
#cat("Type '2' to read pre-saved SQL query of the above.\n")
#cat("choice <- ")

#db.path <- file.choose()
# Define Variables
## set the path to the database #this will hoefully be a 
db.path <- "C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/3_Other/NE/Habitat_sensitivity/database/PD_AoO.accdb"
drv.path <- "Microsoft Access Driver (*.mdb, *.accdb)" #"SQL Server"#or #
srv.host <- "Null"#e.g. "mysqlhost"

try(read.access.db(db.path,drv.path))
if("try-error" %in% class(read.access.db(db.path,drv.path))){
        qryEUNIS_ActPressSens <- read.csv("C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/3_Other/NE/Habitat_sensitivity/qryhabsens/qryEUNIS_ActPressSens.txt")
}


read.access.db <- function(db.p = db.path, drv.p = drv.path, srv.host = NULL){
        
        #MySQL: 
        #dbhandle <- odbcDriverConnect('driver={SQL Server};server=mysqlhost;database=mydbname;trusted_connection=true')
        #res <- sqlQuery(dbhandle, 'select * from information_schema.tables')
        
        #Define variables: SET THE PATH TO THE Access driver and the ACCESS DATABASE
        
        #database.path <- "Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=D:/projects/fishing_displacement/2_subprojects_and_data/5_internal_data_copies/database/PD_AoO.accdb"
        connection.path <- paste0("Driver={",drv.path,"};DBQ=",db.path)#server=",srv.host,";
        
        # Issues on GIT: currently only a local copy of the MS Access database is available on my working hard drive, and this needs to be pointed at the network (eventually) when approved
        
        
        # Connect to Access db to allow reading the data into R environment.
        #conn <- odbcDriverConnect("Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=D:/projects/fishing_displacement/2_subprojects_and_data/5_internal_data_copies/database/PD_AoO.accdb") # prelim tha tlinks to the Access database on my laptop
        conn <- odbcDriverConnect(connection.path)
        
        
        ## Inspect data
        ## List of Tables
        subset(sqlTables(conn), TABLE_TYPE == "TABLE") %>%
                arrange(TABLE_NAME)
        ## List of VIEW queries
        subset(sqlTables(conn), TABLE_TYPE == "VIEW")%>%
                arrange(TABLE_NAME)
        
        
        # Get data
        ## All three "building" queries, included, but only query 3 required, as long as the queries are stored in the Access database. IF not stored in the Access database, Query 1 and 2 would have to be saved as a dataframes, and the required tables from Access also, then set-up joins to create query three
        ## could also just read in query 3
        
        #1: Step 1 if queries are in Access this step is NOT required, but can be run to VIEW the data; if queries not housed in PD_AoO database this step is neccessary
        qryEUNISFeatAct <- sqlQuery( conn , paste("SELECT tblEUNISFeature.EUNISCode, tblFeatureActivity.FeatSubHabCode, tblFeatureActivity.FARelevant, tblActivityLUT.OperationCode, tblFeatureActivity.ActivityCode, tblActivityLUT.ActivityName 
                                                  FROM tblActivityLUT INNER JOIN (tblFeatureActivity INNER JOIN tblEUNISFeature ON tblFeatureActivity.FeatSubHabCode = tblEUNISFeature.FeatSubHabCode) ON tblActivityLUT.ActivityCode = tblFeatureActivity.ActivityCode 
                                                  WHERE (((tblFeatureActivity.FARelevant)='Yes') AND ((tblActivityLUT.OperationCode)='11'));")) #by changing the very last value '11' to any other , it will change the operation considered. by remvoing it, all operations will be included.
        
        # step 2a if queries are in Access this step is NOT required, but can be run to VIEW the data; if queries not housed in PD_AoO database, skip to next step
        qryEUNIS_grp_act <- sqlQuery( conn , paste("SELECT qryEUNISFeatAct.EUNISCode, qryEUNISFeatAct.ActivityCode, qryEUNISFeatAct.ActivityName FROM qryEUNISFeatAct
                                                   GROUP BY qryEUNISFeatAct.EUNISCode, qryEUNISFeatAct.ActivityCode, qryEUNISFeatAct.ActivityName;"))
        
        #this should be the same as step 2a using dplyr
        qryEUNIS_grp_act <- qryEUNISFeatAct %>% select(EUNISCode, 
                                                       ActivityCode,
                                                       ActivityName) %>%
                group_by(EUNISCode,ActivityCode, ActivityName) %>%
                distinct()
        #----------------------------------------------------------------------------------------
        #read in additional tables needed fpor query (using dplyr with dbplyr backend) # not tested
        copy_to(conn, tblEUNISLUT)
        tblEUNISLUT <- tbl(conn, "tblEUNISLUT")
        
        copy_to(conn, tblEUNISPressure)
        tblEUNISPressure <- tbl(conn, "tblEUNISPressure")
        
        copy_to(conn, tblActivityPressure)
        tblActivityPressure <- tbl(conn, "tblActivityPressure")
        
        copy_to(conn, tblPressureLUT)
        tblPressureLUT <- tbl(conn, "tblPressureLUT")
        
        copy_to(conn, tblSensitivityLUT)
        tbl(conn, "tblSensitivityLUT")
        
        #qryEUNIs_grp_act
        #use this to reconstruct the below:
        
        #--------------------------
        #NB NB NB NB NB NB KEY query!!!!!!!!!!!!!!!!!!!!!!!
        # 3a if queries are in Access this step is NOT required, but can be run to VIEW the data; else skip to next step
        qryEUNIS_ActPressSens <- sqlQuery(conn, paste("SELECT qryEUNIs_grp_act.ActivityCode, qryEUNIs_grp_act.ActivityName, tblEUNISPressure.PressureCode, tblPressureLUT.PressureName, qryEUNIs_grp_act.EUNISCode, tblEUNISLUT.EUNISName, tblSensitivityLUT.ActSensRank
                                                      FROM tblPressureLUT INNER JOIN (tblActivityPressure INNER JOIN ((tblEUNISLUT INNER JOIN qryEUNIs_grp_act ON tblEUNISLUT.EUNISCode = qryEUNIs_grp_act.EUNISCode) INNER JOIN (tblSensitivityLUT INNER JOIN tblEUNISPressure ON tblSensitivityLUT.EPSens = tblEUNISPressure.Sensitivity) ON qryEUNIs_grp_act.EUNISCode = tblEUNISPressure.EUNISCode) ON (tblEUNISPressure.PressureCode = tblActivityPressure.PressureCode) AND (tblActivityPressure.ActivityCode = qryEUNIs_grp_act.ActivityCode)) ON tblPressureLUT.PressureCode = tblActivityPressure.PressureCode
                                                      WHERE (((tblSensitivityLUT.SensPriority)<'8') AND ((tblActivityPressure.APRelevant)='Yes'))
                                                      ORDER BY qryEUNIs_grp_act.ActivityCode, tblEUNISPressure.PressureCode, qryEUNIs_grp_act.EUNISCode;"))
        
        
        
        #3b still needs writing/completing as it will require reading all the above the tables, in addition to the queries here, sequentially join them...
        #qryEUNIS_ActPressSens <- inner_join()
        
        #this query lists the sensitivities of each eunis code 
        qrySeaRegion_EUNIS_Sens <- sqlQuery(conn, paste("SELECT tblEUNISFeature.EUNISCode, tblEUNISFeature.FeatSubHabCode, qrySeaRegion_relevant_biotopes.BGRCode, tblEUNISPressure.PressureCode, tblEUNISPressure.Sensitivity, tblSensitivityLUT.ActSensRank, tblSensitivityLUT.SensPriority 
                                                        FROM tblSensitivityLUT INNER JOIN ((qrySeaRegion_relevant_biotopes INNER JOIN tblEUNISFeature ON qrySeaRegion_relevant_biotopes.EUNISCode = tblEUNISFeature.EUNISCode) 
                                                        INNER JOIN tblEUNISPressure ON tblEUNISFeature.EUNISCode = tblEUNISPressure.EUNISCode) ON tblSensitivityLUT.EPSens = tblEUNISPressure.Sensitivity WHERE (((tblSensitivityLUT.SensPriority)<'7'));"))
        #rm(qrySeaRegion_EUNIS_Sens)
        
        #This query lists the EUNIs codes of the biotopes which are known to occur within each of the sub-biogeographic regions (sbgr).
        qrySeaRegion_relevant_biotopes <- sqlQuery(conn, paste("SELECT tblEUNISBiogeoRegion.EUNISCode, tblEUNISBiogeoRegion.BGRCode, tblEUNISBiogeoRegion.RelevantToRegion, qrySeaRegionLUT_relevant.RegionalSea
                                                               FROM tblEUNISBiogeoRegion INNER JOIN qrySeaRegionLUT_relevant ON tblEUNISBiogeoRegion.BGRCode = qrySeaRegionLUT_relevant.BGRCode
                                                               WHERE (((tblEUNISBiogeoRegion.RelevantToRegion)='Yes'));"))
        
        ##house kepping: close the connection: S3 method for class 'RODBC'
        close(con = conn)
}

read.access.db()
rm(db.path,drv.path,srv.host)
