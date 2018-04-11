## The following code is part of the example scripts included
## in the "Soil Organic Carbon Mapping Cookbook"
## @knitr 2-OverlayCovariates

# Load the processed data. This table was prepared in the previous
# chapter.
dat <- read.csv("data/dataproc.csv")

files <- list.files(path = "covs", pattern = "tif$",
                    full.names = TRUE)

covs <- stack(files)

#covs <- stack(covs, soilmap.r)

# correct the name for layer 14
#names(covs)[14] <- "soilmap"

library (raster)

#mask the covariates with the country mask from the data repository
mask <- raster("data/mask.tif")

covs <- mask(x = covs, mask = mask)

# export all the covariates
save(covs, file = "covariates.RData")

plot(covs)

#upgrade points data frame to SpatialPointsDataFrame
coordinates(dat) <- ~ X + Y

# extract values from covariates to the soil points
dat <- extract(x = covs, y = dat, sp = TRUE)

# LCEE10 and soilmap are categorical variables
dat@data$LCEE10 <- as.factor(dat@data$LCEE10)

#dat@data$soilmap <- as.factor(dat@data$soilmap)
#levels(soilmap) <- Symbol.levels

summary(dat@data)

dat <- as.data.frame(dat)

# The points with NA values has to be removed
dat <- dat[complete.cases(dat),]

# export as a csv table
write.csv(dat, "data/MKD_RegMatrix.csv", row.names = FALSE)
