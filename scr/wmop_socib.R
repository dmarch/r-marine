
# https://github.com/aodn/imos-user-code-library/wiki/Using-the-IMOS-User-Code-Library-with-R#21-output-structure
# http://oceanwatch.pifsc.noaa.gov/tutorials.html


library(raster)
library(leaflet)
library(rasterVis)
library(httr)

# Get data though NetcdfSubset service from SOCIB (http://thredds.socib.es/thredds)
url <- "http://thredds.socib.es/thredds/ncss/operational_models/oceanographical/hydrodynamics/wmop/latest.nc?var=salt&var=temp&var=u&var=v&north=41&west=0.7&east=5&south=37&disableProjSubset=on&horizStride=1&time_start=2016-10-24T00%3A00%3A00Z&time_end=2016-10-26T00%3A00%3A00Z&timeStride=1&addLatLon=true&accept=netcdf"
junk <- GET(url, write_disk("data/wmop.nc", overwrite = TRUE))



### Import data from EMODNET Bathymetry Portal
wmop <- brick("data/wmop.nc", varname="temp", stopIfNotEqualSpaced=FALSE)
plot(wmop)


u <- brick("tutorial_marine_gis/data/latest2.nc", varname="u", stopIfNotEqualSpaced=FALSE)
v <- brick("tutorial_marine_gis/data/latest2.nc", varname="v", stopIfNotEqualSpaced=FALSE)
uv <- stack(u,v)


vectorplot(uv, isField = 'dXY', par.settings = RdBuTheme, narrows=1000)
streamplot(uv)




hovmoller(wmop,
          at = seq(19, 25, 0.1),
          panel = panel.levelplot.raster,
          interpolate = TRUE,
          yscale.components = yscale.raster.subticks,
          par.settings = BuRdTheme)

horizonplot(wmop,
            col.regions = rev(brewer.pal(n = 10, 'RdBu')))


### Import data from EMODNET Bathymetry Portal
temp <- raster("tutorial_marine_gis/data/latest2.nc", varname="temp", stopIfNotEqualSpaced=FALSE)
x <- terrain(temp, opt=c("slope", "aspect", "TPI", "TRI", "roughness", "flowdir"), unit='degrees')



