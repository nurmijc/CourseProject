#If not already downloaded, download UCI dataset
#download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "data/gettingdataproj1.zip", method = "curl")

#Set UCI dataset as working directory

#load library plyr and library data.table
library(data.table)
library(plyr)

####Create column names
#Get xTest and xTrain column names from features.txt
featureColumnNamesDF <- read.table("UCI HAR Dataset/features.txt")
#take second column and convert to lower case for text matching using grep
featureColumnNames <- featureColumnNamesDF[,2]
#Create a logical vector indicating what columns relate to mean or std
#I excluded "Angle" calculations that include mean since the angle calculation is not a mean calculation.
#I excluded "MeanFreq" because it is a seconday calculation off a primary calculation
#Make lower case after pulling mean and 
featureColumnNamesMeanStd <- grepl(("mean()|std()"),featureColumnNames)
#Create activity and subject column names for future use
activityColumnName <- "activity"
subjectColumnName <- "subject"

####Get activity labels for future substitution
activityLabelsDF <- read.table("UCI HAR Dataset/activity_labels.txt")

####Read and label the test set
xTest <- read.table("UCI HAR Dataset/test/X_test.txt")
#use lowercase column names for easier text manipulation
names(xTest) <- tolower(featureColumnNames)
xTestMeanStd <- xTest[,featureColumnNamesMeanStd]
yTestDF <- read.table("UCI HAR Dataset/test/Y_test.txt")
##Merge yTest with activity names using join() from plyr to preserve order.
yTestMerge <- join(yTestDF,activityLabelsDF,by = "V1",type="inner")
activity <- yTestMerge[,2]
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
names(subjectTest) <- subjectColumnName
testSet <- cbind(activity,subjectTest,xTestMeanStd)

#read and label training set
xTrain <- read.table("UCI HAR Dataset/train/X_train.txt")
#use lowercase column names for easier text manipulation
names(xTrain) <- tolower(featureColumnNames)
xTrainMeanStd <- xTrain[,featureColumnNamesMeanStd]
yTrainDF <- read.table("UCI HAR Dataset/train/Y_train.txt")
##Merge yTrain with activity names using join() from plyr to preserve order.
yTrainMerge <- join(yTrainDF,activityLabelsDF,by = "V1",type="inner")
activity <- yTrainMerge[,2]
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
names(subjectTrain) <- subjectColumnName
trainSet <- cbind(activity,subjectTrain,xTrainMeanStd)

#Combine datasets
superSet <- rbind(testSet,trainSet)

#Make column names clean
names(superSet) <- sub("bodybodyaccjerkmag-"," domain of body body jerk magnitude using accelerometer: ",names(superSet),)
names(superSet) <- sub("bodybodygyromag-"," domain of body body magnitude using gyroscope: ",names(superSet),)
names(superSet) <- sub("bodybodygyrojerkmag-"," domain of body body jerk magnitude using gyroscope: ",names(superSet),)
names(superSet) <- sub("bodyacc-"," domain of body using accelerometer: ",names(superSet),)
names(superSet) <- sub("gravityacc-"," domain of gravitaty force using accelerometer: ",names(superSet),)
names(superSet) <- sub("bodyaccjerk-"," domain of body jerk using accelerometer: ",names(superSet),)
names(superSet) <- sub("bodygyro-"," domain of body using gyroscope: ",names(superSet),)
names(superSet) <- sub("bodygyrojerk-"," domain of body jerk using gyroscope: ",names(superSet),)
names(superSet) <- sub("bodyaccmag-"," domain of body magnitude using accelerometer: ",names(superSet),)
names(superSet) <- sub("gravityaccmag-"," domain of gravity magnitude using accelerometer: ",names(superSet),)
names(superSet) <- sub("bodyaccjerkmag-"," domain of body jerk magnitude using accelerometer: ",names(superSet),)
names(superSet) <- sub("bodygyromag-"," domain of body magnitude using gyroscope: ",names(superSet),)
names(superSet) <- sub("bodygyrojerkmag-"," domain of body jerk magnitude using gyroscope: ",names(superSet),)
names(superSet) <- sub("t domain","Time domain",names(superSet),)
names(superSet) <- sub("f domain","Frequency domain",names(superSet),)
names(superSet) <- sub("\\(", "",names(superSet),)
names(superSet) <- sub("\\)", "",names(superSet),)
names(superSet) <- sub("meanfreq()","Mean Frequency of ",names(superSet),)
names(superSet) <- sub("mean()","Mean of ",names(superSet),)
names(superSet) <- sub("std()","Standard deviation of ",names(superSet),)
names(superSet) <- sub("-x","X-Axis",names(superSet),)
names(superSet) <- sub("-y","Y-Axis",names(superSet),)
names(superSet) <- sub("-z","Z-Axis",names(superSet),)

#Summarize tidy data
superSet.dt <- data.table(superSet)
keycols <- c("activity","subject")
setkeyv(superSet.dt, keycols)
superSet.dt.mean<-superSet.dt[,lapply(.SD,mean), by="subject"]

#Write tidy file to working directory
write.table(superSet.dt.mean, file = "tidySet.txt",row.name=FALSE)
