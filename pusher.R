setwd("C:/Users/Dusty.Turner/Desktop/R Work/USMAPAO")

print(Sys.time())

# rsconnect::addServerCertificate(name = "shinyapps.io", certificate = "C:/Users/Dusty.Turner/AppData/Local/Temp/RtmpSq7cx0/cacerts55981f436af3.pem")
options(rsconnect.check.certificate = FALSE)

# system()
# system("echo | openssl s_client -connect https://dustyturner.shinyapps.io:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'")
# options(rsconnect.check.certificate = FALSE)

options(rsconnect.http.trace = TRUE)
options(rsconnect.http.trace.json = TRUE)
options(rsconnect.http.verbose = TRUE)

# rsconnect::listBundleFiles("C:/Users/Dusty.Turner/Desktop/R Work/USMAPAO")
# rsconnect::serverInfo(name = "shinyapps.io")
# rsconnect::addServerCertificate()

rsconnect::setAccountInfo(name='westpointmath', 
                          token='21B8A56CD9B10976DB2A85BB8028FC62', 
                          secret='SJP0ZguEKltcVWy/3fuf/sbLG2wtWWZKd5/15Ot/')

# print(Sys.time())
print("setaccountinfocomplete")

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

print("appdeployed")
# rsconnect::addServerCertificate()
# rsconnect::deployApp(appDir = "C:/Users/Dusty.Turner/Desktop/R Work/USMAPAO",
#                      appFiles =  NULL,
#                      # appFileManifest = "C:/Users/Dusty.Turner/AppData/Local/Temp/3edc-d182-f655-df03",
#                      appPrimaryDoc = "USMAPAO.Rmd", 
#                      appSourceDoc = "C:/Users/Dusty.Turner/Desktop/R Work/USMAPAO/USMAPAO.Rmd",
#                      account = "westpointmath", 
#                      server = "shinyapps.io", 
#                      appName = "USMAPAO",
#                      appId = 600635,
#                      launch.browser = function(url) {         message("Deployment completed: ", url)     },
#                      lint = FALSE, metadata = list(asMultiple = FALSE, asStatic = FALSE),
#                      logLevel = "verbose",
#                      forceUpdate = TRUE) 
