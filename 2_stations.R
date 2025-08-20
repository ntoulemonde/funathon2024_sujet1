read.csv("https://www.data.gouv.fr/api/1/datasets/r/cbacca02-6925-4a46-aab6-7194debbb9b7", header = TRUE, sep = ";") |> 
  dplyr::rename(station_name=Nom, lat.lon=Position.géographique, citycode = Code.commune) |> 
  dplyr::select(station_name, citycode, lat.lon) |> 
  dplyr::mutate(
    # We extract latitude and longitude 
    lat = as.numeric(stringr::str_extract(lat.lon, pattern = ".*(?=,)")), 
    lon = as.numeric(stringr::str_extract(lat.lon, pattern = "(?<=,).*")), 
    lat.lon = NULL, 
    # Removing all "-" and trimming the result to deal with "-" and multiple spaces
    station_name = stringr::str_replace_all(station_name, pattern="-", replacement = " "),
    station_name = stringr::str_squish(station_name)
  ) -> stations_df

