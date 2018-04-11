## The following code is part of the example scripts included
## in the "Soil Organic Carbon Mapping Cookbook"
## @knitr optional-Merging

profiles <- read.csv("data/dataproc_profiles.csv")
topsoils <- read.csv("data/dataproc.csv")


# column names could be different, but the units and order has
# to be the same! Because we are going to add the rows from 1
# table to the other table.

topsoils <- topsoils[, c("ID", "X", "Y", "SOC", "BLD",
                         "OCSKGM", "meaERROR")]

profiles <- profiles[, c("id", "X", "Y", "SOC", "BLD",
                         "OCSKGM", "meaERROR")]

names(profiles) <- names(topsoils)
dat <- rbind(topsoils, profiles)

write.csv(dat, "data/dataproc_all.csv", row.names = F)
