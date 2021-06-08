## Geef hier een buurtcode in
buurtcodeselectie <- "BU03638600"

## Libraries
library(httr)
library(tidyverse)
library(sf)

## Buurt gegevens ophalen
request <- "https://geodata.nationaalgeoregister.nl/wijkenbuurten2020/wfs?request=GetCapabilities"
buurt.sf <- st_read(request, layer = "wijkenbuurten2020:cbs_buurten_2020")
buurt.sf.selectie <- subset(buurt.sf, buurtcode == buurtcodeselectie)
buurt.sf.selectie <- buurt.sf.selectie[, c('buurtcode', 'buurtnaam', 'gemeentecode', 'geom')]
# transform from Multisurface to Polygon, anders geeft plotten een error
buurt.sf.selectie <- st_cast(buurt.sf.selectie, "GEOMETRYCOLLECTION") %>% st_collection_extract("POLYGON")
plot(buurt.sf.selectie[1])

## Bounding box maken
st_bbox_by_feature = function(x) {
  fun <- function(y) st_as_sfc(st_bbox(y))
  do.call("c", lapply(x, fun))
}
buurt.sf.selectie$bbox_geom <- st_bbox_by_feature(buurt.sf.selectie$geom)

xmin <- min(buurt.sf.selectie$bbox_geom[[1]][[1]][,1])
xmax <- max(buurt.sf.selectie$bbox_geom[[1]][[1]][,1])
ymin <- min(buurt.sf.selectie$bbox_geom[[1]][[1]][,2])
ymax <- max(buurt.sf.selectie$bbox_geom[[1]][[1]][,2])
bbox <- paste(xmin, ymin, xmax, ymax, sep=",") 

## Pand gegevens ophalen
url <- parse_url("https://geodata.nationaalgeoregister.nl/bag/wfs/v1_1?")
url$query <- list(service = "wfs",
                  version = "2.0.0",
                  request = "GetFeature",
                  typename = "bag:pand",
                  srsName  = "EPSG:28992",
                  bbox = bbox,
                  outputFormat='json')
request <- build_url(url);request
panden.sf <- st_read(request)
panden.sf_sub <- panden.sf[buurt.sf.selectie,]

## Perceel gegevens ophalen
url <- parse_url("https://geodata.nationaalgeoregister.nl/kadastralekaart/wfs/v4_0?")
url$query <- list(service = "wfs",
                  version = "2.0.0",
                  request = "GetFeature",
                  typename = "kadastralekaartv4:perceel",
                  srsName  = "EPSG:28992",
                  bbox = bbox,
                  outputFormat='json')
request <- build_url(url);request
percelen.sf <- st_read(request)
percelen.sf_sub <- percelen.sf[buurt.sf.selectie$geom,]



## Pand, buurt en perceel gegevens combineren (clippen)
plot(buurt.sf.selectie$geom)
plot(panden.sf$geometry, add=TRUE)
#haal alle panden weg die niet in de buurt vallen
clip.pand.buurt = st_intersection(buurt.sf.selectie$geom, panden.sf$geometry) 
plot(clip.pand.buurt)
#haal alle percelen weg die niet in de buurt en panden vallen
clip.pand.buurt.percelen = st_intersection(clip.pand.buurt, percelen.sf$geometry) 
plot(clip.pand.buurt.percelen)

## Clean environment
rm(list=ls()[! ls() %in% c("buurt.sf","panden.sf_sub", "percelen.sf_sub", "clip.pand.buurt.percelen")])


## Dit alles geeft dezelfde output als gebruiken maken van de geopackage ontwikkeld in Python
buurt_py <- st_read("tempdata/BU03638600.gpkg", layer= "buurt")
panden_py <- st_read("tempdata/BU03638600.gpkg", layer= "panden")
percelen_py <- st_read("tempdata/BU03638600.gpkg", layer= "percelen")


plot(percelen.sf_sub[1]) 
## ! Alleen bij de percelen geeft percelen.sf_sub een andere (foutieve) output, hoe kan dat?
