
#-----------------------------------------------------------------------------------------------

# Aerial image (from ECW or TIFF)

#-----------------------------------------------------------------------------------------------

#GDAL available?
#if not please review SRC > 'packages.R'
valid_gdal <- !is.null(getOption("gdalUtils_gdalPath"))
valid_gdal

#aerial image
#name of input file (ECW) (if available in AI-directory)
input <- paste0(ai.dir,"amsterdam.ecw")

#-------------------------------------------------------
#this location provides ecw for The Netherlands https://datasciencevng.nl/s/ztnYabpulASJakHR
#the file is 169GB, it takes some time to download

#download manually and store in the AI-directory

#input <- paste0(ai.dir,"2020_LR_CIR_totaalmozaiek_v2_clip.ecw")
#-------------------------------------------------------

#name of output file (TIF)
output <- paste0(data.loc,neighbourhood,".tif")

#read TIFF (FALSE=ECW, TRUE=TIFF)
tiff.as.source<-TRUE

#local TIFF exists?
tiff.rdy<-FALSE
tiff.rdy<-file.exists(output)
tiff.rdy

#-----------------------------------------------------------------------------------------------

if(tiff.as.source==TRUE & tiff.rdy==FALSE) {

  message("extract aerial photo in TIF-format from VNG Stack")

  #remote TIFF (input)
  path_tif <- paste0("https://datasciencevng.nl/remote.php/webdav/Data/cir2020perbuurt/",neighbourhood,".tif")

  tif <- R.utils::downloadFile(url      = path_tif,
                               path     = data.loc,
                               username = webdav_login,
                               password = webdav_password,
                               verbose  = FALSE)
}

#-----------------------------------------------------------------------------------------------

#ECW
if(tiff.as.source==FALSE & tiff.rdy==FALSE) {

  message("extract aerial photo in ECW-format from AI directory")

  gdalUtils::gdal_translate(input, output, overwrite=T)
}

#-----------------------------------------------------------------------------------------------

#create RasterBrick
if(tiff.as.source==TRUE) {
  #TIFF as source
  #info on TIFF
  #GDALinfo(output)

  ai <-  as(stars::read_stars(output), "Raster")
  rm(tif)
} else {
  #ECW as source
  ai<-raster::brick(output)
}

#-----------------------------------------------------------------------------------------------
#meta data

#structure
str(ai)

#layers
nlayers(ai)

#extent
extent(ai)

#layer names
names(ai)

#set correct layer names
#https://www.mngeo.state.mn.us/chouse/airphoto/cir.html
names(ai) <- c("nir","red","green")


#-----------------------------------------------------------------------------------------------
#cropping and masking

#crop neighbourhood
ai_crop <- raster::crop(ai, buurt_sf)
rm(ai)

#mask buurt
ai_buurt <- raster::mask(ai_crop, buurt_sf)

#mask tuinen
ai_tuinen <- raster::mask(ai_crop, tuinen_sf)

rm(ai, ai_crop)

#-----------------------------------------------------------------------------------------------
#Geopackage raster data

#remove existing raster geopackage
unlink(gpkg_raster)

message("store CIR layers as rasters in geopackage")

#create (fresh) multi-raster GeoPackage
#NIR
names(ai_buurt[[1]]) <-"nir"
ai_buurt[[1]] %>% #RasterLayer
  st_as_stars %>% #convert to a stars object
  write_stars(gpkg_raster
              , driver = "GPKG"
              , options = c("RASTER_TABLE=NIR.BAND","APPEND_SUBDATASET=YES"
              )
  )

#RED
names(ai_buurt[[2]]) <-"red"
ai_buurt[[2]] %>% #RasterLayer
  st_as_stars %>% #convert to a stars object
  write_stars(gpkg_raster
              , driver = "GPKG"
              , options = c("RASTER_TABLE=Red.BAND","APPEND_SUBDATASET=YES")
  )

#read GPKG
#ai_rb <- read_stars(gpkg_raster) %>%
#  as("Raster")

#GDAL options for GPKG
#https://gdal.org/drivers/raster/gpkg.html#creation-options


#-----------------------------------------------------------------------------------------------
#Plots

#plot of aerial image bands
png(paste0(plots.loc,"rs_cir_bands_",neighbourhood,".png"), height = 1280,width=1280,res=180,units = "px")
plot(ai_tuinen)
dev.off()

#Relationship bands NIR and red
png(paste0(plots.loc,"rs_nir_red_relationship_",neighbourhood,".png"), bg="white")
pairs(ai_buurt[[2:1]], main = "Red vs NIR")
dev.off()

#This distribution of points (between NIR and red) is unique due to its triangular shape. Vegetation
#reflects very highly in the NIR range than red and creates the upper corner close to NIR (y) axis. Water absorbs energy
#from all the bands and occupies the location close to origin. The furthest corner is created due to highly reflecting
#surface features like bright soil or concrete.

#buurt
png(paste0(plots.loc,"rs_rgb_",neighbourhood,".png"), bg="white", height = 1280,width=1280,res=180,units = "px")
par(col.axis = "white", col.lab = "white", tck = 0,mar = c(1,1,1,1))
aerial_rgb <- terra::plotRGB(ai_buurt,
                              r = 1, g = 2, b = 3,
                              #stretch the values to increase the contrast of the image
                              stretch = "lin",
                              axes = TRUE,
                              main = paste0("RGB stack neighbourhood ", neighbourhood))
plot(percelen_sf$geom, add=TRUE, col="transparent", legend=FALSE)
box(col = "white")
aerial_rgb
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
dev.off()

#tuinen in buurt
png(paste0(plots.loc,"rs_rgb_",neighbourhood,"_tuinen.png"), bg="white", height = 1280,width=1280,res=180,units = "px")
par(col.axis = "white", col.lab = "white", tck = 0,mar = c(1,1,1,1))
aerial_rgb <- terra::plotRGB(ai_tuinen,
                              r = 1, g = 2, b = 3,
                              #stretch the values to increase the contrast of the image
                              stretch = "lin",
                              axes = TRUE,
                              main = paste0("RGB stack gardens ", neighbourhood))
plot(percelen_sf$geom, add=TRUE, col="transparent", legend=FALSE)
box(col = "white")
aerial_rgb
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
dev.off()

gc()
