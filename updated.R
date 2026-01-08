install.packages("pacman")
pacman::p_load(rgbif,ggplot2,maps,dplyr)

library(rgbif)
library(ggplot2)
library(maps)
library(dplyr)

# Get Cucumis occurrence data (with coordinates)
cucumis_data <- occ_search(
  scientificName = "Cucumis",
  hasCoordinate = TRUE,
  limit = 1000  # Increase for more records
)

# Check if we got data
if(nrow(cucumis_data$data) == 0) {
  stop("No records found - try removing 'hasCoordinate' filter")
}

# Clean the data
clean_data <- cucumis_data$data %>%
  filter(!is.na(decimalLongitude) & !is.na(decimalLatitude)) %>%
  distinct(decimalLongitude, decimalLatitude, .keep_all = TRUE)

df <- cucumis_data$data %>%
  # Select key columns
  dplyr::select(
    species, decimalLongitude, decimalLatitude,
    country, year, basisOfRecord
  ) %>%
  # Remove rows with NA coordinates
  filter(!is.na(decimalLongitude) & !is.na(decimalLatitude)) %>%
  # Remove duplicate coordinates
  distinct(decimalLongitude, decimalLatitude, .keep_all = TRUE)

# View the dataframe
head(df)








world_map <- map_data("world")

ggplot() +
  geom_polygon(data = world_map, 
               aes(x = long, y = lat, group = group),
               fill = "gray90", color = "gray50") +
  geom_point(data = cucumis_data,
             aes(x = decimalLongitude, y = decimalLatitude),
             color = "darkgreen", size = 2, alpha = 0.6) +
  coord_fixed(ratio = 1.3) +
  labs(title = "GBIF Occurrence Records for Genus Cucumis",
       subtitle = paste(nrow(cucumis_data), "records with coordinates"),
       x = "Longitude", y = "Latitude") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
