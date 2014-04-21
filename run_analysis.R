################################################################################
#
#   Getting and Cleaning Data Project
#
#   R Script Summary: this script creates a working directory, downloads and 
#   unpacks a zip file containing accelerometer data files, then combines 
#   and manipulates the data files to create output data sets as specified 
#   in the "Getting and Cleaning Data Project" 
#
#   The script has four sections: 
#   1) Set working directory, download and unpack raw zip file 
#   2) Merge the training and the test sets to create one data set
#   3) Create one data set with mean and std dev for each measurement 
#   4) Create an output data set with the average of each mean and std dev
#      variable for each activity and each subject. 
#     
################################################################################

################################################################################
#
#   1) Set working directory, download and unpack raw zip file (as needed)
#     
################################################################################

#   setwd("put your desired working directory path here")    # uncomment & use as needed

#   If zip file has not been unpacked into "UCI HAR Dataset"
#   subdirectory, create temporary file and directory path and 
#   download accelerometer data zip file; if the data is already
#   unpacked it should be found under the working directory in
#   the subdirectory: /UCI HAR Dataset

if (file.exists("./UCI HAR Dataset"))  {
} else  {
  
tempFile <- tempfile()
filePath  <- file.path(getwd())
download.file("http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",tempFile, mode = 'wb')

files <- unzip( tempFile , exdir = filePath )     # unpack zip file
file.remove(tempFile)                             # remove zip file

}

################################################################################
#
#   2) Merge the training and the test sets to create one data set
#
#      Preparatory subtasks include: parse features labels and create 
#      activity labels table; then parse test and train variable files 
#      along with their associated subjects files to build data frames
#     
################################################################################

#    Parse features.txt file; create "features" character vector

con <- file("./UCI HAR Dataset/features.txt", "rt")
features <- (readLines(con))
close(con)

for (i in 1:length(features))  {
  
  features[i] = gsub("^.* ","",features[i])   # trim feature number from label
  
}

#    Manually create activityLabels data frame

n <- c(1:6)
m <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")
activityLabels <- data.frame (activityCode = n, activityLabel = as.character(m), stringsAsFactors=FALSE)

#    Open test variable file and parse by loops to extract variable columns

con <- file("./UCI HAR Dataset/test/X_test.txt", "rt")
testText <- (readLines(con))
close(con)

testDf <- data.frame(matrix(nrow = 2947, ncol = 561), stringsAsFactors=FALSE)  # initialize empty data frame for output

begin = 1               # initialize character position for begin variable value read
end = 16                # initialize character position for end variable value read

for (i in 1:561)  {
  
  buildVector <- c()      # initialize vector to contain variable values
  
for (j in 1:2947) {
  
  valueRead = as.numeric(substr(testText[j], start=begin, stop=end))

  buildVector <- c(buildVector, valueRead) 

}

testDf[,i] <- buildVector

begin = begin + 16
end = end + 16

}

#   Add feature names to test data frame

colnames(testDf) <- features

#   Add activity codes to test data frame 

con <- file("./UCI HAR Dataset/test/y_test.txt", "rt")
testActivityCodes <- (readLines(con))
close(con)

testDf <- data.frame(testDf, activityCode = as.numeric(testActivityCodes))

#   Add activity label column corresponding to activity codes

addDummyCol=rep("NA",nrow(testDf))
testDf <- data.frame(testDf,activity=as.character(addDummyCol), stringsAsFactors=FALSE)


for (i in 1:nrow(testDf)) {
  
  n = as.factor(activityLabels[testDf[i,562],2])
  testDf[i,563]=as.character(n)   
  
} 

#   Add subject column for each observation

con <- file("./UCI HAR Dataset/test/subject_test.txt", "rt")
testSubject <- (readLines(con))
close(con)

testDf <- data.frame(testDf,subject=as.character(testSubject), stringsAsFactors=FALSE)

   ##########################################################
   #                                                        #
   #      Adapt procedures above to build trainDf           #
   #                                                        #
   ##########################################################

#    Open test variable file and parse by loops to extract variable columns

con <- file("./UCI HAR Dataset/train/X_train.txt", "rt")
trainText <- (readLines(con))
close(con)

trainDf <- data.frame(matrix(nrow = 7352, ncol = 561), stringsAsFactors=FALSE)  # initialize empty data frame for output

begin = 1               # initialize character position for begin variable value read
end = 16                # initialize character position for end variable value read

for (i in 1:561)  {
  
  buildVector <- c()      # initialize vector to contain variable values
  
  for (j in 1:7352) {
    
    valueRead = as.numeric(substr(trainText[j], start=begin, stop=end))
    
    buildVector <- c(buildVector, valueRead) 
    
  }
  
  trainDf[,i] <- buildVector
  
  begin = begin + 16
  end = end + 16
  
}

#   Add feature names to train data frame

colnames(trainDf) <- features

#   Add activity codes to train data frame 

con <- file("./UCI HAR Dataset/train/y_train.txt", "rt")
trainActivityCodes <- (readLines(con))
close(con)

trainDf <- data.frame(trainDf, activityCode = as.numeric(trainActivityCodes))

#   Add activity label column corresponding to activity codes

addDummyCol=rep("NA",nrow(trainDf))
trainDf <- data.frame(trainDf,activity=as.character(addDummyCol), stringsAsFactors=FALSE)


for (i in 1:nrow(trainDf)) {
  
  n = as.factor(activityLabels[trainDf[i,562],2])
  trainDf[i,563]=as.character(n)   
  
} 

#   Add subject column for each observation

con <- file("./UCI HAR Dataset/train/subject_train.txt", "rt")
trainSubject <- (readLines(con))
close(con)

trainDf <- data.frame(trainDf,subject=as.character(trainSubject), stringsAsFactors=FALSE)

#   Combine tesDf and trainDf datasets into one

totalDf <- rbind(testDf, trainDf)

################################################################################
#
#   3) Create one data set with mean and standard deviation for each measurement  
#     
################################################################################

meanFeatures <- grep("mean",features)
stdFeatures <- grep("std",features)
meanAndStdFeatures <-c(meanFeatures, stdFeatures)

keepColumns <- c(meanAndStdFeatures, 562:564)
trimDf = totalDf[,keepColumns]

################################################################################
#
#   4) Create an output data set with the average of each mean and std dev
#      variable for each activity and each subject. 
#     
################################################################################

#    Melt and recast data summarizing the variable means

trimDfMelt <- melt(trimDf,id=c(names(trimDf[,80:82])),measure.vars=c(names(trimDf[,1:79])))
subjectActivityMeans <- dcast(trimDfMelt, subject + activity ~ variable, mean)

#    Sort output by subject and activity

sortedOutput <-arrange(subjectActivityMeans, as.numeric(subject), activity)

#    Output data frame as .txt file with separators = commas

write.table(sortedOutput, file = "GettingCleaningDataProject.txt", sep = ",")

#    To read output file use: read.table("GettingCleaningDataProject.txt", sep = ",")
