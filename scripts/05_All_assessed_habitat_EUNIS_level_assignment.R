# Develop possible combination of assesssed habitat

library(dplyr)
#EunisAssessed<- data.frame(matrix(EunisAssessed))
#names(EunisAssessed) <- "EUNISCode"
EunisAssessed$level <- nchar(as.character(EunisAssessed$EUNISCode), type = "chars", allowNA = T, keepNA = T)-1 # THIS NEEDS TO BE + 1

#nchar.hab <- nchar(as.character(EunisAssessed$EUNISCode), type = "chars", allowNA = T, keepNA = T)

EunisAssessed$l6 <- "NA"
EunisAssessed$l6[EunisAssessed$level == 6] <- substr(as.character(EunisAssessed$EUNISCode[EunisAssessed$level == 6]), 1,7)

EunisAssessed$l5 <- "NA"
EunisAssessed$l5[EunisAssessed$level == 5] <- substr(as.character(EunisAssessed$EUNISCode[EunisAssessed$level == 5]), 1,6)

EunisAssessed$l4 <- "NA"
EunisAssessed$l4[EunisAssessed$level == 4] <- substr(as.character(EunisAssessed$EUNISCode[EunisAssessed$level == 4]), 1,5)

EunisAssessed$l3 <- "NA"
EunisAssessed$l3[EunisAssessed$level == 3] <- substr(as.character(EunisAssessed$EUNISCode[EunisAssessed$level == 3]), 1,4)

EunisAssessed$l2 <- "NA"
EunisAssessed$l2[EunisAssessed$level == 2] <- substr(as.character(EunisAssessed$EUNISCode[EunisAssessed$level == 2]), 1,2)

EunisAssessed$l1 <- "NA"
EunisAssessed$l1[EunisAssessed$level == 1] <- substr(as.character(EunisAssessed$EUNISCode[EunisAssessed$level == 1]), 1,1)

EunisAssessed$eunis.code <- EunisAssessed$EUNISCode

####-----
#Attempt to turn this into a function - not working yet

#xy <- vector("list", nrow(EunisAssessed))
#eunis.levels <- function(x = EunisAssessed, lvl = 1:6){
#        for (i in seq_along(lvl)){
#                nam <- paste("l", i, sep = "")

#                y <- data.frame(i,nrow(x))
#               names(y) <- paste("l", i, sep = "")
#                x[i+2][x$level == i] <- substr(as.character(x$EUNISCode[x$level == i]), 1,i+1)
#                xy[[i]] <- x
#                
#        }
#        do.call(cbind, xy)
#}
#eunis.levels()