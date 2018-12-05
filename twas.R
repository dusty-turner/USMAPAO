library(tidyverse)
library(lubridate)
# library(googlesheets)
library(rtweet)
library(rsconnect)

setwd("C:/Users/Dusty.Turner/Desktop/R Work/USMAPAO")

twit_path="~/.rtweet_token.rds"
# Twitter_tok<-readRDS("C:/Users/Nicholas/.rtweet_token1.rds") #Locate where your twitter token is stored
Twitter_tok<-readRDS(twit_path) #Locate where your twitter token is stored

# setwd("C:/Users/Nicholas/USMAPAO")

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

#### START RUNNING AT THIS LINE#######

# my_sheets <- gs_ls()
# USMAPAO = gs_title("USMAPAO")
# gsdata = gs_read(USMAPAO)

addtothisdf = read_csv("PAOTweets.csv")

# newtweets =
# addtothisdf %>% 
#   # mutate(time = mdy_hms(time)) %>% 
#   mutate(df = "old") %>% bind_rows(text_df %>% mutate(df = "new")) %>%
#   distinct(
#     # text,
#     time,
#     screenname,
#     # searchterm,
#     .keep_all = TRUE) %>% filter(df == "new") %>% select(-df)


added =
addtothisdf %>% 
  # mutate(time = mdy_hms(time)) %>% 
  bind_rows(text_df) %>%
  distinct(
    # text,
    time,
    screenname,
    # searchterm,
    .keep_all = TRUE)

write.csv(added,"PAOTweets.csv", row.names = FALSE)

# gs_add_row(ss = USMAPAO, ws = "Sheet1", input = newtweets)

df = data.frame(Sys.time())
write.csv(df,"junk.csv")

#Need to go into app.shiny.io and pull your account info with token and secret visible
#rsconnect::setAccountInfo(name='ltcclark',
#                          token='<>',
#                          secret='<>')
# # 
# rsconnect::setAccountInfo(name='dustyturner', 
#                           token='A581909F2A807449F6DCE921BAF74BF1', 
#                           secret='hcsi/Fgb3kVw/lMJtz8673fTc8N3UEF6pUkO9XeZ')

print("3")

rsconnect::setAccountInfo(name='westpointmath', 
                          token='21B8A56CD9B10976DB2A85BB8028FC62', 
                          secret='SJP0ZguEKltcVWy/3fuf/sbLG2wtWWZKd5/15Ot/')

print("4")


# deployApp(forceUpdate=TRUE, appName = "USMAPAO", account = "dustyturner", upload = FALSE)

rsconnect::deployApp(appDir = "C:/Users/Dusty.Turner/Desktop/R Work/USMAPAO",
                     # appFileManifest = "C:/Users/Dusty.Turner/AppData/Local/Temp/4/79be-7eb9-940c-f09b",
                     appPrimaryDoc = "USMAPAO.Rmd", 
                     appSourceDoc = "C:/Users/Dusty.Turner/Desktop/R Work/USMAPAO/USMAPAO.Rmd",      
                     account = "westpointmath", server = "shinyapps.io", appName = "USMAPAO",      
                     appId = 600635, 
                     launch.browser = function(url) {         message("Deployment completed: ", url)     },
                     lint = FALSE, 
                     metadata = list(asMultiple = FALSE, asStatic = FALSE),      
                     # logLevel = "verbose",
                     forceUpdate = TRUE) 
