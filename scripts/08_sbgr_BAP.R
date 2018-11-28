# join the pressure to a sbgr-consolidated data set: This code joins pressures within sbgr within an activity, as opposed to activity within sbgr.
#libraries
library(plyr)
library(dplyr)
library(magrittr)


xap.ls <- act.press.list.2 %>% 
        plyr::llply(function(y){
                
                
                tidy.p <- y 
                
                sbgr.bap <- sbgr.matched.btpt.w.rpl %>% 
                        plyr::llply(function(x) { 
                                
                                x.df <- x %>% dplyr::select(eunis.code.gis, sbgr, 1:14, 19:354) %>%
                                        tidyr::gather("A5.22":"A5.7211",key = "eunis.assessed",value = "eunis.gis") %>%
                                        filter(eunis.gis != "<NA>" | eunis.gis != "NA") %>%
                                        select(sbgr, eunis.code.gis, eunis.match.assessed = eunis.assessed) %>%
                                        arrange(sbgr, eunis.code.gis,eunis.match.assessed)
                                
                                
                                xp.df <- right_join(x.df, tidy.p, by = c("eunis.match.assessed" = "EUNISCode"))
                                
                        })
                
                
                return(sbgr.bap)
        }, .progress = "text")

#housekeeping: remove objects no longer required
rm(sbgr.matched.btpt.w.rpl)

#saveRDS(xap.ls,"./output/xap_ls.rds") # not saving this any longer - as the code works, and this is an intermediate data set.
