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
                #sbgr.BAP.tmp <- x %>% # select a dataframe (temporary name for dataframe where PER sbgr dataframe is stored, and run through the rest of the code)
                        p <- Z10.5 %>% rename(eunis.code.gis = "EUNISCode")
                        left_join(x,p, by = "eunis.code.gis")
                        #plyr::colwise(function(y){
                                #then apply to each column within the datafrfame
                         #       name(y) <- "EUNISCode"
                          #      col.press.tmp <- left_join(Z10.5, y, by  = "EUNISCode")
                                
                           #     Z10.5#this is currently in the environment so can call it here - but will need to updated to loop through a list of these....not sure how yet; Possible repeating the pattern above, after consolidating all the pressures into a list of dataframes
                        
                       # })
        })
names(sbgr.BAP[[1]])
sbgr.BAP[[1]]$D2
View(sbgr.BAP[[1]])
##double check in put

#create a list of test dataframes

#sample of sbgr data
test.dat <- sbgr.matched.btpt.w.rpl %>% 
        llply(function(x){
                print(class(x))
                sample_n(x, 10, replace = F) %>%
                        select(1:10) #select(1:14, 19:354)    (remove the columns with EUNIs codes, h.lvl etc., but also only sample ten columns at this stage) 
})
str(test.dat) # list of dataframes completely comprising 
#sample pressure data
test.p <- Z10.5 %>%
        select(eunis.code = EUNISCode, D5, D6)
str(test.p) # all chr, so correct



test.code <- test.dat %>% 
        plyr::llply(function(x) { 
                print("Start of llply iteration...") # this shows that the llply function workssplits 
                print(class(x)) # this shows that it is a dataframe...that goes into
                
                cols.lst <- list() # create empty list to store FOR LOOP results in
                #p <- d3 %>% rename(chrs = chrs.wrong.name) #some mock code to check that renaming a variable defined outside the function will work
                #p$chrs <- as.character(p$chrs) # make sure that the column on which we want to join is the same in p df and the lists of dfs.
                
                
                for (i in seq_along(x)){
                        x[[i]] <- as.character(x[[1]])
                        
                        y <- x %>% 
                               dplyr::select(names(x)[[i]])
                        
                        
                        xname <- names(x)[[i]]
                        yname <- names(p)[[2]]
                        myfn <- function(xname, yname) {
                                #data(iris)
                                cols.lst[[i]] <- left_join(y,p, by = setNames(xname, yname))
                        }
                        
                }
                
                
                
                
                #cols.lst <- cbind(cols.lst)
                
                
                ###QA remove this if works
                #x <- lst1[[1]]
                #then apply to each column within the dataframe
                #plyr::daply(.data = x, .fun = function(y){
                #        col <- left_join(y,p, by = "chrs")
                #}, .variables = )
                #lapply(X = x, FUN = function(y){
                #        col <- left_join(as.character(y),p, by = "chrs")
                #})
                #amalgamate results
                #cols.lst <- rbind(cols.df, col, function(y){
                #        col <- left_join(y,p, by = "chrs")
                #}, .variables = )
                
                
                
                
               
        })
#df <- do.call("rbind",test.code) # binds all lists into matrix



###OTHER FAKE TEST DATA
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

#test frame to join to
SF <- c("High", "Medium", "Low", "Not Assessed", "Not relevant")
sens.fake <- as.character(sample(SF,10, replace = TRUE))
L3 <- LETTERS[1:3]
chr <- as.character(sample(L3,10,replace = TRUE))
(d3 <- data.frame(sens.fake = sens.fake, chrs.wrong.name = chr ))
rm(SF, sens.fake, chr)