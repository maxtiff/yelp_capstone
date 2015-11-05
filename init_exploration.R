setwd('~/capstone')

require(jsonlite)
require(RJSONIO)
require(rjson)
require(foreach)
require(doSNOW)
require(tm)
require(wordcloud)
require(RColorBrewer)
require(ggplot2)

## Initialize clusters for multi-core processing
cl       <- makeCluster(4)
registerDoSNOW(cl)

## Source all required scripts.
required_scripts <- c('download.R')
sapply(required_scripts, source, .GlobalEnv)

## Download yelp dataset
url      <- "https://d396qusza40orc.cloudfront.net/
             dsscapstone/dataset/yelp_dataset_challenge_academic_dataset.zip"
url      <- gsub(pattern='\\s',replacement="",x=url)
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

positive       = read.delim('positive-words.txt', skip=33)
negative       = read.delim('negative-words.txt', skip=33)

###############
## What makes a good burger joint?
burger         = business[which(grepl('Burger',business$categories)),]
burger_flat    = flatten(burger)
## Replace NAs with 0
burger_flat [is.na(burger_flat)]  =0

regex_string   = 'hours\\.\\w+day\\.\\w+|
                  attributes\\.Music\\.\\w+|
                  attributes\\.Hair Types Specialized In\\.\\w+|
                  attributes\\.Dietary Restrictions\\.\\w+'

regex_string   =  gsub(pattern='\\s',replacement="",x=regex_string)

burger_flat    = as.data.frame(burger_flat[which(!grepl(regex_string,
                                                      colnames(burger_flat)))])

drops          = c('type',
                   'latitude',
                   'longitude',
                   'full_address',
                   'open',
                   'neighborhoods',
                   'attributes.By Appointment Only',
                   'attributes.Good For Dancing',
                   'attributes.Coat Check',
                   'attributes.Smoking',
                   'attributes.Caters',
                   'attributes.Dogs Allowed',
                   'attributes.Accepts Insurance',
                   'attributes.Ages Allowed')

burger_flat    = burger_flat[,!(names(burger_flat) %in% drops)]


# Subset review data by business ids from burger_flat subset
burger_ids     = as.list(burger_flat$business_id)
review_flat    = as.data.frame(flatten(review))
burger_review  = review_flat[review_flat$business_id %in% burger_ids,]

# Merge restaurant and review data
merged         = merge(burger_review, burger_flat, by ='business_id')

# Subset tip data by business ids from burger_flat subset
tip_flat       = as.data.frame(flatten(tip))
burger_tip     = tip_flat[tip_flat$business_id %in% burger_ids,]

# Subset user data by users who have reviewed burger spots to check for
# sham reviewers
review_users   = as.list(unique(burger_review$user_id))
user_flat      = flatten(user)
user_flat      = user_flat[user_flat$user_id %in% review_users,]

# Review corpus for sentiment analysis
vs       = VectorSource(merged$text)
myCorpus = VCorpus(vs)
myCorpus = tm_map(myCorpus, content_transformer(tolower))
myCorpus = tm_map(myCorpus, removePunctuation)
myCorpus = tm_map(myCorpus, removeNumbers)
myCorpus = tm_map(myCorpus, function(x) removeWords(x, stopwords("english")))
myCorpus = tm_map(myCorpus, stemDocument)

# Create word cloud
c_tdm    = TermDocumentMatrix(myCorpus)
c_tdm    = rollup(c_tdm, 2, na.rm=TRUE, FUN = sum)
c_tdm.m  = as.matrix(c_tdm)
c_tdm.v  = sort(rowSums(c_tdm.m),decreasing=TRUE)
c_tdm.d  = data.frame(word = names(c_tdm.v),freq=c_tdm.v)
table(c_tdm.d$freq)
pal2 = brewer.pal(8,"Dark2")
png("wordcloud_packages.png", width=1280,height=800)
wordcloud(c_tdm.d$word,c_tdm.d$freq, scale=c(8,.2),min.freq=3,
          max.words=Inf, random.order=FALSE, rot.per=.15, colors=pal2)
dev.off()



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
checkin  <- stream_in(file('data/yelp_academic_dataset_checkin.json'))

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

