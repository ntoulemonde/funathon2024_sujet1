# API Travel Time ----

## Importing credientials 
secrets <- yaml::read_yaml("secrets.yaml")
X_API_ID <- secrets$travelTim$X_API_ID
X_API_KEY <- secrets$travelTime$X_API_KEY

## Toying with API ----
# Endpoint
ROUTES_API_URL <- "https://api.traveltimeapp.com/v4/routes"
# storing the config headers
my_headers <- httr::add_headers("Content-Type"= "application/json", 
                                "X-Application-Id" = X_API_ID, 
                                "X-Api-Key" = X_API_KEY)
# Request stored in a dedicated file
playground_request_file <- "playground_r.json"

get_travel_time_api_response <- function(endpoint = ROUTES_API_URL, req_file = playground_request_file){
  # Calling API
  response <- httr::POST(endpoint,
                         config = my_headers, 
                         body = httr::upload_file(req_file))
  # Checking received the good response
  if (response$status_code == 200) {
    # If reply is ok we get the travel time from the first response
    res = httr::content(response)
  } else {
    res = sprintf("Une erreur est survenue. Code de la réponse : %d", httr::status_code(response))
  }
  return(res)
}

response <- get_travel_time_api_response()

# A list of all itineraries in the response
list_itinerary = response[["results"]][[1]][["locations"]][[1]][["properties"]]

# Extracting travel time for the train part of the first itinerary
list_itinerary[[1]][["route"]][["parts"]] |>
  # spreading to filter to retain only the train parts of the itinerary
  tidyjson::spread_all() |>
  dplyr::filter(mode == 'train') |>
  # Keeping only valuable info
  dplyr::select(departure_station, departs_at, arrival_station, arrives_at, travel_time) |>
  # Storing travel_time as duration 
  dplyr::mutate(travel_time = lubridate::dseconds(travel_time)) |>
  # Turning into a df
  dplyr::as_tibble()
