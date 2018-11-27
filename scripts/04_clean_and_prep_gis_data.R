#Clean geodata file; done from attribute table - i.e. remove the geomotry to make the file small and managable to work with.
#to do: functionalise: make gis.hab.bgr.dat a changable variable:#specify unique id and other variables

library(tidyverse)

#function that reads file from specified locality, or defaults to a back-up locality, # needs working up
load.gis.attrib <- function(attr = hab.map@data){ #hab.map is the habitat map that was read in 03_read_spatial_habitat_data
        gis.attr <- try(attr) # input data from habitat map - if error read the hab map attributes from a back file
        if("try-error" %in% class(gis.attr)) {
                cat("The GIS habitat map is not read in, or there is an error, trying read a back up copy of attribute file.\n")
                backup.attribute.tbl <- "C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/4_R/sensitivities_per_pressure/gisattr.rds"
                gis.attr <- read_rds(path = backup.attribute.tbl)
                
        }
        cat("Make sure that the gis attribute and habitat types have the same number of observations.\n")
        gis.attr
}

gis.attr <- load.gis.attrib()

#clean data
gis.hab.bgr.dat <- function(dat = gis.attr){
        require(dplyr)
        d <- rownames(dat)
        #if(is.null(dat$pkey)) # there are duplcaited pkeys - as this was a column in the GIS, which got split when intersected with sbgr...think about updating the pkey in the GIS
                dat$pkey <- d
        #clean HAB_TYPE column from multiple entries
        dat$HAB_TYPE <- gsub(" or ", "/", dat$HAB_TYPE) # replace ; with / to make consistent
        dat$HAB_TYPE <- gsub(";", "/", dat$HAB_TYPE) # replace ; with / to make consistent
        dat$HAB_TYPE <- gsub("(8)", "", dat$HAB_TYPE) # remove (8) to make consistent
        dat$HAB_TYPE <- gsub(" #", "", dat$HAB_TYPE) # remove (8) to make consistent
        
        # Separate HAB_TYPE into multiple columns where "/" appears to allow for the next step
        hab.types <- dat %>%
                select(pkey, HAB_TYPE, bgr_subreg_id = SubReg_id) %>%
                tidyr::separate(HAB_TYPE, into = c("hab.1", "hab.2", "hab.3", "hab.4"), sep = "/", remove = F)
        # Remove any leading or trailing white spaces which could cause problems when matching the eunis columns between gis and database.
        hab.types <- purrr::map_df(hab.types, function(x) trimws(x, which = c("both")))
        str(hab.types) # changed integer top char for all!
        hab.types$pkey <- as.integer(hab.types$pkey)
        
        
        
        #check if there are values in all columns, and drop columns with no values
        hab.types %>%
                distinct(hab.4)
        #remove column 5 hab.4
        hab.types <- hab.types %>% 
                select(-hab.4)
        #only na values - so can be removed
        hab.types %>%
                distinct(hab.3)
        #has multiple values - keep
        hab.types
}

hab.types <- gis.hab.bgr.dat(gis.attr)
