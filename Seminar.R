rm(list=ls())

wd <- ("E:\\Fakultet\\Usluge zasnovane na lokaciji\\Seminar") # Ovdje promjeni samo svoj put
setwd(wd)

library(raster)
library(rgdal)
library(ggvoronoi)

elevationUp <- raster(paste0("N45E014.hgt"))
elevationDown <- raster(paste0("N44E014.hgt"))
elevationMerge <- mosaic(elevationUp, elevationDown, fun = mean) # S ovom funkcijom spajam ove odvojene karte

#pt <- cbind(14.61, 45.1) # Koordinate centra Krka stavio odokativno
# S ovim ih prikazao

#size <- 0.21
#e <- extent(pt[1]-size, pt[1]+size, pt[2]-size, pt[2]+size)

#plot(elevationMerge, main = "Digital elevation model", ext = e)
#points(pt)


print(elevationMerge)
map <- crop(elevationMerge, extent(14.43, 14.82, 44.95, 45.2)) # S ovim sam odrezao na dimenzije krka
ed = as.data.frame(map, xy = TRUE)  #pretvara se u data frame, ima x,y (koordinate) i layer kao visinu

ed = ed[seq(1, ncell(ed), 100), ] # Ovdje promjenio s stavio ncell i smanjio na 100 iako ncell ili nrow ne vidim neku razliku 

layout <- ggplot(ed) + geom_voronoi(aes(x, y, fill = layer)) #voronoi, treba promjenit boju, dat vise podataka itd.
print(layout)