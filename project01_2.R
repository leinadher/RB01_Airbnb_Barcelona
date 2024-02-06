# 01.02.2024

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
library(readxl)

# For maps:
library(sf)
library(ggmap)
library(leaflet)
library(osmdata)
library(maptiles)    ## for get_tiles() / used instead of OpenStreetMap
library(tidyterra)   ## for geom_spatraster_rgb() - Background tiles
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

# EXTRACT STAR-RATING FROM NAME, AND ADD AS COLUMN TO DATA FRAME

extract_star_rating <- function(name) {
  matches <- str_extract(name, "★([0-9.]+)")
  as.numeric(gsub("★", "", matches))
}

Barcelona_md$star_rating <- sapply(Barcelona_md$name, extract_star_rating)

head(Barcelona_md[c("name", "star_rating")], 5)

################################################################################

# EXTRACT LICENSE STATUS
# Save to a new column 'LicenseGrouping'

Barcelona_md <- Barcelona_md %>%
  mutate(LicenseGrouping = case_when(
    grepl("Exempt", license, ignore.case = TRUE) ~ "Exempt",
    license != "" & !is.na(license) ~ "License is displayed",
    TRUE ~ "License is not displayed"
  ))

print(Barcelona_md)

################################################################################

# GROUP LARGE TENANTS AND SMALL TENANTS

Barcelona_md <- Barcelona_md %>%
  mutate(TenantSizeGrouping = case_when(
    calculated_host_listings_count >= 10 ~ "Large tenant",
    calculated_host_listings_count <= 9 ~ "Small tenant",
    TRUE ~ NA_character_ # This handles any unexpected cases, such as missing values
  ))

# View the first few rows of the transformed dataset to verify the changes
head(Barcelona_md)

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
       y = "Count", 
       title = "Count of each room type",
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

cor_matrix <- cor(numeric_data, use = "pairwise.complete.obs")
corrplot(cor_matrix, type = "full", tl.col = "black", 
         title = "Correlation of Numerical Values",
         subtitle = "Barcelona",
         tl.srt = 45, # Rotate text labels 45 degrees
         mar = c(0, 0, 2, 0), # Adjust margins to make room for rotated labels
         tl.cex = 0.8, # Adjust text label size
         pch = 15) # Use full squares (ASCII 15)

################################################################################

# PLOT3: LICENSE STATUS

license_count <- Barcelona_md %>%
  group_by(LicenseGrouping) %>%
  summarise(quantity = n())

# Create the bar plot
ggplot(license_count, 
       aes(x = reorder(LicenseGrouping, quantity), 
           y = quantity, 
           fill = 'red')) +
  geom_bar(stat = "identity") +
  labs(x = "",
       y = "Count", 
       title = "License status",
       subtitle = "Barcelona") +
  coord_flip() + # Flip the plot to horizontal bars
  guides(fill = FALSE)  # Remove the legend

################################################################################

# PLOT 4: GREAT AND SMALL TENANTS

tenant_count <- Barcelona_md %>%
  group_by(TenantSizeGrouping) %>%
  summarise(quantity = n())

# Create the bar plot
ggplot(tenant_count, 
       aes(x = reorder(TenantSizeGrouping, quantity), 
           y = quantity, 
           fill = 'red')) +
  geom_bar(stat = "identity") +
  labs(x = "",
       y = "Count", 
       title = "Types of Tenant",
       subtitle = "Barcelona") +
  coord_flip() + # Flip the plot to horizontal bars
  guides(fill = FALSE)  # Remove the legend

################################################################################

# PLOT 5: ROOM TYPE BY NEIGHBOURHOOD

ggplot(Barcelona_md, aes(x = neighbourhood_group)) + 
  geom_bar(aes(fill = room_type), position = "dodge") +
  facet_wrap(~ room_type, scales = "free_y", nrow = 2) +
  theme_minimal() +
  labs(title = "Type of Accommodation per Neighbourhood",
       subtitle = "Barcelona",
       x = "Neighbourhood Group",
       y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_minimal()

################################################################################

# PLOT6: AVERAGE PRICES BY NEIGHBOURHOOD, MAP

# Import geojson and convert to data frame:
Barcelona_geo <- st_read("Data/Barcelona/neighbourhoods.geojson")
Barcelona_geo <- st_make_valid(Barcelona_geo)
print(Barcelona_geo)

merged_data <- merge(Barcelona_geo, Barcelona_md, by = "neighbourhood", all.x = TRUE)

# Calculate the mean price for each neighborhood
mean_price_by_neighbourhood <- aggregate(price ~ neighbourhood, merged_data, mean)

merged_data <- merge(merged_data, mean_price_by_neighbourhood, by = "neighbourhood")

ggplot(merged_data) +
  geom_sf(aes(fill = price.y, label = neighbourhood)) +
  scale_fill_viridis_c() +
  labs(title = "Average Price by Neighbourhood")

# Display with background!

################################################################################

# PLOT 7: LISTINGS BY MINIMUM NIGHTS

# Modify the minimum_nights column to create a '35+' category
Barcelona_md$minimum_nights_grouped <- ifelse(Barcelona_md$minimum_nights > 35, 
                                              "35+",
                                              as.character(Barcelona_md$minimum_nights))

# Convert the column to a factor to control the order in the plot
Barcelona_md$minimum_nights_grouped <- factor(Barcelona_md$minimum_nights_grouped,
                                              levels = c(as.character(1:35),
                                                         "35+"))

# Create the histogram
ggplot(Barcelona_md, aes(x = minimum_nights_grouped)) +
  geom_bar(fill = "darkgrey") +
  labs(x = "Minimum Nights",
       y = "Count",
       title = "Distribution of Listings by Minimum Nights",
       subtitle = "Barcelona") +
  theme(axis.text.x = element_text(angle = 0,
                                   vjust = 0.5, 
                                   hjust = 1))

################################################################################

# PLOT 8: LISTINGS BY HOST

listings_per_host <- Barcelona_md %>%
  group_by(host_id) %>%
  summarize(count = n()) %>%
  ungroup()

# Group all counts of 10 or more into '10+'
listings_per_host$count_grouped <- ifelse(listings_per_host$count > 10,
                                          "10+",
                                          as.character(listings_per_host$count))

# Convert the column to a factor to control the order in the plot
listings_per_host$count_grouped <- factor(listings_per_host$count_grouped,
                                          levels = c(as.character(1:10), 
                                                     "10+"))

# Create the histogram
ggplot(listings_per_host, aes(x = count_grouped)) +
  geom_bar(fill = "darkgrey") +
  labs(x = "Listings per Host",
       y = "Number of Hosts",
       title = "Distribution of Listings per Host",
       subtitle = "Barcelona") +
  theme(axis.text.x = element_text()) +
  theme_minimal()

# 10+ is WRONG!

################################################################################

# PLOT 9: JITTER + VIOLIN PLOT PRICE BY NEIGHBOURHOOD

ggplot(Barcelona, aes(x = neighbourhood_group, y = price)) +
  geom_jitter(width = 0.2,
              alpha = 0.25) +
  geom_violin(fill = NA) +
  scale_y_log10() +
  labs(title = "Neighbourhood vs Price",
       subtitle = "Barcelona",
       x = "Neighbourhood",
       y = "Price") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45))

################################################################################

# PLOT 10: SCATTERPLOT PRICE BY RATING

ggplot(Barcelona_md, aes(x = star_rating, y = price)) +
  geom_point(width = 0.2,
             alpha = 0.25) + # Plot the points
  geom_smooth(method = "lm", color = "red") + # Add linear model line
  labs(title = "Scatter Chart of Star Rating vs. Price with Linear Model",
       subtitle = "Barcelona",
       x = "Star Rating",
       y = "Price") +
  theme_minimal()

################################################################################

# PLOT 11: BOXPLOTS BY PRICE

ggplot(Barcelona_md, aes(x = neighbourhood_group, y = price)) +
  geom_boxplot(fill = "lightblue") +
  scale_y_log10() +
  labs(title = "Price by Neighbourhood",
       subtitle = "Barcelona",
       x = "Neighbourhood",
       y = "Price") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45))

################################################################################

# PLOT 12: BOXPLOTS BY MINIMUM NIGHTS

ggplot(Barcelona_md, aes(x = neighbourhood_group, y = minimum_nights)) +
  geom_boxplot(fill = "lightgreen") +
  scale_y_log10() + # Otherwise boxplot conveys no information
  labs(title = "Minimum Nights by Neighbourhood",
       subtitle = "Barcelona",
       x = "Neighbourhood",
       y = "Minimum Number of Nights") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45))

################################################################################

# PLOT 13: BOXPLOTS BY NUMBER OF REVIEWS

# Hay que ajustar el yscale, o eliminar los outliers. Si no, el plot es plano!

ggplot(Barcelona_md, aes(x = neighbourhood_group, y = number_of_reviews)) +
  geom_boxplot(fill = "lightsalmon") +
  coord_cartesian(ylim = c(0, 200)) + 
  labs(title = "Number of Reviews by Neighbourhood",
       subtitle = "Barcelona",
       x = "Neighbourhood",
       y = "Number of Reviews") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45))

################################################################################

# PLOT 14: TOP 5 HOSTS BY NUMBER OF LISTINGS

top_hosts <- Barcelona_md %>%
  distinct(host_name, .keep_all = TRUE) %>%
  arrange(desc(calculated_host_listings_count)) %>%
  slice_head(n = 5)

# Create the ggplot2 horizontal barplot
ggplot(top_hosts, aes(x = reorder(host_name, calculated_host_listings_count),
                      y = calculated_host_listings_count)) +
  geom_bar(stat = "identity",
           fill = "skyblue", alpha = 0.8) +
  geom_text(aes(label = calculated_host_listings_count), 
            hjust = 2, 
            color = "black",
            size = 3) +
  labs(title = "Top 5 Hosts by Number of Listings",
       subtitle = "Barcelona",
       x = "",
       y = "Listing Count") +
  coord_flip() + # Flip the plot to horizontal bars
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1),
        panel.grid.major.x = element_line(color = "gray"),
        panel.grid.minor.x = element_line(color = "gray")
        )
