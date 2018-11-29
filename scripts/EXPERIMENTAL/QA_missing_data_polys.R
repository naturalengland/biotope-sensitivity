hab.types$hab.1[hab.types$pkey == "158108"]

names(xap.ls$Z10.5$`4a`)

#test errors
xap.ls$Z10.5$`4a` %>% 
        filter(eunis.code.gis == "A4.13", grepl("A4.13", eunis.match.assessed, fixed = TRUE), PressureCode == "D6", ActivityCode == "Z10.5") %>%
        group_by(eunis.match.assessed) %>%
        summarise(max.sens = max(rank.value))
