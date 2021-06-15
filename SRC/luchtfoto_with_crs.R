
##Redundant?

library(slippymath)
library(glue)

buurt_py  <- sf::st_transform(buurt_py, 4326)
buurt_py <- st_geometry(buurt_py)
centroid <- sf::st_centroid(st_union(buurt_py))

zoom <- 14

uluru_bbox <- st_bbox(st_bbox(buurt_py),
                      crs = st_crs("+proj=longlat +ellps=WGS84"))

#
tile_grid <- bbox_to_tile_grid(uluru_bbox, zoom = zoom)


tilenum <- slippymath::lonlat_to_tilenum(centroid[[1]][1], centroid[[1]][2], zoom = zoom)

image.loc <- paste0(paste(site, zoom, tilenum$x, tilenum$y, sep="/"),".jpeg")

mapbox_query_string <- image.loc

images <- pmap(tile_grid$tiles,
               function(x, y, zoom) {
                 outfile <- glue("{x}_{y}.jpg")
                 curl_download(url = glue(mapbox_query_string), destfile = outfile) 
                 outfile 
               },
               zoom = tile_grid$zoom)

raster_out <- compose_tile_grid(tile_grid, images)
#plot(raster_out)

names(raster_out) <- c("NIR Band","Red Band","Green Band")

red <- raster_out[["Red.Band"]]
nir <- raster_out[["NIR.Band"]]


panden_py <- sf::st_transform(panden_py, 3857)
panden_py <- st_geometry(panden_py)


#Normalized difference vegetation index (NDVI)
#ndvi <- (nir - red)/(nir + red)
ndvi <- raster::overlay(red, nir, fun = function(x, y) { (y-x) / (y+x) })
plot(ndvi)
plot(panden_py, add = TRUE)
