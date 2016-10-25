######################################################################################
#
# Title: Lesson 3 - Pelagic ecosystems
# Course: Using R to work with marine spatial data
#
# Author: David March, PhD
# Email: dmarch@socib.es
# Website: https://github.com/dmarch/r-marine
# Last revision: 2016/10/25
#
# Keywords: R, marine, data, GIS, map, raster, ROMS, numerical model, time series
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
library(rasterVis)
library(httr)
library(ncdf4)
library(maptools)
library(dygraphs)
library(zoo)
#----------------------------------------------


#----------------------------------------------
# Part 1: Import ROMS from SOCIB (WMOP)
#----------------------------------------------

# Check slides to get access to SOCIB, navigate throughout the Thredds catalog,
# find the data of interest, and use the NetcdfSubset service.

# Get data though NetcdfSubset service from SOCIB (http://thredds.socib.es/thredds)
# Data correspond to:
# - Model: WMOP (ROMS SOCIB numerical model)
# - Product: Aggregated best time series
# - Variables: Temperature, salinity, u, v
# - Spatial subset: north=41, west=0, east=5, south=37
# - Temporal subset: 2016-10-01T00:00:00Z to 2016-10-05T00:00:00Z
ncss.url <- "http://thredds.socib.es/thredds/ncss/operational_models/oceanographical/hydrodynamics/model_run_aggregation/wmop/wmop_best.ncd?var=salt&var=temp&var=u&var=v&north=41&west=0&east=5&south=37&disableProjSubset=on&horizStride=1&time_start=2016-10-01T00%3A00%3A00Z&time_end=2016-10-05T00%3A00%3A00Z&timeStride=1&addLatLon=true&accept=netcdf"
GET(ncss.url, write_disk("data/wmop.nc", overwrite = TRUE))



#----------------------------------------------
# Part 2: Inspect netCDF
#----------------------------------------------

# Open netcdf
nc <- nc_open("data/wmop.nc")
print(nc)

### Inspect attributes
ncatt_get(nc, varid=0)  # global attributes
ncatt_get(nc, varid="temp")  # attributes for one variable
ncatt_get(nc, varid="time") # attributes for one dimension

### Get data
data <- ncvar_get(nc, varid="temp")
class(data)
dim(data)
## Exercise: Inspect the dimension of the nc and try to gess what is the meaning of dim(data)

nc_close(nc)  # closes netcdf
#----------------------------------------------



#----------------------------------------------
# Part 3: Multidimensional gridded data
#----------------------------------------------

### Import multiband netCDF
wmop <- brick("data/wmop.nc", varname="temp", stopIfNotEqualSpaced=FALSE)  # compare with raster()
plot(wmop)
#animate(wmop)

### Map algebra
cellStats(wmop, "mean")  # calculate mean for each layer
wmop.mean <- calc(wmop, fun=mean)  # create mean map using all layers
wmop.sd <- calc(wmop, fun=sd)  # create sd map using all layers
plot(wmop.mean)
plot(wmop.sd)

### Consider temporal aggregations
getZ(wmop)  # get time values for each layer
wmop.daily.mean <- zApply(wmop, by=as.Date, fun=mean, name="day")  # calculate daily means
plot(wmop.daily.mean)
#----------------------------------------------



#----------------------------------------------
# Part 4: Integrate data
#----------------------------------------------

# Import data genearted previouly
area <- readShapePoly("output/area") # data created in script "01_virtual_ecologist.R"
stations <- readShapePoints("output/stations")  # data created in script "01_virtual_ecologist.R"

# Geographic subset define by study area
wmop.crop <- crop(wmop.mean, area)
plot(wmop.crop)

# OVerlay stations with
plot(wmop.mean)
plot(stations,add=TRUE)
stations <- extract(wmop.mean, stations, method="simple", sp=TRUE)
names(stations)[6] <- "temperature"
head(stations)
#----------------------------------------------


#--------------------------------------------------
# Part 5: Get and Display Time Series from ROMS
#--------------------------------------------------

# NetcdfSubset service has a hidden feature: you can extract a time series for a specific
# station. The web GUI does not provide such option, so you can inspect the example
# provided bellow or check the documentation from unidata at:
# "http://www.unidata.ucar.edu/software/thredds/current/tds/reference/NetcdfSubsetServiceReference.html"

# Get data though NetcdfSubset service from SOCIB (http://thredds.socib.es/thredds)
# Data correspond to:
# - Model: WMOP (ROMS SOCIB numerical model)
# - Product: Aggregated best time series
# - Variables: Temperature, Salinity
# - Station: lon=1.8, lat=40.2
# - Temporal subset: 2016-01-01T00:00:00Z to 2016-09-30T00:00:00Z

# Download data
ncss.url <- "http://thredds.socib.es/thredds/ncss/operational_models/oceanographical/hydrodynamics/model_run_aggregation/wmop/wmop_best.ncd?req=station&var=salt,temp&latitude=40.2&longitude=1.8&time_start=2016-01-01T00%3A00%3A00Z&time_end=2016-09-30T00%3A00%3A00Z&accept=CSV"
GET(ncss.url, write_disk("data/wmop_ts.csv", overwrite = TRUE))

# Read data and convert to zoo class
wmop.ts <- read.table("data/wmop_ts.csv", sep=",", dec=".", header=TRUE)  # read csv
wmop.ts$datetime <- as.POSIXct(wmop.ts$date, format="%Y-%m-%dT%H:%M:%SZ")  # define time class
plot(wmop.ts$datetime, wmop.ts$temp.unit.Celsius., type="l")  # plot time series of temperature

# Plot Time series using Dygraphs
wmop.ts <- zoo(wmop.ts, order.by=wmop.ts$datetime)  # convert to zoo
 
dygraph(wmop.ts$temp.unit.Celsius.) %>%
  dySeries(label="Temperarure (ºC)") %>%
  dyAxis(name="y", drawGrid=TRUE,
         valueRange=c(min(as.numeric(wmop.ts$temp.unit.Celsius.), na.rm=TRUE),
                      max(as.numeric(wmop.ts$temp.unit.Celsius.), na.rm=TRUE))) %>%
  dyRangeSelector(height=20, strokeColor="")
# Now you can zoom dynamically across the time series
#--------------------------------------------------



#----------------------------------------------
### ADDITIONAL EXERCISES

# Exercise 1: Incorporate depth and slope to sampling stations
# Exercise 2: Create web map with pop-ups at sampling stations showing integrated data


# EXTRA BONUS
### Plot sea surface velocity (meter second-1)

# prepare raster stack
u <- raster("data/wmop.nc", varname="u", stopIfNotEqualSpaced=FALSE)  # eastward sea surface velocity
v <- raster("data/wmop.nc", varname="v", stopIfNotEqualSpaced=FALSE)  # northward sea surface velocity
uv <- stack(u,v)

# plot vector and streamlines
vectorplot(uv, isField = 'dXY', par.settings = RdBuTheme, narrows=1000)
streamplot(uv, isField = 'dXY')
#----------------------------------------------


