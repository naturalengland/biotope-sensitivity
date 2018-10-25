#link the sbgr.BAP.min.max.sens to the GIS

str(hab.types)


sbgr.hab.gis <- hab.types %>%
        unite(sbgr.hab, bgr_subreg_id, hab.1, remove = FALSE)
names(sbgr.hab.gis)
unique(sbgr.hab.gis$sbgr.hab)


tmp <- sbgr.BAP.min.max.sens[[1]][[1]]
names(tmp)
act <- names(sbgr.BAP.min.max.sens)
sbgrs <- names(sbgr.BAP.min.max.sens[[1]])




tmp <- sbgr.BAP.min.max.sens %>%
        ldply(function(x){
                x %>%
                        ldply(function(y){
                                y
                        })
                names(x)
        })

