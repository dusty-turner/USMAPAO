apikey<-"b89f391b2d4445e99d0e69f1184a0534"

library(rjson)
library(jsonlite)
library(dplyr)
library(sentimentr)
library(tidyverse)
library(RSelenium)
library(XML)
library(rvest)

term<-'"West+Point"'
key<-apikey

USMA.JSON<-fromJSON(paste0("https://newsapi.org/v2/everything?q=",term,"&apiKey=",key,sep=""))
article.df<-USMA.JSON$articles
article.df$source<-article.df$source$name

sent <- sentiment_by(article.df$content
)
article.df$sentiment <- sent$ave_sentiment * 100

neg.art<-article.df %>% filter(sentiment< -20)

pos.art<-article.df %>% filter(sentiment >10)


pos.art$source


most.pos<-post.art %>% filter(sentiment==max(sentiment))
most.neg<-neg.art %>% filter(sentiment==min(sentiment))
best.art<-most.pos$url

worst.art<-most.neg$url


rD <- rsDriver(browser = 'firefox', phantomver = NULL) 

remDr <- rD$client
remDr$open()


baseUrl <- best.art


#go to most positive article
remDr$navigate(baseUrl)


#go to most negative article

baseURL <- worst.art

remDr$navigate(baseURL)
remDr$close()
