## The following code is part of the example scripts included
## in the "Soil Organic Carbon Mapping Cookbook"
## @knitr 1A-DataPreparation-Profiles

dat <- read.csv(file = "data/horizons.csv")

# Explore the data
str(dat)
summary(dat)

dat_sites <- read.csv(file = "data/site-level.csv")

# Explore the data
str(dat_sites)

# summary of column CRF (Coarse Fragments) in the example data base
summary(dat$CRF)

# Convert NA's to 0
dat$CRF[is.na(dat$CRF)] <- 0

hist(dat$CRF)

# Creating a function in R to estimate BLD using the SOC
# SOC is the soil organic carbon content in \%
estimateBD <- function(SOC, method="Saini1996"){
  OM <- SOC * 1.724
  if(method=="Saini1996"){BD <- 1.62 - 0.06 * OM}
  if(method=="Drew1973"){BD <- 1 / (0.6268 + 0.0361 * OM)}
  if(method=="Jeffrey1979"){BD <- 1.482 - 0.6786 * (log(OM))}
  if(method=="Grigal1989"){BD <- 0.669 + 0.941 * exp(1)^(-0.06 * OM)}
  if(method=="Adams1973"){BD <- 100 / (OM /0.244 + (100 - OM)/2.65)}
  if(method=="Honeyset_Ratkowsky1989"){BD <- 1/(0.564 + 0.0556 * OM)}
  return(BD)
}

# summary of BLD (bulk density) in the example data base
summary(dat$BLD)

# See the summary of values produced using the pedo-transfer
# function with one of the proposed methods.
summary(estimateBD(dat$SOC[is.na(dat$BLD)], m
                   ethod="Honeyset_Ratkowsky1989"))

# Fill NA's using the pedotransfer function:
dat$BLD[is.na(dat$BLD)] <- estimateBD(dat$SOC[is.na(dat$BLD)],
                                      method="Grigal1989")

# explore the results
boxplot(dat$BLD)

# Load aqp package
library(aqp)

# Promote to SoilProfileCollection
# The SoilProfileCollection is a object class in R designed to
# handle soil profiles
depths(dat) <- ProfID ~ top + bottom

# Merge the soil horizons information with the site-level
# information from dat_sites
site(dat) <- dat_sites

# Set spatial coordinates
coordinates(dat) <- ~ X + Y

# A summary of our SoilProfileCollection
dat

library(GSIF)

## Estimate 0-30 standard horizon usin mass preserving splines
try(SOC <- mpspline(dat, 'SOC', d = t(c(0,30))))
try(BLD <- mpspline(dat, 'BLD', d = t(c(0,30))))
try(CRFVOL <- mpspline(dat, 'CRF', d = t(c(0,30))))

## Prepare final data frame
dat <- data.frame(id = dat@site$ProfID,
                  Y = dat@sp@coords[,2],
                  X = dat@sp@coords[,1],
                  SOC = SOC$var.std[,1],
                  BLD = BLD$var.std[,1],
                  CRFVOL = CRFVOL$var.std[,1])

dat <- dat[complete.cases(dat),]

## Take a look to the results
head(dat)

# Estimate Organic Carbon Stock
# SOC must be in g/kg
# BLD in kg/m3
# CRF in percentage
OCSKGM <- OCSKGM(ORCDRC = dat$SOC, BLD = dat$BLD*1000,
                 CRFVOL = dat$CRFVOL, HSIZE = 30)

dat$OCSKGM <- OCSKGM
dat$meaERROR <- attr(OCSKGM,"measurementError")
dat <- dat[dat$OCSKGM>0,]
summary(dat)

## We can save our processed data as a table
write.csv(dat, "data/dataproc.csv")
