read.csv("https://www.data.gouv.fr/api/1/datasets/r/cbacca02-6925-4a46-aab6-7194debbb9b7", header = TRUE, sep = ";") |> 
  dplyr::select(station_name=Nom, citycode = Code.commune, lat.lon=Position.géographique) |> 
  dplyr::mutate(
    # We extract latitude and longitude 
    lat = as.numeric(stringr::str_extract(lat.lon, pattern = ".*(?=,)")), 
    lon = as.numeric(stringr::str_extract(lat.lon, pattern = "(?<=,).*")), 
    lat.lon = NULL, 
    # Removing all "-" and trimming the result to deal with "-" and multiple spaces
    station_name = stringr::str_replace_all(station_name, pattern="-", replacement = " "),
    station_name = stringr::str_squish(station_name)
  ) -> stations_df

# Strasbourg-Ville no exception : lat and lon are in the station
get_station_coordinates <- function(station_name = "Lille Flandres", data = stations_df, verbose = FALSE){
  # Dealing with - and other differences
  station_name_light = stringr::str_replace_all(station_name, pattern="-", replacement = " ")
  station_name_light = stringr::str_squish(station_name_light)
  
  coords <- stations_df |> 
    dplyr::filter(station_name == station_name_light) |> 
    dplyr::summarise(lat = dplyr::first(lat), lon = dplyr::first(lon))
  
  if (verbose) {
    cat(sprintf("%s -> (%f, %f)\n", station_name, coords[1], coords[2]))
  }
  
  return(coords)
}

# Test 
get_station_coordinates("Toulouse-Matabiau", verbose = FALSE)

# Function to get the number of hours between two train stations
get_time_two_stations <- function(
    departure_name = "Paris Montparnasse", 
    arrival_name = "Toulouse Matabiau", 
    verbose = FALSE){
  
  # Getting the coordinates of the two stations
  depart = as.numeric(get_station_coordinates(station_name = departure_name,
                                              verbose = FALSE)[1,])
  arrival = as.numeric(get_station_coordinates(station_name = arrival_name,
                                               verbose = FALSE)[1,])
  
  # Calling the API
  response = get_travel_time_api_response(
    endpoint = "https://api.traveltimeapp.com/v4/routes",
    depart = depart, 
    arrival = arrival
  )
  
  # Getting the first 
  first_it_traveltime = NA
  first_it_traveltime = response[["results"]][[1]][["locations"]][[1]][["properties"]][[1]][["travel_time"]]

  # If no itinerary, then time is infinite
  if (is.na(first_it_traveltime)) {
    first_it_traveltime = Inf
  }
  
  # Print result 
  if (verbose) {
    cat(sprintf("%s -> %s : %.0f h %.0f min", departure_name, arrival_name, first_it_traveltime %/% (60*60), (first_it_traveltime/60) %% 60))
  }
  
  return(lubridate::dseconds(first_it_traveltime))
}

# Testing the function
res = get_time_two_stations(verbose = TRUE)
