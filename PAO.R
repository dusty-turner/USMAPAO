# devtools::install_github("mkearney/rtweet")
#Test to check connectivityasdf 
library(rtweet)
library(tidyverse)
library(tidytext)
library(lubridate)
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


# 
# rt %>% leaflet() %>% setView(-100, 40, zoom = 4) %>%
#   addTiles() %>%  # Add default OpenStreetMap map tiles
#   addMarkers(~lng,~lat,popup = ~as.character(screen_name), label = ~as.character(text), clusterOptions = markerClusterOptions())
usma <- data_frame(line = 1:length(USMA$text), 
                   text = as.character(USMA$text),
                   screenname = USMA$screen_name,
                   time = USMA$created_at, 
                   searchterm = "USMA", 
                   coords = USMA$coords_coords, 
                   location = USMA$location, 
                   followerscount = USMA$followers_count, 
                   favoritescount = USMA$favorite_count)
wp %>%
  # arrange(desc(favoritescount)) %>% select(screenname,favoritescount, followerscount)
  filter(screenname=="Boyd_2650") %>% select(text,location)
  # select(media_t.co, media_expanded_url,media_url,media_type)



wp <- data_frame(line = 1:length(WestPoint$text), 
                   text = as.character(WestPoint$text),
                   screenname = WestPoint$screen_name,
                   time = WestPoint$created_at, 
                   searchterm = "WestPoint", 
                   coords = WestPoint$coords_coords, 
                   location = WestPoint$location, 
                   followerscount = WestPoint$followers_count, 
                   favoritescount = WestPoint$favorite_count)
  

text_df = bind_rows(usma,wp) %>%
  lat_lng() %>% select(-coords)

#### START RUNNING AT THIS LINE#######

addtothisdf = read_csv("PAOTweets.csv")

added = text_df %>% bind_rows(addtothisdf) %>%
  distinct(text,time,searchterm, .keep_all = TRUE)

write.csv(added,"PAOTweets.csv", row.names = FALSE)

textcleaned = added %>%
  unnest_tokens(word, text)

cleanedarticle = anti_join(textcleaned,stop_words, by = "word") %>% select(line,word,screenname,time,followerscount,favoritescount)
# dropwords = data.frame(word = as.character(c("https","trump")))
# cleanedarticle = anti_join(cleanedarticle,dropwords, by = "word")

####################
# Insites To Present
####################


### Sentiment by Day
cleanedarticle %>%
  full_join(get_sentiments("nrc"), by = "word") %>%
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
  filter(as.character(time)=="2018-11-04") %>%
  arrange(desc(followerscount)) %>%
  group_by(screenname,sentiment) %>%
  mutate(total = n()) %>%
  distinct(screenname,sentiment, followerscount,favoritescount,total) %>%
  arrange(desc(favoritescount)) %>%
  filter(sentiment=="negative")



# Who is this twitter user 
negexample = added %>% filter(screenname=="OnMontagueSt") %>% select(text) 
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

example2 = added %>% filter(screenname=="SecPompeo") %>% select(text) 
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
  mutate(prop = n()/nrow(bigrams_united)) %>% 
  # arrange(desc(prop))
  filter(prop>.01) %>%
  ggplot(aes(bigram, prop)) + 
  geom_col()

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

cleanedarticle %>%
  full_join(get_sentiments("nrc"), by = "word") %>%
  filter(complete.cases(.)) %>%
  filter(sentiment=="positive" | sentiment == "negative") %>%
  mutate(time = floor_date(time, unit = "day")) %>%
  mutate(score = ifelse(sentiment=="positive",1,-1)) %>%
  group_by(time) %>%
  summarise(dayscore = sum(score)/sum(abs(score))) %>%
  ggplot(aes(time,dayscore, color = dayscore)) +
  geom_smooth() +
  theme(legend.position = "none") +
  labs(title = "Sentiment Score Over Time", x = "Date", y = "Sentiment Score")  
  

#### Sentiment Score Over Time

textcleaned %>%
  mutate(team = ifelse(team=="mets", "Mets","Yankees")) %>%
  select(line,team) %>%
  ggplot(aes(x=team, fill = team), color = team) +
  geom_bar() +
  scale_colour_manual(values = c("blue", "white")) +
  scale_fill_manual(values = c("orange", "navy blue")) +
  labs(title = "Total Number of Words in Tweets \n Containing Team's Name", x = "Team", y = "Words", fill = "Team")



