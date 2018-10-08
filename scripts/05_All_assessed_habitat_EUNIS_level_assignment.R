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

#group_by EUNIS levels, and sort
#EunisAssessed <- EunisAssessed %>% group_by(l2) %>% distinct() %>% arrange(EUNISCode)


#join to BGR


#jntbl.habtype.assessed <- left_join(df.hab.type,EunisAssessed, by = "eunis.code")

#jntbl.habtype.assessed$act.sen.ass <- jntbl.habtype.assessed$EUNISCode

