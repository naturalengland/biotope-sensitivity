# join the pressure to a sbgr-consolidated data set




#testcode
names(sbgr.matched.btpt.w.rpl[[1]])
test <- as.data.frame(cbind(sbgr.matched.btpt.w.rpl[[1]][[18]], sbgr.matched.btpt.w.rpl[[1]][[1]]))

names(test) <- c("EUNISCode", "v1")

#test 2
nms <- names(sbgr.matched.btpt.w.rpl[[1]])
sqc <- c(1:14,19:354)

join.sbgr.btp.sens.z10.5 <- data.frame(nrows = 169)
for (i in 1:sqc) {
        #names(sbgr.matched.btpt.w.rpl[[1]])
        test.tmp <- as.data.frame(cbind(sbgr.matched.btpt.w.rpl[[1]][[18]], sbgr.matched.btpt.w.rpl[[1]][[i]]))
        names(test.tmp) <- c("EUNISCode", nms[i])
        join.sbgr.btp.sens.z10.5[,i] <- left_join(test.tmp, Z10.5, by = "EUNISCode")
}



#start the loops

sbgr.BAP <- sbgr.matched.btpt.w.rpl %>% 
        plyr::llply(function(x){ 
                
                # Do for each sbgr :
                sbgr.BAP.tmp <- x %>% # select a dataframe (temporary name for dataframe where PER sbgr dataframe is stored, and run through the rest of the code)
                        plyr::ldply(function(y){
                                #then apply to each column within the datafrfame
                                plyr::daply(y,)
                                
                                Z10.5#this is currently in the environment so can call it here - but will need to updated to loop through a list of these....not sure how yet; Possible repeating the pattern above, after consolidating all the pressures into a list of dataframes
                        
                        })
        })

