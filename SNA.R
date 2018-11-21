library(rtweet)
library(tidyverse)
library(tidytext)
library(lubridate)
library(sentimentr)
# install.packages("rtweet")

# ## whatever name you assigned to your created app
appname <- "RappDusty"
# 
# ## api key (example below is not a real key)
key <- "qUieRdpQjDpXbvbsvJR6upXRP"
# 
# ## api secret (example below is not a real key)
secret <- "bSexK8RvqCu7wAQqrrzSV7kPp8oySwxTisvdVGALBbZaDIKI3a"

token = "232263908-8JfnQTXlCnQzs0TiyJuLSB3rEl70B2CJvvPcpUvS"

secrettoken = 	"dHvdONwFo2XMyTL2UYPI2WRo7Dvp7hG5A9YFR3Vq0858B"


require(vosonSML)
require(magrittr)
myTwitterData <- Authenticate("twitter",
                              apiKey=key,
                              apiSecret=secret,
                              accessToken=token,
                              accessTokenSecret=secrettoken) %>%
  Collect(searchTerm='"West Point"', numTweets=500, writeToFile=FALSE, verbose=TRUE)

sent <- sentiment_by(myTwitterData$text)

myTwitterData$sentiment <- sent$ave_sentiment * 100



neg.tweets<-myTwitterData %>% filter(sentiment< -10)

most.neg<-neg.tweets %>% filter(sentiment==min(sentiment))

extract_sentiment_terms(most.neg$text)


pos.tweets<-myTwitterData %>% filter(sentiment >10) 

most.pos<-pos.tweets %>% filter(sentiment==max(sentiment))

pos.that.matter<-pos.tweets %>% filter(favoriteCount>10)
neg.that.matter<-neg.tweets %>% filter(favoriteCount>10)
extract_sentiment_terms(most.pos$text)


g_twitter_actor <- myTwitterData %>% Create("Actor")

g_twitter_semantic<-myTwitterData %>% Create("Semantic",removeTermsOrHashtags=c("usma","#usma"))

g_bimodal_twitter<-myTwitterData %>% Create("Bimodal",removeTermsOrHashtags=c("usma","#usma","West Point"),writeToFile=TRUE)

pageRank<-sort(page.rank(g_twitter_semantic)$vector,decreasing=TRUE)
head(pageRank,n=10)
