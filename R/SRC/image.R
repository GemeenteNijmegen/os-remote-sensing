
#-----------------------------------------------------------------------------------------------

# Color-infrared (CIR) aerial photography (TIF or ECW format)

#-----------------------------------------------------------------------------------------------

#we assume you use your own color-infrared (CIR) aerial photography

#Alternatively, this location provides ECW-format aerial image for The Netherlands:
#https://datasciencevng.nl/s/ztnYabpulASJakHR
#the file is 169GB, it takes some time to download
#please clip the desired area before implementing in this procedure

#this procedure checks the AI directory first, then checks for a clipping on the VNG stack

#name of output file (TIF)
output <- paste0(data.loc,"/",neighbourhood,".tif")

#local TIF exists? (from previous run (as output file))
tiff.rdy <- FALSE
tiff.rdy <- file.exists(output)
tiff.rdy

#-----------------------------------------------------------------------------------------------
#Check for Aerial image in AI-directory (TIF-format)

#tif as a source (as input file)
if(tiff.rdy==FALSE & tiff.as.source==TRUE) {

#input.tif <- list.files(ai.dir, pattern = "\\.tif$", full.names = TRUE)
input.tif <- paste0(ai.dir,"/",neighbourhood,".tif")

if(length(input.tif) != 0) {

#message("extract CIR aerial photo in TIF-format from AI directory")
#move to output folder
file.copy(from = input.tif,
          to   = output)

tiff.rdy <- file.exists(output)
}

}

#-----------------------------------------------------------------------------------------------
#Check for Aerial image clipping of the neighbourhood on VNG Stack
#please request for the image first

if(tiff.as.source==TRUE & tiff.rdy==FALSE) {

  message("extract CIR aerial photo in TIF-format from VNG Stack")

  #remote TIFF (input)
  path_tif <- paste0("https://datasciencevng.nl/remote.php/webdav/Data/cir2020perbuurt/",neighbourhood,".tif")

  tif <- R.utils::downloadFile(url      = path_tif,
                               path     = data.loc,
                               username = webdav_login,
                               password = webdav_password,
                               verbose  = FALSE)
  tiff.rdy <- file.exists(output)
}

#-----------------------------------------------------------------------------------------------
#Check for Aerial image in AI-directory (ECW-format)

if(tiff.as.source==FALSE & tiff.rdy==FALSE) {

  input.ecw <- list.files(ai.dir, pattern = "\\.ecw$", full.names = TRUE)
  if(length(input.ecw) != 0) {

    message("extract CIR aerial photo in ECW-format from AI directory")

    gdalUtils::gdal_translate(src_dataset=input.ecw, dst_dataset=output, of="GTiff", overwrite=T, verbose=TRUE)

    tiff.rdy <- file.exists(output)
  } else {
    message("no aerial photo in ECW-format available in AI directory")
  }

}

#-----------------------------------------------------------------------------------------------

if(tiff.rdy==FALSE) {
  message("No (valid) CIR aerial photo available in AI directory")
  stop("procedure terminated")
}

#create RasterBrick
if(tiff.as.source==TRUE) {
  #TIFF as source
  #info on TIFF
  GDALinfo(output)

  ai <- as(stars::read_stars(output), "Raster")
  #rm(tif)
} else {
  #ECW as source
  ai <- raster::brick(output)
}

message("The projection of the aerial photo will be set")
raster::crs(ai) <- crs_sp

#-----------------------------------------------------------------------------------------------
#meta data

#structure
str(ai)

#layers
nlayer<-nlayers(ai)
nlayer

if(nlayer<3) {
  stop("Number of bands in the aerial image is less than 3")
}

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
if (file.exists(gpkg_raster)) {
unlink(gpkg_raster)
}

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
#Principle component bands

if(pca.ai==TRUE) {
ai_pca <- RStoolbox::rasterPCA(ai_buurt, nSamples = NULL, nComp = nlayers(ai_buurt), spca = FALSE)
ai_pca$model

ai_pca_img <- stack(ai_pca$map)

png(paste0(plots.loc,"rs_pca_",neighbourhood,".png"), bg="white", height=1280,width=1280,res=180,units="px")
terra::plotRGB(ai_pca_img, r=1, b=2, g=3, stretch="lin", smooth=TRUE,main=paste0("PCA ", neighbourhood))
plot(percelen_sf$geometry, add=TRUE, col="transparent", legend=FALSE)
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
dev.off()

rm(ai_pca,ai_pca_img)
}

#-----------------------------------------------------------------------------------------------
#Plots

#plot of aerial image bands
#png(paste0(plots.loc,"rs_cir_bands_",neighbourhood,".png"), height = 1280,width=1280,res=180,units = "px")
#plot(ai_tuinen)
#dev.off()

#Relationship bands NIR and red

#This distribution of points (between NIR and red) is unique due to its triangular shape. Vegetation
#reflects very highly in the NIR range than red and creates the upper corner close to NIR (y) axis. Water absorbs energy
#from all the bands and occupies the location close to origin. The furthest corner is created due to highly reflecting
#surface features like bright soil or concrete.
#png(paste0(plots.loc,"rs_nir_red_relationship_",neighbourhood,".png"), bg="white")
#terra::pairs(ai_buurt[[2:1]], main = "Red vs NIR")
#dev.off()

#buurt
png(paste0(plots.loc,"rs_rgb_",neighbourhood,".png"), bg="white", height=1280,width=1280,res=180,units="px")
par(col.axis = "white", col.lab = "white", tck = 0,mar = c(1,1,1,1))
aerial_rgb <- terra::plotRGB(ai_buurt,
                              r = 1, g = 2, b = 3,
                              #stretch the values to increase the contrast of the image
                              stretch = "lin",
                              smooth=TRUE,
                              axes = TRUE
                             # ,main = paste0("RGB stack neighbourhood ", neighbourhood)
                             )
aerial_rgb
plot(percelen_sf$geometry, add=TRUE, col="transparent", legend=FALSE)
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
box(col = "white")
dev.off()

#grey image
RStoolbox::ggR(ai_buurt, stretch = "lin") +
  theme_void()
plot.nme = paste0('rs_grey_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

#tuinen in buurt
png(paste0(plots.loc,"rs_rgb_",neighbourhood,"_tuinen.png"), bg="white", height=1280,width=1280,res=180,units="px")
par(col.axis = "white", col.lab = "white", tck = 0,mar = c(1,1,1,1))
aerial_rgb <- terra::plotRGB(ai_tuinen,
                              r = 1, g = 2, b = 3,
                              #stretch the values to increase the contrast of the image
                              stretch = "lin",
                              axes = TRUE,
                              main = paste0("RGB stack ", neighbourhood)
                             )
plot(percelen_sf$geometry, add=TRUE, col="transparent", legend=FALSE)
box(col = "white")
aerial_rgb
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
dev.off()

#garbage collection
gc()
