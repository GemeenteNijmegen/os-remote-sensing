
#-----------------------------------------------------------------------------------------------

#Current Dutch Elevation (Actueel Hoogtebestand Nederland, AHN)

#-----------------------------------------------------------------------------------------------

#AHN3, 0.5 m resolution based on Digital Surface Model (DSM) and Digital Terrain Model (DTM)

#nationaalgeoregister.nl as direct source (aka not package)
ngr_source <- FALSE #FALSE (default), is faster

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

#points cloud
#ahn_points <- ahn_pc(name = "BBOX pc", bbox = c(xmin, ymin, xmax,ymax), AHN = "AHN2", gefilterd = TRUE)
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
                  WIDTH=701.765000000014, #why?
                  HEIGHT=604.097200000077 #why?
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
                  WIDTH=701.765000000014, #why?
                  HEIGHT=604.097200000077 #why?
)
request <- build_url(url);request
ahn_dtm_raster <- as(stars::read_stars(request), "Raster")
names(ahn_dtm_raster) <- "BBOXrs_rAHN3_05m_DTM"
}

#digital surface model minus digital terrain model to obtain height of objects
ahn_raster<-ahn_dsm_raster-ahn_dtm_raster

rm(ahn_dsm_raster,ahn_dtm_raster)

#adjust resolution (to match aerial image)
#ahn_raster_hr <- raster::disaggregate(ahn_raster, fact=4)
ahn_raster_hr <- terra::disaggregate(ahn_raster, fact=4)

ahn_raster_hr<-ahn_raster

#resample to match dimension, resolution and extent with nearest neighbor as method (we do not want to change values as with bilinear method)
#ahn_raster_hr_rs <- raster::resample(ahn_raster_hr,ndvi, method = 'ngb') # or raster::projectRaster
ahn_raster_hr_rs <- terra::resample(ahn_raster_hr,ndvi, method = 'ngb') # or raster::projectRaster

#mask rasters
ahn_buurt <- terra::mask(ahn_raster_hr_rs, buurt_sf)
ahn_tuinen <- terra::mask(ahn_raster_hr_rs, tuinen_sf)
ahn_panden <- terra::mask(ahn_raster_hr_rs, panden_sf)

rm(ahn_raster, ahn_raster_ahn,ahn_raster_hr, ahn_raster_hr_rs)

plot(ahn_buurt, xlab = "X", ylab = "Y", main = "AHN Elevation buurt (m)")
#plot(ahn_tuinen, xlab = "X", ylab = "Y", main = "AHN Elevation tuinen (m)")
#plot(ahn_panden, xlab = "X", ylab = "Y", main = "AHN Elevation panden (m)")

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

#buurt
png(paste0(plots.loc,"rs_ahn_buurt_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180, units="px")
par(col.axis = "white", col.lab = "white", tck = 0)
aerial_rgb <- terra::plotRGB(ai_buurt,
                              r = 1, g = 2, b = 3,
                              #stretch the values to increase the contrast of the image
                              stretch = "lin",
                              alpha=0,#hide (0), show(255)
                              axes = TRUE,
                              main = paste0("AHN buurt ", neighbourhood))
plot(ahn_buurt, add=TRUE, legend=FALSE, col= rev(hcl.colors(12, "YlOrRd")))
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
aerial_rgb
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
dev.off()

#tuinen
png(paste0(plots.loc,"rs_ahn_tuinen_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180, units="px")
par(col.axis = "white", col.lab = "white", tck = 0)
aerial_rgb <- terra::plotRGB(ai_buurt,
                              r = 1, g = 2, b = 3,
                              #stretch the values to increase the contrast of the image
                              stretch = "lin",
                              alpha=0,#hide (0), show(255)
                              axes = TRUE,
                              main = paste0("AHN tuinen ", neighbourhood))
plot(ahn_tuinen, add=TRUE, legend=FALSE
     #,col=colorRampPalette(c("red", "white", "blue"))(255)
     , col= rev(hcl.colors(12, "YlOrRd"))
     )
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
aerial_rgb
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
dev.off()

rm(ahn_tuinen, ai_buurt)
