#Clean geodata file
#to do: functionalise: make gis.hab.bgr.dat a changable variable:#specify unique id and other variables

library(tidyverse)

#trying using the gpkg just made
#gis.hab.bgr.dat <- gpkg@data
#names(gis.hab.bgr.dat)
#unique(duplicated(gis.hab.bgr.dat$OBJECTID))

#clean data
gis.hab.bgr.dat <- function(dat = gpkg@data, id.gis = "OBJECTID", habitat.type = "HAB_TYPE"){
        
        #clean habitat.type column from multiple entries
        dat$habitat.type <- gsub(" or ", "/", dat$habitat.type) # replace ; with / to make consistent
        dat$habitat.type <- gsub(";", "/", dat$habitat.type) # replace ; with / to make consistent
        dat$habitat.type <- gsub("(8)", "", dat$habitat.type) # remove (8) to make consistent
        dat$habitat.type <- gsub(" #", "", dat$habitat.type) # remove (8) to make consistent

        # Separate habitat.type into multiple columns where "/" appears to allow for the next step
        hab.types <- dat %>%
                select(id.gis, habitat.type, bgr_subreg_id) %>%
                tidyr::separate(habitat.type, into = c("hab.1", "hab.2", "hab.3", "hab.4"), sep = "/", remove = F)
        # Remove any leading or trailing white spaces which could cause problems when matching the eunis columns between gis and database.
        hab.types <- purrr::map_df(hab.types, function(x) trimws(x, which = c("both")))
        str(hab.types) # changed integer top char for all!
        hab.types$id.gis <- as.integer(hab.types$id.gis)


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

}

gis.hab.bgr.dat()
