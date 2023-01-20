rm(list=ls())

wd <- ("/home/vanja/Desktop/LBS-Seminar")
setwd(wd)

library(raster)
library(tidyverse)
library(rgdal)
library(ggvoronoi)
library(sp)
library(sf)
library(dplyr)
library(rnaturalearth)
library(remotes)
library(rgeoboundaries)
library(data.table)

sf_use_s2(FALSE)

california <- map_data("state") %>% filter(region == "california")

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



elevationUp <- raster(paste0("N45E014.hgt.zip"))
elevationDown <- raster(paste0("N44E014.hgt.zip"))
elevationMerge <- mosaic(elevationUp, elevationDown, fun = mean) # S ovom funkcijom spajam ove odvojene karte


print(elevationMerge)
map <- crop(elevationMerge, extent(14.43, 14.82, 44.936, 45.257)) # S ovim sam odrezao na dimenzije krka



srtmPoints <- rasterToPoints(map)
srtmFrame <- data.frame(srtmPoints)

colnames(srtmFrame) = c("lat", "lon", "alt")

lonvals <- srtmFrame$lon
latvals <- srtmFrame$lat
lonvals <- unique(lonvals)
latvals <- unique(latvals)

lonvals <- lonvals[seq(9, length(lonvals), 12)]
latvals <- latvals[seq(9, length(latvals), 12)]

srtmFrame <- reshape(srtmFrame, idvar="lon", timevar = "lat", direction = "wide")
rownames(srtmFrame) <- srtmFrame[,1]
srtmFrame[,1] <- NULL

newSrtm <- srtmFrame
newSrtm = newSrtm[seq(9, nrow(newSrtm), 12), ]
newSrtm = newSrtm[, seq(9, ncol(newSrtm), 12)]


matx <- as.matrix(srtmFrame)
class(matx) <- "numeric"

#res <- tapply(matx, list((row(matx) + 16L) %/% 17L, (col(matx) + 16L) %/% 17L), mean, na.rm = TRUE)
#res[is.nan(res)] <- NA

#lowdata <- data.frame(res)
#colnames(lowdata) <- latvals
#lowdata$lon <- lonvals
library(tidyr)
library(data.table)

#longman <- melt(setDT(lowdata), id.vars = "lon", variable.name = "lat")

colnames(newSrtm) <- latvals
newSrtm$lon <- lonvals
longSrtm <- melt(setDT(newSrtm), id.vars = "lon", variable.name = "lat")
colnames(longSrtm) = c("lat", "lon", "value")

longSrtm$lon = as.numeric(as.character(longSrtm$lon))

ggplot(longSrtm) +
  scale_fill_gradientn("Elevation", 
                       colors=c("seagreen","darkgreen","green1","yellow","gold4", "sienna"),
                       values=scales::rescale(c(-5,0,50,100,200,500))) + 
  scale_color_gradientn("Elevation", 
                        colors=c("seagreen","darkgreen","green1","yellow","gold4", "sienna"),
                        values=scales::rescale(c(-5,0,50,100,200,500))) + 
  theme_minimal() +
  theme(axis.text=element_blank(),
        axis.title=element_blank()) +
  #geom_point(aes(lon, lat, color=value), size=.01) +
  geom_path(data=krk_dt, aes(lon, lat, group=group), color="black", size=1.5) +
  geom_voronoi(aes(lon, lat, fill = value), outline=krk_dt) #voronoi, treba promjenit boju, dat vise podataka itd.