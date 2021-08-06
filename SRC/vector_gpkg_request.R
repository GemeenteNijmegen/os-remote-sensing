
#-----------------------------------------------------------------------------------------------

# Polygon data 

#-----------------------------------------------------------------------------------------------

# download prefab geopackage from VNG Stack location
path_processed <- file.path("https://datasciencevng.nl/remote.php/webdav/Data/processed", 
                            neighbourhood, paste0(neighbourhood, "_vector.gpkg"))
gpkg_vector <- R.utils::downloadFile(url      = path_processed,
                                     path     = data.dir,
                                     username = webdav_login, 
                                     password = webdav_password, 
                                     verbose  = FALSE)

sf::st_layers(gpkg_vector)

#read existing geopackage, individual layers
buurt_sf <- sf::st_read(gpkg_vector, layer= "buurt", geometry_column="geom")
panden_sf <- sf::st_read(gpkg_vector, layer= "panden",geometry_column="geom")
percelen_sf <- sf::st_read(gpkg_vector, layer= "percelen",geometry_column="geom")
verblijfsobjecten_sf <- sf::st_read(gpkg_vector, layer= "verblijfsobjecten", geometry_column="geom")
tuinen_sf <- st_read(gpkg_vector, layer = "tuinen", geometry_column="geom")
woningen_sf <- st_read(gpkg_vector, layer = "woningen", geometry_column="geom")

#for testing
buurt_sf_py <- buurt_sf
panden_sf_py <- panden_sf
percelen_sf_py <- percelen_sf
verblijfsobjecten_sf_py <- verblijfsobjecten_sf
tuinen_sf_py <- tuinen_sf
woningen_sf_py <- woningen_sf