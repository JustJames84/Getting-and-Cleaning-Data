library(dplyr)
#read in raw data files
testData <- read.table("./UCI HAR Dataset/test/X_test.txt")
testActivities <- read.table("./UCI HAR Dataset/test/y_test.txt")
testSubject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
trainingData <- read.table("./UCI HAR Dataset/train/X_train.txt")
trainingActivities <- read.table("./UCI HAR Dataset/train/y_train.txt")
trainingSubject <- read.table("./UCI HAR Dataset/train/subject_train.txt")
colNames <- read.table("./UCI HAR Dataset/features.txt", col.names = c("id", "feature"))
activityMapping <- read.table("./UCI HAR Dataset/activity_labels.txt", col.names = c("activityCode", "activityDesc"))

#combine data into one large dataframe
fullTestData <- cbind(testSubject, testActivities, testData)
fullTrainingData <- cbind(trainingSubject, trainingActivities, trainingData)
fullData <- rbind(fullTestData, fullTrainingData)
colnames(fullData) <- c("subjectID", "activityCode", as.character(colNames$feature))

#Extract only the measurements on the mean and standard deviation for each measurement
#features with names including "meanFreq()" are excluded, but any other features with "std()" or "mean()" in their names are included
relevantColumns <- c(1,2, grep("std\\()|mean\\()",colnames(fullData)))
fullData <- fullData[,relevantColumns]


#add a column for activity name based on value of activity code

fullData <- merge(fullData, activityMapping)

#summarize the data
groupedData <- group_by(fullData, subjectID, activityDesc)
summaryData <- summarise_at(groupedData, vars(2:67), mean )

#make column names more descriptive
colnames(summaryData)[3:68] <- paste("Mean of", colnames(summaryData[,c(3:68)]))

write.table(summaryData, file="FinalData.txt", row.names = FALSE)