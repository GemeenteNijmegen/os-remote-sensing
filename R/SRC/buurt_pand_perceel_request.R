
#-----------------------------------------------------------------------------------------------

# Buurt, pand and perceel polygons

#-----------------------------------------------------------------------------------------------

#vector geopackage already available?
vec.gpkg.rdy<-FALSE

#check existence
vec.gpkg.rdy<-file.exists(gpkg_vector)

if(vec.gpkg.rdy==FALSE) {
#not available, let's create gpkg

#-----------------------------------------------------------------------------------------------

#Gemeente

#-----------------------------------------------------------------------------------------------

#read local file containing all gemeenten in NL

  gemeenten.rdy<-FALSE
  gemeenten.rdy<-file.exists("DATA/gemeenten_nl_sf.rds")

  if(gemeenten.rdy==FALSE) {
  message("extract NL-gemeente polygon from nationaalgeoregister.nl")
  url <- parse_url("https://geodata.nationaalgeoregister.nl/bestuurlijkegrenzen/wfs?")
  url$query <- list(service = "wfs",
                    version = "1.1.0",
                    request = "GetFeature",
                    typename = "bestuurlijkegrenzen:gemeenten", #bestuurlijkegrenzen:provincies
                    srsName  = "EPSG:28992",
                    outputFormat='json')

  request <- build_url(url);request

  gemeenten_nl_sf <- sf::st_read(request)
  saveRDS(gemeenten_nl_sf, "DATA/gemeenten_nl_sf.rds")
  rm(gemeenten_nl_sf)
  }

  gemeente_sf <- readRDS("DATA/gemeenten_nl_sf.rds")
  gemeente_sf <- gemeente_sf %>% filter(gemeentenaam == municipality)

  #transform from Multisurface to Polygon
  gemeente_sf <- st_cast(gemeente_sf, "GEOMETRYCOLLECTION") %>% st_collection_extract("POLYGON")

#-----------------------------------------------------------------------------------------------

#Buurt

#-----------------------------------------------------------------------------------------------

#read local file containing all buurten in NL
buurten.rdy<-FALSE
buurten.rdy<-file.exists("DATA/buurten_nl_sf.rds")

if(buurten.rdy==FALSE) {

 message("extract NL-buurten polygon from nationaalgeoregister.nl ")
#Buurt request
 url <- parse_url("https://geodata.nationaalgeoregister.nl/wijkenbuurten2020/wfs?")
 url$query <- list(service = "wfs",
                   version = "2.0.0",
                   request = "GetCapabilities",
                   srsName  = "EPSG:28992",
                   outputFormat='json')
 request <- build_url(url);request

buurten_nl_sf <- sf::st_read(request, layer = "wijkenbuurten2020:cbs_buurten_2020")
saveRDS(buurten_nl_sf, "DATA/buurten_nl_sf.rds")
rm(buurten_nl_sf)
}

buurt_sf <- readRDS("DATA/buurten_nl_sf.rds")
buurt_sf <- buurt_sf %>% filter(buurtcode == neighbourhood)
buurt_sf <- buurt_sf[, c('buurtcode', 'buurtnaam', 'gemeentecode', 'geom')]

#transform from Multisurface to Polygon
buurt_sf <- st_cast(buurt_sf, "GEOMETRYCOLLECTION") %>% st_collection_extract("POLYGON")

#Extend and bounding box
buurt_extend <- sf::st_bbox(buurt_sf$geom)

xmin <- buurt_extend[1]
xmax <- buurt_extend[3]
ymin <- buurt_extend[2]
ymax <- buurt_extend[4]
bbox <- paste(xmin, ymin, xmax, ymax, sep=",")

#centroid buurt
centroid_alt <- sf::st_centroid(buurt_sf)
centroid_alt<- centroid_alt$geom

cen<-unlist(centroid_alt)
x_centroid<-cen[1]
y_centroid<-cen[2]

#-----------------------------------------------------------------------------------------------

#Pand

#-----------------------------------------------------------------------------------------------

message("extract panden polygons from nationaalgeoregister.nl ", neighbourhood)

#loop because of limit of 1000 results
loops = c(0,1001,2001,3001,4001,5001)
empty_df = list()
for (loop in loops) {
  url <- parse_url("https://geodata.nationaalgeoregister.nl/bag/wfs/v1_1?")
  url$query <- list(service = "wfs",
                    version = "2.0.0",
                    request = "GetFeature",
                    typename = "bag:pand",
                    srsName  = "EPSG:28992",
                    startindex = loop,
                    bbox = bbox,
                    outputFormat='json')
  request <- build_url(url);request
  data <- sf::st_read(request)
  empty_df <- list.append(empty_df, data)
  print(paste0("startindex ", loop," - entities: ",nrow(data), " panden"))
  if(nrow(data) < 1000) {panden_sf <- rbindlist(empty_df, use.names=TRUE) %>% st_as_sf(); break}
}
rm(data, empty_df)

#relevant features percelen
panden_cols<-colnames(panden_sf)

#subset panden within buurt
panden_sf <- sf::st_intersection(buurt_sf, panden_sf) %>% #clip with buurt
  sf::st_make_valid() %>% #repair
  sf::st_collection_extract("POLYGON") %>% #polygons
  group_by(identificatie) %>% #unique
  slice(1) %>%
  dplyr::select(one_of(panden_cols)) #relevant features

rownames(panden_sf) <- panden_sf$identificatie


#-----------------------------------------------------------------------------------------------

#Panden 3d

#-----------------------------------------------------------------------------------------------

#BAG footprints with calculated height from AHN3 (from TU Delft)

#UNDER CONSTRUCTION
#https://data.3dbag.nl/api/BAG3D_v2/wfs?request=getcapabilities

buildings_3d <- FALSE

if(buildings_3d==TRUE) {

#loops = c(0,1001,2001,3001,4001,5001,6001)
empty_df = list()
#for (loop in loops) {
  url <- parse_url("http://3dbag.bk.tudelft.nl/data/wfs?")
  url$query <- list(SERVICE = "WFS",
                    REQUEST = "GetFeature",
                    TYPENAMES = "BAG3D:pand3d",
                    startindex = loop,
                    bbox = bbox,
                    outputFormat='json')
  request <- build_url(url);request
  data <- sf::st_read(request)
  empty_df <- list.append(empty_df, data)
  print(paste0("startindex ", loop," - entities: ",nrow(data), " 3d panden"))
  panden3d_sf <- rbindlist(empty_df, use.names=TRUE) %>% st_as_sf()
#}

#subset 3d panden within buurt
panden3d_sf <- sf::st_intersection(buurt_sf, panden3d_sf) %>% #clip with buurt
  sf::st_make_valid() %>% #repair
  sf::st_collection_extract("POLYGON") %>% #polygons
  group_by(identificatie) %>% #unique
  slice(1)

}

#-----------------------------------------------------------------------------------------------

#Perceel

#-----------------------------------------------------------------------------------------------

message("extract percelen polygons from nationaalgeoregister.nl " , neighbourhood)

empty_df = list()
for (loop in loops) {
  url <- parse_url("https://geodata.nationaalgeoregister.nl/kadastralekaart/wfs/v4_0?")
  url$query <- list(service = "wfs",
                    version = "2.0.0",
                    request = "GetFeature",
                    typename = "kadastralekaartv4:perceel",
                    srsName  = "EPSG:28992",
                    startindex = loop,
                    bbox = bbox,
                    outputFormat='json')
  request <- build_url(url);request
  data <- sf::st_read(request)
  empty_df <- list.append(empty_df, data)
  print(paste0("startindex ", loop," - entities: ",nrow(data), " percelen"))
  if(nrow(data) < 1000) {percelen_sf <- rbindlist(empty_df, use.names=TRUE) %>% st_as_sf(); break}
}
rm(data, empty_df)

#relevant features percelen
percelen_cols<-colnames(percelen_sf)

#subset percelen within buurt
percelen_sf <- percelen_sf[buurt_sf,]
percelen_sf <- sf::st_intersection(buurt_sf, percelen_sf) %>% #clip with buurt
              sf::st_make_valid() %>% #repair
              sf::st_collection_extract("POLYGON") %>% #polygons
              group_by(id) %>% #unique
              slice(1) %>%
              dplyr::select(one_of(percelen_cols)) #relevant features

#add id to rownames
rownames(percelen_sf) <- percelen_sf$identificatieLokaalID

#-----------------------------------------------------------------------------------------------

#Verblijfsobjecten

#-----------------------------------------------------------------------------------------------

message("extract verblijfsobjecten from nationaalgeoregister.nl ", neighbourhood)

empty_df = list()
for (loop in loops) {
  url <- parse_url("https://geodata.nationaalgeoregister.nl/bag/wfs/v1_1?")
  url$query <- list(service = "wfs",
                    version = "2.0.0",
                    request = "GetFeature",
                    typename = "bag:verblijfsobject",
                    srsName  = "EPSG:28992",
                    startindex = loop,
                    bbox = bbox,
                    outputFormat='json')
  request <- build_url(url);request
  data <- sf::st_read(request)
  empty_df <- list.append(empty_df, data)
  print(paste0("startindex ", loop," - entities: ",nrow(data), " verblijfsobjecten"))
  if(nrow(data) < 1000) {verblijfsobjecten_sf <- rbindlist(empty_df, use.names=TRUE) %>% st_as_sf(); break}
}
rm(data, empty_df)

#relevant features verblijfsobjecten
verblijfsobjecten_cols <- colnames(verblijfsobjecten_sf)

#subset verblijfsobjecten within buurt
verblijfsobjecten_sf <- verblijfsobjecten_sf[buurt_sf$geom,] #containing
verblijfsobjecten_sf <- sf::st_intersection(buurt_sf, verblijfsobjecten_sf) %>%
                      group_by(gid) %>% slice(1)#clipping
verblijfsobjecten_sf <- verblijfsobjecten_sf %>% dplyr::select(one_of(verblijfsobjecten_cols)) #relevant vbo features

#-----------------------------------------------------------------------------------------------

#Tuinen

#-----------------------------------------------------------------------------------------------

message("build tuinen " , neighbourhood)

#tuinen within percelen with object woonfunctie

#verblijfsobjecten with status 'in gebruik' or 'verbouwing'
woningen_sf <- verblijfsobjecten_sf[verblijfsobjecten_sf$status %like% "Verblijfsobject in gebruik"
                                    | verblijfsobjecten_sf$status %like% "Verbouwing verblijfsobject"
                                    ,]

#verblijfsobjecten with object 'woonfunctie' or 'logiesfunctie'
woningen_sf <- woningen_sf[woningen_sf$gebruiksdoel %like% "woonfunctie" | woningen_sf$gebruiksdoel %like% "logiesfunctie",]

#percelen with woonverblijfsobject
percelenwoonfunctie_sf <- percelen_sf[woningen_sf,] %>% dplyr::select(one_of(percelen_cols))

#panden on woonperceel
pandenwoonperceel_sf<-panden_sf[percelenwoonfunctie_sf,]

#tuin = perceelwoonfunctie-pandenwoonperceel
st_erase = function(x, y) st_difference(x, st_union(y))

tuinen_sf <- st_erase(percelenwoonfunctie_sf,pandenwoonperceel_sf) %>%
  sf::st_make_valid() %>% #repair
  sf::st_collection_extract("POLYGON") %>% #polygons
  filter(!is.na(perceelnummer)) %>% #garden with perceelnummer
  mutate(area = as.numeric(st_area(geom))) %>%
  filter(area > 1) %>% #remove garbage elements
  dplyr::select(one_of(percelen_cols)) #relevant columns

#interactive Leaflet presentation of the layers buurt, percelen and panden
#mapview(list(panden_sf,percelenwoonfunctie_sf,tuinen_sf),alpha.regions = 0.6, alpha = 1)
#mapview(list(verschiltuinen,tuinen_sf_py,tuinen_sf),alpha.regions = 0.6, alpha = 1)
#mapview(list(verschilpanden,tuinen_sf),alpha.regions = 0.6, alpha = 1)

#-----------------------------------------------------------------------------------------------

message("store layers in geopackage ",neighbourhood,"_vector.gpkg")

#create vector geopackage (GPKG)
sf::st_write(buurt_sf, dsn=gpkg_vector, layer='buurt',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(panden_sf, dsn=gpkg_vector, layer='panden',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(percelen_sf, dsn=gpkg_vector, layer='percelen',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(verblijfsobjecten_sf, dsn=gpkg_vector, layer='verblijfsobjecten',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(woningen_sf, dsn=gpkg_vector, layer='woningen',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(tuinen_sf, dsn=gpkg_vector, layer='tuinen',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(percelenwoonfunctie_sf, dsn=gpkg_vector, layer='percelenwoonfunctie',layer_options = "OVERWRITE=YES",append=FALSE)

#review layers
sf::st_layers(gpkg_vector)

} else {
message("read layers from existing geopackage ",neighbourhood,"_vector.gpkg")

#read existing geopackage, individual layers
buurt_sf <- sf::st_read(gpkg_vector, layer= "buurt", geometry_column="geom")
panden_sf <- sf::st_read(gpkg_vector, layer= "panden",geometry_column="geom")
percelen_sf <- sf::st_read(gpkg_vector, layer= "percelen",geometry_column="geom")
verblijfsobjecten_sf <- sf::st_read(gpkg_vector, layer= "verblijfsobjecten", geometry_column="geom")
woningen_sf <- sf::st_read(gpkg_vector, layer= "woningen", geometry_column="geom")
tuinen_sf <- sf::st_read(gpkg_vector, layer= "tuinen", geometry_column="geom")
}

#-----------------------------------------------------------------------------------------------
#extend and bounding box

buurt_extend <- sf::st_bbox(buurt_sf$geom)

xmin <- buurt_extend[1]
xmax <- buurt_extend[3]
ymin <- buurt_extend[2]
ymax <- buurt_extend[4]
bbox <- paste(xmin, ymin, xmax, ymax, sep=",")

#centroid perceel
cntrd_perceel <- st_centroid(st_geometry(percelen_sf))

#centroid tuinen
cntrd_tuinen <- st_centroid(st_geometry(tuinen_sf))

#extract coordinates tuinen
coord_tuinen<-as.data.frame(st_coordinates(cntrd_tuinen))

#-----------------------------------------------------------------------------------------------

png(paste0(plots.loc,"rs_tuinen_",neighbourhood,".png"), bg="white", height = 1280,width=1280,res=180,units = "px")
plot(st_geometry(tuinen_sf))
dev.off()

rm(percelenwoonfunctie_sf,pandenwoonperceel_sf)
