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
library(plotKML)
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


### Map algebra
cellStats(wmop, "mean")  # calculate mean for each layer
wmop.mean <- calc(wmop, fun=mean)  # create mean map using all layers
wmop.sd <- calc(wmop, fun=sd)  # create sd map using all layers
plot(wmop.mean)
plot(wmop.sd)
#----------------------------------------------







### Plot sea surface velocity (meter second-1)

# prepare raster stack
u <- raster("data/wmop.nc", varname="u", stopIfNotEqualSpaced=FALSE)  # eastward sea surface velocity
v <- raster("data/wmop.nc", varname="v", stopIfNotEqualSpaced=FALSE)  # northward sea surface velocity
uv <- stack(u,v)

# plot vector and streamlines
vectorplot(uv, isField = 'dXY', par.settings = RdBuTheme, narrows=1000)
streamplot(uv, isField = 'dXY')








#----------------------------------------------
# Part 3: Time series of layers
#----------------------------------------------

library(zoo)
getZ(wmop)  # get time values for each layer
wmop.daily.mean <- zApply(wmop, by=as.Date, fun=mean, name="day")  # calculate daily means
plot(wmop.daily.mean)


# animations
animate(wmop, pause=0.25)


#----------------------------------------------
# Part 4: Integrate data
#----------------------------------------------


# Extract data using study area

# Simulate date time information for sampling stations

# Overlay bathymetry and slope


#----------------------------------------------
# Part 5: Time series data
#----------------------------------------------



### ADDITIONAL EXERCISES

# Exercise 1: Incorporate depth and slope to sampling stations
# Exercise 2: Create web map with pop-ups at sampling stations showing integrated data



