
#-----------------------------------------------------------------------------------------------

# Functions

#-----------------------------------------------------------------------------------------------

#numeric to lon/lat bounding box
num2deg <- function(xtile, ytile, zoom){
  n = 2.0^zoom
  
  lon_deg_nw = xtile / n * 360.0 - 180.0
  lat_rad_nw = atan(sinh(pi * (1 - 2 * ytile / n)))
  lat_deg_nw = lat_rad_nw * 180 / pi
  
  lon_deg_se = (xtile + 1) / n * 360.0 - 180.0
  lat_rad_se = atan(sinh(pi * (1 - 2 * (ytile - 1) / n)))
  lat_deg_se = lat_rad_se * 180 / pi
  
  #returns extent: vector (length=4; order= xmin, xmax, ymin, ymax)
  return(c(lon_deg_nw, lon_deg_se, lat_deg_nw, lat_deg_se))
}

#lon/lat degrees conversion to numeric
deg2num <-function(lat_deg, lon_deg, zoom){
  lat_rad <- lat_deg * pi /180
  n <- 2.0 ^ zoom
  xtile <- floor((lon_deg + 180.0) / 360.0 * n)
  ytile = floor((1.0 - log(tan(lat_rad) + (1 / cos(lat_rad))) / pi) / 2.0 * n)
  return( c(xtile, ytile))
}

## tile coordinates of lat/lon points on various zoom level maps 
## number of tiles: 2^n (n = zoom)
## bron: https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#lon.2Flat_to_tile_numbers
xtile_col <- function(data, zoom) {
  (as.numeric(data) + 180.0) / 360.0 * 2.0 ^ zoom
}

ytile_col <- function(data, zoom) {
  lat_rad <- as.numeric(data) * pi /180
  (1.0 - log(tan(lat_rad) + (1 / cos(lat_rad))) / pi) / 2.0 * 2.0 ^ zoom
}

aerial_photo <- function(x, y, zoom = zoom, site = site) {
  zoom <- zoom
  x <- floor(x)
  y <- floor(y)
  site <- site
  image.loc <- paste0(paste(site, zoom, x, y, sep="/"),".jpeg")
  tmp <- tempfile()
  image <- curl_download(image.loc, destfile = tmp)
  map <- stack(image)
  raster::brick(map)
}  

## Bounding box maken
st_bbox_by_feature = function(x) {
  fun <- function(y) st_as_sfc(st_bbox(y))
  do.call("c", lapply(x, fun))
}

# create a grayscale color palette to use for the image.
grayscale_colors <- gray.colors(100,            # number of different color levels 
                                start = 0.0,    # how black (0) to go
                                end = 1.0,      # how white (1) to go
                                gamma = 2.2,    # correction between how a digital 
                                # camera sees the world and how human eyes see it
                                alpha = NULL)   #Null=colors are not transparent