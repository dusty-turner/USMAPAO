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
names(USMA)

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


# addtothisdf = read_csv("yvm.csv")


# addtothisdf = text_df %>% bind_rows(addtothisdf) %>%
#   distinct(text,time,team, .keep_all = TRUE) 

# write.csv(addtothisdf,"yvm.csv", row.names = FALSE)

textcleaned = text_df %>%
  unnest_tokens(word, text)

cleanedarticle = anti_join(textcleaned,stop_words, by = "word") %>% select(line,word,screenname,time,followerscount,favoritescount)
# dropwords = data.frame(word = as.character(c("https","trump")))
# cleanedarticle = anti_join(cleanedarticle,dropwords, by = "word")


cleanedarticle %>%
  full_join(get_sentiments("nrc"), by = "word") %>%
  # select(-c(location,lat,lng,coords_coords,bbox_coords,geo_coords)) %>%
  filter(complete.cases(.)) %>%
  filter(sentiment=="positive" | sentiment == "negative") %>%
  mutate(time = floor_date(time, unit = "day")) %>%
  filter(as.character(time)=="2018-11-04") %>%
  arrange(desc(followerscount)) %>%
  group_by(screenname,sentiment) %>%
  mutate(total = n()) %>%
  distinct(screenname,sentiment, followerscount,favoritescount,total) %>%
  arrange(desc(favoritescount)) %>%
  filter(sentiment=="negative")



test =text_df %>% filter(screenname=="WarInstitute") %>% select(text) 
test$text


cleanedarticle %>%
  full_join(get_sentiments("nrc"), by = "word") %>%
  # select(-c(location,lat,lng,coords_coords,bbox_coords,geo_coords)) %>%
  filter(complete.cases(.)) %>%
  filter(sentiment=="positive" | sentiment == "negative") %>%
  mutate(time = floor_date(time, unit = "day")) %>%
  ggplot(aes(sentiment, fill = sentiment)) +
  geom_bar() +
  facet_grid(~time)

addtothisdf %>%
  mutate(team = ifelse(team=="mets", "Mets","USMA")) %>%
  select(line,team) %>%
  ggplot(aes(x=team, fill = team), color = team) +
  geom_bar() +
  scale_colour_manual(values = c("blue", "white")) +
  scale_fill_manual(values = c("orange", "navy blue")) +
  labs(title = "Total Number of Tweets \n Containing Team's Name", x = "Team", y = "Tweets", fill = "Team")

textcleaned %>%
  mutate(team = ifelse(team=="mets", "Mets","Yankees")) %>%
  select(line,team) %>%
  ggplot(aes(x=team, fill = team), color = team) +
  geom_bar() +
  scale_colour_manual(values = c("blue", "white")) +
  scale_fill_manual(values = c("orange", "navy blue")) +
  labs(title = "Total Number of Words in Tweets \n Containing Team's Name", x = "Team", y = "Words", fill = "Team")


bind_rows(
  text_df %>%
    filter(str_detect(text, "Yankees")) %>%
    mutate(text = gsub(".*Yankees","",.$text)) %>%
    mutate(text = word(text,2,7)),
  
  text_df %>%
    filter(str_detect(text, "Mets")) %>%
    mutate(text = gsub(".*Mets","",.$text)) %>%
    mutate(text = word(text,2,7))
) %>%
  select(text, team) %>%
  filter(complete.cases(.)) %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word") %>%
  full_join(get_sentiments("nrc"), by = "word") %>%
  filter(complete.cases(.)) %>%
  # filter(sentiment=="positive" | sentiment == "negative") %>%
  mutate(team = ifelse(team=="mets", "Mets","Yankees")) %>%
  group_by(team,word) %>% 
  mutate(count = n()) %>%
  ggplot(aes(x=team, fill = team)) +
  geom_bar() +
  facet_wrap("sentiment") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  scale_colour_manual(values = c("blue", "white")) +
  scale_fill_manual(values = c("orange", "navy blue")) +
  labs(title = "Total Emotion Words in Tweets", x = "Team", y = "Words With Sentiment", fill = "Team")

bind_rows(
  text_df %>%
    filter(str_detect(text, "Yankees")) %>%
    mutate(text = gsub(".*Yankees","",.$text)) %>%
    mutate(text = word(text,2,7)),
  
  text_df %>%
    filter(str_detect(text, "Mets")) %>%
    mutate(text = gsub(".*Mets","",.$text)) %>%
    mutate(text = word(text,2,7))
) %>%
  select(text, team, line) %>%
  filter(complete.cases(.)) %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word") %>%
  full_join(get_sentiments("nrc"), by = "word") %>%
  filter(complete.cases(.)) %>%
  # filter(sentiment=="positive" | sentiment == "negative") %>%
  mutate(team = ifelse(team=="mets", "Mets","Yankees")) %>%
  group_by(team,sentiment) %>% 
  mutate(count = n()) %>%
  summarise(grouptotal = n()) %>%
  mutate(totaltweets = ifelse(team=="Yankees", sum(text_df$team=="yankees"),sum(text_df$team=="mets"))) %>%
  mutate(percent = grouptotal/totaltweets) %>%
  ggplot(aes(x=team, y = percent, fill = team)) +
  geom_bar(stat = 'identity') +
  facet_wrap("sentiment") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  scale_colour_manual(values = c("blue", "white")) +
  scale_fill_manual(values = c("orange", "navy blue")) +
  labs(title = "Percent of Tweets with Specific Emotion by Team", x = "Team", y = "Percent", fill = "Team")


####

austen_bigrams <- addtothisdf %>% select(-c(location,lat,lng,coords_coords,bbox_coords,geo_coords)) %>% 
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

bigrams_united

bigrams_filtered %>%
  filter(word1 == "yankees") %>%
  count(team, word2, sort = TRUE)

bigrams_filtered %>%
  filter(word1 == "mets") %>%
  count(team, word2, sort = TRUE)

bigram_tf_idf <- bigrams_united %>%
  count(team, bigram) %>%
  bind_tf_idf(bigram, team, n) %>%
  arrange(desc(tf_idf))

bigrams_united %>% mutate(team = ifelse(team=="mets", "Mets","Yankees")) %>%
  filter(bigram != "york mets" & bigram != "york yankees") %>%
  group_by(bigram) %>%
  mutate(n = n()) %>%
  filter(n()>50) %>%
  ggplot(aes(x=fct_reorder(bigram, n), fill = team), color = team) +
  geom_bar() +
  scale_colour_manual(values = c("blue", "white")) +
  scale_fill_manual(values = c("orange", "navy blue")) +
  facet_wrap("team")+
  # theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  coord_flip() +
  labs(title = "Popular Content with Mets and Yankees Tweets", x = "Content", y = "Bigram Count", fill = "Team")






addtothisdf %>% select(-c(location,lat,lng,coords_coords,bbox_coords,geo_coords)) %>%
  unnest_tokens(trigram, text, token = "ngrams", n = 3) %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ") %>%
  filter(!word1 %in% stop_words$word,
         !word2 %in% stop_words$word,
         !word3 %in% stop_words$word) %>%
  count(word1, word2, word3, sort = TRUE)
