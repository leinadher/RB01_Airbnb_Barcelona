#29.01.2024

library(ggplot2)
library(ggthemes)
library(tidyr)
library(dplyr)

setwd("~/HSLU/24.1 Second Semester/W.MSCIDS_RB01.H23 - R-Bootcamp/00 Project")

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

Barcelona$room_type <- as.factor(Barcelona$room_type)

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
mean(Rome$price, na.rm = TRUE)
mean(Zurich$price, na.rm = TRUE)

# Number of reviews means
mean(Barcelona$number_of_reviews, na.rm = TRUE)
mean(Rome$number_of_reviews, na.rm = TRUE)
mean(Zurich$number_of_reviews, na.rm = TRUE)

# Number of reviews medians
median(Barcelona$number_of_reviews, na.rm = TRUE)
median(Rome$number_of_reviews, na.rm = TRUE)
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

# The following plot shows a seasonality every 3 months:
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
  geom_point() +
  labs(title = "Gráfico de dispersión de Número de Revisiones vs Precio",
       x = "Número de Revisiones",
       y = "Precio") +
  theme_minimal()

################################################################################

# SCATTERPLOT: Price per Neighbourhood Group

# Crear el gráfico de dispersión
ggplot(Barcelona, aes(x = neighbourhood_group, y = price)) +
  geom_violin() +
  geom_jitter(width = 0.2, alpha = 0.5) +
  scale_y_log10() +
  labs(title = "Scatter Plot of Neighbourhood Group vs Price",
       x = "Neighbourhood Group",
       y = "Price") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


################################################################################

ggplot(Barcelona, aes(x = neighbourhood_group, fill = room_type)) +
  geom_histogram(stat = "count", position = "stack") +
  labs(title = "Histograma Apilado por Barrio y Tipo de Alojamiento",
       x = "Barrio",
       y = "Cantidad") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

################################################################################

ggplot(Barcelona, aes(x = neighbourhood_group, fill = room_type)) +
  geom_histogram(stat = "count", position = "stack") +
  labs(title = "Histograma Apilado por Barrio y Tipo de Alojamiento",
       x = "Barrio",
       y = "Cantidad") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

################################################################################

df_separated <- Barcelona %>%
  separate(name, into = paste("name_part", 1:10, sep = "_"), sep = " ", extra = "merge")

# Muestra las primeras filas del dataframe modificado
head(df_separated)
