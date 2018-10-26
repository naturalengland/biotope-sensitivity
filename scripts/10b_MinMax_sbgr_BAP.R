#extract sensitivity scores (maximum, minimum (with a cap) from sbgr_bap): working with XAP instead
library(plyr)
library(tidyverse)

#test----------------------
#tmp <- sbgr.bap[[1]][[1]]

#max.sens.test <- as.tibble(tmp) %>% 
#        dplyr::group_by(eunis.code.gis, PressureCode) %>%
#        dplyr::mutate(max.sens = max(rank.value), # maximum sensitivity value, done using mutate to preserve the "eunis.match.assessed" column
#                      min.sens = min(rank.value[rank.value > 3]),
#                      min.sens.na = min(rank.value)) %>% # minimum sensitity value
#        slice(1) # keeps only the top value /selects row by position, done to preserve eunis.match.assessed code

#[myvector > 0]

#appears to be able to take care of both max and min in one code, and preserve the correct/or at least same eunis.match.assessed       
#min.sens.test <- as.tibble(tmp) %>% 
#        dplyr::group_by(eunis.code.gis, PressureCode) %>%
#        dplyr::mutate(min.sens = min(rank.value)) %>% # minimum sensitity value
#        slice(1) # keeps only the top value /selects row by position, done to preserve assessed eunis code

# Active code: in double list
sbgr.BAP.min.max.sens <- xap.ls %>%
        llply(function(x){ # splits by activity
                x %>%
                        llply(function(y){ #splits by sub_biogeoregion
                                min.max.sens <- as.tibble(y) %>% 
                                        dplyr::group_by(eunis.code.gis, PressureCode) %>%
                                        dplyr::mutate(max.sens = max(rank.value), # maximum sensitivity value, done using mutate to preserve the "eunis.match.assessed" column
                                                      min.sens = min(rank.value[rank.value > 3]),
                                                      min.sens.na = min(rank.value)) %>% # minimum sensitity value
                                        slice(1) %>%# keeps only the top value /selects row by position, done to preserve eunis.match.assessed code
                                        arrange(PressureCode)
                        })
        }, .progress = "text") %>% #now we can reshape the data as follows:
        llply(function(x){#splits by activity, and returns a list split by activity - becuase each activity will be mapped separately
                x %>%
                        ldply(function(y){ #splits list by sub_biogeoregion - and returns a dataframe (per activity - see above), becuase we want to match the senstivities to GIS in one go for all biogeoregions (per activity)
                                y
                        })
        }, .progress = "text")


rm(xap.ls)

