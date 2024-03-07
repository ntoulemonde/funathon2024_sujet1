#Mettre les codes API après inscription sur le site traveltime.com
X_Api_Id <- "c32b3037"
X_Api_Key <- "c0c067d7cddbdb9acbd6389ef5b73aae"

#Fonction qui envoie un requêtes avec un JSON à un endpoint donné
API_isochrones_Test <- function(url, json){
  # On prépare les headers
  headers <- httr::add_headers("Content-Type" = "application/json",
                               "X-Application-Id" = X_Api_Id,
                               "X-Api-Key" = X_Api_Key)
  # On envoie la requête avec les headers spécifiés
  response <- httr::POST(url, body = json, encode = "json", headers)
  #Récupération du contenu de la réponse
  content <- httr::content(response)
  #Récupération du code de la réponse
  code <- httr::status_code(response)
  return(list(content, code))
}

#Test de la fonction API_isochrones_Test
url <- "https://api.traveltimeapp.com/v4/time-map"

# Paramètre de la requête :
# Lieu : Centre de Paris
# Isochrones : 4h00
# Mode de transport : Transport public (bus, métro, tram, train)
# Date et heure : 2024-03-07 à 18h00 UTC
# Flexibilité : 2h00

json <- '{
  "departure_searches": [
    {
      "id": "isochrone-0",
      "coords": {
        "lat": 48.8534951,
        "lng": 2.3483915
      },
      "departure_time": "2024-03-07T18:00:00.000Z",
      "travel_time": 14400,
      "transportation": {
        "type": "public_transport",
        "walking_time": 900,
        "cycling_time_to_station": 100,
        "parking_time": 0,
        "boarding_time": 0,
        "driving_time_to_station": 1800,
        "pt_change_delay": 0,
        "disable_border_crossing": false
      },
      "level_of_detail": {
        "scale_type": "simple",
        "level": "medium"
      },
      "single_shape": false,
      "no_holes": false,
      "range": {
        "enabled": true,
        "width": 7200
      }
    }
  ]
}'


result <- API_isochrones_Test(url, json)

#Extraction d'un polygone de l'isochrone
rawShape1 <- result[[1]]$results[[1]]$shapes[[1]]$shell
shape1 <- do.call(rbind, lapply(rawShape1, function(x) {data.frame(lat = x$lat, lng = x$lng)}))

#Extraction de tous les polygones de l'isochrone
shapeList <- list()
for (i in 1:length(result[[1]]$results[[1]]$shapes)){
  rawShape <- result[[1]]$results[[1]]$shapes[[i]]$shell
  shape <- do.call(rbind, lapply(rawShape, function(x) {data.frame(lat = x$lat, lng = x$lng)}))
  shapeList[[length(shapeList)+1]] <- shape
}





library(leaflet)

######################
### Initialisation ###
######################

apiKey <- "e6f6cfad-a662-4589-b060-1d7eed6d88a3"

# Lien des tuiles Stadia Maps pour les fonds de carte (Autres URL disponibles ici : https://stadiamaps.com/themes/)
ALIDADE_SMOOTH_TILES_URL <- "https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key="
OUTDOORS_TILES_URL <- "https://tiles.stadiamaps.com/tiles/outdoors/{z}/{x}/{y}{r}.png?api_key="
ALIDADE_SATELLITE_TILES_URL <- "https://tiles.stadiamaps.com/tiles/alidade_satellite/{z}/{x}/{y}{r}.png?api_key="

TILES_URL <- paste0(ALIDADE_SMOOTH_TILES_URL,apiKey)

##########################
### Programme statique ###
##########################


# Initialisation et création de la carte de base
leafletMap <- leaflet() %>%
  addTiles(urlTemplate = TILES_URL)

# Boucle pour ajouter chaque polygone de shapeList à la carte
for (s in shapeList) {
  leafletMap <- leafletMap %>% addPolygons(data = s, 
                                           ~lng, ~lat, 
                                           color = "#FF0000", 
                                           fillColor = "#FFAAAA", 
                                           fillOpacity = 0.5, 
                                           weight = 2)
}

# On affiche la carte
leafletMap





