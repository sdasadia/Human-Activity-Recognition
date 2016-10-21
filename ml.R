# Cleaning a Tidy Data set. This code assumes that you have already download dataset in your present working directory. 

# Read data

features <- read.table("features.txt")
activityLabels <- read.table("activity_labels.txt")

subjectTrain <- read.table("subject_train.txt")
xTrain <- read.table("X_train.txt")
yTrain <- read.table("y_train.txt")

subjectTest <- read.table("subject_test.txt")
xTest <- read.table("X_test.txt")
yTest <- read.table("y_test.txt")

# Assign Column Names

colnames(activityLabels)  = c('activityId','activityType')

colnames(subjectTrain)  = "subjectId"
colnames(xTrain) = features[,2]
colnames(yTrain) = "activityId"

colnames(subjectTest)  = "subjectId"
colnames(xTest) = features[,2]
colnames(yTest) = "activityId"

# Combine Data sets

trainingData = cbind(yTrain,subjectTrain,xTrain)
testData = cbind(yTest,subjectTest,xTest)


# Extract only the measurements on the mean and standard deviation for each measurement

colNames  = colnames(trainingData)
vector <- grepl("activity..",colNames) | grepl("subject..",colNames) | grepl("..mean..",colNames)  | grepl("..sd..",colNames) 

trainingData = trainingData[vector == TRUE]
testData = testData[vector == TRUE]

# Uses descriptive activity names to name the activities in the data set

trainingData = merge(trainingData,activityLabels,by='activityId',all.x=TRUE)
testData = merge(testData,activityLabels,by='activityId',all.x=TRUE)

colNames  = colnames(trainingData)

# Appropriately labels the data set with descriptive variable names

colnames(trainingData) <- gsub("^t","time", colnames(trainingData))
colnames(trainingData) <- gsub("^f","frequency", colnames(trainingData))
colnames(trainingData) <- gsub("^Acc","Accelerometer", colnames(trainingData))
colnames(trainingData) <- gsub("Gyro", "Gyroscope", colnames(trainingData))
colnames(trainingData) <- gsub("Mag", "Magnitude", colnames(trainingData))
colnames(trainingData) <- gsub("BodyBody", "Body", colnames(trainingData))
colnames(trainingData) <- gsub("\\()", "", colnames(trainingData))
colnames(trainingData) <- gsub("-std$", "StdDev", colnames(trainingData))
colnames(trainingData) <- gsub("mean", "Mean", colnames(trainingData))
colnames(trainingData) <- gsub("[Gg]ravity)","Gravity", colnames(trainingData))
colnames(trainingData) <- gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body", colnames(trainingData))
colnames(trainingData) <- gsub("\\-", "", colnames(trainingData))



colnames(testData) <- gsub("^t","time", colnames(testData))
colnames(testData) <- gsub("^f","frequency", colnames(testData))
colnames(testData) <- gsub("^Acc","Accelerometer", colnames(testData))
colnames(testData) <- gsub("Gyro", "Gyroscope", colnames(testData))
colnames(testData) <- gsub("Mag", "Magnitude", colnames(testData))
colnames(testData) <- gsub("BodyBody", "Body", colnames(testData))
colnames(testData) <- gsub("\\()", "", colnames(testData))
colnames(testData) <- gsub("-std$", "StdDev", colnames(testData))
colnames(testData) <- gsub("-mean", "Mean", colnames(testData))
colnames(testData) <- gsub("[Gg]ravity)","Gravity", colnames(testData))
colnames(testData) <- gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body", colnames(testData))
colnames(testData) <- gsub("\\-", "", colnames(testData))


# Check Dimensions

dim(trainingData)
dim(testData)

table(trainingData$activityType)

# For Machine Leaning, we ignore first two colmns (activityId, subjectId)

trainingData <- trainingData[,-c(1,2)]
testData <- testData[,-c(1,2)]

# Load necessary packes 

library(caret)
library(randomForest)
library(rattle)
library(class)
library(gmodels)

M <- abs(cor(trainingData[,-47]))
diag(M) <- 0
nrow(which(M > 0.8, arr.ind=T))


preProc <- preProcess(trainingData[,-47], method ="pca", pcaComp = 40)
trainPC <- predict(preProc,trainingData[,-47]) # Apply preProc to training data
testPC <- predict(preProc,testData[,-47])


modelrf <- randomForest(trainingData$activityType ~.,data = trainPC)
confusionMatrix(testData$activityType, predict(modelrf, testPC))

# ~90% accuracy

modelknn <- knn(trainingData[,-47],testData[,-47],cl = trainingData$activityType, k =6)
#CrossTable(x = testData$activityType, y = modelknn, prop.chisq = F)
table(modelknn,testData$activityType)


