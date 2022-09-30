
#-----------------------------------------------------------------------------------------------

# Color-infrared (CIR) airborne imagery

#-----------------------------------------------------------------------------------------------

#we assume you use your own color-infrared (CIR) airborne imagery

#Alternatively, this location provides ECW-format aerial image for The Netherlands:
#https://datasciencevng.nl/s/ztnYabpulASJakHR
#the file is 169GB, it takes some time to download
#please clip the desired area before implementing in this procedure

#this procedure checks the AI directory first, then checks for a clipping on the VNG stack

#neighbourhood<-"BU15810004"
#location of output.tif file (TIF)
output.tif <- paste0(data.loc,"/",neighbourhood,".tif")

#does local TIF exist?
tif.rdy <- FALSE
tif.rdy <- file.exists(output.tif)
tif.rdy

#-----------------------------------------------------------------------------------------------
#Check for Aerial image in AI-directory (TIF-format)

#tif as a source (as input file)
if(tif.as.source==TRUE & tif.rdy==FALSE) {

#location of input file
#input.tif <- list.files(ai.dir, pattern = "\\.tif$", full.names = TRUE)
input.tif <- paste0(ai.dir,"/",neighbourhood,".tif")

if(length(input.tif) != 0) {
#move to output folder
file.copy(from = input.tif,
          to   = output.tif)

#verify
tif.rdy <- file.exists(output.tif)
}

}

#-----------------------------------------------------------------------------------------------
#Check for Aerial image clipping of the neighbourhood on VNG Stack
#please request for the image first

if(tif.as.source==TRUE & tif.rdy==FALSE) {

  message("\nextract CIR aerial photo in TIF-format from VNG Stack")

  #remote TIFF (input)
  path_tif <- paste0("https://datasciencevng.nl/remote.php/webdav/Data/cir2020perbuurt/",neighbourhood,".tif")

  tif <- R.utils::downloadFile(url      = path_tif,
                               path     = data.loc,
                               username = webdav_login,
                               password = webdav_password,
                               verbose  = FALSE)
  tif.rdy <- file.exists(output.tif)
}

#-----------------------------------------------------------------------------------------------
#Check for Aerial image in AI-directory (ECW-format)

if(tif.as.source==FALSE & tif.rdy==FALSE) {

  input.ecw <- list.files(ai.dir, pattern = "\\.ecw$", full.names = TRUE)
  if(length(input.ecw) != 0) {

    message("\nextract CIR aerial photo in ECW-format from AI directory")

    gdalUtils::gdal_translate(src_dataset=input.ecw, dst_dataset=output.tif, of="GTiff", overwrite=T, verbose=TRUE)

    tif.rdy <- file.exists(output.tif)
  } else {
    message("\nno aerial photo in ECW-format available in AI directory")
  }

}

#-----------------------------------------------------------------------------------------------

if(tif.rdy==FALSE) {
  message("\nNo (valid) CIR aerial photo available in AI directory")
  stop("\nprocedure terminated")
}

ai <- terra::rast(output.tif)

#set projection of the raster
message("The projection of the aerial photo will be set to ", crs_sp)
crs(ai) <- crs_str

#-----------------------------------------------------------------------------------------------
#meta data

#structure
str(ai)

#layers
nlayer<-nlyr(ai)
nlayer

if(nlayer<3) {
  stop("\nNumber of bands in the aerial image is less than three : ", nlayer)
}

#layer names
names(ai)

#set correct layer names
#https://www.mngeo.state.mn.us/chouse/airphoto/cir.html
names(ai) <- band_nms

#-----------------------------------------------------------------------------------------------
#cropping and masking

#crop neighbourhood
ai_crop <- terra::crop(ai, buurt_sf)

#mask buurt
ai_buurt <- terra::mask(ai_crop, buurt_sf)

#mask tuinen
ai_tuinen <- terra::mask(ai_crop, tuinen_sf)

rm(ai,ai_crop)

#-----------------------------------------------------------------------------------------------
#Geopackage raster data

#remove existing raster geopackage
if (file.exists(gpkg_raster)) {
unlink(gpkg_raster)
}

#message("store CIR layers as rasters in geopackage")

#GDAL options for GPKG
#https://gdal.org/drivers/raster/gpkg.html#creation-options

#-----------------------------------------------------------------------------------------------
#assign bands (CIR)

if(report_tuinen==TRUE) {
  #near-infrared band from aerial photo masked/clipped tuinen (which vegetation strongly reflects)
  nir <- ai_tuinen[[nir_seq]]
  #red light from aerial photo masked/clipped tuinen (which vegetation absorbs)
  red <- ai_tuinen[[red_seq]]
} else {
  #near-infrared band from aerial photo masked/clipped buurt (which vegetation strongly reflects)
  nir <- ai_buurt[[nir_seq]]
  #red light from aerial photo masked/clipped buurt (which vegetation absorbs)
  red <- ai_buurt[[red_seq]]
}

#-----------------------------------------------------------------------------------------------
#Principle component bands

if(pca.ai==TRUE) {
ai_pca <- RStoolbox::rasterPCA(ai_buurt, nSamples = NULL, nComp = nlayers(ai_buurt), spca = FALSE)
#ai_pca$model

ai_pca_img <- stack(ai_pca$map)

#plot PCA
plotting_terra(ai_pca_img,percelen_sf$geometry,"PCA","rs_pca",NULL,NULL,NULL)

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

#RGB plot buurt
#plotting_terra(ai_buurt,percelen_sf$geometry,NULL,"rs_rgb_buurt",NULL,NULL,NULL)

if(report_tuinen==TRUE) {
#RGB plot tuinen in buurt
plotting_terra(ai_tuinen,percelen_sf$geometry,NULL,"rs_rgb_tuinen",NULL,NULL,NULL)
}

#grey image
RStoolbox::ggR(ai_buurt, stretch = "lin") +
  theme_void()
plot.nme = paste0('rs_grey_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

#garbage collection
gc()
