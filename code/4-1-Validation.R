dat <- read.csv("data/dat_test.csv")

# Promote to spatialPointsDataFrame
coordinates(dat) <- ~ X + Y

dat@proj4string <- CRS(projargs = "+init=epsg:4326")

library(raster)

OCSKGM_rf <- raster("results/MKD_OCSKGM_rf.tif")

dat <- extract(x = OCSKGM_rf, y = dat, sp = TRUE)

# prediction error
dat$PE_rf <- dat$MKD_OCSKGM_rf - dat$OCSKGM

# Mean Error
ME_rf <- mean(dat$PE_rf, na.rm=TRUE)

# Mean Absolute Error (MAE)
MAE_rf <- mean(abs(dat$PE_rf), na.rm=TRUE)

# Mean Squared Error (MSE)
MSE_rf <- mean(dat$PE_rf^2, na.rm=TRUE)

# Root Mean Squared Error (RMSE)
RMSE_rf <- sqrt(sum(dat$PE_rf^2, na.rm=TRUE) / length(dat$PE_rf))

# Amount of Variance Explained (AVE)
AVE_rf <- 1 - sum(dat$PE_rf^2, na.rm=TRUE) /
  sum( (dat$MKD_OCSKGM_rf - mean(dat$OCSKGM, na.rm = TRUE))^2,
       na.rm = TRUE)
