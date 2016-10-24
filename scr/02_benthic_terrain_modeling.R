######################################################################################
#
# Title: Lesson 2 - Benthic Terrain Modeling
# Course: Using R to work with marine spatial data
#
# Author: David March, PhD
# Email: dmarch@socib.es
# Website: https://github.com/dmarch/r-marine
# Last revision: 24-March-2015
#
# Keywords: R, marine, data, GIS, map, raster, bathymetry, terrain
#
# Copyright 2015 SOCIB
# The script is distributed under the terms of the GNUv3 General Public License
#
######################################################################################


#----------------------------------------------
# Load required libraries
#----------------------------------------------
library(raster)
library(leaflet)
library(RColorBrewer)
#----------------------------------------------


#----------------------------------------------
# Part 1: Import bathymetry from EMODnet
#----------------------------------------------


### Import EMODNET Bathymetry (see download instructions on slides)
bat <- raster("data/emodnet-mean.tif")  # read raster data


### Inspect data
bat
summary(bat)


### Viualize data

# plot using defaults
plot(bat)  




### Plot with leaflet
pal <- colorNumeric(c("#FFFFCC", "#41B6C4", "#0C2C84"), domain=c(0, max(values(bat), na.rm=T)),
                    na.color = "transparent")

leaflet() %>%
  addProviderTiles("Esri.OceanBasemap") %>%  # Base map
  addRasterImage(bat, colors = pal, opacity = 0.8) %>%
  addLegend(pal = pal, values = values(bat),
            title = "Depth")



### Terrain analysis

# Slope
# Hillshade
# Roughness

x <- terrain(bat, opt=c("slope", "aspect", "TPI", "TRI", "roughness", "flowdir"), unit='degrees')
plot(x)



### PCA between bands or pearson to assess cross-correlation

plot(bat*(-1), breaks=esri.ocean(scale="medium",breaks=TRUE),
     col=esri.ocean(scale="medium", alpha=0.5))


### Plot 3D
library(rasterVis)
library(rgl)

myPal <- colorRampPalette(brewer.pal(9, 'Blues'))
plot3D(bat*(-1), col=myPal, rev=TRUE, specular="black")


### Export data