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

# Structure of data:
str(Barcelona)
str(Zurich)

# Dimensions:
dim(Barcelona)
dim(Zurich)

# All data sets contain the same number of variables
# Barcelona and Rome contain significantly more listings

################################################################################

# KEY METRIC ANALYSIS

# Price means
mean(Barcelona$price, na.rm = TRUE)
mean(Zurich$price, na.rm = TRUE)

# Number of reviews means
mean(Barcelona$number_of_reviews, na.rm = TRUE)
mean(Zurich$number_of_reviews, na.rm = TRUE)

# Number of reviews medians
median(Barcelona$number_of_reviews, na.rm = TRUE)
median(Zurich$number_of_reviews, na.rm = TRUE)

################################################################################

# BARPLOTS: Frequency of room types:

gradientZH <- colorRampPalette(c("blue", "lightblue"))
gradientBCN <- colorRampPalette(c("red", "pink"))

par(mfrow = c(1, 2))

barplot(table(Barcelona$room_type),
        main = "Barcelona",
        xlab = "Room Type",
        ylab = "Frequency",
        col = gradientBCN(4))

barplot(table(Zurich$room_type),
        main = "Zurich",
        xlab = "Room Type",
        ylab = "Frequency",
        col = gradientZH(4))

################################################################################

# BOXPLOTS: Price per Neighbourhood Group

par(mfrow = c(2, 1))

# BARCELONA

# Extract unique levels of neighbourhood_group
unique_neighbourhoods <- unique(Barcelona$neighbourhood_group)
# Use the color palette for each neighbourhood group
boxplot(Barcelona$price ~ Barcelona$neighbourhood_group, 
        outline = FALSE, 
        main = "Barcelona - Price per Neighbourhood",
        xlab = "Neighbourhood group",
        ylab = "Euro",
        col = gradientBCN(length(unique_neighbourhoods)))

# ZURICH

# Extract unique levels of neighbourhood_group
unique_neighbourhoods <- unique(Zurich$neighbourhood_group)
# Use the color palette for each neighbourhood group
boxplot(Zurich$price ~ Zurich$neighbourhood_group,  # Corrected: Use Zurich data
        outline = FALSE, 
        main = "Zurich - Price per Neighbourhood",
        xlab = "Neighbourhood group",
        ylab = "CHF",
        col = gradientZH(length(unique_neighbourhoods)))

################################################################################

# SCATTERPLOT: Price per Availability

plot(Barcelona$availability_365,
     Barcelona$price,
     col = "darkgrey",
     xlim = c(0, 365),
     ylim = c(0, 2000),
     pch = 16,
     cex = 0.4,
     main = "Price per availability",
     xlab = "Availability in days",
     ylab = "Price in euros")

################################################################################

# SCATTERPLOT: Price per Reviews

filtered_data <- subset(Barcelona, number_of_reviews < 5000 & price < 1200)

# Crear el gráfico de dispersión
ggplot(filtered_data, aes(x = number_of_reviews, y = price)) +
  geom_point(width = 0.2, alpha = 0.5) +
  labs(title = "Review Number vs Price",
       subtitle = "Barcelona",
       x = "Number of reviews",
       y = "Precio") +
  theme_minimal()

################################################################################

# SCATTERPLOT: Price per Neighbourhood Group

ggplot(Barcelona, aes(x = neighbourhood_group, y = price)) +
  geom_violin() +
  geom_jitter(width = 0.2, alpha = 0.25) +
  scale_y_log10() +
  labs(title = "Neighbourhood vs Price",
       subtitle = "Barcelona",
       x = "Neighbourhood",
       y = "Price") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


################################################################################

# STACKED HISTOGRAM: Room Type per Neighbourhood

ggplot(Barcelona, aes(x = neighbourhood_group, fill = room_type)) +
  geom_histogram(stat = "count", position = "stack") +
  labs(title = "Room Type per Neighbourhood",
       subtitle = "Barcelona",
       x = "Neighbourhood",
       y = "Frequency") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

################################################################################

df_separated <- Barcelona %>%
  separate(name,
           into = paste("name_part", 1:10, sep = "_"),
           sep = " ",
           extra = "merge")

head(df_separated)
