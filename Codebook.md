Getting and Cleaning Data Course Project
Accelerometer Data Prep and Summarization
========================================================

This R markdown document provides explanations of the steps required to obtain and prepare data from an accelerometer data set as fulfill for the student project required for the "Getting and Cleaning Data" course taught by Jeff Leek in April 2014.

Explanation of the files and data:

The source data files are all in .txt format and include two metadata files and three data files each for test and training, as follows:

activity_labels.txt     - associates activity codes to activity labels
features.txt            - descriptive labels for the 561 accelerometer variables

X_test.txt              - 2947 rows of observations in the test set
y_test.txt              - provides the activity code number for each test observation
subject_test.txt        - provides the subject (person tested) for each test observation

X_train.txt             - 7352 rows of observations in the training set
y_train.txt             - provides the activity code number for each training observation
subject_train.txt       - provides the subject (person tested) for each training observation


The scripts embedded in this document are fully self contained and include all actions required to set up a working environment in R, acquire and manipulate the data, and write an output file.

Overview of the Steps:

1) Set working directory, download and unpack raw zip file 
2) Merge the training and the test sets to create one data set
3) Create one data set with mean and std dev for each measurement 
4) Create an output data set with the average of each mean and std dev variable for each activity and each subject. 

Section 1: Set working directory, download and unpack raw data zip file 

You will first need to create a working directory and set your R session to that working directory:

```{r}
setwd("specify your desired working directory path here")    
```

Then, the following script will check to see if you already have the data set unzipped in your working directory, and if not the script will access the data set zip file and unzip it in your working directory under the subdirectory "/UCI HAR Dataset".  Once unzipped, the original zip file is removed to save disk space:

```{r}
if (file.exists("./UCI HAR Dataset"))  {
} else  {
  
tempFile <- tempfile()
filePath  <- file.path(getwd())
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",tempFile, mode = 'wb')

files <- unzip( tempFile , exdir = filePath )     # unpack zip file
file.remove(tempFile)                             # remove zip file

}
```
