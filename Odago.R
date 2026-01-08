# Remove old rJava and reinstall
remove.packages("rJava")
install.packages("rJava", dependencies = TRUE)

# Set Java options before loading
options(java.parameters = "-Xmx4g")  # Adjust memory as needed
library(rJava)
setwd("E:/Modelling Odago")
getwd()

library(usdm)
library(sf)
library(dplyr)
library(tidyverse)
library(leaflet)
library(raster)
library(sp)
library(dismo)
library(patchwork)
library (ENMeval)
library(usdm)
library(terra)
library(geodata)
library(rnaturalearth)
library(terra)
library(sdm)
bounds <- aggregate(vect(ne_countries(continent = "Africa")))
plot(bounds)
#Load occurrence data
occ <- read.csv("Anisopus.csv")
head(occ)
dim(occ)
occ <- occ |> mutate (species = 1) |> 
  dplyr::select(species, longitude, latitude)

occ_unique <- occ |> 
  unique() |> 
  vect(geom = c ("longitude",
                 "latitude"),
       crs = "epsg:4326") # Using terra, not sf

occ_sf <- crop(occ_unique, bounds) 
plot(occ_sf, add = T)
#occ_sp <- as_Spatial(occ_unique)
#Load the present dataset
present <- rast("present2_Africa.tif")
present
plot(present)

names(present) <- gsub("wc2.1_2.5m_bio_", "bio", names(present))
plot(present)

v <- vifcor(present)
v
#exclude the highly correlated variables
present <- exclude(present, v)
names(present)



#future dataset
fut_21_40_45 <- rast("africa_ssp245_2021-2040.tif")
names(fut_21_40_45)
names(fut_21_40_45) <- gsub("wc2.1_30s_bioc_CMCC-ESM2_ssp245_2021-2040_", "bio", names(fut_21_40_45))
names(fut_21_40_45)
fut_21_40_45 <- exclude(fut_21_40_45, v)
names(fut_21_40_45)

fut_21_40_85 <- rast("africa_ssp585_2021-2040.tif")
names(fut_21_40_85)
names(fut_21_40_85) <- gsub("wc2.1_30s_bioc_CMCC-ESM2_ssp585_2021-2040_", "bio", names(fut_21_40_85))
fut_21_40_85 <- exclude(fut_21_40_85, v)
names(fut_21_40_85)

fut_41_60_45 <- rast("africa1_ssp245_2041-2060.tif")
names(fut_41_60_45)
names(fut_41_60_45) <- gsub("wc2.1_30s_bioc_CMCC-ESM2_ssp245_2041-2060_", "bio", names(fut_41_60_45))
v <- vifcor(present)
v
names(present)

fut_41_60_45 <- exclude(fut_41_60_45,v)
names(fut_41_60_45)

fut_41_60_85 <- rast("africa_ssp585_2041-2060.tif")
names(fut_41_60_85)
names(fut_41_60_85) <- gsub("wc2.1_30s_bioc_CMCC-ESM2_ssp585_2041-2060_", "bio", names(fut_41_60_85))
fut_41_60_85 <- exclude(fut_41_60_85, v)
names(fut_41_60_85)

#FOR ANALYSIS

occ <- occ |> dplyr::select(longitude = longitude, 
                            latitude = latitude)
occ <- occ |> unique ()

occ_renamed <- occ %>%
  rename(x = longitude, y = latitude)

remotes::install_github("rspatial/dismo")
1

bg_points <- spatSample(present, size = 10000, method = "random", 
                        na.rm = TRUE, as.points = TRUE)  

bg_df <- as.data.frame(crds(bg_points), col.names = c("lon", "lat"))
#bg <- randomPoints(present, n = 10000)
#bg <- terra::spatSample(
# present[[9]],  # Use 9th layer
# size = 10000,
#method = "random",
# na.rm = TRUE,
#xy = TRUE
#) %>% 
#as.data.frame()

# 2. Match column names to occurrence data
#colnames(bg) <- colnames(occ)

#bg <- dismo::randomPoints(present[[4]], n = 10000) %>% as.data.frame()
colnames(bg_df) <- colnames(occ_renamed)

tune.args <- list(fc = c("L", "LQ", "H", "LQH", "LQHP"), 
                  rm = c (1,3,5))

#ENMeval
library(ENMeval)
maxent_tuning <- ENMevaluate(
  occs = occ_renamed,
  envs = present,
  bg = bg_df,
  algorithm = "maxent.jar",
  tune.args = tune.args,
  partitions = "block",
  partition.settings = list(orientation = "lat_lon", aggregation.factor = 2),  # Correct argument name
  #doClamp = TRUE,
  #parallel = TRUE,
  numCores = 2
)


write.csv (maxent_tuning@results, 
           file = "E:/Modelling Odago/tuning_results.csv")

# Select the four models with highest testing AUC
t_results <- maxent_tuning@results
t_results <- t_results [order (t_results$auc.val.avg, decreasing = TRUE),]
t_results <- t_results [1:4,]

# among these, select the model with the lowest AUC_diff
l <- which.min(t_results$auc.diff.avg)
tune_args <- as.character(t_results$tune.args[l])
bestmod <- which (maxent_tuning@results$tune.args == tune_args)

# Get evaluation metrics of this model
bestmod_eval <- maxent_tuning@results[bestmod,]
bestmod_eval

# Save model evaluation metrics of the best model
write.csv (bestmod_eval, file = "E:/Modelling Odago/evaluation_best_model.csv")



options(java.parameters = "-Xmx4g")  # 4GB RAM (use 8g/16g if you have 16GB+ RAM)
library(rJava)
library(dismo)

install.packages("pryr")
library(pryr)
mem_used() 
# Make predictions of the best model
pr <- raster::predict(present, 
                      maxent_tuning@models[[bestmod]], 
                      type = 'cloglog')

pr_fut_21_40_45 <- raster::predict(fut_21_40_45,
                                   maxent_tuning@models[[bestmod]],
                                   type = 'cloglog')
pr_fut_21_40_85 <- raster::predict(fut_21_40_85,
                                   maxent_tuning@models[[bestmod]],
                                   type = 'cloglog')
pr_fut_41_60_45 <- raster::predict(fut_41_60_45, 
                                   maxent_tuning@models[[bestmod]], 
                                   type = 'cloglog')

pr_fut_41_60_85 <- raster::predict(fut_41_60_85, 
                                   maxent_tuning@models[[bestmod]], 
                                   type = 'cloglog')

# Save predictions
writeRaster (pr, "E:/Modelling Odago/current.tif")
writeRaster (pr_fut_21_40_45, "E:/Modelling Odago/fut_21_40_45.tif")
writeRaster (pr_fut_21_40_85, "E:/Modelling Odago/fut_21_40_85.tif")
writeRaster (pr_fut_41_60_45, "E:/Modelling Odago/fut_41_60_45.tif")
writeRaster (pr_fut_41_60_85, "E:/Modelling Odago/fut_41_60_85.tif")

# extract suitability for presence points
pres <- occ_renamed [which (occ_renamed$species == 1),]
pres_coordinates <- data.frame(geom(pres))[,c("x", "y")]
suit_pres <- terra::extract(pr, pres_coordinates)

# extract suitability for background points
bg <- as_Spatial (st_as_sf (bg_df, coords = c ("longitude", "latitude"), crs = 4326))

bg_coordinates <- data.frame(geom(bg))[,c("x", "y")]
suit_bg <- terra::extract(pr, bg_coordinates)

# Convert to dataframes
pr_df <- as.data.frame(pr, xy = TRUE) |> na.omit()
pr_fut_21_40_45_df <- as.data.frame(pr_fut_21_40_45, xy =TRUE) |> na.omit()
pr_fut_21_40_85_df <- as.data.frame(pr_fut_21_40_85, xy = TRUE) |> na.omit() 
pr_fut_41_60_45_df <- as.data.frame(pr_fut_41_60_45, xy = TRUE) |> na.omit() 
pr_fut_41_60_85_df <- as.data.frame(pr_fut_41_60_85, xy = TRUE) |> na.omit()

library(ggplot2)
plot1 <- ggplot (data = pr_df) +
  geom_tile (aes (x = x, y = y, fill =  lyr1)) +
  scale_fill_gradient (low = "gray90", high = "blue",
                       breaks=c (0,0.5,1),
                       labels=c ("0.0",0.5,"1.0"),
                       limits=c (0,1)) +
  coord_quickmap () +
  theme_classic () +
  theme (text = element_text (size = 10),
         legend.title=element_text(size = 8),
         legend.position = c(0.15, 0.25),
         legend.key.size = unit(0.3, "cm"),
         legend.background=element_rect(fill = scales::alpha("white", 0)),
         legend.key=element_rect (fill = scales::alpha ("white", .5))) +
  labs (x = "Longitude (°E)", y = "Latitude (°N)",
        fill = "Suitability")

plot2 <- ggplot (data = pr_fut_21_40_45_df) +
  geom_tile (aes (x = x, y = y, fill =  lyr1)) +
  scale_fill_gradient (low = "gray90", high = "blue",
                       breaks=c (0,0.5,1),
                       labels=c ("0.0",0.5,"1.0"),
                       limits=c (0,1)) +
  coord_quickmap () +
  theme_classic () +
  theme (text = element_text (size = 10),
         legend.title=element_text(size = 8),
         legend.position = c(0.15, 0.25),
         legend.key.size = unit(0.3, "cm"),
         legend.background=element_rect(fill = scales::alpha("white", 0)),
         legend.key=element_rect (fill = scales::alpha ("white", .5))) +
  labs (x = "Longitude (°E)", y = "Latitude (°N)",
        fill = "Suitability")

plot3 <- ggplot (data = pr_fut_21_40_85_df) +
  geom_tile (aes (x = x, y = y, fill =  lyr1)) +
  scale_fill_gradient (low = "gray90", high = "blue",
                       breaks=c (0,0.5,1),
                       labels=c ("0.0",0.5,"1.0"),
                       limits=c (0,1)) +
  coord_quickmap () +
  theme_classic () +
  theme (text = element_text (size = 10),
         legend.title=element_text(size = 8),
         legend.position = c(0.15, 0.25),
         legend.key.size = unit(0.3, "cm"),
         legend.background=element_rect(fill = scales::alpha("white", 0)),
         legend.key=element_rect (fill = scales::alpha ("white", .5))) +
  labs (x = "Longitude (°E)", y = "Latitude (°N)",
        fill = "Suitability")
plot3


plot4 <- ggplot (data = pr_fut_41_60_45_df) +
  geom_raster (aes (x = x, y = y, fill =  lyr1)) +
  scale_fill_gradient (low = "gray90", high = "blue",
                       breaks=c (0,0.5,1),
                       labels=c ("0.0",0.5,"1.0"),
                       limits=c (0,1)) +
  coord_quickmap () +
  theme_classic () +
  theme (text = element_text (size = 10),
         legend.title=element_text(size = 8),
         legend.position = c(0.15, 0.25),
         legend.key.size = unit(0.3, "cm"),
         legend.background=element_rect(fill = scales::alpha("white", 0)),
         legend.key=element_rect (fill = scales::alpha ("white", .5))) +
  labs (x = "Longitude (°E)", y = "Latitude (°N)",
        fill = "Suitability")
library(ggplot2)
pr_fut_41_60_85_df <- na.omit(pr_fut_41_60_85_df)
plot5 <- ggplot (data = pr_fut_41_60_85_df) +
  geom_raster (aes (x = x, y = y, fill =  lyr1)) +
  scale_fill_gradient (low = "gray90", high = "blue",
                       breaks=c (0,0.5,1),
                       labels=c ("0.0",0.5,"1.0"),
                       limits=c (0,1)) +
  coord_quickmap () +
  theme_classic () +
  theme (text = element_text (size = 10),
         legend.title=element_text(size = 8),
         legend.position = c(0.15, 0.25),
         legend.key.size = unit(0.3, "cm"),
         legend.background=element_rect(fill = scales::alpha("white", 0)),
         legend.key=element_rect (fill = scales::alpha ("white", .5))) +
  labs (x = "Longitude (°E)", y = "Latitude (°N)",
        fill = "Suitability")

p1<-rast("fut_21_40_45.tif")
p
plot(p)
p2<-rast("current.tif")
plot(p2)
(plot1 + plot2 + plot3)/ 
(plot4 + plot5) +
  plot_layout (widths = c (3, 3))

wrap_plots (plot1, plot2, plot3, 
            plot4, plot5) + plot_annotation (tag_levels = "A")
ggsave ("E:/Alazar/Modelling/new/new/suitability.png", 
        dpi = 400, width = 10, height = 7)


####To try
# Read rasters with terra
current <- rast("E:/Modelling Odago/current.tif")

# Direct plotting without converting to dataframe
library(terra)
install.packages("tidyterra")
library(tidyterra)
plot1 <- ggplot() +
  geom_spatraster(data = current) +
  scale_fill_gradient(
    low = "gray90", 
    high = "blue",
    limits = c(0, 1),  # Fixed: limits should be length-2 vector (min, max)
    breaks = seq(0, 1, by = 0.5),  # Proper way to set breaks
    na.value = NA
  ) +
  coord_sf() +
  theme_classic() +
  labs(fill = "Suitability") +
  theme(legend.position = c(0.15, 0.25))

fut_21_40_45 <- rast("E:/Modelling Odago/fut_21_40_45.tif")
plot2 <- ggplot() +
  geom_spatraster(data = fut_21_40_45) +
  scale_fill_gradient(
    low = "gray90", 
    high = "blue",
    limits = c(0, 1),  # Fixed: limits should be length-2 vector (min, max)
    breaks = seq(0, 1, by = 0.5),  # Proper way to set breaks
    na.value = NA
  ) +
  coord_sf() +
  theme_classic() +
  labs(fill = "Suitability") +
  theme(legend.position = c(0.15, 0.25))

fut_21_40_85 <- rast("E:/Modelling Odago/fut_21_40_85.tif")
plot3 <- ggplot() +
  geom_spatraster(data = fut_21_40_85) +
  scale_fill_gradient(
    low = "gray90", 
    high = "blue",
    limits = c(0, 1),  # Fixed: limits should be length-2 vector (min, max)
    breaks = seq(0, 1, by = 0.5),  # Proper way to set breaks
    na.value = NA
  ) +
  coord_sf() +
  theme_classic() +
  labs(fill = "Suitability") +
  theme(legend.position = c(0.15, 0.25))

fut_41_60_45 <- rast("E:/Modelling Odago/fut_41_60_45.tif")
plot4 <- ggplot() +
  geom_spatraster(data = fut_41_60_45) +
  scale_fill_gradient(
    low = "gray90", 
    high = "blue",
    limits = c(0, 1),  # Fixed: limits should be length-2 vector (min, max)
    breaks = seq(0, 1, by = 0.5),  # Proper way to set breaks
    na.value = NA
  ) +
  coord_sf() +
  theme_classic() +
  labs(fill = "Suitability") +
  theme(legend.position = c(0.15, 0.25))

fut_41_60_85 <- rast("E:/Modelling Odago/fut_41_60_85.tif")
plot5 <- ggplot() +
  geom_spatraster(data = fut_41_60_85) +
  scale_fill_gradient(
    low = "gray90", 
    high = "blue",
    limits = c(0, 1),  # Fixed: limits should be length-2 vector (min, max)
    breaks = seq(0, 1, by = 0.5),  # Proper way to set breaks
    na.value = NA
  ) +
  coord_sf() +
  theme_classic() +
  labs(fill = "Suitability") +
  theme(legend.position = c(0.15, 0.25))

wrap_plots (Plot1, plot2, plot3, 
            plot4, plot5) + plot_annotation (tag_levels = "A")
ggsave ("E:/Modelling Odago/suitability.png", 
        dpi = 400, width = 10, height = 7)

