
#-----------------------------------------------------------------------------------------------

# Buurt pand perceel selectie

#-----------------------------------------------------------------------------------------------

#is geopackage already available
gpkg.rdy<-FALSE
gpkg.rdy<-file.exists(gpkg_vector)

if(gpkg.rdy==FALSE) {
#not available, let's create gpkg

#neighbourhood request
request <- "https://geodata.nationaalgeoregister.nl/wijkenbuurten2020/wfs?request=GetCapabilities"

buurt_sf <- st_read(request, layer = "wijkenbuurten2020:cbs_buurten_2020") %>%
                    subset(buurtcode == neighbourhood)

buurt_sf <- buurt_sf[, c('buurtcode', 'buurtnaam', 'gemeentecode', 'geom')]

#transform from Multisurface to Polygon
buurt_sf <- st_cast(buurt_sf, "GEOMETRYCOLLECTION") %>% st_collection_extract("POLYGON")

#Bounding box
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

#relevant features panden
panden_cols<-colnames(panden_sf)

#subset panden within buurt
panden_sf <- panden_sf[buurt_sf,] #containing
panden_sf <- sf::st_intersection(buurt_sf, panden_sf) #clipping

#-----------------------------------------------------------------------------------------------

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

#relevant features percelen
percelen_cols<-colnames(percelen_sf)

#subset percelen within buurt
percelen_sf <- percelen_sf[buurt_sf,] #containing
#percelen_sf <- sf::st_intersection(buurt_sf, percelen_sf) #clipping 

#-----------------------------------------------------------------------------------------------

#Verblijfsobjecten request
url <- parse_url("https://geodata.nationaalgeoregister.nl/bag/wfs/v1_1?")
url$query <- list(service = "wfs",
                  version = "2.0.0",
                  request = "GetFeature",
                  typename = "bag:verblijfsobject",
                  srsName  = "EPSG:28992",
                  bbox = bbox,
                  outputFormat='json')
request <- build_url(url);request
verblijfsobject_sf <- sf::st_read(request)

#relevant features verblijfsobjecten
verblijfsobject_cols<-colnames(verblijfsobject_sf)

#subset verblijfsobjecten within buurt
verblijfsobject_sf <- verblijfsobject_sf[buurt_sf$geom,] #containing
verblijfsobject_sf <- sf::st_intersection(buurt_sf, verblijfsobject_sf) #clipping

#spatial object percelen
#percelen_sp <- as(st_geometry(percelen_sf), Class="Spatial")

#-----------------------------------------------------------------------------------------------
#post-processing

#percelen
#filter-out invalid features, calculate surface area
percelen_sf <- percelen_sf  %>%
  #make sure shapes are valid (after clipping)
  st_make_valid()  #%>%
  #feature area calculation (m^2)
  #mutate(area = st_area(percelen_sf))

#add id to rownames
rownames(percelen_sf)<-percelen_sf$identificatieLokaalID

#panden
#filter-out invalid features, calculate surface area
panden_sf <- panden_sf  %>%
  #make sure shapes are valid (after clipping)
  st_make_valid()

#add id to rownames
rownames(panden_sf)<-panden_sf$identificatie

#-----------------------------------------------------------------------------------------------
#create vector geopackage (GPKG)
sf::st_write(buurt_sf, dsn=gpkg_vector, layer='buurt',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(panden_sf, dsn=gpkg_vector, layer='panden',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(percelen_sf, dsn=gpkg_vector, layer='percelen',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(verblijfsobject_sf, dsn=gpkg_vector, layer='verblijfsobjecten',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_layers(gpkg_vector)

} else {
#read existing geopackage, individual layers
buurt_sf <- sf::st_read(gpkg_vector, layer= "buurt", geometry_column="geom")
panden_sf <- sf::st_read(gpkg_vector, layer= "panden",geometry_column="geom")
percelen_sf <- sf::st_read(gpkg_vector, layer= "percelen",geometry_column="geom")
verblijfsobject_sf <- sf::st_read(gpkg_vector, layer= "verblijfsobjecten", geometry_column="geom")
}

#plot(st_geometry(percelen_sf))

#-----------------------------------------------------------------------------------------------

plots_vs<- FALSE

if(plots_vs==TRUE) {
#plot(buurt_sf$geom)
#plot(st_geometry(panden_sf), add=TRUE)

#Overlapping area (clipping)
#haal alle panden weg die niet in de buurt vallen
clip.pand.buurt = sf::st_intersection(buurt_sf, panden_sf)

#st_crs(clip.pand.buurt)

ggplot(clip.pand.buurt) +
  geom_sf(aes(fill=identificatie)) +
  theme_minimal() +
  scale_fill_viridis(discrete=TRUE, option="E")
plot.nme = paste0('rs_panden_within_buurt_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, dpi=dpi, limitsize = FALSE)

#haal alle percelen weg die niet in de buurt en panden vallen
clip.pand.buurt.percelen = sf::st_intersection(clip.pand.buurt, percelen_sf)

ggplot(clip.pand.buurt.percelen) +
  geom_sf(aes()) +
  theme_minimal()
plot.nme = paste0('rs_panden_within_buurt_percelen_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, dpi=dpi)
}

#-----------------------------------------------------------------------------------------------


#dd<-percelen_sf %>%
#  st_make_valid() %>%
#  st_cast('MULTIPOLYGON') %>%
#  st_cast('POLYGON', warn=FALSE) %>%
#  filter(st_area(.) > units::set_units(1, m^2)) %>%
#  group_by(id) %>%
#  summarize(geometry = st_combine(geometry))





## Clean environment
#rm(list=ls()[! ls() %in% c("buurt_sf","panden_sf_sub", "percelen_sf_sub", "clip.pand.buurt.percelen")])
