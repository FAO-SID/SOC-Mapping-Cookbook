# load data
dat <- read.csv("data/MKD_RegMatrix.csv")

dat$LCEE10 <- as.factor(dat$LCEE10)
dat$soilmap <- as.factor(dat$soilmap)

# explore the data structure
str(dat)

library(sp)

# Promote to spatialPointsDataFrame
coordinates(dat) <- ~ X + Y

class(dat)

dat@proj4string <- CRS(projargs = "+init=epsg:4326")

dat@proj4string

library(raster)

# list all the itf files in the folder covs/
files <- list.files(path = "covs", pattern = "tif$",
                    full.names = TRUE)

# load all the tif files in one rasterStack object
covs <- stack(files)

# load the vectorial version of the soil map
soilmap <- shapefile("MK_soilmap_simple.shp")

# rasterize using the Symbol layer
soilmap@data$Symbol <- as.factor(soilmap@data$Symbol)
soilmap.r <- rasterize(x = soilmap, y = covs[[1]], field = "Symbol")

# stack the soil map and the other covariates
covs <- stack(covs, soilmap.r)

# correct the name for layer 14
names(covs)[14] <- "soilmap"

# print the names of the 14 layers:
names(covs)

datdf <- dat@data

datdf <- datdf[, c("OCSKGM", names(covs))]

# Fit a multiple linear regression model between the log transformed
# values of OCS and the top 20 covariates
model.MLR <- lm(log(OCSKGM) ~ ., data = datdf)

# stepwise variable selection
model.MLR.step <- step(model.MLR, direction="both")

# summary and anova of the new model using stepwise covariates
# selection
summary(model.MLR.step)
anova(model.MLR.step)

# graphical diagnosis of the regression analysis
par(mfrow=c(2,2))
plot(model.MLR.step)
par(mfrow=c(1,1))

# collinearity test using variance inflation factors
library(car)
vif(model.MLR.step)

# problematic covariates should have sqrt(VIF) > 2
sqrt(vif(model.MLR.step))

# Removing B07CHE3 from the stepwise model:
model.MLR.step <- update(model.MLR.step, . ~ . - B07CHE3)

# Test the vif again:
sqrt(vif(model.MLR.step))

## summary  of the new model using stepwise covariates selection
summary(model.MLR.step)

# outlier test using the Bonferroni test
outlierTest(model.MLR.step)

# Project point data.
dat <- spTransform(dat, CRS("+init=epsg:6204"))

# project covariates to VN-2000 UTM 48N
covs <- projectRaster(covs, crs = CRS("+init=epsg:6204"),
                      method='ngb')

covs$LCEE10 <- as.factor(covs$LCEE10)
covs$soilmap <- as.factor(covs$soilmap)

# Promote covariates to spatial grid dataframe. Takes some time and
# a lot of memory!
covs.sp <- as(covs, "SpatialGridDataFrame")
covs.sp$LCEE10 <- as.factor(covs.sp$LCEE10)
covs.sp$soilmap <- as.factor(covs.sp$soilmap)

# RK model
library(automap)


# Run regression kriging prediction. This step can take hours...!
OCS.krige <- autoKrige(formula =
                         as.formula(model.MLR.step$call$formula),
                       input_data = dat,
                       new_data = covs.sp,
                       verbose = TRUE,
                       block = c(1000, 1000))

OCS.krige

# Convert prediction and standard deviation to rasters
# And back-tansform the vlaues
RKprediction <- exp(raster(OCS.krige$krige_output[1]))
RKpredsd <- exp(raster(OCS.krige$krige_output[3]))


plot(RKprediction)

## Save results as tif files
writeRaster(RKprediction, filename = "results/MKD_OCSKGM_RK.tif",
            overwrite = TRUE)

writeRaster(RKpredsd, filename = "results/MKD_OCSKGM_RKpredsd.tif",
            overwrite = TRUE)

# save the model
saveRDS(model.MLR.step, file="results/RKmodel.Rds")

