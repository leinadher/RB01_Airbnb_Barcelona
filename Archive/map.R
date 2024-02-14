
setwd("~/GitHub/RB01_AirBnB_TwoCities/Data/Barcelona")

# Load required libraries
library(ggplot2)
library(dplyr)
library(maptiles)
library(sf)
library(tidyterra)
library(ggmap)

# Load GeoJSON file and convert to sf object
geojson_BCN <- sf::st_read("neighbourhoods.geojson")

# Create bounding box limits and map
bbox.limits <- sf::st_bbox(geojson_BCN)
example.map <- get_tiles(bbox.limits,
                         provider = "OpenStreetMap")
## Plot the map
ggplot(geojson_BCN) +
  ## Add tiles / background map
  geom_spatraster_rgb(data = example.map) +
  ## Add polygons from sf
  geom_sf() +
  theme_minimal()

################################################################################

register_stadiamaps("8df95c0b-0133-4440-b3f0-c1c6e2f26844", write = TRUE)

## Background map
## get_map is a function present in the package ggmap

bbox.limits <- sf::st_bbox(geojson_BCN)

map_BCN <- get_stadiamap(getbb("Barcelona"), maptype = "stamen_toner_lite", zoom = 12)

## Plot map
ggmap(map_BCN) +
  geom_sf(data = geojson_BCN,
          inherit.aes = FALSE) +
  labs(x = "Longitude", y = "Latitude")

################################################################################


# PLOT6: AVERAGE PRICES BY NEIGHBOURHOOD, MAP

register_stadiamaps("8df95c0b-0133-4440-b3f0-c1c6e2f26844", write = TRUE)

# Load GeoJSON file and convert to sf object
geojson_BCN <- sf::st_read("Data/Barcelona/neighbourhoods.geojson")

# Create bounding box limits and map
bbox.limits <- sf::st_bbox(geojson_BCN)
map_BCN <- get_stadiamap(getbb("Barcelona"), maptype = "stamen_toner_lite", zoom = 12)

merged_data <- merge(geojson_BCN, Barcelona_md, by = "neighbourhood", all.x = TRUE)

# Calculate the mean price for each neighborhood
mean_price_by_neighbourhood <- aggregate(price ~ neighbourhood, merged_data, mean)

merged_data <- merge(merged_data, mean_price_by_neighbourhood, by = "neighbourhood")

## Plot map
ggmap(map_BCN) +
  geom_sf(aes(fill = price.y, label = neighbourhood),
          color = "#f1796f", 
          linewidth = 0.4) +
  scale_fill_gradient(low = "white", high = "#f1796f") +
  labs(title = "Average Price by Neighbourhood") +
  labs(x = "Longitude", y = "Latitude")