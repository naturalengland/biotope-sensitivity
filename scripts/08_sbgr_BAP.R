# join the pressure to a sbgr-consolidated data set
library(plyr)
library(dplyr)
library(magrittr)

#To Do, include Full Pressure list, (consider doing one for each pressure, and then join to sensitivity data

sbgr.bap <- sbgr.matched.btpt.w.rpl %>% 
        plyr::llply(function(x) { 

                
                x.df <- x %>% select(1:14, 19:354) # this is only the data, which is to be isolated for the calculations
                x.rn <- x$eunis.code.gis # this is the EUNIs codes of the GIS files, which will become the row names for each data frame
                #unique(duplicated(x.rn)) #QA code: should be FALSE only
                cols.df <- data.frame(matrix(nrow = nrow(x.df))) # create empty dataframe to store FOR LOOP results in, specifying only that it needsthe same number of rows as the dataframe that i spassed to it
                
                
                for (i in seq_along(x.df)){
                        
                        #x.df[,i] <- as.character(x.df[[1]])
                        
                        y <- x.df %>% 
                               dplyr::select(names(x.df)[[i]])
                        
                        #set the variable names to be used in join
                        xname <- names(x.df[i]) # varaible anme from sbgr...to be used to join to pressure
                        yname <- names(p)[[1]] # varaible name that will be used to join table pressure to sbgr...
                        
                        #define a result dataframe to store the joined data in
                        join.result <- data.frame(matrix(nrow = nrow(x.df[i]),ncol = (ncol(p)-1)+ncol(x.df[i])))
                        join.result.names <- c(names(x.df)[[i]],paste0(names(p[,-1]),"_",names(x.df)[[i]]))# output
                        names(join.result) <- join.result.names
                        
                        joinfn <- function(xname, yname) {#Is it neccessary to name this function?
                                join.result[i] <- left_join(y,p, by = setNames(xname, yname)) # this allows tables to be joined using non-matching names
                        }
                        
                        cols.df <- cbind(cols.df,join.result) 
                }
                
                cols.df <- cols.df[,-1]
                cols.df$eunis.gis.code <- x.rn #Could not sepcify as row.names(cols.df) <- x.rn, so just added as a column (this adds the GIS EUNI S Codes back ontot eh dataframe for reference)
                cols.df <- cbind(cols.df, count = (apply(sbgr.bap[[1]], 1, function(x)length(unique(!is.na(x) )))))#count the number of uniq values per column
                #write.csv(cols.df, ".output/cols.df") # if desired a counter or naming needs top be pasted on...
                return(cols.df)
        }, .progress = "text")
saveRDS(sbgr.bap,"./output/sbgr_bap.rds")








