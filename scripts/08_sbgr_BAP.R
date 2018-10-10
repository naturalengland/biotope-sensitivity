# join the pressure to a sbgr-consolidated data set
library(plyr)
library(dplyr)
library(magrittr)



sbgr.bap <- sbgr.matched.btpt.w.rpl %>% 
        plyr::llply(function(x) { 

                
                x.df <- x %>% select(1:14, 19:354) # this is only the data, which is to be isolated for the calculations
                x.rn <- x %>% select("eunis.code.gis") # this is the EUNIs codes of the GIS files, which will become the row names for each data frame
                
                cols.df <- data.frame(matrix(nrow = nrow(x.df))) # create empty dataframe to store FOR LOOP results in, specifying only that it needsthe same number of rows as the dataframe that i spassed to it
                
                
                for (i in seq_along(x.df)){
                        
                        #x.df[,i] <- as.character(x.df[[1]])
                        
                        y <- x.df %>% 
                               dplyr::select(names(x.df)[[i]])
                        
                        
                        xname <- names(x.df[i]) # input
                        yname <- names(test.p)[[1]] # input
                        
                        #define a result dataframe to store the joined data in
                        join.result <- data.frame(matrix(nrow = nrow(x.df[i]),ncol = (ncol(test.p)-1)+ncol(x.df[i])))
                        join.result.names <- c(names(x.df)[[i]],paste0(names(test.p[,-1]),"_",names(x.df)[[i]]))# output
                        names(join.result) <- join.result.names
                        
                        joinfn <- function(xname, yname) {#Is it neccessary to name this function?
                                #data(iris)
                                join.result[i] <- left_join(y,test.p, by = setNames(xname, yname))
                        }
                        
                        cols.df <- cbind(cols.df,join.result) 
                }
               row.names(cols.df) <- x.rn
                return(cols.df)
        })




