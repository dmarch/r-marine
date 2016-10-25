######################################################################################
#
# Title: Lesson 2 - Benthic Terrain Modeling
# Course: Using R to work with marine spatial data
#
# Author: David March, PhD
# Email: dmarch@socib.es
# Website: https://github.com/dmarch/r-marine
# Last revision: 2016/10/25
#
# Keywords: R, marine, data, GIS, map, raster, bathymetry, terrain
#
# Copyright 2016 SOCIB
# The script is distributed under the terms of the GNUv3 General Public License
#
######################################################################################


#----------------------------------------------
# Load required libraries
#----------------------------------------------
library(raster)
library(leaflet)
library(rgdal)
library(RColorBrewer)
library(rasterVis)
library(rgl)
#----------------------------------------------


#----------------------------------------------
# Part 1: Import bathymetry from EMODnet
#----------------------------------------------

### Import EMODNET Bathymetry (see download instructions on slides)
bat <- raster("data/emodnet-mean.tif")  # read raster data

### Inspect data
bat
summary(bat)
hist(bat)
plot(bat)  
levelplot(bat)

### Create map
pal <- colorNumeric(c("#FFFFCC", "#41B6C4", "#0C2C84"), domain=c(0, max(values(bat), na.rm=T)),
                    na.color = "transparent")
leaflet() %>%
  addProviderTiles("Esri.OceanBasemap") %>%  # Base map
  addRasterImage(bat, colors = pal, opacity = 0.8) %>%
  addLegend(pal = pal, values = values(bat),
            title = "Depth")



#----------------------------------------------
# Part 2: 3D Plot while doing some map algebra
#----------------------------------------------
myPal <- colorRampPalette(brewer.pal(9, 'Blues'), alpha=TRUE)  # palette
plot3D(bat*(-1), col=myPal, rev=TRUE, specular="black")  # plot 3d with rgl



#----------------------------------------------
# Part 3: Bathymetric Terrain Modeling
#----------------------------------------------

# Calculate terrain characteristic from bathymetry
models <- terrain(bat, opt=c("slope", "aspect", "TPI", "TRI", "roughness", "flowdir"), unit='degrees')
class(models)
models
plot(models)

# Assess correlation between characteristics using pearson
cor<-layerStats(models,"pearson", na.rm=T)
cor

# Hillshade
slope <- subset(models, "slope")  # select slope
aspect <- subset(models, "aspect")  # select slope
hill <- hillShade(slope, aspect, 45, 270)
plot(hill, col = grey(0:100/100), legend = FALSE)
plot(bat, col = rainbow(25, alpha=0.35), add=TRUE)
#----------------------------------------------



#----------------------------------------------
# Part 4: Export your data
#----------------------------------------------

### Save data
writeRaster(slope, filename="output/slope.grd", overwrite=TRUE)  # save binary file for slope
KML(bat, "output/bat.kml", col = myPal(100), overwrite = TRUE)  # save KML file for bathymetry

## EERCISE: Export your multiband raster in netCDF format

