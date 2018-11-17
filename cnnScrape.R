#----News Grabber
#test case: CNN

library(RSelenium)
library(XML)
library(rvest)
rD <- rsDriver(browser = 'firefox', phantomver = NULL) 

remDr <- rD$client
remDr$open()

#remDr$maxWindowSize()

baseUrl <- 'http://www.cnn.com'
searchTerm <- '"West Point"'
searchTime <- 'Past year'


#go to cnn front page
remDr$navigate(baseUrl)

#click on search button
searchButton <- remDr$findElement(using = 'css', value = '.search__button')
searchButton$clickElement()

#enter search text
searchField <- remDr$findElement(using = 'css', value = '.search__input-field')
searchField$sendKeysToElement(list(searchTerm))

pause<-remDr$getPageSource()
#submit search
submit <- remDr$findElement(using = 'css', value = '.search__submit-button')
submit$clickElement()

#---subset on time frame NOT WORKING
#option <- remDr$findElement(using='xpath',  "//*/option[@value = 'pastYear']")
#option$clickElement()



#scrape the article metadata from the first page of search results
articles <- remDr$findElements(using = 'css', value = '.cnn-search__result--article')
count <- 1
pb <- txtProgressBar(max = length(articles), style = 3)
articleList <- list()
for(i in 1:length(articles)){
  article <- read_html(articles[[i]]$getElementAttribute("outerHTML")[[1]]) 
  title <- article %>%
    html_node('.cnn-search__result-headline') %>%
    html_text()
  link <- article %>%
    html_node('a') %>%
    html_attr('href') 
  #%>%
   # paste(baseUrl, ., sep = '')
  #date <- article %>%
   # html_node('.cnn-search__result-publish-date') %>%
  #  html_text() %>%
   # as.POSIXct(format = '%B %d, %Y %I:%M%p', tz = 'EST')
  
  dfTemp <- data.frame(title = title, link = paste("http:",link,sep=""), date = NA, stringsAsFactors = FALSE)
  articleList[[i]] <- dfTemp
  setTxtProgressBar(pb, i)
}
articleDF <- do.call('rbind', articleList)

#Click to next page THIS IS NOT WORKING#######################

searchField <- remDr$findElement(using = 'css', value = '.search__input-field')
searchField$clickElement()


moreSearch <- remDr$findElement(using = 'css', value = '.pagination-arrow-right')
moreSearch$clickElement()

#Scrape metadata again
articleDF2<-articleDF

#scrape the article metadata from the first page of search results
articles <- remDr$findElements(using = 'css', value = '.cnn-search__result--article')
count <- 1
pb <- txtProgressBar(max = length(articles), style = 3)
articleList <- list()
for(i in 1:length(articles)){
  article <- read_html(articles[[i]]$getElementAttribute("outerHTML")[[1]]) 
  title <- article %>%
    html_node('.cnn-search__result-headline') %>%
    html_text()
  link <- article %>%
    html_node('a') %>%
    html_attr('href')
  #date <- article %>%
  # html_node('.cnn-search__result-publish-date') %>%
  #  html_text() %>%
  # as.POSIXct(format = '%B %d, %Y %I:%M%p', tz = 'EST')
  
  dfTemp <- data.frame(title = title, link = link, date = NA, stringsAsFactors = FALSE)
  articleList[[i]] <- dfTemp
  setTxtProgressBar(pb, i)
}
articleDF <- do.call('rbind', articleList)

articleDF<-rbind(articleDF2,articleDF)

#scrape the article text (using selenium)
articleDF$text <- NA
pb <- txtProgressBar(max = nrow(articleDF), style = 3)
for(i in 1:nrow(articleDF)){
  link <- articleDF$link[i]
  remDr$navigate(link)
  
  articleText <- remDr$findElement(using = 'css', value = '.cnn-search__result-body')
 articleDF$text[i] <- articleText$getElementText()[[1]]
  setTxtProgressBar(pb, i)
}



#######################################################################



#scrape article text (using rvest - more reliable and faster)
library(snowfall)

sfInit(parallel = TRUE, cpus = 4)

sfLibrary(rvest)
sfLibrary(dplyr)

sfExport('articleDF')

getCnnArticle <- function(url){
  article <- read_html(url)
  
  text<- article %>%
    html_node('.pg-rail-tall__body') %>%
    html_text()
  
  author <- article %>%
    html_node('.byline__author') %>%
    html_text()
  
  tmp <- data.frame(link = url, text = text, author = NA, stringsAsFactors = FALSE)
}

out <- sfLapply(articleDF$link, getCnnArticle)

sfStop()

detailsDF <- data.table::rbindlist(out)

df <- articleDF %>%
  left_join(detailsDF, by = 'link')

df$text.x <- NULL
colnames(df)[4] <- 'text'

#easy enrichments

library(sentimentr)
sent <- sentiment_by(df$text)
df$sentiment <- sent$ave_sentiment * 100

#frequently mentioned words
library(qdap)
freq <- freq_terms(df$text, top = 20, at.least = 4, stopwords = Top200Words) 

#extract entities
#install.packages(c("RWeka"))
library(NLP)
library(openNLP)
library(RWeka)
#special load for entity extraction info (english only)
#install.packages("openNLPmodels.en",
#                  repos = "http://datacube.wu.ac.at/",
#                  type = "source")
#utility function
entities <- function(doc, kind) {
  s <- doc$content
  a <- annotation(doc)[[1]]
  if(hasArg(kind)) {
    k <- sapply(a$features, `[[`, "kind")
    s[a[k == kind]]
  } else {
    s[a[a$type == "entity"]]
  }
}

word_ann <- Maxent_Word_Token_Annotator()
sent_ann <- Maxent_Sent_Token_Annotator()
person_ann <- Maxent_Entity_Annotator(kind = "person")
location_ann <- Maxent_Entity_Annotator(kind = "location")
organization_ann <- Maxent_Entity_Annotator(kind = "organization")


####################NOT WORKING####################
pb <- txtProgressBar(max = nrow(df), style = 3)
df$people <- NA
df$places <- NA
df$orgs <- NA
for(i in 1:nrow(df)){
  annotations <- annotate(df$text[i], list(sent_ann, word_ann, person_ann, location_ann, organization_ann))
  print(i)
  document <- AnnotatedPlainTextDocument(df$text[i], a=annotations)
  
  df$orgs[i] <- paste(as.vector(unique(entities(document, 'organization'))), collapse=", ")
  df$people[i] <- paste(as.vector(unique(entities(document, 'person'))), collapse=", ")
  df$places[i] <- paste(as.vector(unique(entities(document, 'location'))), collapse=", ")
  
  setTxtProgressBar(pb, i)
}
