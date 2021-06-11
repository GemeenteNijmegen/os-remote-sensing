
#-----------------------------------------------------------------------------------------------

# Buurt pand perceel selectie

#-----------------------------------------------------------------------------------------------

#buurt selectie
buurtcodeselectie <- neighbourhood

#is geopackage already available
gpkg.rdy<-FALSE
gpkg.rdy<-file.exists(neigh.loc)


if(gpkg.rdy==FALSE) {
#not available, let's create gpkg
  
## Buurt gegevens ophalen
request <- "https://geodata.nationaalgeoregister.nl/wijkenbuurten2020/wfs?request=GetCapabilities"


buurt_sf <- st_read(request, layer = "wijkenbuurten2020:cbs_buurten_2020") %>%
                    subset(buurtcode == buurtcodeselectie) 

buurt_sf <- buurt_sf[, c('buurtcode', 'buurtnaam', 'gemeentecode', 'geom')]

# transform from Multisurface to Polygon, anders geeft plotten een error
buurt_sf <- st_cast(buurt_sf, "GEOMETRYCOLLECTION") %>% st_collection_extract("POLYGON")
#plot(buurt_sf[1])

## Bounding box maken
buurt_sf$bbox_geom <- st_bbox_by_feature(buurt_sf$geom)

xmin <- min(buurt_sf$bbox_geom[[1]][[1]][,1])
xmax <- max(buurt_sf$bbox_geom[[1]][[1]][,1])
ymin <- min(buurt_sf$bbox_geom[[1]][[1]][,2])
ymax <- max(buurt_sf$bbox_geom[[1]][[1]][,2])
bbox <- paste(xmin, ymin, xmax, ymax, sep=",") 

#centroid buurt
centroid_alt <- sf::st_centroid(buurt_sf)
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
panden_sf <- st_read(request)
panden_sf_sub <- panden_sf[buurt_sf,]

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
percelen_sf <- st_read(request)
percelen_sf_sub <- percelen_sf[buurt_sf$geom,]

## Pand, buurt en perceel gegevens combineren (clippen)
plot(buurt_sf$geom)
plot(panden_sf$geometry, add=TRUE)

#haal alle panden weg die niet in de buurt vallen
clip.pand.buurt = st_intersection(buurt_sf$geom, panden_sf$geometry) 
plot(clip.pand.buurt)

#haal alle percelen weg die niet in de buurt en panden vallen
clip.pand.buurt.percelen = st_intersection(clip.pand.buurt, percelen_sf$geometry) 
plot(clip.pand.buurt.percelen)

## Clean environment
#rm(list=ls()[! ls() %in% c("buurt_sf","panden_sf_sub", "percelen_sf_sub", "clip.pand.buurt.percelen")])
rm(panden_sf_sub,percelen_sf_sub,clip.pand.buurt.percelen)

#create geopackage
st_write(buurt_sf, dsn=neigh.loc, layer='buurt',layer_options = "OVERWRITE=YES",append=FALSE)
st_write(panden_sf, dsn=neigh.loc, layer='panden',layer_options = "OVERWRITE=YES",append=FALSE)
st_write(percelen_sf, dsn=neigh.loc, layer='percelen',layer_options = "OVERWRITE=YES",append=FALSE)
st_layers(neigh.loc)

} else {

#read existing geopackage, individual layers
buurt_sf <- st_read(neigh.loc, layer= "buurt")
panden_sf <- st_read(neigh.loc, layer= "panden")
percelen_sf <- st_read(neigh.loc, layer= "percelen")

#plot(percelen_sf_sub[1]) 
## ! Alleen bij de percelen geeft percelen_sf_sub een andere (foutieve) output, hoe kan dat?

}