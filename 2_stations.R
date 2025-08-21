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
    cat(sprintf("%s -> %s : %.0f h %.0f min (%.0f s) \n", 
                departure_name, 
                arrival_name, 
                first_it_traveltime %/% (60*60), 
                (first_it_traveltime/60) %% 60, 
                first_it_traveltime
                )
        )
  }
  
  return(lubridate::dseconds(first_it_traveltime))
}

# # Testing the function
# get_time_two_stations(verbose = TRUE)

generate_matrix <- function(stations_list, sleep_time = 15) {
  # Storing matrix length and initialization
  n = length(stations_list)
  res = matrix(nrow = n, ncol = n, dimnames = list(stations_list, stations_list))
  
  # Looping over each row
  for (row in 1:n) {
    # Looping for each row over the columns, 
    for (col in row:n) { # Symetric matrix so calculation only from row to last
      if (row == col) { # If we are on the diagonal : time = 0
        res[row, col] = 0
      } else {
        res[row, col] = get_time_two_stations(
          departure_name = stations_list[row], 
          arrival_name = stations_list[col], 
          verbose = TRUE)
        res[col, row] = res [row, col] # Completing the matrix
        if (sleep_time != 0) {
          cat(sprintf("System to sleep for %.0f s \n", sleep_time))
          Sys.sleep(sleep_time) 
        }
        }
    }
  }
  
  return(res)
}

main_stations <- c(
  "Paris Gare du Nord",
  "Lyon Perrache",
  "Marseille Saint Charles",
  "Toulouse Matabiau",
  "Lille Flandres",
  "Bordeaux Saint Jean",
  "Nice",
  "Nantes",
  "Strasbourg",
  "Montpellier Saint Roch",
  "Rennes",
  "Grenoble",
  "Toulon"
)

time_matrix = round(generate_matrix(main_stations, sleep_time = 0) / 3600, 
            digits = 2)

# We extract the couple of cities that are below 4:30h
THRESHOLD  <- 4.5

lower_tri_matrix  <- lower.tri(time_matrix, diag = FALSE)
under_threshold_indices <- which(time_matrix <= 4.5 & time_matrix > 0 & lower_tri_matrix, arr.ind = TRUE, useNames = TRUE)
under_threshold_routes <- dplyr::tibble(
  depart = c(colnames(time_matrix)[under_threshold_indices[,'col']],
             rownames(under_threshold_indices)),
  arrivee = c(rownames(under_threshold_indices),
              colnames(time_matrix)[under_threshold_indices[,'col']])
)
