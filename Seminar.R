rm(list=ls())

wd <- ("E:\\Fakultet\\Usluge zasnovane na lokaciji\\Seminar")
setwd(wd)

library(raster)
library(rgdal)

elevationUp <- raster(paste0("N45E014.hgt"))
elevationDown <- raster(paste0("N44E014.hgt"))
elevationMerge <- mosaic(elevationUp, elevationDown, fun = mean) # S ovom funkcijom spajam ove odvojene karte
#elevation <- raster(paste0(wd, "N44E014.hgt"))
#elevation

#image(elevationMerge)
#plot(elevationMerge, main="Digital elevation model", maxpixels = 2000000)

pt <- cbind(14.61, 45.1) # Koordinate centra Krka stavio odokativno
points(pt) # S ovim ih prikazao

size <- 0.21
e <- extent(pt[1]-size, pt[1]+size, pt[2]-size, pt[2]+size)

plot(elevationMerge, main = "Digital elevation model", ext = e)