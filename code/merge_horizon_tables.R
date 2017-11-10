chem <- read.csv("data/test_chem.csv")
phys <- read.csv("data/test_phys.csv")
mech <- read.csv("data/test_mech.csv")


names(chem)
names(phys)
names(mech)

dat <- merge(chem, phys, by.x = "HorID", by.y = "HorID")
dat <- merge(dat, mech, by.x = "HorID", by.y = "HorID")


str(dat)

dat$ProfID <- substr(dat$HorID, 0, 5)

dat$SAND <- dat$Coarse_sand + dat$Fine_sand


dat <- dat[,c("ProfID", "HorID", "DepthFrom.x", "DepthTo.x", "Humus", "Bulk_density", "Skeleton",
       "SAND", "Silt", "Clay") ]

names(dat) <- c("ProfID", "HorID", "top", "bottom", "SOC", "BLD", "CRF",
                 "SAND", "SILT", "CLAY")

dat <- dat[dat$ProfID %in% prof$ProfID, ]

write.csv(dat, "data/horizons.csv", row.names = F)




#### Profile ID #####
library(raster)
prof <- read.csv("data/test_site.csv")
prof <- prof[prof$ProfID %in% dat$ProfID, ]
prof<- prof[!is.na(prof$X_coord), ]

#remove duplicate profiles
profdupl <- as.data.frame(table(prof$ProfID))
profdupl <- profdupl[profdupl$Freq!=1,1]
profdupl <- as.character(profdupl)
prof <- prof[!prof$ProfID %in% profdupl,]


soils <- shapefile("raw-data/MKD_SoilMappingUnitsMap/MK_Soil_20160113.shp")
prof_sp <- prof
coordinates(prof_sp) <- ~ X_coord + Y_coord
prof_sp@proj4string <- CRS("+init=epsg:6204")
prof_sp <- spTransform(prof_sp, soils@proj4string)

profsoils <- over(prof_sp, soils)
profsoils$FAO

prof_sp@data$soiltype <- profsoils$FAO


write.csv(as.data.frame(prof_sp), "data/site-level.csv", row.names = F)

############################################### add landcover info

prof <- read.csv("data/site-level.csv")

lc <- read.csv("data/site-level_landcover.csv")

prof <- merge(prof, lc)

head(prof)

prof <- prof[,c("ProfID", "X", "Y", "soiltype", "Land.Cover")]
write.csv(prof, "data/site-level.csv", row.names = F)
