library(tidyverse)
library(glue)
library(fs)
library(furrr)

plan(multiprocess)


# Download ----------------------------------------------------------------

download_path <- "https://s3.amazonaws.com/capitalbikeshare-data/2018{month}-capitalbikeshare-tripdata.zip"
download_path <- glue(download_path, month = str_pad(1:12, width = 2, side = "left", pad = "0"))

destination_path <- fs::path("data/raw/capitale_bikeshare/", fs::path_file(download_path))

future_map2(download_path, destination_path, curl::curl_download, .progress = TRUE)

future_map(destination_path, unzip, exdir = "data/raw/capitale_bikeshare/", overwrite = TRUE, .progress = TRUE)

fs::dir_delete("data/raw/capitale_bikeshare/__MACOSX/")
fs::file_delete(destination_path)


# Format data -------------------------------------------------------------

# Clean names and also reduce number of observations

files <- list.files("data/raw/capitale_bikeshare/", full.names = TRUE)

read_bike <- function(file) {
  
  df <- data.table::fread(file) %>% 
    janitor::clean_names() %>% 
    sample_frac(size = 0.1) %>% 
    data.table::fwrite(fs::path("data/clean/capitale_bikeshare/", fs::path_file(file)))
  
}

walk(files, read_bike)
