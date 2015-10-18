setwd('~/capstone')

library(jsonlite)
library(RJSONIO)
library(rjson)

## Source all required scripts.
# required_scripts <- c('fsi_ifs_functions.R','corpus.R')
# sapply(required_scripts, source, .GlobalEnv)


review <- stream_in(file('data/yelp_academic_dataset_review.json'))

business <- stream_in(file('data/yelp_academic_dataset_business.json'))

business.attributes <- business$attributes

tip <- stream_in(file('data/yelp_academic_dataset_tip.json'))

user <- stream_in(file('data/yelp_academic_dataset_user.json'))
