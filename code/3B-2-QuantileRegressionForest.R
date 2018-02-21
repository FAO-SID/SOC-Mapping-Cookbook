#Generate an empty dataframe
validation <- data.frame(rmse=numeric(), r2=numeric())
#Sensitivity to the dataset
#Start a loop with 10 model realizations
for (i in 1:10){
  # We will build 10 models using random samples of 25%
  smp_size <- floor(0.25 * nrow(dat))
  train_ind <- sample(seq_len(nrow(dat)), size = smp_size)
  train <- dat[train_ind, ]
  test <- dat[-train_ind, ]
  modn <- train(fm, data=train, method = "rf", trControl = ctrl)
  pred <- stack(pred, predict(covariates, modn))
  test$pred <- predict(modn[11][[1]], test)
  # Store the results in a dataframe
  validation[i, 1] <- rmse(test$OCSKGMlog, test$pred)
  validation[i, 2] <- cor(test$OCSKGMlog, test$pred)^2
}

#The sensitivity map is the dispersion of all individual models
sensitivity <- calc(pred[[-1]], sd)

plot(sensitivity, col=rev(topo.colors(10)),
     main='Sensitivity based on 10 realizations using 25% samples')

#Sensitivity of validation metrics
summary(validation)

# Plot of the map based on 75% of data and the sensitivity to data
# variations
prediction75 <- exp(pred[[1]])

plot(prediction75, main='OCSKGM prediction based on 75% of data',
     col=rev(topo.colors(10)))

# Use quantile regression forest to estimate the full conditional
# distribution of OCSKGMlog, note that we are using the mtry
# parameter that was selected by the train funtion of the caret
# package, assuming that the 75% of data previously used well
# resembles the statistical distribution of the entire data
# population. Otherwise repeat the train function with all available
#data (using the object dat that instead of train) to select mtry.


model <- quantregForest(y=dat$OCSKGMlog, x=dat[,1:13], ntree=500,
                        keep.inbag=TRUE, mtry = as.numeric(mod$bestTune))

library(snow)
# Estimate model uncertainty at the pixel level using parallel
# computing
beginCluster() #define number of cores to use
# Estimate model uncertainty
unc <- clusterR(covariates, predict, args=list(model=model,what=sd))
# OCSKGMlog prediction based in all available data
mean <- clusterR(covariates, predict,
                 args=list(model=model, what=mean))
# The total uncertainty is the sum of sensitivity and model
# uncertainty
unc <- unc + sensitivity
# Express the uncertainty in percent (divide by the mean)
Total_unc_Percent <- exp(unc)/exp(mean)
endCluster()

# Plot both maps (the predicted OCSKGM + its associated uncertainty)
plot(exp(mean), main='OCSKGM based in all data',
     col=rev(topo.colors(10)))

plot(Total_unc_Percent, col=rev(heat.colors(100)), zlim=c(0, 5),
     main='Total uncertainty')

#Save the resulting maps in separated *.tif files
writeRaster(exp(mean), file='rfOCSKGMprediction.tif',
            overwrite=TRUE)
writeRaster(Total_unc_Percent, file='rfOCSKGMtotalUncertPercent.tif',
            overwrite=TRUE)
