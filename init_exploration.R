setwd('~/capstone')

library(jsonlite)
library(RJSONIO)
library(rjson)
library(foreach)
library(doSNOW)

## Initialize clusters for multi-core processing
cl       <- makeCluster(4)
registerDoSNOW(cl)

## Source all required scripts.
required_scripts <- c('download.R')
sapply(required_scripts, source, .GlobalEnv)

## Download yelp dataset
url      <- "https://d396qusza40orc.cloudfront.net/
             dsscapstone/dataset/yelp_dataset_challenge_academic_dataset.zip"
url      <- strwrap(url, width=10000,simplify=T)
download(url)

## Get each json file into a data frame in global environment
paths    <- list.dirs(dir(pattern = 'data'))
data_dir <- paths[2]
jsons    <- list.files(data_dir,pattern = '\\.json$')

foreach(i=1:length(jsons)) %dopar% {
  library(jsonlite)
  
  path   <- paste(data_dir,jsons[i],sep='/')
  print(path)
  varname <-gsub('yelp\\_academic\\_dataset\\_',"",jsons[i])
  assign(varname,stream_in(file(path)))
}

stopCluster(cl)

###############
## What makes a good burger joint?
burger <- business[which(grepl('Burger',business$categories)),]



######################################################################
## Initial Exploration

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
burger_flat <- flatten(burger)
## Replace NAs with 0
cross [is.na(cross)] <- 0
burger_flat [is.na(burger_flat)] <- 0
## Run fisher.test on cross tabulation
results1  <- fisher.test(table(cross$fans >= 1, cross$votes.useful >= 1))
results2  <- fisher.test(table(cross$compliments.cute >= 1, cross$fans >= 1))
results3  <- fisher.test(table(burger_flat$stars >= 4.0, 
                               burger_flat$attributes.Ambience.hipster))

# aim to build a model that predicts the mean star rating of each of the ~3000
# medical professionals (doctors, dentists, therapists) in the data set. 
# Candidate predictors will include hours of operation, parking, specialization,
# review language indicating levels of administrative service, bedside manner, 
# and medical effectiveness, country, business size, and other factors. 
# I will attempt multivariate polynomial linear regression, splines, regression 
# trees in a random forest, (+ other algorithms I may explore) and ensemble solutions
# that combine models to maximize predictive accuracy. Focusing on medical 
# professionals reduces the heterogeneity of the dataset, and also spotlights 
# professionals that clients hesitate to review -- a spotlight that may help 
# understand how reviewers negociate this new and difficult public conversation. 

