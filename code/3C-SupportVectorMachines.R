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

load(file = "covariates.RData")

names(covs)

# plot the names of the covariates
names(dat@data)

# variable selection using correlation analysis
selectedCovs <- cor(x = as.matrix(dat@data[,5]),
                    y = as.matrix(dat@data[,-c(1:7,13,21)]))

# print correlation results
selectedCovs

library(reshape)
x <- subset(melt(selectedCovs), value != 1 | value != NA)
x <- x[with(x, order(-abs(x$value))),]

idx <- as.character(x$X2[1:5])

dat2 <- dat[c('OCSKGM', idx)]
names(dat2)

COV <- covs[[idx]]

# Selected covariates
names(COV)


# Categorical variables in svm models
dummyRaster <- function(rast){
  rast <- as.factor(rast)
  result <- list()
  for(i in 1:length(levels(rast)[[1]][[1]])){
    result[[i]] <- rast == levels(rast)[[1]][[1]][i]
    names(result[[i]]) <- paste0(names(rast),
                                 levels(rast)[[1]][[1]][i])
  }
  return(stack(result))
}

# convert soilmap from factor to dummy
soilmap_dummy <- dummyRaster(covs$soilmap)

# convert LCEE10 from factor to dummy
LCEE10_dummy <- dummyRaster(covs$LCEE10)

# Stack the 5 COV layers with the 2 dummies
COV <- stack(COV, soilmap_dummy, LCEE10_dummy)

# print the final layer names
names(COV)

# convert soilmap column to dummy, the result is a matrix
# to have one column per category we had to add -1 to the formula
dat_soilmap_dummy <- model.matrix(~soilmap -1, data = dat@data)
# convert the matrix to a data.frame
dat_soilmap_dummy <- as.data.frame(dat_soilmap_dummy)


# convert LCEE10 column to dummy, the result is a matrix
# to have one column per category we had to add -1 to the formula
dat_LCEE10_dummy <- model.matrix(~LCEE10 -1, data = dat@data)
# convert the matrix to a data.frame
dat_LCEE10_dummy <- as.data.frame(dat_LCEE10_dummy)

dat@data <- cbind(dat@data, dat_LCEE10_dummy, dat_soilmap_dummy)

names(dat@data)

# Fitting a svm model and parameter tuning
library(e1071)
library(caret)

#  Test different values of epsilon and cost
tuneResult <- tune(svm, OCSKGM ~.,  data = dat@data[,c("OCSKGM",
                                                       names(COV))],
                   ranges = list(epsilon = seq(0.1,0.2,0.02),
                                 cost = c(5,7,15,20)))


plot(tuneResult)

# Choose the model with the best combination of epsilon and cost
tunedModel <- tuneResult$best.model

print(tunedModel)


# Use the model to predict the SOC in the covariates space
OCSsvm <- predict(COV, tunedModel)

# Save the result
writeRaster(OCSsvm, filename = "results/MKD_OCSKGM_svm.tif",
            overwrite=TRUE)

plot(OCSsvm)

# Variable importance in svm. Code by:
# stackoverflow.com/questions/34781495

w <- t(tunedModel$coefs) %*% tunedModel$SV     # weight vectors
w <- apply(w, 2, function(v){sqrt(sum(v^2))})  # weight

w <- sort(w, decreasing = T)
print(w)
