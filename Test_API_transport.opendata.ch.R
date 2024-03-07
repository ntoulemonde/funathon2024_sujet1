library(httr)

###########################################
### On cherche le nom des localisations ###
###########################################

locationName="Paris"

url <- paste0("http://transport.opendata.ch/v1/locations?query=",locationName)

# Faire la requête GET
response <- GET(url)

resultat <- content(response, "parsed")

for (i in 1:length(resultat$stations)){
  cat("      Nom : ",resultat$stations[[i]]$name)
  cat("\n")
  cat("       ID : ",resultat$stations[[i]]$id)
  cat("\n")
  cat("        x : ",resultat$stations[[i]]$coordinate$x)
  cat("\n")
  cat("        y : ",resultat$stations[[i]]$coordinate$y)
  cat("\n")
  cat("Transport : ",resultat$stations[[i]]$icon)
  cat("\n")
  cat("\n")
  cat("\n")
}




start <- "8739100"
end <- "8761100"

# L'URL de l'API pour obtenir les connections
url <- paste0("http://transport.opendata.ch/v1/connections?from=",start,"&to=",end)

# Faire la requête GET
response <- GET(url)

resultat <- content(response, "parsed")

for (i in 1:length(resultat$connections))
{
  cat("            De : ", resultat$connections[[i]]$from$station$name)
  cat("\n")
  
  cat("             A : ", resultat$connections[[i]]$to$station$name)
  cat("\n")
  
  cat("Correspondance : ", length(resultat$connections[[i]]$sections)-1)
  cat("\n")
  
  timeStampDelta <- resultat$connections[[i]]$to$arrivalTimestamp - resultat$connections[[i]]$from$departureTimestamp
  minuteDelta <- timeStampDelta / 60
  hour <- floor(minuteDelta / 60)
  minutes = floor(minuteDelta %% 60)
  cat("         Temps : ", hour, "h", minutes, " min")
  
  cat("\n")
  cat("\n")
  cat("\n")
}



  
