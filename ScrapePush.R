library(tidyverse)
library(lubridate)
library(googlesheets)
library(rtweet)
library(rsconnect)
setwd("C:/Users/Nicholas/USMAPAO")


Twitter_tok<-readRDS("~/.rtweet_token1.rds") #Locate where your twitter token is stored

df = data.frame(Sys.time())
write.csv(df,"junk1.csv")

USMA <- search_tweets(
  "USMA", n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE,token=Twitter_tok) #Manually call the token

WestPoint <- search_tweets(
  '"West Point"', n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE,token=Twitter_tok) #Manually call the token

USNA <- search_tweets(
  "USNA", n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE,token=Twitter_tok) #Manually call the token

USNavalA <- search_tweets(
  '"Naval Academy"', n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE,token=Twitter_tok) #Manually call the token

USAFA <- search_tweets(
  "USAFA", n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE,token=Twitter_tok) #Manually call the token

AFA <- search_tweets(
  '"Air Force Academy"', n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE,token=Twitter_tok) #Manually call the token

usma <- data_frame(line = 1:length(USMA$text),
                   text = as.character(USMA$text),
                   screenname = USMA$screen_name,
                   time = USMA$created_at,
                   searchterm = "USMA",
                   coords = USMA$coords_coords,
                   location = USMA$location,
                   followerscount = USMA$followers_count,
                   favoritescount = USMA$favorite_count)

wp <- data_frame(line = 1:length(WestPoint$text),
                 text = as.character(WestPoint$text),
                 screenname = WestPoint$screen_name,
                 time = WestPoint$created_at,
                 searchterm = "WestPoint",
                 coords = WestPoint$coords_coords,
                 location = WestPoint$location,
                 followerscount = WestPoint$followers_count,
                 favoritescount = WestPoint$favorite_count)

usna <- data_frame(line = 1:length(USNA$text),
                   text = as.character(USNA$text),
                   screenname = USNA$screen_name,
                   time = USNA$created_at,
                   searchterm = "USNA",
                   coords = USNA$coords_coords,
                   location = USNA$location,
                   followerscount = USNA$followers_count,
                   favoritescount = USNA$favorite_count)

naval <- data_frame(line = 1:length(USNavalA$text),
                    text = as.character(USNavalA$text),
                    screenname = USNavalA$screen_name,
                    time = USNavalA$created_at,
                    searchterm = "Naval Academy",
                    coords = USNavalA$coords_coords,
                    location = USNavalA$location,
                    followerscount = USNavalA$followers_count,
                    favoritescount = USNavalA$favorite_count)

usafa <- data_frame(line = 1:length(USAFA$text),
                    text = as.character(USAFA$text),
                    screenname = USAFA$screen_name,
                    time = USAFA$created_at,
                    searchterm = "USAFA",
                    coords = USAFA$coords_coords,
                    location = USAFA$location,
                    followerscount = USAFA$followers_count,
                    favoritescount = USAFA$favorite_count)

usaf <- data_frame(line = 1:length(AFA$text),
                   text = as.character(AFA$text),
                   screenname = AFA$screen_name,
                   time = AFA$created_at,
                   searchterm = "Air Force Academy",
                   coords = AFA$coords_coords,
                   location = AFA$location,
                   followerscount = AFA$followers_count,
                   favoritescount = AFA$favorite_count)

text_df = bind_rows(usma,wp,usna,naval,usaf,usafa) %>%
  lat_lng(coords = "coords") %>% select(-coords)

addtothisdf = read_csv("PAOTweets.csv")

mostrecenttweets = text_df %>% mutate(id = "new") %>%
  bind_rows(addtothisdf %>% mutate(id = "old")) %>% 
  group_by(screenname,time) %>% 
  arrange(desc(time)) %>%
  filter(n()>1) %>% 
  arrange(desc(favoritescount)) %>%
  filter(id == "new") %>%
  select(-id) %>% ungroup()

 
oldtweets = text_df %>% bind_rows(addtothisdf) %>%
  group_by(screenname,time) %>%
  filter(n()==1) %>% ungroup()

added = oldtweets %>% bind_rows(mostrecenttweets) 

write.csv(added,"PAOTweets.csv", row.names = FALSE)

df = data.frame(Sys.time())
write.csv(df,"junk.csv")

rsconnect::setAccountInfo(name='westpointmath', 
                          token='3E00B8DCBC70358D386EE10322E6374C', 
                          secret='i+sifq41K7/Ohd4lTxukuMe+jftXNpfmIYdtUVZa')

deployApp(forceUpdate=TRUE,launch.browser=TRUE)
