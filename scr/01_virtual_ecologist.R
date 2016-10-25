######################################################################################
#
# Title: Lesson 1 - Virtual ecologist
# Course: Using R to work with marine spatial data
#
# Author: David March, PhD
# Email: dmarch@socib.es
# Website: https://github.com/dmarch/r-marine
# Last revision: 2016/10/25
#
# Keywords: R, marine, data, sampling design, simulation, distributions, GIS, map, vector
#
# Copyright 2016 SOCIB
# The script is distributed under the terms of the GNUv3 General Public License
#
######################################################################################


#----------------------------------------------
# Load required libraries
#----------------------------------------------
library(leaflet)
library(raster)
library(maptools)
library(sp)
#----------------------------------------------


#----------------------------------------------
# Part 1: Create your sampling area
#----------------------------------------------
# Define your sampling area using a bounding box (x: longitude, y: latitude)
# Note: you can use Google Earth to explore your area, get latitude and longitude,
# and define your own
xmin = 2
xmax = 4
ymin = 38
ymax = 39
e <- extent(c(xmin, xmax, ymin, ymax)) # create extent
box <- as(e, "SpatialPolygons") # coerce to a SpatialPolygons object
plot (box)  # now the plot is not meaningful... we need some base maps
#----------------------------------------------


#----------------------------------------------
# Part 2: Create your first map using leaflet
#----------------------------------------------
# Add sampling area to the map
map <- leaflet() %>%
  addProviderTiles("Esri.OceanBasemap") %>%  # Base map
  setView(lng=2.8, lat=39, zoom=8) %>%  # Position to center map and zoom level
  addPolygons(data=box, fillColor="transparent")  # add bounding box
map  # plot map
#----------------------------------------------


#----------------------------------------------
# Part 3: Spatial sampling design
#----------------------------------------------
# Define input parameters
n = 100  # number of sampling stations
type = "random"  # options: regular, random, stratified, nonaligned, hexagonal, clustered, Fibonacci

# Create sampling stations inside your study area
set.seed(123)  # set seed for random
pts <- spsample(box, n, type, pretty=TRUE)  # run ?spsample for further options

# Plot your results
plot(box)
points(pts, col="red", pch=19)
#----------------------------------------------


#----------------------------------------------
# Part 4: Simulate presence/absence data
#----------------------------------------------
# Convert to data.frame and manipulate some basics
data <- data.frame(pts) # convert to data.frame
names(data) <- c("lon", "lat")  # change column names
data$id <- 1:nrow(data)  # create station id based on number of rows
head(data)  # explore first rows of your data set

# Use binomial distribution to generate 1-0 data
set.seed(1234)
data$presence <- rbinom(n, size=1, prob=0.6)  # 60% probability for presence
hist(data$presence)  # histogram
n.pre <- length(which(data$presence == 1))  # count number of presences
head(data)
#----------------------------------------------


#----------------------------------------------
# Part 5: Simulate abundance data
#----------------------------------------------
# Use normal distribution
set.seed(123)
val <- rnorm(n.pre, mean=50, sd=10)  # simulate abundance data
hist(val)  # histogram
mean(val)  # mean value
sd(val)  # standard deviation
data$abundance <- NA  # create new column with NA data
data$abundance[data$presence == 1] <- val  # assign values on those locations where there is a presence
head(data)
#----------------------------------------------


#----------------------------------------------
# Part 6: Map your data
#----------------------------------------------
# Color palette
pal <- colorFactor(c("red", "yellow"), domain = c("1", "0"))

# Leaflet map
map <- leaflet() %>%
  addProviderTiles("Esri.OceanBasemap") %>%  # Base map
  setView(lng=2.8, lat=39, zoom=8) %>%  # Position to center map and zoom level
  addCircles(data=data,  # add sampling stations
             color = ~pal(presence),  # presence/absence is represented by color
             radius= ~abundance*50,  # abundance is represented by radius of circles
             weight = 3,
             fillOpacity = 0.5)
map  # plot map
#----------------------------------------------


#----------------------------------------------
# Part 7: Export your new generated data
#----------------------------------------------
#### Sampling stations (POINTS)
# Export to CSV
write.table(data, "output/stations.csv", sep=";", dec=",", row.names=FALSE)  # to csv

# Export to shapefile
coordinates(data)= ~lon+lat  # convert to sp class
proj4string(data) <- CRS("+init=epsg:4326")  # define CRS
writePointsShape(data, "output/stations")  # save shapefile

# Export to KML
kmlPoints(obj = data,
          kmlfile = "output/stations.kml",
          kmlname = "Sampling stations",
          icon = "http://maps.google.com/mapfiles/ms/micons/blue.png",
          description = paste("<b>Station ID:</b>", data$id,
                               "<br><b>Longitude:</b>", data$lon,
                               "<br><b>Latitude:</b>", data$lat,
                               "<br><b>Presence:</b>", data$presence,
                               "<br><b>Abundance:</b>", data$abundance)              
          )

#### Study area (POLYGONS)
# Export to shapefile
box <- SpatialPolygonsDataFrame(box, data=data.frame(area=1))  # convert to SPDF
writePolyShape(box, "output/area")

# Export to KML
kmlPolygons(obj = box,
          kmlfile = "output/area.kml",
          kmlname = "Sampling area")
#----------------------------------------------
