rm(list=ls())

library(raster)
library(tidyverse)
library(rgdal)
library(ggvoronoi)
library(sp)
library(sf)
library(remotes)
library(rgeoboundaries)
library(data.table)
library(rgeos)

elevationUp <- raster(paste0("N45E014.hgt.zip"))
elevationDown <- raster(paste0("N44E014.hgt.zip"))
elevationMerge <- mosaic(elevationUp, elevationDown, fun = mean)

print(elevationMerge)
map <- crop(elevationMerge, extent(14.43, 14.82, 44.936, 45.257))

sf_use_s2(FALSE)
croatia = geoboundaries("Croatia", "adm1")
pgz = subset(croatia, shapeName=="Primorje-Gorski Kotar")
borders = c(xmin = 14.43, ymin = 44.936, xmax = 14.82, ymax = 45.257)
krk = st_crop(pgz, borders)
st_geometry(krk)
krk_geom = krk$geometry
krk_dt = data.table(do.call(cbind, krk_geom[[1]][[2]]))
colnames(krk_dt) = c ("lon", "lat")

klong = unique(krk_dt$long)
klat = unique(krk_dt$lat)
krk_dt[ , `:=` (group = 4)]
ggplot(krk_geom) + geom_sf()


srtmPoints <- rasterToPoints(map)
srtmFrame <- data.frame(srtmPoints)
proj4string(map)

colnames(srtmFrame) = c("lat", "lon", "alt")
srtmFull <- srtmFrame

lonvals <- srtmFrame$lon
latvals <- srtmFrame$lat
lonvals <- unique(lonvals)
latvals <- unique(latvals)

lonvals <- lonvals[seq(9, length(lonvals), 17)]
latvals <- latvals[seq(9, length(latvals), 17)]

srtmFrame <- reshape(srtmFrame, idvar="lon", timevar = "lat", direction = "wide")
#prvi red se briše jer on sadrži lat vrijednosti koje će smetati kod pretvaranja
srtmFrame[,1] <- NULL


newSrtm <- srtmFrame
#uzima se središna točka 17x17 područja
newSrtm = newSrtm[seq(9, nrow(newSrtm), 17), ]
newSrtm = newSrtm[, seq(9, ncol(newSrtm), 17)]
#postavlja se geografska širina i visina
colnames(newSrtm) <- latvals
newSrtm$lon <- lonvals
#podatkovni okvir se pretvara nazad u long format kako bi se mogao koristit za Voronoievu tesalaciju
longSrtm <- melt(setDT(newSrtm), id.vars = "lon", variable.name = "lat")
#postavljaju se imena stupaca
colnames(longSrtm) = c("lat", "lon", "value")
#vrijednost geografske visine se pretvara u numeric za korištenje u Voronoi-u
longSrtm$lon = as.numeric(as.character(longSrtm$lon))

krk_voronoi <- voronoi_polygon(data=longSrtm, x="lon", y="lat", outline=krk_dt)

set.seed(123)
n_points <- 1000
random_indeces <- sample(1:nrow(srtmFull), size=n_points, replace=FALSE)
random_points_df <- srtmFull[random_indeces,]
random_points <- SpatialPointsDataFrame(coords=cbind(random_points_df$lat, random_points_df$lon),
                                        data=data.frame(value=random_points_df$alt))

#Getting a list of all points which are contained within voronoi polygon
points_over_voronoi <- over(random_points, krk_voronoi)

#Removing values at indeces which contain NA
indeces_not_na <- which(!is.na(points_over_voronoi$group))
points_over_voronoi <- points_over_voronoi[indeces_not_na,]
random_points <- random_points[indeces_not_na,]

#Calculating difference between prediction and real value
height_diff <- random_points$value - points_over_voronoi$value
points_in_polygon <- gContains(krk_voronoi, random_points, byid = TRUE)

plot(krk_voronoi)
plot(random_points, col="red", pch=20, add=TRUE)

# ggplot(longSrtm) +
#   scale_fill_gradientn("Elevation", 
#                        colors=c("seagreen","darkgreen","green1","yellow","gold4", "sienna"),
#                        values=scales::rescale(c(-5,0,50,100,200,500))) + 
#   scale_colour_gradientn("Elevation", 
#                         colors=c("seagreen","darkgreen","green1","yellow","gold4", "sienna"),
#                         values=scales::rescale(c(-5,0,50,100,200,500))) + 
#   theme_minimal() +
#   theme(axis.text=element_blank(),
#         axis.title=element_blank()) +
#   geom_path(data=krk_dt, aes(lon, lat, group=group), color="black", size=1.5) +
#   geom_voronoi(aes(lon, lat, fill = value), outline=krk_dt)

