# API Travel Time ----

## Importing credentials 
secrets <- yaml::read_yaml("secrets.yaml")
X_API_ID <- secrets$travelTim$X_API_ID
X_API_KEY <- secrets$travelTime$X_API_KEY

# Generating the API request from latitude and longitude of departure and arrival. 
# Date is updated to today, 9am by default. 
generate_brequest <- function(    
    depart = c(50.6365654, 3.0635282), 
    arrival = c(48.8588897, 2.320041)
    ){
  paste0('{
    "locations": [
      {
        "id": "point-from",
        "coords": {
          "lng": ', depart[2], ',
          "lat": ', depart[1], 
         '}
      },
      {
        "id": "point-to-1",
        "coords": {
          "lng": ', arrival[2], ',
          "lat": ', arrival[1], '}
      }
    ],
    "departure_searches": [
      {
        "id": "departure-search",
        "transportation": {
          "type": "train"
        },
        "departure_location_id": "point-from",
        "arrival_location_ids": [
          "point-to-1"
        ],
        "departure_time": "', lubridate::today(),'T09:00:00+02:00",
        "properties": [
          "travel_time",
          "route"
        ],
        "range": {
          "enabled": true,
          "max_results": 5,
          "width": 43200
        }
      }
    ]
  }'
  )
}

# Function to retrieve train transport time from API
get_travel_time_api_response <- function(
    endpoint = "https://api.traveltimeapp.com/v4/routes",
    depart = c(50.6365654, 3.0635282), 
    arrival = c(48.8588897, 2.320041)
){
  
  # storing the config headers
  my_headers <- httr::add_headers("Content-Type"= "application/json", 
                                  "X-Application-Id" = X_API_ID, 
                                  "X-Api-Key" = X_API_KEY)
  
  # Generating the request
  body_request = generate_brequest(depart, arrival)
  
  # Calling API
  response <- httr::POST(endpoint,
                         config = my_headers, 
                         body = body_request)
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

# Getting the travel time of the first result
first_itinerary_traveltime = lubridate::dseconds(
  response[["results"]][[1]][["locations"]][[1]][["properties"]][[1]][["travel_time"]]
)

# If we want a list of all itineraries in the response
list_itinerary = response[["results"]][[1]][["locations"]][[1]][["properties"]]

#### !!!!!!!!!!! DOESNT WORK WITH NON DIRECT CONNECTION -- NEED TO CAPTURE THIS PART

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
