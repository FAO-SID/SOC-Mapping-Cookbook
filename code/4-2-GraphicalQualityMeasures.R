# scatter plot
plot(dat$MKD_OCSKGM_rf, dat$OCSKGM, main="rf", xlab="predicted",
     ylab='observed')
# 1:1 line in black
abline(0,1, lty=2, col='black')
# regression line between predicted and observed in blue
abline(lm(dat$OCSKGM ~ dat$MKD_OCSKGM_rf), col = 'blue', lty=2)

# spatial bubbles for prediction errors
bubble(dat[!is.na(dat$PE_rf),], "PE_rf", pch = 21,
       col=c('red', 'green'))
