# ophalen polygoon data NL - dit is enkel voor test doeleinden. 
request <- "https://geodata.nationaalgeoregister.nl/wijkenbuurten2020/wfs?request=GetCapabilities"
# beschikbare layers
st_layers(request)
# haal polygoon data binnen
bu.sf <- st_read(request, layer = "wijkenbuurten2020:cbs_buurten_2020")
# # transform from Multisurface to Polygon
sf <- st_cast(bu.sf, "GEOMETRYCOLLECTION") %>% st_collection_extract("POLYGON")
# subset data
sf <- subset(sf, gemeentenaam == gemeente & wijknaam == wijk)# & buurtnaam == buurt)
# behoud enkel de geom
sf <- st_geometry(sf)
# transform crs naar WGS84
sf <- sf::st_transform(sf, 4326)
#check projection
crs(sf)
# bepaal middelpunt 
centroid <- sf::st_centroid(sf)