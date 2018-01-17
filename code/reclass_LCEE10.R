## LCEE10 reclassify

round(table(values(as.factor(covs$LCEE10))) / 63632,2)

# 10 is crops
covs$LCEE10[covs$LCEE10 == 11] <-  10
covs$LCEE10[covs$LCEE10 == 12] <-  10
covs$LCEE10[covs$LCEE10 == 20] <-  10
covs$LCEE10[covs$LCEE10 == 30] <-  10

# 60 is tree cover
covs$LCEE10[covs$LCEE10 == 40] <-  60
covs$LCEE10[covs$LCEE10 == 70] <-  60
covs$LCEE10[covs$LCEE10 == 90] <-  60
covs$LCEE10[covs$LCEE10 == 100] <-  60

# 120 shrublands or grasslands
covs$LCEE10[covs$LCEE10 == 130] <-  120
covs$LCEE10[covs$LCEE10 == 150] <-  120
covs$LCEE10[covs$LCEE10 == 180] <-  120

# bare lands + urban areas
covs$LCEE10[covs$LCEE10 == 190] <-  200

## RECLASS
covs$LCEE10[covs$LCEE10 == 10] <-  1
covs$LCEE10[covs$LCEE10 == 60] <-  2
covs$LCEE10[covs$LCEE10 == 120] <-  3
covs$LCEE10[covs$LCEE10 == 200] <-  4
covs$LCEE10[covs$LCEE10 == 210] <-  5

writeRaster(covs$LCEE10, "covs/LCEE10.tif", overwrite=T)

