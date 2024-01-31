# 30.01.2024

setwd("~/GitHub/RB01_AirBnB_TwoCities")

library(ggplot2)
library(ggthemes)
library(tidyr)
library(dplyr)
library(plotly)
library(RColorBrewer) # For loading special colour palettes

# Loading 'listings.csv' files from all city folders:
file_paths <- list.files(pattern = "listings.csv$",
                         recursive = TRUE,
                         full.names = TRUE)

for (file_path in file_paths) {
  # Extract city name from the file path
  city_name <- sub(".*/(\\w+)/listings.csv", "\\1", file_path, perl = TRUE)
  
  # Read CSV file and assign it to a variable with the city name
  assign(city_name, read.csv(file_path))
}

################################################################################