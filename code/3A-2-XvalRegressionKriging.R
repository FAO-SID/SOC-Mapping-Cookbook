## The following code is part of the example scripts included
## in the "Soil Organic Carbon Mapping Cookbook"
## @knitr 3A-2-XvalRegressionKriging

# autoKrige.cv() does not removes the duplicated points
# we have to do it manually before running the cross-validation
dat = dat[which(!duplicated(dat@coords)), ]

OCS.krige.cv <- autoKrige.cv(formula =
                               as.formula(model.MLR.step$call$formula),
                             input_data = dat, nfold = 10)

summary(OCS.krige.cv)
