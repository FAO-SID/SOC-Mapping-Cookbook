## The following code is part of the example scripts included
## in the "Soil Organic Carbon Mapping Cookbook"
## @knitr optional-Merging

profiles <- read.csv("data/dataproc_profiles.csv")
topsoils <- read.csv("data/dataproc.csv")

topsoils <- topsoils[, c("ID", "X", "Y", "OC_percent", "BLD",
                         "OCSKGM", "meaERROR")]

profiles <- profiles[, c("ID", "X", "Y", "SOC", "BLD",
                         "OCSKGM", "meaERROR")]

names(profiles) <- names(topsoils)
dat <- rbind(topsoils, profiles)

write.csv(dat, "data/dataproc_all.csv", row.names = F)
