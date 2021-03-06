#devtools::install_github("mkearney/rtweet")
#Test to check connectivityasdf 
library(rtweet)
library(tidyverse)
library(tidytext)
library(lubridate)
library(igraph)

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
## create token named "twitter_token"
twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret)

USMA <- search_tweets(
  "USMA", n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE
)
WestPoint <- search_tweets(
  '"West Point"', n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE
)

USNA <- search_tweets(
  "USNA", n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE
)
USNavalA <- search_tweets(
  '"Naval Academy"', n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE
)
USAFA <- search_tweets(
  "USAFA", n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE
)
AFA <- search_tweets(
  '"Air Force Academy"', n = 18000/2, include_rts = FALSE, retryonratelimit = FALSE
)

WestPoint %>%
  filter(!is.na(quoted_followers_count)) %>%
  as.data.frame() %>%
  filter(row_number()==c(1:10))
names(USMA)



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

addtothisdf = read_csv("PAOTweets.csv")
# for_gs <- gs_title("USMAPAO")
# addtothisdf <- gs_read(for_gs)

added =
  text_df %>% bind_rows(addtothisdf) %>%
  distinct( 
           # text, 
           time,
           screenname, 
           # searchterm,
           .keep_all = TRUE)


# gs_edit_cells(for_gs, ws = "Sheet1", anchor = "A1", input = addtothisdf, byrow = FALSE, trim = TRUE)

write.csv(added,"PAOTweets.csv", row.names = FALSE)
# write.csv(addtothisdf,"PAOTweetsbackup.csv", row.names = FALSE)
unique(added$searchterm)

############# try maps

library(leaflet)

added %>% 
  filter(!is.na(lat)) %>%
  leaflet() %>% setView(-100, 40, zoom = 4) %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(~lng,~lat,popup = ~as.character(screenname), label = ~as.character(text), clusterOptions = markerClusterOptions())



############## start doing analysis


textcleaned = added %>%
  unnest_tokens(word, text)

cleanedarticle = anti_join(textcleaned,stop_words, by = "word") %>% select(line,word,screenname,time,followerscount,favoritescount, searchterm)
# dropwords = data.frame(word = as.character(c("https","trump")))
# cleanedarticle = anti_join(cleanedarticle,dropwords, by = "word")

####################
# Insites To Present
####################

### Sentiment by Day
cleanedarticle %>%
  full_join(get_sentiments("nrc"), by = "word") %>% 
  filter(searchterm == "USMA" | searchterm == "West Point") %>%
  # select(-c(location,lat,lng,coords_coords,bbox_coords,geo_coords)) %>%
  filter(complete.cases(.)) %>%
  filter(sentiment=="positive" | sentiment == "negative") %>%
  mutate(time = floor_date(time, unit = "day")) %>%
  mutate(dayofweek = weekdays(time)) %>%
  ggplot(aes(sentiment, fill = sentiment)) +
  geom_bar() +
  # facet_grid(~time)
  facet_wrap(time~dayofweek, ncol = 7) +
  labs(title = "Total Sentiment over Time", xlab = "Sentiment Type", ylab = "Number of Words with Sentiment")



### On Sunday, who was the most influential negative tweater
cleanedarticle %>%
  full_join(get_sentiments("nrc"), by = "word") %>%
  # select(-c(location,lat,lng,coords_coords,bbox_coords,geo_coords)) %>%
  filter(complete.cases(.)) %>%
  filter(sentiment=="positive" | sentiment == "negative") %>%
  mutate(time = floor_date(time, unit = "day")) %>%
  mutate(dayofweek = weekdays(time)) %>%
  # filter(as.character(time)=="2018-11-04") %>%
  arrange(desc(followerscount)) %>%
  group_by(screenname,sentiment) %>%
  mutate(total = n()) %>%
  distinct(screenname,sentiment, followerscount,favoritescount,total) %>%
  # filter(sentiment=="negative") %>%
  ungroup() %>%
  mutate(total = ifelse(sentiment=="negative",total*-1,total)) %>%
  group_by(screenname) %>%
  summarise(FollowersCount = max(followerscount), FavoritesCount = max(favoritescount), Total = sum(total), Total_Sentament_Words = sum(abs(total))) %>%
  arrange(desc(Total)) 


added %>%
  mutate(time = floor_date(time, unit = "day")) %>%
  mutate(dayofweek = weekdays(time)) %>%
  # filter(time <= input$dateRange[2]) %>%
  # filter(time >= input$dateRange[1]) %>%
  select(screenname, text, time)

# Who is this twitter user 
negexample = added %>% filter(screenname=="OnMontagueSt") %>% select(text)
negexample = added %>% filter(screenname=="WestPoint_USMA") %>% select(text,favoritescount) %>% filter(favoritescount==387)
  
negexample$text

#### Now, back to normal
cleanedarticle %>%
  full_join(get_sentiments("nrc"), by = "word") %>%
  filter(complete.cases(.)) %>%
  filter(sentiment=="positive" | sentiment == "negative") %>%
  mutate(time = floor_date(time, unit = "day")) %>%
  mutate(dayofweek = weekdays(time)) %>%
  filter(as.character(time)=="2018-11-06") %>%
  arrange(desc(followerscount)) %>%
  group_by(screenname,sentiment) %>%
  mutate(total = n()) %>%
  distinct(screenname,sentiment, followerscount,favoritescount,total) %>%
  arrange(desc(favoritescount)) 

example1 = added %>% filter(screenname=="marcorubio") %>% select(text) 
example1$text

example2 = added %>% filter(screenname=="ReaganBattalion") %>% select(text) 
example2$text

example2 = added %>% filter(screenname=="VP") %>% select(text) 
example2$text

### Common Words
cleanedarticle %>%
  full_join(get_sentiments("nrc"), by = "word") %>%
  filter(complete.cases(.)) %>%
  filter(sentiment=="positive" | sentiment == "negative") %>%
  mutate(time = floor_date(time, unit = "day")) %>%
  mutate(dayofweek = weekdays(time)) %>%
  group_by(word,sentiment) %>%
  summarise(n=n()) %>%
  arrange(desc(n))
  
### Common Word Pairs
added %>% select(-c(location,lat,lng,coords_coords,bbox_coords,geo_coords)) %>% 
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  group_by(bigram) %>%
  summarise(n=n()) %>%
  arrange(desc(n))


#### -- Bigram Look

austen_bigrams <- added %>% select(-c(location,lat,lng,coords_coords,bbox_coords,geo_coords)) %>% 
  unnest_tokens(bigram, text, token = "ngrams", n = 2)

bigrams_separated <- austen_bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")

bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  filter(!word1 %in% c("https")) %>%
  filter(!word2 %in% c("https")) 

# new bigram counts:
bigram_counts <- bigrams_filtered %>% 
  count(word1, word2, sort = TRUE)

bigram_counts

bigrams_united <- bigrams_filtered %>%
  unite(bigram, word1, word2, sep = " ")

bigrams_united %>% 
  group_by(bigram) %>%
  mutate(n = n()) %>%
  filter(n()>50) %>%
  ggplot(aes(x=fct_reorder(bigram, n))) +
  geom_bar() +
  # theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  coord_flip() +
  labs(title = "Popular Word Pairs in Tweets", x = "Content", y = "Bigram Count")

#### Sentiment chagne over time
cleanedarticle$searchterm %>% unique()

cleanedarticle %>% 
  mutate(Academy = case_when(searchterm=="USMA" ~ "West Point",
                             searchterm=="WestPoint" ~ "West Point",
                             searchterm=="USNA" ~ "Navy",
                             searchterm=="United States NAval Academy" ~ "Navy",
                             searchterm=="Air Force Academy" ~ "Air Force",
                             searchterm=="USAFA" ~ "Air Force")) %>%
  full_join(get_sentiments("nrc"), by = "word") %>%
  filter(complete.cases(.)) %>%
  filter(sentiment=="positive" | sentiment == "negative") %>%
  mutate(time = floor_date(time, unit = "day")) %>%
  mutate(score = ifelse(sentiment=="positive",1,-1)) %>%
  group_by(time, Academy) %>%
  summarise(dayscore = sum(score)/sum(abs(score))) %>%
  ggplot(aes(time,dayscore, color = Academy)) +
  geom_smooth() +
  # geom_line() +
  theme(legend.position = "bottom") +
  labs(title = "Reputation Heartbeat", x = "Date", y = "Sentiment Score")  



####Creating a Network of Neg. Tweeters########  

#Select the Neg Tweets and count them by user
Neg.Tweets=cleanedarticle%>%
  full_join(get_sentiments("nrc"), by = "word") %>%
  filter(complete.cases(.))%>%
  filter(sentiment=="negative")%>%
  group_by(screenname)%>%
  summarise(Total.Neg = n())%>%
  arrange(desc(Total.Neg))



#Find the n biggest frequency

n=20

Biggest.Neg=Neg.Tweets%>%
  slice(1:n)%>%
  select(screenname)

g.DF=NULL

for(i in 1:n){
  
  #remove first name from list
  name = Biggest.Neg[i,1]%>%
    as.character()
  
  #get the followers
  Neg.Followers=name%>%
    get_followers()%>%
    slice(1:n)
  
  if(length(Neg.Followers)>0){
    
    #get the screen names of followers
    Screen.Names=lookup_users(Neg.Followers$user_id)%>%
      select(screen_name,followers_count)
    
    #add them to the dataframe
    df=Screen.Names%>%
      mutate(Name = name)%>%
      select(Name,screen_name,followers_count)%>%
      as.data.frame()
    
    #keep a frame
    g.DF = rbind(g.DF,df)
    
  }
  else{
    
    Screen.Names = NULL
    
  }
  
  
}

#Plot Graph
g<-graph.data.frame(g.DF,directed = F)
plot(g)

#Make adjaceny matrix
adj.mat=get.adjacency(g)%>%
  as.matrix()%>%
  as.tibble()

#calculate eigenvector centrality
Eigen.Centrality = eigen_centrality(g)

##############
library(sentimentr)

added2 = added %>%
mutate(text = iconv(text, "UTF-8", "UTF-8",sub='')) 

senttest = get_sentences(added2$text)
scores_by = sentiment_by(senttest)

added3 = added2 %>%
  mutate(polaritysent = scores_by$ave_sentiment) %>%
  select(-lat,-lng,-coords_coords,-bbox_coords,-geo_coords) 
  # arrange((polaritysent))

added3 %>% select(-line,-location) %>%
  mutate(time = floor_date(time, unit = "day")) %>%
  mutate(day = day(time)) %>%
  mutate(week = week(time)) %>%
  group_by(day) %>%
  mutate(MeanSentiment = mean(polaritysent)) %>%
  ggplot(aes(x=time, y = polaritysent, group = day)) +
  # geom_point() +
  # geom_boxplot() +
  geom_violin(aes(fill = MeanSentiment)) +
  # geom_jitter(aes(y=polaritysent, color = polaritysent), width = 1) +
  facet_wrap(~week, scales = "free_x")

library(scales)

added3 %>% select(-line,-location) %>%
  mutate(filterday = date(time)) %>%
  filter(time <= today()) %>%
  filter(time >= today()-days(3)) %>%
  mutate(searchterm = ifelse(searchterm=="USMA" | searchterm=="WestPoint", "West Point",
                         ifelse(searchterm=="USNA"|searchterm=="Naval Academy", "Navy", "Air Force"))) %>%
  mutate(hour = hour(time)*60+minute(time)) %>%
  mutate(dayofweek = weekdays(time)) %>%
  filter(favoritescount>0) %>%
  filter(followerscount>0) %>%
  filter(polaritysent!=0) %>%
  ggplot(aes(x=time,y = polaritysent, color = fct_rev(searchterm))) +
  geom_point(aes(size = favoritescount, fill = fct_rev(searchterm),alpha = polaritysent), shape = 21) +
  scale_fill_manual(values = c("Black", "Yellow", "Blue")) +
  scale_color_manual(values = c("Black", "Blue", "White"), guide = "none") +
  scale_alpha(guide = "none") +
  scale_x_datetime(labels = date_format("%d %b %Y"),
                   date_breaks = "1 day") +
  labs(x="Time",y="Polarity Sentiment", size = "Favorites Count", fill = "University", title = "Polarity Sentiment over Time by University")

  
library(sparkline)
sparkline(added3$polaritysent)

plot(added3$polaritysent, transformation.function = syuzhet::get_dct_transform)

# library(YaleToolkit)
# data(YaleEnergy)
# y <- YaleEnergy[YaleEnergy$name==YaleEnergy$name[2],]
# sparkline(y$ELSQFT, times=y$year+y$month/12,
#           xaxis=TRUE, yaxis=TRUE, main="Branford College Electrical Consumption",
#           buffer=unit(1, "lines"), margins = unit(c(1, 1, 1, 1), 'inches'))
# 
# sparkline(Nile,
#           buffer = unit(1, "lines"),
#           ptopts = list(labels = 'min.max'),
#           margin.pars = gpar(fill = 'lightblue'),
#           buffer.pars = gpar(fill = 'lightgreen'),
#           frame.pars = gpar(fill = 'lightyellow'),
#           yaxis = TRUE, xaxis=TRUE,
#           IQR = gpar(fill = 'grey', col = 'grey'),
#           main="Nile Discharge between 1871 and 1970",
#           sub='In what units?')
