apikey<-"b89f391b2d4445e99d0e69f1184a0534"

library(rjson)
library(jsonlite) 
library(dplyr)
library(sentimentr)
library(tidyverse)
library(RSelenium)
library(XML)
library(rvest)
#Enter Search Term 
term<-"USMA"  #Include Branch Night
key<-apikey

USMA.JSON<-fromJSON(paste0("https://newsapi.org/v2/everything?q=",term,"&from=2018-11-10&apiKey=",key,sep=""))
article.df<-USMA.JSON$articles
article.df$source<-article.df$source$name
#Classify sentiment of Articles
sent <- sentiment_by(article.df$content
)
article.df$sentiment <- sent$ave_sentiment * 100

neg.art<-article.df %>% filter(sentiment< -10)

pos.art<-article.df %>% filter(sentiment >10) 

#List of all news agencies writing good things about us
pos.art$source
pos.art$title
#List of all news agencies writing negative things about us
neg.art$source
neg.art$title
most.pos<-pos.art %>% filter(sentiment==max(sentiment))
most.neg<-neg.art %>% filter(sentiment==min(sentiment))
best.art<-most.pos$url[1]

worst.art<-most.neg$url[1]


rD <- rsDriver(browser = 'firefox', phantomver = NULL) 

remDr <- rD$client
remDr$open()


baseUrl <- best.art


#go to most positive article
remDr$navigate(baseUrl)
extract_sentiment_terms(most.pos$content)

#go to most negative article

baseURL <- worst.art[1]

remDr$navigate(baseURL)


#Close Remote access
remDr$close()
