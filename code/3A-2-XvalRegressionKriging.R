OCS.krige.cv <- autoKrige.cv(formula =
                               as.formula(model.MLR.step$call$formula),
                             input_data = dat, nfold = 10)

summary(OCS.krige.cv)
