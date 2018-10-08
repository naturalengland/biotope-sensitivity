# join the pressure to a sbgr-consolidated data set


#testcode
names(sbgr.matched.btpt.w.rpl[[1]])
test <- as.data.frame(cbind(sbgr.matched.btpt.w.rpl[[1]][[18]], sbgr.matched.btpt.w.rpl[[1]][[1]]))

names(test) <- c("EUNISCode", "v1")




join.sbgr.btp.sens <- left_join(test, Z10.5[,c(1,7)], by = "EUNISCode")


#start the loops
sapply(df, function(x) max(as.numeric(x)) )
