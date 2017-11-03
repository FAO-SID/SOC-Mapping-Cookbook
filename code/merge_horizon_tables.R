chem <- read.csv("data/test_chem.csv")
phys <- read.csv("data/test_phys.csv")
mech <- read.csv("data/test_mech.csv")


names(chem)
names(phys)
names(mech)

dat <- merge(chem, phys, by.x = "HorID", by.y = "HorID")
dat <- merge(dat, mech, by.x = "HorID", by.y = "HorID")


str(dat)

dat$ProfID <- substr(dat$HorID, 0, 4)

dat <- dat[,c("ProfID", "HorID", "DepthTo.x", "DepthTo.x", "Humus", "Bulk_density", "Skeleton",
       "Coarse_sand", "Fine_sand", "Silt", "Clay") ]

write.csv(dat, "data/horizons.csv")




#### Profile ID #####

prof <- read.csv("data/site-level.csv")

