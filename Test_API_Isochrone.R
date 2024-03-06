#Fonction qui envoie un requêtes avec un JSON à un endpoint donné
#Entrée:
#   - url: l'endpoint de l'API
#   - json: le JSON à envoyer
#Sortie:
#   - la réponse de l'API
#   - le code de la réponse

API_isochrones_Test <- function(url, json){
  #Envoie de la requête
  response <- httr::POST(url, body = json, encode = "json")
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