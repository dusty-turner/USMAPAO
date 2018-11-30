library(tidyverse)
library(lubridate)
#library(googlesheets)
library(rtweet)
# twit_path="C:/Users/Dusty.Turner/Documents/.rtweet_token.rds"
# Twitter_tok<-readRDS("C:/Users/Nicholas/.rtweet_token1.rds") #Locate where your twitter token is stored
Twitter_tok<-readRDS(twit_path) #Locate where your twitter token is stored

# setwd("C:/Users/Nicholas/USMAPAO")
setwd("C:/Users/Dusty.Turner/Desktop/R Work/USMAPAO")

df = data.frame(Sys.time())
write.csv(df,"junk1.csv")

USMA <- search_tweets(
  "USMA", n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE,token=Twitter_tok) #Manually call the token
df = data.frame(Sys.time())
write.csv(df,"junk.csv")
