#-----------------------------------------------------------------------------------------------

# percelen disection

#-----------------------------------------------------------------------------------------------

#cut out buildings (panden) from percelen to discover potential gardens
woonpercelen_garden_sf <- sf::st_difference(percelen_sf,panden_sf) %>%
  filter(gebruiksdoel %like% "woonfunctie") %>%
  #select(percelen_cols) %>%
  st_make_valid()
dim(woonpercelen_garden_sf)

#empty polygons?
#any(is.na(st_dimension(woonpercelen_garden_sf)))
#corrupt or invalid?
#any(na.omit(st_is_valid(woonpercelen_garden_sf)) == FALSE)
#reason for invalidity
#st_is_valid(woonpercelen_garden_sf, reason = TRUE)

#cast explicitly to polygon
#woonpercelen_garden_sf<-sf::st_cast(woonpercelen_garden_sf,to="MULTIPOLYGON")

#write layer to vector gpkg
sf::st_write(woonpercelen_garden_sf, dsn=gpkg_vector, layer='gardens',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_layers(gpkg_vector)