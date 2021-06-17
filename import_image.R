
#-----------------------------------------------------------------------------------------------

# Aerial image (from ECW or TIFF)

#-----------------------------------------------------------------------------------------------

#GDAL available?
#if not please review SRC > 'packages.R' 
valid_gdal <- !is.null(getOption("gdalUtils_gdalPath"))
valid_gdal

#read TIFF instead of ECW (FALSE=ECW, TRUE=TIFF)
tiff.as.source<-FALSE

#location of aerial image
input <- "tempdata/amsterdam.ecw"
output <- "tempdata/amst.tiff"

#TIFF exists?
tiff.rdy<-FALSE
tiff.rdy<-file.exists(output)
tiff.rdy

if(tiff.as.source==FALSE & tiff.rdy==FALSE) {
gdalUtils::gdal_translate(input, output, overwrite=T)
}

#create RasterBrick
if(tiff.as.source==TRUE) {
#TIFF as source
#info on TIFF
GDALinfo(output)
  
#stars based on Tiff
(x = read_stars(output))
#plot(x)
(ai = as(x, "Raster"))
rm(x)
} else {
#ECW as source
ai<-raster::brick(output)  
}

#structure
str(ai)

#projection
raster::crs(ai) <- "EPSG:4326"

#layers
nlayers(ai)

#extent
extent(ai)

#layer names
names(ai)

#set correct layer names
#https://www.mngeo.state.mn.us/chouse/airphoto/cir.html
names(ai) <- c("nir","red","green", "allopacity")

plot(ai)

#crop neighbourhood
ai_crop <- crop(ai, buurt_sf)
(ai_crop)

rm(ai)

png(paste0(plots.dir,"rs_rgbplot_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio, height=png_height)
par(col.axis = "white", col.lab = "white", tck = 0)
aerial_rgb<-plotRGB(ai_crop,
                    r = 1, g = 2, b = 3,
                    #stretch the values to increase the contrast of the image
                    stretch = "lin",
                    axes = TRUE,
                    main = paste0("composite image stack ", neighbourhood))
box(col = "white")
aerial_rgb
dev.off()

#plot NIR and polygon percelen
plot(ai_crop[[1]])
plot(st_geometry(percelen_sf), add=TRUE)
dev.off()

#remove existing raster geopackage
unlink(neigh.ras.loc)

#create (fresh) multi-raster GeoPackage
#NIR
names(ai_crop[[1]]) <-"nir"
ai_crop[[1]] %>% #RasterLayer
  st_as_stars %>% # convert the RasterLayer to a stars object
  write_stars(neigh.ras.loc
              , driver = "GPKG"
              , options = c("RASTER_TABLE=NIR.BAND","APPEND_SUBDATASET=YES"
                            )
  )
#RED
names(ai_crop[[2]]) <-"red"
ai_crop[[2]] %>% #RasterLayer
  st_as_stars %>% # convert the RasterLayer to a stars object
  write_stars(neigh.ras.loc
              , driver = "GPKG"
              , options = c("RASTER_TABLE=Red.BAND","APPEND_SUBDATASET=YES")
  )

#read GPKG
#ai_rb<-read_stars(neigh.ras.loc) %>% 
#  as("Raster")

#GDAL options for GPKG
#https://gdal.org/drivers/raster/gpkg.html#creation-options
