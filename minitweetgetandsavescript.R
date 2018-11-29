library(tidyverse)
library(lubridate)
#library(googlesheets)
library(rtweet)

Twitter_tok<-readRDS("C:/Users/Nicholas/.rtweet_token1.rds") #Locate where your twitter token is stored

setwd("C:/Users/Nicholas/USMAPAO")

df = data.frame(Sys.time())
write.csv(df,"junk1.csv")

USMA <- search_tweets(
  "USMA", n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE,token=Twitter_tok
) #Manually call the token
df = data.frame(Sys.time())
write.csv(df,"junk.csv")
