Getting and Cleaning Data Course Project
========================================================
Accelerometer Data Prep and Summarization
--------------------------------------------------------


This document provides explanations of the steps required to obtain and prepare data from an accelerometer data set as fulfillment for the student project required for the "Getting and Cleaning Data" course taught by Jeff Leek in April 2014.  R scripts are included that execute each of the procedures described herein.

Explanation of the files and data:

The source data files are all in .txt format and include two metadata files plus three data files each for test and training, as follows:

File | Description
-----|-------------
activity_labels.txt         | associates activity codes to activity labels  
features.txt        | descriptive labels for the 561 accelerometer variables  
X_test.txt        | 2947 rows of observations in the test set  
y_test.txt        | provides the activity code number for each test observation  
subject_test.txt        | provides the subject (person tested) for each test observation  
X_train.txt         | 7352 rows of observations in the training set  
y_train.txt         | provides the activity code number for each training observation  
subject_train.txt         | provides the subject (person tested) for each training observation  

The scripts embedded in this document are fully self contained and include all actions required to set up a working environment in R, acquire and manipulate the data, and write an output file.

Overview of the Steps:

1. Set working directory, download and unpack raw zip file 
2. Merge the training and the test sets to create one data set
3. Create one data set with mean and std dev for each measurement 
4. Create an output data set with the average of each mean and std dev variable for each activity + subject combination. 

Section 1: Set working directory, download and unpack raw data zip file 
------------
You will first need to create a working directory and set your R session to that working directory:

```{r}
#  uncomment the following line and insert your working directory
#  setwd("specify your desired working directory path here")    
```

Then, the following script will check to see if you already have the data set unzipped in your working directory.  If not, the script will access the data set zip file from its website and unzip it in your working directory under the subdirectory "/UCI HAR Dataset".  Once unzipped, the original zip file is removed to save disk space:

```{r}
if (file.exists("./UCI HAR Dataset"))  {
} else  {
  
tempFile <- tempfile()
filePath  <- file.path(getwd())
urlPath <- paste("http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")
download.file(urlPath,tempFile, mode = 'wb')

files <- unzip( tempFile , exdir = filePath )     # unpack zip file
file.remove(tempFile)                             # remove zip file

}
```

Section 2: Merge the training and the test sets to create one data set
-------------
Most of the data manipulation occurs in this step and requires some detailed explanations which are provided throughout. The general theme is to parse the .txt source files and assemble them into an aggregated data frame, "totalDf".  This will then be used to create the summarized output called for in this project.

The first step is to parse the features.txt file and create a "features" character vector that can later be used to rename the column labels in the totalDf data frame.  The file is first opened and read:

```{r}

con <- file("./UCI HAR Dataset/features.txt", "rt")
features <- (readLines(con))
close(con)
```
Then, because the features have both a number and a text label, we loop through the features to trim off the number and spaces that precede the text label:

```{r}
for (i in 1:length(features))  {
  
  features[i] = gsub("^.* ","",features[i])   # trim feature number from label
  
}
```

Next, we manually create a simple [6,2] table that can be used later as a lookup to insert readable activity labels associated to each accelerometer observation.  The source file "activity_labels.txt" is a short, single line file that is faster to re-create manually than through regex and other manipulations:
```{r}
n <- c(1:6)
m <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")
activityLabels <- data.frame (activityCode = n, activityLabel = as.character(m), stringsAsFactors=FALSE)
```

For the next script section it is important to describe the layout of the data in the  lines for the "X_test.txt" and "X_train.txt" files.  These two files carry the majority of the data; each line is 8976 characters long made up of 561 variables in scientific notation with overall length of 16 characters per variable.  Separation is not consistent between the variables, as some are positive (2 spaces between) and some are negative (1 space between).  Consequently, this data needs to be parsed by character position.  The parsing is done column-wise so columns can be created and added to the data frame.  In the course of reading the variable values, they need to be converted to decimal notation.

To begin, we open the X_test.txt variable file:

```{r}
con <- file("./UCI HAR Dataset/test/X_test.txt", "rt")
testText <- (readLines(con))
close(con)
```
Then we create an empty data frame "testDf" and parse the variable data in "X_test.txt" column-wise with each column of variable values being added to "testDf" as the parsing of each column is completed.
```{r}
testDf <- data.frame(matrix(nrow = 2947, ncol = 561), stringsAsFactors=FALSE)  

begin = 1                 # initialize character position for begin variable value read
end = 16                  # initialize character position for end variable value read

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
```

Then 561 feature names are added to the testDf data frame using the "features" vector created earlier:
```{r}
colnames(testDf) <- features
```

Now we add the activity codes associated to each observation in the test set: 

```{r}
con <- file("./UCI HAR Dataset/test/y_test.txt", "rt")
testActivityCodes <- (readLines(con))
close(con)

testDf <- data.frame(testDf, activityCode = as.numeric(testActivityCodes))

```

And, since activity labels are more useful and readable than numeric codes, we add a column called "activity" and populate it with values by performing a lookup using the "activityLabels" lookup table created earlier.  

```{r}
addDummyCol=rep("NA",nrow(testDf))
testDf <- data.frame(testDf,activity=as.character(addDummyCol), stringsAsFactors=FALSE)


for (i in 1:nrow(testDf)) {
  
  n = as.factor(activityLabels[testDf[i,562],2])
  testDf[i,563]=as.character(n)   
  
} 
```

Next we open the test subject file and add a column to testDf to show the subject number associated to each row of accelerometer observations.

```{r}
con <- file("./UCI HAR Dataset/test/subject_test.txt", "rt")
testSubject <- (readLines(con))
close(con)

testDf <- data.frame(testDf,subject=as.character(testSubject), stringsAsFactors=FALSE)
```

This then completes the assembly of testDf data frame.  It has 2947 rows of observations and 564 columns of variables, 561 of which are numeric accelerometer measurements and the remaining three are identification variables for subject, activity label, and activity code.

The next section of script performs the same procedures as above applied to the training data set.  All steps are identical but the data set has more than twice the number of observations (nrow=7352)
```{r}
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
```
Finally, we are now ready to combine the testDf and trainDf datasets into one:
```{r}
totalDf <- rbind(testDf, trainDf)
```
Section 3: Create one data set with mean and standard deviation for each measurement  
----------
In this step, we first note that the raw accelerometer measurements were transformed by the authors of the data research into 17 types of transformed measures using a variety of methods.  To give an idea, five of them are:

Type | Description
----- | ---------
mean() | Mean value
std() | Standard deviation
mad() | Median absolute deviation 
max() | Largest value in array
min() | Smallest value in array

The assignment calls for selecting only the measures that are "mean" and "std dev" measures, which requires identifying and removing measures that do not have "mean" or "std" in the feature label. A vector is created that identifies columns to be removed, which is then accomplished as follows:
```{r}
meanFeatures <- grep("mean",features)
stdFeatures <- grep("std",features)
meanAndStdFeatures <-c(meanFeatures, stdFeatures)

keepColumns <- c(meanAndStdFeatures, 562:564)
trimDf = totalDf[,keepColumns]
```
Section 4: Create an output data set 
----------------
The project requirements state the output file should include the average of each mean and std dev variable for each activity and each subject. An expedient way to accomplish this that avoids iterative looping is to melt and recast the data as follows:

```{r}
trimDfMelt <- melt(trimDf,id=c(names(trimDf[,80:82])),measure.vars=c(names(trimDf[,1:79])))
subjectActivityMeans <- dcast(trimDfMelt, subject + activity ~ variable, mean)
```
Finally we sort the output by subject and activity and write it to a comma separated .txt file:
```{r}
sortedOutput <-arrange(subjectActivityMeans, as.numeric(subject), activity)

write.table(sortedOutput, file = "GettingCleaningDataProject.txt", sep = ",")

#    To read output file use: read.table("GettingCleaningDataProject.txt", sep = ",")
```
