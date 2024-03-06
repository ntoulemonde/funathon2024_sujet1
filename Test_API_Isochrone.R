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

json <- '{
  "departure_searches": [
    {
      "id": "isochrone-0",
      "coords": {
        "lat": 44.82148171853187,
        "lng": -0.560818726848197
      },
      "departure_time": "2024-03-06T08:00:00.000Z",
      "travel_time": 7140,
      "transportation": {
        "type": "public_transport"
      }
    }
  ]
}'


result <- API_isochrones_Test(url, json)

result
