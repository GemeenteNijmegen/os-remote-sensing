
#-----------------------------------------------------------------------------------------------

# Buurt pand perceel selectie

#-----------------------------------------------------------------------------------------------

#buurt selectie
buurtcodeselectie <- neighbourhood

#is geopackage already available
gpkg.rdy<-FALSE
gpkg.rdy<-file.exists(neigh.vec.loc)

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

# Bounding box
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

#-----------------------------------------------------------------------------------------------

#Pand request
url <- parse_url("https://geodata.nationaalgeoregister.nl/bag/wfs/v1_1?")
url$query <- list(service = "wfs",
                  version = "2.0.0",
                  request = "GetFeature",
                  typename = "bag:pand",
                  srsName  = "EPSG:28992",
                  bbox = bbox,
                  outputFormat='json')
request <- build_url(url);request
panden_sf <- sf::st_read(request)
#subset panden within buurt
panden_sf <- panden_sf[buurt_sf,]

#Perceel request
url <- parse_url("https://geodata.nationaalgeoregister.nl/kadastralekaart/wfs/v4_0?")
url$query <- list(service = "wfs",
                  version = "2.0.0",
                  request = "GetFeature",
                  typename = "kadastralekaartv4:perceel",
                  srsName  = "EPSG:28992",
                  bbox = bbox,
                  outputFormat='json')
request <- build_url(url);request
percelen_sf <- sf::st_read(request)
#subset percelen within buurt
percelen_sf <- percelen_sf[buurt_sf$geom,]

#-----------------------------------------------------------------------------------------------

#combine pand, buurt en perceel (clip)
plot(buurt_sf$geom)
plot(st_geometry(panden_sf), add=TRUE)

#Overlapping area (clipping)
#haal alle panden weg die niet in de buurt vallen
clip.pand.buurt = sf::st_intersection(buurt_sf, panden_sf) 

#clip.pand.buurt = st_intersection(buurt_sf$geom, panden_sf$geometry) 
ggplot(clip.pand.buurt) +
  geom_sf(aes(fill=gebruiksdoel)) + 
  theme_minimal() 
plot.nme = paste0('rs_panden_within_buurt_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio*3, dpi=dpi)

#haal alle percelen weg die niet in de buurt en panden vallen
clip.pand.buurt.percelen = sf::st_intersection(clip.pand.buurt, percelen_sf) 

ggplot(clip.pand.buurt.percelen) +
  geom_sf(aes()) + 
  theme_minimal() 
plot.nme = paste0('rs_panden_within_buurt_percelen_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)

## Clean environment
#rm(list=ls()[! ls() %in% c("buurt_sf","panden_sf_sub", "percelen_sf_sub", "clip.pand.buurt.percelen")])

#-----------------------------------------------------------------------------------------------
#post-processing

# Filter-out invalid features, calculate surface area
percelen_sf <- percelen_sf  %>% 
  #make sure shapes are valid  
  st_make_valid()  %>%
  #feature area calculation (m^2)
  mutate(area = st_area(percelen_sf))

#add id to rownames
rownames(percelen_sf)<-percelen_sf$identificatieLokaalID
head(percelen_sf)

percelen_cols<-colnames(percelen_sf)


# Filter-out invalid features, calculate surface area
panden_sf <- panden_sf  %>% 
  #make sure shapes are valid  
  st_make_valid()  

#add id to rownames
rownames(panden_sf)<-panden_sf$identificatie

#-----------------------------------------------------------------------------------------------
#create vector geopackage (GPKG)
sf::st_write(buurt_sf, dsn=neigh.vec.loc, layer='buurt',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(panden_sf, dsn=neigh.vec.loc, layer='panden',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(percelen_sf, dsn=neigh.vec.loc, layer='percelen',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_layers(neigh.vec.loc)

} else {
#read existing geopackage, individual layers
buurt_sf <- st_read(neigh.vec.loc, layer= "buurt")
panden_sf <- st_read(neigh.vec.loc, layer= "panden")
percelen_sf <- st_read(neigh.vec.loc, layer= "percelen")
}

#-----------------------------------------------------------------------------------------------

#relevant features percelen
percelen_cols<-colnames(percelen_sf)

#relevant features panden
panden_cols<-colnames(panden_sf)