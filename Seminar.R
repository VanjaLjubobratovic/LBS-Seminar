rm(list=ls())

wd <- ("/home/student/R/Seminar")
setwd(wd)

library(raster)
library(rgdal)
library(ggvoronoi)

elevationUp <- raster(paste0("N45E014.hgt"))
elevationDown <- raster(paste0("N44E014.hgt"))
elevationMerge <- mosaic(elevationUp, elevationDown, fun = mean) # S ovom funkcijom spajam ove odvojene karte
#elevation <- raster(paste0(wd, "N44E014.hgt"))
#elevation

#image(elevationMerge)
#plot(elevationMerge, main="Digital elevation model", maxpixels = 2000000)



pt <- cbind(14.61, 45.1) # Koordinate centra Krka stavio odokativno
# S ovim ih prikazao

size <- 0.21
e <- extent(pt[1]-size, pt[1]+size, pt[2]-size, pt[2]+size)

plot(elevationMerge, main = "Digital elevation model", ext = e)
points(pt)


ed = as.data.frame(elevationMerge, xy = TRUE)  #pretvara se u data frame, ima x,y (koordinate) i layer kao visinu

ed = ed[seq(1, nrow(ed), 10000), ] #uzimam svaki 10000 podatak jer mi se sa svim podacima crasha R,
#                                   a dovoljno je za neke osnovne testove


ggplot(ed) + geom_voronoi(aes(x,y, fill = layer)) #voronoi, treba promjenit boju, dat vise podataka itd.