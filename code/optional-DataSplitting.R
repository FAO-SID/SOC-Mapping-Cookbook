library(caret)

dat <- read.csv("data/dataproc.csv")

train.ind <- createDataPartition(1:nrow(dat), p = .75, list = FALSE)
train <- dat[ train.ind,]
test  <- dat[-train.ind,]

plot(density (log(train$OCSKGM)), col='red',
     main='Statistical distribution of train and test datasets')
lines(density(log(test$OCSKGM)), col='blue')
legend('topright', legend=c("train", "test"),
       col=c("red", "blue"), lty=1, cex=1.5)

write.csv(train, file="data/dat_train.csv", row.names = FALSE)
write.csv(test, file="data/dat_test.csv", row.names = FALSE)
