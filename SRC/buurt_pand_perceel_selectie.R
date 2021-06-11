
#buurt selectie
buurtcodeselectie <- neighbourhood

## Buurt gegevens ophalen
request <- "https://geodata.nationaalgeoregister.nl/wijkenbuurten2020/wfs?request=GetCapabilities"


buurt.sf <- st_read(request, layer = "wijkenbuurten2020:cbs_buurten_2020") %>%
                    subset(buurtcode == buurtcodeselectie) 

buurt.sf <- buurt.sf[, c('buurtcode', 'buurtnaam', 'gemeentecode', 'geom')]

# transform from Multisurface to Polygon, anders geeft plotten een error
buurt.sf <- st_cast(buurt.sf, "GEOMETRYCOLLECTION") %>% st_collection_extract("POLYGON")
#plot(buurt.sf[1])

## Bounding box maken
st_bbox_by_feature = function(x) {
  fun <- function(y) st_as_sfc(st_bbox(y))
  do.call("c", lapply(x, fun))
}
buurt.sf$bbox_geom <- st_bbox_by_feature(buurt.sf$geom)

xmin <- min(buurt.sf$bbox_geom[[1]][[1]][,1])
xmax <- max(buurt.sf$bbox_geom[[1]][[1]][,1])
ymin <- min(buurt.sf$bbox_geom[[1]][[1]][,2])
ymax <- max(buurt.sf$bbox_geom[[1]][[1]][,2])
bbox <- paste(xmin, ymin, xmax, ymax, sep=",") 

#centroid buurt
centroid_alt <- sf::st_centroid(buurt.sf)
centroid_alt<- centroid_alt$geom

cen<-unlist(centroid_alt)
x_centroid<-cen[1]
y_centroid<-cen[2]

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
panden.sf_sub <- panden.sf[buurt.sf,]

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
percelen.sf_sub <- percelen.sf[buurt.sf$geom,]

## Pand, buurt en perceel gegevens combineren (clippen)
plot(buurt.sf$geom)
plot(panden.sf$geometry, add=TRUE)

#haal alle panden weg die niet in de buurt vallen
clip.pand.buurt = st_intersection(buurt.sf$geom, panden.sf$geometry) 
plot(clip.pand.buurt)

#haal alle percelen weg die niet in de buurt en panden vallen
clip.pand.buurt.percelen = st_intersection(clip.pand.buurt, percelen.sf$geometry) 
plot(clip.pand.buurt.percelen)

## Clean environment
#rm(list=ls()[! ls() %in% c("buurt.sf","panden.sf_sub", "percelen.sf_sub", "clip.pand.buurt.percelen")])
rm(panden.sf_sub,percelen.sf_sub,clip.pand.buurt.percelen)

#create geopackage
st_write(buurt.sf, dsn=neigh.loc, layer='buurt',layer_options = "OVERWRITE=YES",append=FALSE)
st_write(panden.sf, dsn=neigh.loc, layer='panden',layer_options = "OVERWRITE=YES",append=FALSE)
st_write(percelen.sf, dsn=neigh.loc, layer='percelen',layer_options = "OVERWRITE=YES",append=FALSE)
st_layers(neigh.loc)

#read geopackage, individual layers
#buurt_py <- st_read(neigh.loc, layer= "buurt")
#panden_py <- st_read(neigh.loc, layer= "panden")
#percelen_py <- st_read(neigh.loc, layer= "percelen")

buurt_py <- buurt.sf
panden_py <- panden.sf
percelen_py <- percelen.sf

#plot(percelen.sf_sub[1]) 
## ! Alleen bij de percelen geeft percelen.sf_sub een andere (foutieve) output, hoe kan dat?
