
#-----------------------------------------------------------------------------------------------

# Aerial image (from ECW or TIFF)

#-----------------------------------------------------------------------------------------------

#GDAL available?
#if not please review SRC > 'packages.R'
valid_gdal <- !is.null(getOption("gdalUtils_gdalPath"))
valid_gdal

#read TIFF instead of ECW (FALSE=ECW, TRUE=TIFF)
tiff.as.source<-TRUE

#location of aerial image
#ECW
input <- paste0(temp.dir,"amsterdam.ecw")
output <- paste0(temp.dir,neighbourhood,".tif")

#remote TIFF
path_tif <- paste0("https://datasciencevng.nl/remote.php/webdav/Data/cir2020perbuurt/",neighbourhood,".tif")
library(R.utils)
tif <- downloadFile(url      = path_tif,
                    path     = temp.dir,
                    username = "remotesensing", 
                    password = "VNGRS2021!", 
                    verbose  = FALSE)


#local TIFF exists?
tiff.rdy<-FALSE
tiff.rdy<-file.exists(output)
tiff.rdy

#ECW
if(tiff.as.source==FALSE & tiff.rdy==FALSE) {
gdalUtils::gdal_translate(input, output, overwrite=T)
}

#create RasterBrick
if(tiff.as.source==TRUE) {
#TIFF as source
#info on TIFF
GDALinfo(output)

#stars based on Tiff
(x = read_stars(tif))
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
names(ai) <- c("nir","red","green")

plot(ai)

#crop neighbourhood
ai_crop <- crop(ai, buurt_sf)
(ai_crop)

rm(ai)

png(paste0(plots.dir,"rs_rgb_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio, height=png_height)
par(col.axis = "white", col.lab = "white", tck = 0)
aerial_rgb<-plotRGB(ai_crop,
                    r = 1, g = 2, b = 3,
                    #stretch the values to increase the contrast of the image
                    stretch = "lin",
                    axes = TRUE,
                    main = paste0("composite image stack ", neighbourhood))
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
aerial_rgb
dev.off()

#plot NIR and polygon percelen
plot(ai_crop[[1]])
plot(st_geometry(percelen_sf), add=TRUE)
dev.off()

#remove existing raster geopackage
unlink(gpkg_raster)

#create (fresh) multi-raster GeoPackage
#NIR
names(ai_crop[[1]]) <-"nir"
ai_crop[[1]] %>% #RasterLayer
  st_as_stars %>% #convert to a stars object
  write_stars(gpkg_raster
              , driver = "GPKG"
              , options = c("RASTER_TABLE=NIR.BAND","APPEND_SUBDATASET=YES"
                            )
  )
#RED
names(ai_crop[[2]]) <-"red"
ai_crop[[2]] %>% #RasterLayer
  st_as_stars %>% #convert to a stars object
  write_stars(gpkg_raster
              , driver = "GPKG"
              , options = c("RASTER_TABLE=Red.BAND","APPEND_SUBDATASET=YES")
  )

#read GPKG
#ai_rb<-read_stars(gpkg_raster) %>%
#  as("Raster")

#GDAL options for GPKG
#https://gdal.org/drivers/raster/gpkg.html#creation-options
