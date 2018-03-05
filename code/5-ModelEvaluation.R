## The following code is part of the example scripts included
## in the "Soil Organic Carbon Mapping Cookbook"
## @knitr 5-ModelEvaluation

library(raster)
RF<-raster('results/MKD_OCSKGM_rf.tif')
RK<-raster('results/MKD_OCSKGM_RK.tif')
SVM<-raster('results/MKD_OCSKGM_svm.tif')
#Note that RK has a different reference system
RK <- projectRaster(RK, SVM)
models <- stack(RK, RF, SVM)

library(psych)
pairs.panels(na.omit(as.data.frame(models)),
             method = "pearson", # correlation method
             hist.col = "#00AFBB",
             density = TRUE,  # show density plots
             ellipses = TRUE # show correlation ellipses
)


library(rasterVis)
densityplot(models)

SD <- calc(models , sd)
library(mapview)
mapview(SD)

RKRF  <- calc(models[[c(1,2)]], diff)
RKSVM <- calc(models[[c(1,3)]], diff)
RFSVM <- calc(models[[c(2,3)]], diff)
preds <- stack(RKRF, RKSVM, RFSVM)
names(preds) <- c('RKvsRF','RKvsSVM','RFvsSVM')
X <- cellStats(preds, mean)
levelplot(preds - X, at=seq(-0.5,0.5, length.out=10),
          par.settings = RdBuTheme)

dat <- read.csv("results/validation.csv")

# prepare 3 new data.frame with the observed, predicted and the model
modRK <- data.frame(obs = dat$OCSKGM, mod = dat$MKD_OCSKGM_RK,
                    model = "RK")

modRF <- data.frame(obs = dat$OCSKGM, mod = dat$MKD_OCSKGM_rf,
                    model = "RF")

modSVM <- data.frame(obs = dat$OCSKGM, mod = dat$MKD_OCSKGM_svm,
                     model = "SVM")

# merge the 3 data.frames into one
modData <- rbind(modRK, modRF, modSVM)

summary(modData)

#Load the openair library
library(openair)

modsts <- modStats(modData,obs = "obs", mod = "mod", type = "model")

modsts

TaylorDiagram(modData, obs = "obs", mod = "mod", group = "model",
              cols = c("orange", "red","blue"), cor.col='brown',
              rms.col='black')

conditionalQuantile(modData,obs = "obs", mod = "mod", type = "model")
