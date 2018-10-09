# join the pressure to a sbgr-consolidated data set
library(plyr)
library(dplyr)
library(magrittr)



#testcode
names(sbgr.matched.btpt.w.rpl[[1]])
test <- as.data.frame(cbind(sbgr.matched.btpt.w.rpl[[1]][[18]], sbgr.matched.btpt.w.rpl[[1]][[1]]))

names(test) <- c("EUNISCode", "v1")

#test 2
nms <- names(sbgr.matched.btpt.w.rpl[[1]])
sqc <- c(1:14,19:354)

join.sbgr.btp.sens.z10.5 <- list()
for (i in 1:sqc) {
        #names(sbgr.matched.btpt.w.rpl[[1]])
        test.tmp <- as.data.frame(cbind(sbgr.matched.btpt.w.rpl[[1]][[18]], sbgr.matched.btpt.w.rpl[[1]][[i]]))
        names(test.tmp) <- c("EUNISCode", nms[i])
        join.sbgr.btp.sens.z10.5[,i] <- left_join(test.tmp, Z10.5, by = "EUNISCode")
}



#start the loops

sbgr.BAP <- sbgr.matched.btpt.w.rpl %>% 
        plyr::llply(function(x){ #splits the list into dataframes
                
                # Do for each sbgr :
                sbgr.BAP.tmp <- x %>% # select a dataframe (temporary name for dataframe where PER sbgr dataframe is stored, and run through the rest of the code)
                        plyr::ldply(function(y){
                                #then apply to each column within the datafrfame
                                plyr::daply(y,)
                                
                                Z10.5#this is currently in the environment so can call it here - but will need to updated to loop through a list of these....not sure how yet; Possible repeating the pattern above, after consolidating all the pressures into a list of dataframes
                        
                        })
        })

##double check in put

#create test dataframes

L3 <- LETTERS[1:3]
chr <- as.character(sample(L3,10,replace = TRUE))
(d <- data.frame(x = 1, y = 1:10, chrs = chr))
rm(L3, chr)

L2 <- LETTERS[1:2]
chr <- as.character(sample(L2,10, replace = TRUE))
(d2 <- data.frame(a = 2,b = round(rnorm(10, mean = 5, sd = 3),0), chrs = chr ))
rm(L2, chr)

lst1 <- list(d, d2)
rm(d,d2)
lst1
lst1[[1]][[1]]



sbgr.BAP <- lst1 %>% 
        plyr::llply(function(x){ 
                
                print(x)
                # Do for each sbgr :
                #tmp <- x %>% # select a dataframe (temporary name for dataframe where PER sbgr dataframe is stored, and run through the rest of the code)
                 #       plyr::dlply(function(y){
                                #then apply to each column within the datafrfame
                                chr.vec <-  plyr::colwise(print(as.character(x))) 
                                
                        #})
                print("End of llply iteration...") # this shows that the llply function workssplits 
                                print(class(x)) # this shows that it is a dataframe...that goes into
        })

