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
get_station_coordinates <- function(station_name = "Lille Flandres", data = stations_df, verbose = TRUE){
  # Dealing with - and other differences
  station_name_light = stringr::str_replace_all(station_name, pattern="-", replacement = " ")
  station_name_light = stringr::str_squish(station_name_light)
  
  coords <- stations_df |> 
    dplyr::filter(station_name == station_name_light) |> 
    dplyr::summarise(lat = dplyr::first(lat), lon = dplyr::first(lon))
  
  if (verbose) {
    cat(sprintf("%s -> (%f, %f)\n", station_name, coords[1], coords[2]))
  }
}

# Test 
# get_station_coordinates("Toulouse-Matabiau")
