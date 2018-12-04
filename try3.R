setwd("C:/Users/Dusty.Turner/Desktop/R Work/USMAPAO")

print("wdset")

rsconnect::setAccountInfo(name='westpointmath', 
                          token='21B8A56CD9B10976DB2A85BB8028FC62', 
                          secret='SJP0ZguEKltcVWy/3fuf/sbLG2wtWWZKd5/15Ot/')

print("setaccountinfoset")


# deployApp(forceUpdate=TRUE, appName = "USMAPAO", account = "dustyturner", upload = FALSE)

# rsconnect::deployApp(appDir = "C:/Users/Dusty.Turner/Desktop/R Work/USMAPAO",
#                      # appFileManifest = "C:/Users/Dusty.Turner/AppData/Local/Temp/4/79be-7eb9-940c-f09b",
#                      appPrimaryDoc = "USMAPAO.Rmd", 
#                      appSourceDoc = "C:/Users/Dusty.Turner/Desktop/R Work/USMAPAO/USMAPAO.Rmd",      
#                      account = "westpointmath", server = "shinyapps.io", appName = "USMAPAO",      
#                      appId = 600635, 
#                      launch.browser = function(url) {         message("Deployment completed: ", url)     },
#                      lint = FALSE, 
#                      metadata = list(asMultiple = FALSE, asStatic = FALSE),      
#                      # logLevel = "verbose",
#                      forceUpdate = TRUE) 

print("appdeployed")