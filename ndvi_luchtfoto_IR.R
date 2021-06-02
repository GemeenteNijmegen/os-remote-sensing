# auteur: Leonard Vanbrabant
# datum aangemaakt: 11-05-2021
# datum laatst gewijzigd: 02-06-2021
# note: dit script is een bewerking van een script geschreven door Esmee 
# Kramer & Rik Scharn van de omgevingsdienst midden-en-west Brabant. 

# load spatial packages
library(raster) # handige tools voor raster data
library(sf)     # simple features
library(curl)   # eenvoudige data transfer


# reguliere packages voor geo - Mark Gremmen
# sf: simple features (die gebruik ik voor het inlezen van shp-files en ontrkken van layers) 
# rgdal: Bindings for the 'Geospatial' Data Abstraction Library (die gebruik ik voor projectie transformatie)
# rgeos: rgeos implements functionality for the manipulation and querying of spatial geometries using the Geometry Engine — Open Source (GEOS)C library.
# raster: Mask values in a Raster object (die gebruik ik om raster data in te lezen en te filteren obv polygon: mask)
# gstat: Spatial and Spatio-Temporal Geostatistical Modelling, Prediction and Simulation (die gebruik ik voor interpolatie)


# infrarood kaart ophalen, er is ook een rgb kaart beschikbaar
site <- "https://geodata.nationaalgeoregister.nl/luchtfoto/infrarood/wmts/Actueel_ortho25IR/EPSG:3857"
#site <- "https://geodata.nationaalgeoregister.nl/luchtfoto/rgb/wmts/Actueel_ortho25/EPSG:3857"

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


# functie voor het ophalen van luchtfoto op basis van een X/Y coord.
Foto_ophalen <- function(x, y, zoom = zoom, site = site) {
  zoom <- zoom
  x <- floor(x)
  y <- floor(y)
  site <- site
  foto_link <- paste0(paste(site, zoom, x, y, sep="/"),".jpeg")
  
  tmp   <- tempfile()
  image <- curl_download(foto_link, destfile = tmp)
  map   <- stack(image)
  map_brick <- brick(map)
  
  map_brick
}  


# ophalen polygoon data NL - dit is enkel voor test doeleinden. 
request <- "https://geodata.nationaalgeoregister.nl/wijkenbuurten2020/wfs?request=GetCapabilities"
# beschikbare layers
st_layers(request)
# haal polygoon data binnen
bu.sf <- st_read(request, layer = "wijkenbuurten2020:cbs_buurten_2020")
# # transform from Multisurface to Polygon
sf <- st_cast(bu.sf, "GEOMETRYCOLLECTION") %>% st_collection_extract("POLYGON")
# subset data
sf <- subset(sf, gemeentenaam == "Eindhoven" & wijknaam == "Oud-Tongelre")# & buurtnaam == "'t Hofke")
# behoud enkel de geom
sf <- st_geometry(sf)
# transform crs van Amersfoort naar WGS84
sf <- sf::st_transform(sf, 4326)

# bepaal middelpunt 
centroid <- sf::st_centroid(sf)

# zoom-niveau luchtfoto - zoom-niveau 19 is de max.
zoom <- 16

# tile coordinates of lat/lon points on various zoom level maps 
tile_x <- xtile_col(centroid[[1]][1], zoom = zoom)
tile_y <- ytile_col(centroid[[1]][2], zoom = zoom)

# haal foto op
f1 <- Foto_ophalen(tile_x, tile_y, zoom, site)

plot(f1)

# View raster structure
nlayers(f1)
names(f1)


## CIR: green - red - nir
## R = XS3 (NIR band)
## G = XS2 (red band)
## B = XS1 (green band)
## (NIR - Red) / (NIR + Red)

# calculate NDVI en rvi using the red band and nir band
red <- f1[[2]]
nir <- f1[[1]]

ndvi <- (nir - red)/(nir + red)

rvi  <- nir / red

# plot the data
plot(ndvi,
     axes = FALSE, box = FALSE)

plot(rvi,
     axes = FALSE, box = FALSE)

hist(ndvi)

## TODO
# laag met polygonen toevoegen aan luchtfoto en per polygoon de ndvi bepalen. 
# hoe gaan we om de randen?, de pixels vallen in meerdere polygonen. 
