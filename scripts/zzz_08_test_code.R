# join the pressure to a sbgr-consolidated data set
library(plyr)
library(dplyr)
library(magrittr)

#create a list of test dataframes

#sample of sbgr data
test.dat <- sbgr.matched.btpt.w.rpl %>% 
        llply(function(x){
                print(class(x))
                sample_frac(x, 0.05, replace = F) %>%
                        select(1:10) #select(1:14, 19:354)    (remove the columns with EUNIs codes, h.lvl etc., but also only sample ten columns at this stage) 
        })
str(test.dat) # list of dataframes completely comprising 
#sample pressure data
test.p <- Z10.5 %>%
        select(eunis.code = EUNISCode, D5, D6) %>%
        sample_n(10)
str(test.p) # all chr, so correct

##script to run

test.code <- test.dat %>% 
        plyr::llply(function(x) { 
                
                cols.df <- data.frame(matrix(nrow = nrow(x))) # create empty dataframe to store FOR LOOP results in, specifying only that it needsthe same number of rows as the dataframe that i spassed to it
                
                
                for (i in seq_along(x)){
                        x[[i]] <- as.character(x[[1]])
                        
                        y <- x %>% 
                                dplyr::select(names(x)[[i]])
                        
                        
                        xname <- names(x[i]) # input
                        yname <- names(test.p)[[1]] # input
                        
                        #define a result dataframe to store the joined data in
                        join.result <- data.frame(matrix(nrow = nrow(x[i]),ncol = (ncol(test.p)-1)+ncol(x[i])))
                        join.result.names <- c(names(x)[[i]],paste0(names(test.p[,-1]),"_",names(x)[[i]]))# output
                        names(join.result) <- join.result.names
                        
                        function(xname, yname) {
                                #data(iris)
                                join.result[i] <- left_join(y,test.p, by = setNames(xname, yname))
                        }
                        
                        cols.df <- cbind(cols.df,join.result) 
                }
                return(cols.df <- cbind(cols.df,join.result) )
        })


#### OTHER (EARLIER) FAKE TEST DATA-----------------
#L3 <- LETTERS[1:3]
#chr <- as.character(sample(L3,10,replace = TRUE))
#(d <- data.frame(x = 1, y = 1:10, chrs = chr))
#rm(L3, chr)

#L2 <- LETTERS[1:2]
#chr <- as.character(sample(L2,10, replace = TRUE))
#(d2 <- data.frame(a = 2,b = round(rnorm(10, mean = 5, sd = 3),0), chrs = chr ))
#rm(L2, chr)
#lst1 <- list(d, d2)
#rm(d,d2)
#lst1
#lst1[[1]][[1]]

#test frame to join to
#SF <- c("High", "Medium", "Low", "Not Assessed", "Not relevant")
#sens.fake <- as.character(sample(SF,10, replace = TRUE))
#L3 <- LETTERS[1:3]
#chr <- as.character(sample(L3,10,replace = TRUE))
#(d3 <- data.frame(sens.fake = sens.fake, chrs.wrong.name = chr ))
#rm(SF, sens.fake, chr)