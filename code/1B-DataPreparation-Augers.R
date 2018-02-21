dat <- read.csv(file = "data/auger.csv")

# Explore the data
str(dat)
summary(dat)

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

# See the summary of values produced using the pedo-transfer
# function with one of the proposed methods.
summary(estimateBD(dat$SOC, method="Honeyset_Ratkowsky1989"))

# Estimate BLD using the pedotransfer function:
dat$BLD <- estimateBD(dat$SOC, method="Grigal1989")

# explore the results
boxplot(dat$BLD)

# Remove points with NA's values
dat <- dat[complete.cases(dat),]

## Take a look to the results
head(dat)

# Estimate Organic Carbon Stock
# SOC must be in g/kg
# BLD in kg/m3
# CRF in percentage
OCSKGM <- OCSKGM(ORCDRC = dat$SOC, BLD = dat$BLD*1000, CRFVOL = 0,
                 HSIZE = 30)

dat$OCSKGM <- OCSKGM
dat$meaERROR <- attr(OCSKGM,"measurementError")
dat <- dat[dat$OCSKGM>0,]
summary(dat)

## We can save our processed data as a table
write.csv(dat, "data/dataproc.csv")
