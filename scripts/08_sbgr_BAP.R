# join the pressure to a sbgr-consolidated data set
library(plyr)
library(dplyr)
library(magrittr)



sbgr.bap <- sbgr.matched.btpt.w.rpl %>% 
        plyr::llply(function(x) { 
                
                
                
                #x.rn <- x$eunis.code.gis # this is the EUNIs codes of the GIS files, which will become the row names for each data frame
                
                #simplified data set
                x.df <- x %>% dplyr::select(eunis.code.gis, 1:14, 19:354) %>% 
                        tidyr::gather("A5.22":"A5.7211",key = "eunis.assessed",value = "eunis.gis") %>%
                        filter(eunis.gis != "<NA>") %>%
                        select(eunis.code.gis, eunis.match.assessed = eunis.assessed) %>%
                        arrange(eunis.code.gis,eunis.match.assessed)
                
                xap.ls <- act.press.list.2 %>% 
                        plyr::llply(function(y){
                                tidy.p <- y %>% 
                                        rename(eunis.match.assessed = EUNISCode)
                                xp.df <- right_join(x.df, tidy.p, by = "eunis.match.assessed")
                                
                        })
                

                return(xap.ls)
        }, .progress = "text")
saveRDS(sbgr.bap,"./output/sbgr_bap.rds")
        




