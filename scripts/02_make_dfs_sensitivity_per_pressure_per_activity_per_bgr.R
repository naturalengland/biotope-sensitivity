#Aim: split Fishing Pressure Sensitivity assessments according to (sub)activities, and save csv for activity

#Author: Philip Haupt
#contact Philip.Haupt@naturalengland.org.uk
#Date: 2018-08-28


#load libraries
library(tidyverse)
library(reshape2)

#orig.d <- "F:/projects/biotope-sensitivity"
#orig.d <- "F:/projects/biotope-sensitivity"#"./biotope-sensitivity"
#setwd(orig.d)

#
sens.act <- qryEUNIS_ActPressSens # from 01_connect_to_access_db.R
sens.act$EUNISCode <- as.character(sens.act$EUNISCode)
rm(qryEUNIS_grp_act, qryEUNISFeatAct)


# add ranking of sensitivity
source("./scripts/09_sensitivity_rank.R")
sens.act.rank <- left_join(sens.act,sens.rank, by = "ActSensRank")
rm(sens.act)


## Or read in the saved text file
# Import csv of sensitivities per EUNIS code per pressue, for each biotope
#wd <- getwd() # save the Project's original working directory to recycle
#tmp.wd <- "F:/copy_data/" # directory where queried data is housed - to make reading location readily accessible
#setwd(tmp.wd) # change the working directory to temporary directory
#sens.act <- read.csv("./qryEUNIS_ActPressSens.txt") # read the data file genered from Access queries Philip Haupt and Sue Harding
#setwd(wd) # change the working directory back to original directory

# Obtain a table of the distinct EUNIS codes for which sensitivity data exists; this table will be used in joins to ensure that each EUNIs code gets checked against the Pressure Sensitivity assessments
EunisAssessed <- sens.act.rank %>% 
        select(EUNISCode) %>% 
        distinct()


# Obtain sensitvity tables, one for each acitivty, with each EUNIs code assessed against each pressure code: 
## A FOR loop follows (for each activity) in which the Activity Pressure Eunis table that was read the following process is carried out for EACh activity (based on Activity code)

#lists to store the rsults from the for loop in
#act.press.list <- list()
act.press.list.2 <- list()

# Sequentially use only one table at a time
for(i in 1:length(unique(sens.act.rank$ActivityCode))){
        
        # filter table by Activity, and sequentially use only one table at a time, and store the table in a temporary dataframe for further processing
        sens.subset.tmp <- sens.act.rank %>% dplyr::filter(ActivityCode == unique(sens.act.rank$ActivityCode)[i])
        
        # Join each Activity pressure to the DISTINCT EUNIS Code table (from outside loop) to obtian a complete table of all pressure sensitivities for each acitvity
        Eunis.Pressure.tmp <- left_join(EunisAssessed, sens.subset.tmp, by  = "EUNISCode")
        #Eunis.Pressure.tmp$ID <- row.names(Eunis.Pressure.tmp)
        # Select only variables of interest
        #sens.select.tmp <- Eunis.Pressure.tmp %>% select(EUNISCode, PressureCode, ActSensRank) #%>%
        sens.select.tmp <- Eunis.Pressure.tmp %>% select(EUNISCode,ActivityCode, PressureCode, rank.value) #%>%
        #nam <- paste("act.", i, sep = "") # generate a name within the FOr LOOP based on the ith cycle in the for loop # not used as it will just count i  = 1,2,3,4 etc
        #nam <- as.character(sens.subset.tmp$ActivityCode[1]) # generate a name within the FOr LOOP based on the ith cycle in the for loop
        
        ## cast the data into a dataframe, where EUNISCode and Pressure are rows and columns, and use ActSensRank as the variable; 
        #dat.tmp <- dcast(data = sens.select.tmp, EUNISCode ~ PressureCode)
        
        #do so while assigning the name created inthe for loop to each data frmae, so as to end up with a unique dataframe for each acitivity in which EUNIs code are transposed against Pressures
        #assign(x = nam, dat.tmp) # 
        
        #write csv - may drop this in due course if list of dataframes work
        #write.csv(dat.tmp ,paste0("./output/",nam,".csv"), row.names = F) # write a csv file to the working directory, wihtin an output folder
        
        #tidy the pressure within the activity - must first check if this is OK, as there may be reason for
        #dat.tmp %>% rename(eunis.match.assessed = EUNISCode) %>% # rename for matching later
        #        gather("B1":"P8", key = pressures.codes, value = sens.rank.value)%>% # tidy the data for easier use
        #        na.omit() # remove non-sensical values
        
        #make a list of pressure files
        #act.press.list[[i]] <- dat.tmp
        act.press.list.2[[i]] <- sens.select.tmp
        
        #house keeping
        #rm(Eunis.Pressure.tmp, sens.subset.tmp, sens.select.tmp, dat.tmp) # empty out the tmp vairables to ensure loops are running with correct data
}

names(act.press.list.2) <- unique(sens.act.rank$ActivityCode) # this will assign the Activity codes as names to teh dataframes within the list.

rm(nam, i) # house keeping: remove temporary or non-essential variables
