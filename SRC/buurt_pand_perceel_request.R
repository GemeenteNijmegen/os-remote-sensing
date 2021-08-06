
#-----------------------------------------------------------------------------------------------

# Buurt pand perceel selectie

#-----------------------------------------------------------------------------------------------

#is geopackage already available
gpkg.rdy<-FALSE
#gpkg.rdy<-file.exists(gpkg_vector)

if(gpkg.rdy==FALSE) {
#not available, let's create gpkg

#read local file containing all buurten in NL  
buurten.rdy<-FALSE

if(buurten.rdy==FALSE) {
#Buurt request
 url <- parse_url("https://geodata.nationaalgeoregister.nl/wijkenbuurten2020/wfs?")
 url$query <- list(service = "wfs",
                   version = "2.0.0",
                   request = "GetCapabilities",
                   srsName  = "EPSG:28992",
                   outputFormat='json')
 request <- build_url(url);request

buurt_sf_totaal <- sf::st_read(request, layer = "wijkenbuurten2020:cbs_buurten_2020")
saveRDS(buurt_sf_totaal, "tempdata/buurt_sf_totaal.rds")
}
  
buurt_sf <- readRDS("tempdata/buurt_sf_totaal.rds")
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

#Pand request
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
  print(paste0("startindex ", loop," - ",nrow(data), " panden"))
  if(nrow(data) < 1000) {panden_sf <- rbindlist(empty_df) %>% st_as_sf(); break}
}
rm(data, empty_df)

#relevant features percelen
panden_cols<-colnames(panden_sf)

#subset panden within buurt
#panden_sf <- panden_sf[buurt_sf,] #containing
panden_sf <- sf::st_intersection(buurt_sf, panden_sf) %>% st_make_valid() #clip with buurt
panden_sf <- panden_sf %>% group_by(identificatie) %>% slice(1) #only keep unique
panden_sf <- panden_sf %>% dplyr::select(one_of(panden_cols)) #relevant features

#verschilpanden <- panden_sf_py %>% dplyr::select(identificatie) %>% unique() %>% 
# filter(!(identificatie %in% panden_sf$identificatie))
#mapview(verschilpanden)


#-----------------------------------------------------------------------------------------------

#Perceel request
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
  print(paste0("startindex ", loop," - ",nrow(data), " percelen"))
  if(nrow(data) < 1000) {percelen_sf <- rbindlist(empty_df) %>% st_as_sf(); break}
}
rm(data, empty_df)

#relevant features percelen
percelen_cols<-colnames(percelen_sf)

#subset percelen within buurt
percelen_sf <- percelen_sf[buurt_sf,]
percelen_sf <- sf::st_intersection(buurt_sf, percelen_sf) %>% st_collection_extract("POLYGON") %>%  st_make_valid() %>% #clip with buurt
              group_by(id) %>% slice(1)
percelen_sf <- percelen_sf %>% dplyr::select(one_of(percelen_cols)) #relevant features

#-----------------------------------------------------------------------------------------------

#Verblijfsobjecten request
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
  print(paste0("startindex ", loop," - ",nrow(data), "panden"))
  if(nrow(data) < 1000) {verblijfsobjecten_sf <- rbindlist(empty_df) %>% st_as_sf(); break}
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
#tuinen within percelen with object woonfunctie

#verblijfsobjecten with status 'in gebruik' or 'verbouwing'
woningen_sf <- verblijfsobjecten_sf[verblijfsobjecten_sf$status %like% "Verblijfsobject in gebruik" 
                                    | verblijfsobjecten_sf$status %like% "Verbouwing verblijfsobject"
                                    #toegevoegen?
                                    #| verblijfsobjecten_sf$status %like% "Verblijfsobject gevormd"
                                    ,]

#verblijfsobjecten with object 'woonfunctie' or 'logiesfunctie'
woningen_sf <- woningen_sf[woningen_sf$gebruiksdoel %like% "woonfunctie" | woningen_sf$gebruiksdoel %like% "logiesfunctie",]

#Selecteer alleen de panden waarin 1 of 2 verblijfsobjecten liggen (zodat apartementen/flats er uit wordt gefilterd)
#@esmee: het aantal verblijfsobjecten komt niet boven 1 uit door de slice bij verblijfsobjecten
woningen_sf2 <- woningen_sf %>% group_by(identificatie) %>% mutate(aantalvbo = n()) %>%
  #ungroup() %>% #@esmee vervolgens moet je m.i. de lijst weer herstellen, toch?
  filter(aantalvbo < 3) %>% dplyr::select(-aantalvbo)

#percelen with woonverblijfsobject
percelenwoonfunctie_sf <- percelen_sf[woningen_sf,] %>% dplyr::select(one_of(percelen_cols))
#percelenwoonfunctie_sf <- sf::st_intersection(buurt_sf, percelenwoonfunctie_sf) #clipping

#panden on woonperceel
pandenwoonperceel_sf<-panden_sf[percelenwoonfunctie_sf,]

#tuin = perceelwoonfunctie-pandenwoonperceel
st_erase = function(x, y) st_difference(x, st_union(y))
tuinen_sf <- st_erase(percelenwoonfunctie_sf,pandenwoonperceel_sf)  %>% dplyr::select(one_of(percelen_cols))

#verschiltuinen <- tuinen_sf_py %>% dplyr::select(identificatieLokaalID) %>% unique() %>% filter(!(identificatieLokaalID %in% tuinen_sf$identificatieLokaalID))
#plot(verschiltuinen)

#interactive Leaflet presentation of the layers buurt, percelen and panden
mapview(list(panden_sf,percelenwoonfunctie_sf,tuinen_sf),alpha.regions = 0.6, alpha = 1)
#mapview(list(verschiltuinen,tuinen_sf_py,tuinen_sf),alpha.regions = 0.6, alpha = 1)
#mapview(list(verschilpanden,tuinen_sf),alpha.regions = 0.6, alpha = 1)

#calculate surface tuinen
tuinen_sf <- tuinen_sf  %>%
  # feature area calculation (m^2)
  mutate(area = st_area(tuinen_sf))

#Select gardens with at least 3 m2
tuinen_sf2 <- tuinen_sf  %>%
  drop_units() %>%
  filter(area > 3.00)

#-----------------------------------------------------------------------------------------------

#compare python vs r (records/features)


#Python vs. R
#panden: 699/10 - 698/10                        OK
#percelen: 556/23 - 547/23                      a bit less percelen in R (<2%)
#verblijfsobjecten 1672/16 - 1679/16            a bit more
#woningen 1282/16 - 1206/16                     less (issue in Python?)
#tuinen 368/6 - 247/23                          remains large difference (issue in Python?)

#-----------------------------------------------------------------------------------------------
#post-processing

#percelen
#filter-out invalid features, calculate surface area
#percelen_sf <- percelen_sf  %>%
  #make sure shapes are valid (after clipping)
  #st_make_valid()  #%>%
  #feature area calculation (m^2)
  #mutate(area = st_area(percelen_sf))

#add id to rownames
rownames(percelen_sf) <- percelen_sf$identificatieLokaalID

#panden
#filter-out invalid features, calculate surface area
#panden_sf <- panden_sf  %>%
  #make sure shapes are valid (after clipping)
  #st_make_valid()

#add id to rownames
rownames(panden_sf) <- panden_sf$identificatie


#-----------------------------------------------------------------------------------------------
#create vector geopackage (GPKG)
sf::st_write(buurt_sf, dsn=gpkg_vector, layer='buurt',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(panden_sf, dsn=gpkg_vector, layer='panden',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(percelen_sf, dsn=gpkg_vector, layer='percelen',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(verblijfsobjecten_sf, dsn=gpkg_vector, layer='verblijfsobjecten',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(woningen_sf, dsn=gpkg_vector, layer='woningen',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(tuinen_sf, dsn=gpkg_vector, layer='tuinen',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_write(percelenwoonfunctie_sf, dsn=gpkg_vector, layer='percelenwoonfunctie',layer_options = "OVERWRITE=YES",append=FALSE)

sf::st_layers(gpkg_vector)

} else {
#read existing geopackage, individual layers
buurt_sf <- sf::st_read(gpkg_vector, layer= "buurt", geometry_column="geom")
panden_sf <- sf::st_read(gpkg_vector, layer= "panden",geometry_column="geom")
percelen_sf <- sf::st_read(gpkg_vector, layer= "percelen",geometry_column="geom")
verblijfsobjecten_sf <- sf::st_read(gpkg_vector, layer= "verblijfsobjecten", geometry_column="geom")
woningen_sf <- sf::st_read(gpkg_vector, layer= "woningen", geometry_column="geom")
tuinen_sf <- sf::st_read(gpkg_vector, layer= "tuinen", geometry_column="geom")
}

#-----------------------------------------------------------------------------------------------

png(paste0(plots.dir,"rs_tuinen_",neighbourhood,".png"), bg="white", height = 1280,width=1280,res=180,units = "px")
plot(st_geometry(tuinen_sf))
dev.off()

plots_vs <- FALSE

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
