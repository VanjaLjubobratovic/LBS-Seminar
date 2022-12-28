rm(list=ls())

wd <- ("/home/vanja/Desktop/LBS-Seminar/")
setwd(wd)

library(raster)
library(rgdal)

#elevation <- raster(paste0(wd, "N45E014.SRTMGL1.hgt.zip"))
elevation <- raster(paste0(wd, "srtm_40_04.tif"))
elevation

image(elevation)
plot(elevation, main="Digital elevation model", maxpixels = 2000000)