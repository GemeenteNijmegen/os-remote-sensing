
#-----------------------------------------------------------------------------------------------

# Vegetation geopackage

#-----------------------------------------------------------------------------------------------

#create fresh multi-raster GeoPackage (gpkg) containing all green indices

unlink(paste0(data.dir,neighbourhood,"_green_indices.gpkg"))
#Stars-packagke

#NDVI (value)
ndvi %>%
  st_as_stars %>% # convert the RasterLayer to a stars object
  write_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
              driver = "GPKG",options = c("RASTER_TABLE=ndvi","APPEND_SUBDATASET=YES"))

#EVI2 (value)
evi2 %>%
  st_as_stars %>% # convert the RasterLayer to a stars object
  write_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
              driver = "GPKG",options = c("RASTER_TABLE=evi2","APPEND_SUBDATASET=YES"))

#vegetation (fixed class)
veg_g %>%
  st_as_stars %>% # convert the RasterLayer to a stars object
  write_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
              driver = "GPKG", options = c("RASTER_TABLE=vegetation_fixed","APPEND_SUBDATASET=YES"))

#substantial green (fixed class)
veg_s %>%
  st_as_stars %>% # convert the RasterLayer to a stars object
  write_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
              driver = "GPKG", options = c("RASTER_TABLE=vegetation_substantial_fixed","APPEND_SUBDATASET=YES"))

#green classes (fixed classes)
veg_c %>%
  st_as_stars %>% # convert the RasterLayer to a stars object
  write_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
              driver = "GPKG", options = c("RASTER_TABLE=vegetation_classes_fixed","APPEND_SUBDATASET=YES"))

#green (unsupervised, classes) 
veg_clus %>%
  st_as_stars %>% # convert the RasterLayer to a stars object
  write_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
              driver = "GPKG", options = c("RASTER_TABLE=vegetation_classes_unsupervised","APPEND_SUBDATASET=YES"))

#RVI
rvi %>%
  st_as_stars %>% # convert the RasterLayer to a stars object
  write_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
              driver = "GPKG", options = c("RASTER_TABLE=rvi","APPEND_SUBDATASET=YES"))

#review raster layers in gpkg-file
gdalUtils::gdalinfo(paste0(data.dir,neighbourhood,"_green_indices.gpkg")) %>%
  cat(sep = "\n")

#gdalUtils::gdalinfo(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
# provide metadata of first subdataset:
#                    sd=1, #ndvi
# the following arguments just control formatting of the output:
#                    approx_stats = TRUE, mm = TRUE, proj4 = TRUE) %>%
#        cat(sep = "\n")
