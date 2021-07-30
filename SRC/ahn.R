
#-----------------------------------------------------------------------------------------------

# Actueel Hoogtebestand Nederland (AHN)

#-----------------------------------------------------------------------------------------------

#raster
ahn_raster <- ahn_area(name = "BBOX rs", bbox = c(xmin, ymin, xmax,ymax), resolution = 0.5)

#points cloud
#ahn_points <- ahn_pc(name = "BBOX pc", bbox = c(xmin, ymin, xmax,ymax), AHN = "AHN2", gefilterd = TRUE)

#mask rasters
ahn_buurt <- raster::mask(ahn_raster, buurt_sf)
ahn_tuinen <- raster::mask(ahn_raster, tuinen_sf)
ahn_panden <- raster::mask(ahn_raster, panden_sf)

rm(ahn_raster)

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
png(paste0(plots.dir,"rs_ahn_buurt_",neighbourhood,".png"), bg="white")
par(col.axis = "white", col.lab = "white", tck = 0)
aerial_rgb <- raster::plotRGB(ai_buurt,
                              r = 1, g = 2, b = 3,
                              #stretch the values to increase the contrast of the image
                              stretch = "lin",
                              alpha=0,#hide (0), show(255)
                              axes = TRUE,
                              main = paste0("composite image stack RGB AHN panden neighbourhood ", neighbourhood))
plot(ahn_buurt, add=TRUE, legend=FALSE)
box(col = "white")
aerial_rgb
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
dev.off()

#panden
png(paste0(plots.dir,"rs_ahn_panden_",neighbourhood,".png"), bg="white")
par(col.axis = "white", col.lab = "white", tck = 0)
aerial_rgb <- raster::plotRGB(ai_buurt,
                              r = 1, g = 2, b = 3,
                              #stretch the values to increase the contrast of the image
                              stretch = "lin",
                              alpha=0,#hide (0), show(255)
                              axes = TRUE,
                              main = paste0("composite image stack RGB AHN panden neighbourhood ", neighbourhood))
plot(ahn_panden, add=TRUE, legend=FALSE)
box(col = "white")
aerial_rgb
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
dev.off()

#tuinen
png(paste0(plots.dir,"rs_ahn_tuinen_",neighbourhood,".png"), bg="white")
par(col.axis = "white", col.lab = "white", tck = 0)
aerial_rgb <- raster::plotRGB(ai_buurt,
                              r = 1, g = 2, b = 3,
                              #stretch the values to increase the contrast of the image
                              stretch = "lin",
                              alpha=0,#hide (0), show(255)
                              axes = TRUE,
                              main = paste0("composite image stack RGB AHN tuinen neighbourhood ", neighbourhood))
plot(ahn_tuinen, add=TRUE, legend=FALSE)
box(col = "white")
aerial_rgb
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
dev.off()
