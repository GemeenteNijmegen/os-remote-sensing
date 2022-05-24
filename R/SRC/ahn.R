
#-----------------------------------------------------------------------------------------------

#Current Dutch Elevation (Actueel Hoogtebestand Nederland, AHN)

#-----------------------------------------------------------------------------------------------

#AHN3, 0.5 m resolution based on Digital Surface Model (DSM) and Digital Terrain Model (DTM)

#raster
if(ngr_source==FALSE) {
#request via R-package

#surface raster (DSM)
ahn_dsm_raster <- rAHNextract::ahn_area(name = "BBOX rs", bbox = c(xmin, ymin, xmax, ymax),
                                    AHN = "AHN3",
                                    dem = "DSM",
                                    resolution = 0.5)

#maaiveld raster (DTM)
ahn_dtm_raster <- rAHNextract::ahn_area(name = "BBOX rs", bbox = c(xmin, ymin, xmax, ymax),
                                        AHN = "AHN3",
                                        dem = "DTM",
                                        resolution = 0.5)
} else {
#request directly via nationaalgeoregister.nl

#surface raster (DSM)
url <- parse_url("https://geodata.nationaalgeoregister.nl/ahn3/wcs?")
url$query <- list(SERVICE = "WCS",
                  VERSION = "1.0.0",
                  REQUEST = "GetCoverage",
                  COVERAGE = "ahn3_05m_DSM",
                  RESPONSE_CRS = "EPSG:28992",
                  CRS = "EPSG:28992",
                  BBOX = bbox,
                  FORMAT="GEOTIFF_FLOAT32",
                  WIDTH=880.906,
                  HEIGHT=716.5
                  )
request <- build_url(url);request
ahn_dsm_raster <- as(stars::read_stars(request), "Raster")
names(ahn_dsm_raster) <- "BBOXrs_rAHN3_05m_DSM"

#maaiveld raster (DTM)
url <- parse_url("https://geodata.nationaalgeoregister.nl/ahn3/wcs?")
url$query <- list(SERVICE = "WCS",
                  VERSION = "1.0.0",
                  REQUEST = "GetCoverage",
                  COVERAGE = "ahn3_05m_DTM",
                  RESPONSE_CRS = "EPSG:28992",
                  CRS = "EPSG:28992",
                  BBOX = bbox,
                  FORMAT="GEOTIFF_FLOAT32",
                  WIDTH=880.9064,
                  HEIGHT=716.5
)
request <- build_url(url);request
ahn_dtm_raster <- as(stars::read_stars(request), "Raster")
names(ahn_dtm_raster) <- "BBOXrs_rAHN3_05m_DTM"
}

#height of objects = digital surface model - digital terrain model
ahn_raster <- raster::overlay(ahn_dsm_raster, ahn_dtm_raster, fun = function(x, y) { (x) - (y) })
names(ahn_raster) <- "height_objects"

#rm(ahn_dsm_raster,ahn_dtm_raster)

#adjust resolution (0.5) (to match aerial image) (0.25)
#ahn_raster_hr <- terra::disaggregate(ahn_raster, fact=4)
ahn_raster_hr <- raster::disaggregate(ahn_raster, fact=4)

#ahn_raster_hr<-ahn_raster

#resample to match dimension, resolution and extent with nearest neighbor as method
#we do not want to change values as with bilinear method
ahn_raster_hr_rs <- terra::resample(ahn_raster_hr,ndvi, method = 'ngb')

#mask rasters
ahn_buurt <- terra::mask(ahn_raster_hr_rs, buurt_sf)
ahn_tuinen <- terra::mask(ahn_raster_hr_rs, tuinen_sf)
ahn_panden <- terra::mask(ahn_raster_hr_rs, panden_sf)

rm(ahn_raster,ahn_raster_hr,ahn_dtm_raster,ahn_dsm_raster,ahn_raster_hr_rs)

#-----------------------------------------------------------------------------------------------
#Update geopackage

ahn_buurt %>% #RasterLayer
  st_as_stars %>% #convert to a stars object
  write_stars(gpkg_raster
              , driver = "GPKG"
              , options = c("RASTER_TABLE=AHN_buurt","APPEND_SUBDATASET=YES"
              )
  )

ahn_tuinen %>% #RasterLayer
  st_as_stars %>% #convert to a stars object
  write_stars(gpkg_raster
              , driver = "GPKG"
              , options = c("RASTER_TABLE=AHN_tuinen","APPEND_SUBDATASET=YES"
              )
  )

ahn_panden %>% #RasterLayer
  st_as_stars %>% #convert to a stars object
  write_stars(gpkg_raster
              , driver = "GPKG"
              , options = c("RASTER_TABLE=AHN_panden","APPEND_SUBDATASET=YES"
              )
  )


#-----------------------------------------------------------------------------------------------
#Plots

#plot(ahn_buurt, xlab = "X", ylab = "Y", main = "AHN Elevation buurt (m)")
#plot(ahn_tuinen, xlab = "X", ylab = "Y", main = "AHN Elevation tuinen (m)")
#plot(ahn_panden, xlab = "X", ylab = "Y", main = "AHN Elevation panden (m)")

#-----------------------------------------------------------------------------------------------

#rm(ai_buurt)
