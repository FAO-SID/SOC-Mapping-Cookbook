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

load(file = "covariates.RData")

names(covs)

# For its use on R we need to define a model formula

fm = as.formula(paste("log(OCSKGM) ~", paste0(names(covs[[-14]]),
                                              collapse = "+")))

library(randomForest)
library(caret)

# Default 10-fold cross-validation
ctrl <- trainControl(method = "cv", savePred=T)
# Search for the best mtry parameter
rfmodel <- train(fm, data=dat@data, method = "rf", trControl = ctrl,
                 importance=TRUE)
# This is a very useful function to compare and test different
# prediction algorithms type names(getModelInfo()) to see all the
# possibilitites implemented on this function


# Variable importance plot, compare with the correlation matrix
# Select the best prediction factors and repeat
varImpPlot(rfmodel[11][[1]])

# Check if the error stabilizes
plot(rfmodel[11][[1]])

#Make a prediction across all Macedonia
#Note that the units are still in log
pred <- predict(covs, rfmodel)

# Back transform predictions log transformed
pred <- exp(pred)

# Save the result as a tiff file
writeRaster(pred, filename = "results/MKD_OCSKGM_rf.tif",
            overwrite=TRUE)


plot(pred)
