setwd('~/capstone')

library(jsonlite)
library(RJSONIO)
library(rjson)

## Source all required scripts.
required_scripts <- c('download.R')
sapply(required_scripts, source, .GlobalEnv)

## Download yelp dataset
url      <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/yelp_dataset_challenge_academic_dataset.zip"
download(url)

## Get data directories
dirs     <- list.dirs(dir(pattern = 'data'))

## Get json files for analysis
jsons    <- list.files(dirs[2],pattern = '\\.json$')

## Read in review json file
review   <- stream_in(file('data/yelp_academic_dataset_review.json'))
## View row 1000 of review json
review[100,]

## Read in business meta json file
business <- stream_in(file('data/yelp_academic_dataset_business.json'))
## How many businesses are reported for having free wi-fi 
## (rounded to the nearest percentage point)?
prop.table(table(business$attributes$`Wi-Fi`))

## Read in tip json file
tip      <- stream_in(file('data/yelp_academic_dataset_tip.json'))
## View row 1000 of tip json
tip[1000,]

## Read in check-n json file
checkin  <- stream_in(file())

## Read in user json file
user     <- stream_in(file('data/yelp_academic_dataset_user.json'))
## Get user with complement votes for funny above 10k
fun_guy  <- user[which(user$compliments$funny >= 10000),]

## Flatten user data for cross tabulation
cross    <- flatten(user)
## Replace NAs with 0
cross [is.na(cross)] <- 0
## Run fisher.test on cross tabulation
results  <- fisher.test(table(cross$fans >= 1, cross$compliments.funny >= 1))


