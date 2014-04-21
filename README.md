GetCleanDataProject
===================

This repository contains outputs submitted in fulfillment of a student project in "Getting and Cleaning Data" (Coursera - Jeff Leek instructor; April, 2014)

The submitted content includes an R script (run_analysis.R) and a codebook file (CodeBook.md) that describes the variables, the data, and work that was performed to transform the raw data into the output format specified in the project requirements.

About the data: cell phone accelerometer data was obtained by researchers (see credit below) who wanted to see if data analysis techniques could be used to determine which of six physical activities a subject was engaged in using only signals from cell phone accelerometers.  The accelerometer data made available by the researchers included raw measurements from the accelerometers and also 561 variables that were derived from the raw data and selected as inputs to the researchers' data models.  For this student project, I ignored the raw accelerometer data and used only the 561 variables selected by the researchers for their models.

About the run_analysis.R script: to run this script successfully you must first create a working directory and set your working directory for your R session accordingly: setwd("your working directory here").  The first section of the script will check to see if the required data has been unzipped into your working directory, and if not it will download the source data file and unzip it in your working directory.  When this is complete you should see a subdirectory named "UCI HAR Dataset" in your working directory.  Refer to the Codebook.md file for functional details on how the R script works.

Credits for the data source: Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
