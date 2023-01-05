rm(list=ls())

wd <- ("/home/vanja/Desktop/LBS-Seminar") # Ovdje promjeni samo svoj put
setwd(wd)

library(raster)
library(rgdal)
library(ggvoronoi)

elevationUp <- raster(paste0("N45E014.SRTMGL1.hgt.zip"))
elevationDown <- raster(paste0("N44E014.SRTMGL1.hgt.zip"))
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

ed = ed[seq(1, ncell(ed), 50), ] # Ovdje promjenio s stavio ncell i smanjio na 100 iako ncell ili nrow ne vidim neku razliku 

ggplot(data=ed,aes(x=long,y=lat)) +
            scale_fill_gradientn("Elevation", 
                       colors=c("seagreen","darkgreen","green1","yellow","gold4", "sienna"),
                       values=scales::rescale(c(-60,0,100,200,300,400))) + 
            scale_color_gradientn("Elevation", 
                        colors=c("seagreen","darkgreen","green1","yellow","gold4", "sienna"),
                        values=scales::rescale(c(-60,0,100,200,300,400))) + 
            coord_quickmap() + 
            theme_minimal() +
            theme(axis.text=element_blank(),
                  axis.title=element_blank()) + 
          geom_voronoi(aes(x, y, fill = layer)) #voronoi, treba promjenit boju, dat vise podataka itd.


#print(layout)