## Script for Getting & Cleaning Data Course Project
## 
## Briefly, this script takes test subject smartphone data obtained during exercise from
## https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
## and outputs a tidy data set in .txt format containing the averages of the mean and 
## std measurements for each subject performing each exercise.
##
## See README.Rmd for a more in-depth explanation of what this script performs.
## See Codebook.Rmd for description of the variables (columns)

## Load dplyr library for later analysis
library(dplyr)

## Download & Open Files
## If files exist, do NOT overwrite, and suppress warnings
curr_dir <- getwd()
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("accdata.zip")) download.file(fileURL, "./accdata.zip")
suppressWarnings(unzip("accdata.zip",overwrite = FALSE))

## Grabbing column data from instructional files
setwd("./UCI HAR Dataset")
activity_labels <- read.table("activity_labels.txt")
features <- as.character(read.table("features.txt")[,2])

## Create Training Set
subject_train <- read.table("./train/subject_train.txt")
y_train <- read.table("./train/y_train.txt")
X_train <- read.table("./train/X_train.txt")
combined_train <- cbind(subject_train,y_train,X_train)
colnames(combined_train) <- c("subject_id","activity",features)

## Create Test Set
subject_test <- read.table("./test/subject_test.txt") 
y_test <- read.table("./test/y_test.txt")
X_test <- read.table("./test/X_test.txt")
combined_test <- cbind(subject_test,y_test,X_test)
colnames(combined_test) <- c("subject_id","activity",features)

## Merge Training & Test Sets
combined_sets <- rbind(combined_train,combined_test)

## Convert activity (currently numeric) to factor with descriptive activity names
combined_sets$activity <- factor(x=as.character(combined_sets$activity),
                                 levels=activity_labels$V1,labels=activity_labels$V2)

## Extract Measurements on mean & STD for each measurement
## Get indices for "mean" and "std" (including first 2 columns) using pattern.  Subset on these indices.
mean_std_sets <- combined_sets[,grepl(pattern="subject_id|activity|[Mm]ean|[Ss]td",
                                      colnames(combined_sets))]

## Rename column names to avoid problematic characters 
colnames(mean_std_sets) <- gsub(pattern = "\\()|-",replacement = "",colnames(mean_std_sets))                             

## Create data set with average (mean) of each variable for each activity and each subject using ddplyr
mean_std_sets <- tbl_df(mean_std_sets)
tidy_set <- mean_std_sets %>% group_by(subject_id, activity) %>% summarize_each(funs(mean))

## Output tidy data set to initial working directory as text file (overwite if file exists)
setwd(curr_dir)
write.table(x = tidy_set,file="tidy_set.txt",row.name=FALSE)