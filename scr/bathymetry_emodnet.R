

library(raster)
library(leaflet)
library(RColorBrewer)

### Import data from EMODNET Bathymetry Portal
bat <- raster("tutorial_marine_gis/data/emodnet-mean.tif")
plot(bat)


pal <- colorNumeric(c("#FFFFCC", "#41B6C4", "#0C2C84"), domain=c(0, max(values(bat), na.rm=T)),#values(bat),
                    na.color = "transparent")

### Plot with leaflet
leaflet() %>%
  addProviderTiles("Esri.OceanBasemap", group="Esri Ocean") %>%  # Base map
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