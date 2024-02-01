# 31.01.2024

setwd("~/GitHub/RB01_AirBnB_TwoCities")

library(ggplot2)
library(ggthemes)
library(tidyr)
library(dplyr)
library(plotly)
library(RColorBrewer)
library(httr)
library(jsonlite)
library(stringr)
library(corrplot)
library(reshape2)
theme_minimal() # So that all plots are aesthetically same

################################################################################

# LOADING CITY AIRBNB DATA
# Read listings.csv files from folder with city name, and save as data frame

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

# API CALL AND DATA MERGE
# 1. We obtain demographics data (2023_pad_mdbas_sexe.csv) via API
# 2. We merge listings.csv with demographics data

# API endpoint
api_url <- "https://opendata-ajuntament.barcelona.cat/data/api/action/datastore_search?resource_id=d0e4ec78-e274-4300-a3bc-cb85cf79014d&limit=3000"

# Sending a GET request to the API and check for success
response <- GET(api_url) %>% stop_for_status()

# Extracting content from the response
data <- fromJSON(content(response, "text"), flatten = TRUE)

# The actual data is usually in a specific part of the JSON
# Adjust the following line according to the structure of the JSON response
demographics <- data$result$records[c("Nom_Districte", "Nom_Barri", "Valor")]

# Viewing the first few rows of the dataframe
head(demographics)

# Group by neighborhood, convert 'Valor' to numeric, and sum values
demographics_grouped <- demographics %>%
  group_by(Nom_Barri) %>%
  mutate(Valor = as.numeric(Valor)) %>%  # Convert 'Valor' column to numeric
  summarise(Total_Population = sum(Valor))

# Merge the datasets
Barcelona_md <- left_join(Barcelona, demographics_grouped, by = 
                           c("neighbourhood" = "Nom_Barri"))

################################################################################

# Install and load necessary packages


# Assuming your data is in a dataframe called 'data'
# Read the data (if not already loaded)
# data <- read.xlsx("path_to_your_excel_file.xlsx", sheet = 1)

# Define a function to extract star rating
extract_star_rating <- function(name) {
  matches <- str_extract(name, "★([0-9.]+)")
  as.numeric(gsub("★", "", matches))
}

# Apply the function to the 'name' column
Barcelona_md$star_rating <- sapply(Barcelona_md$name, extract_star_rating)

# Display the first five rows of the modified dataframe
head(Barcelona_md[c("name", "star_rating")], 25)

################################################################################

# PLOT1: FREQUENCY OF EACH ROOM TYPE
# Summarize the data to count the number of each property type
property_counts <- Barcelona_md %>%
  group_by(room_type) %>%
  summarise(quantity = n())

# Create the bar plot
ggplot(property_counts, 
       aes(x = reorder(room_type, quantity), 
           y = quantity, 
           fill = 'red')) +
  geom_bar(stat = "identity") +
  labs(x = "Room Type", 
       y = "Frequency", 
       title = "Frequency of each room type",
       subtitle = "Barcelona") +
  coord_flip() + # Flip the plot to horizontal bars
  guides(fill = FALSE)  # Remove the legend

################################################################################

# PLOT2: CORRELATION PLOT

numeric_data <- Barcelona_md[, sapply(Barcelona_md, is.numeric)]
numeric_data <- numeric_data[, !colnames(numeric_data) %in% c('id',
                                                              'latitude',
                                                              'longitude', 
                                                              'number_of_reviews_ltm')]

cor_matrix <- cor(numeric_data)
corrplot(cor_matrix)
