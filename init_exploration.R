setwd('~/capstone')

library(jsonlite)
library(RJSONIO)
library(rjson)

## Source all required scripts.
# required_scripts <- c('fsi_ifs_functions.R','corpus.R')
# sapply(required_scripts, source, .GlobalEnv)

## Read in review json file
review <- stream_in(file('data/yelp_academic_dataset_review.json'))
## View row 1000 of review json
review[100,]

## Read in business meta json file
business <- stream_in(file('data/yelp_academic_dataset_business.json'))
## How many businesses are reported for having free wi-fi 
## (rounded to the nearest percentage point)?
prop.table(table(business$attributes$`Wi-Fi`))

## Read in tip json file
tip <- stream_in(file('data/yelp_academic_dataset_tip.json'))
## View row 1000 of tip json
tip[1000,]

## Read in user json file
user <- stream_in(file('data/yelp_academic_dataset_user.json'))
## Get user with complement votes for funny above 10k
funny_dude <- user[which(user$compliments$funny >= 10000),]

table(user[which(user$compliments$funny >= 1),],user[which(user$fans >= 1),])
