
#-----------------------------------------------------------------------------------------------

# Aerial image (from ECW or TIFF)

#-----------------------------------------------------------------------------------------------

#GDAL available?
#if not please review SRC > 'packages.R'
valid_gdal <- !is.null(getOption("gdalUtils_gdalPath"))
valid_gdal

#location of aerial image
#local ECW
input <- paste0(ai.dir,"amsterdam.ecw")
#local TIFF (output)
output <- paste0(data.dir,neighbourhood,".tif")

#read TIFF (FALSE=ECW, TRUE=TIFF)
tiff.as.source<-TRUE

#local TIFF exists?
tiff.rdy<-FALSE
tiff.rdy<-file.exists(output)
tiff.rdy

#-----------------------------------------------------------------------------------------------

if(tiff.as.source==TRUE & tiff.rdy==FALSE) {
#remote TIFF (input)
path_tif <- paste0("https://datasciencevng.nl/remote.php/webdav/Data/cir2020perbuurt/",neighbourhood,".tif")

tif <- R.utils::downloadFile(url      = path_tif,
                    path     = data.dir,
                    username = webdav_login, 
                    password = webdav_password, 
                    verbose  = FALSE)
}

#-----------------------------------------------------------------------------------------------

#ECW
if(tiff.as.source==FALSE & tiff.rdy==FALSE) {
gdalUtils::gdal_translate(input, output, overwrite=T)
}

#-----------------------------------------------------------------------------------------------

#create RasterBrick
if(tiff.as.source==TRUE) {
#TIFF as source
#info on TIFF
GDALinfo(output)

#stars based on Tiff
(x = stars::read_stars(output))
#plot(x)
(ai = as(x, "Raster"))
rm(x,tif)
} else {
#ECW as source
ai<-raster::brick(output)
}

#-----------------------------------------------------------------------------------------------
#meta data 

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


#-----------------------------------------------------------------------------------------------
#cropping and masking 

#crop neighbourhood
ai_crop <- crop(ai, buurt_sf)

#mask buurt
ai_buurt <- raster::mask(ai_crop, buurt_sf)

#mask tuinen
ai_tuinen <- raster::mask(ai_crop, tuinen_sf)

rm(ai, ai_crop)

#-----------------------------------------------------------------------------------------------
#Geopackage raster data

#remove existing raster geopackage
unlink(gpkg_raster)

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

#Relationship bands NIR and red
png(paste0(plots.dir,"rs_nir_red_relationship_",neighbourhood,".png"), bg="white")
pairs(ai_buurt[[2:1]], main = "Red vs NIR")
dev.off()

#This distribution of points (between NIR and red) is unique due to its triangular shape. Vegetation
#reflects very highly in the NIR range than red and creates the upper corner close to NIR (y) axis. Water absorbs energy
#from all the bands and occupies the location close to origin. The furthest corner is created due to highly reflecting
#surface features like bright soil or concrete.

#buurt
png(paste0(plots.dir,"rs_rgb_",neighbourhood,".png"), bg="white")
par(col.axis = "white", col.lab = "white", tck = 0)
aerial_rgb <- raster::plotRGB(ai_buurt,
                              r = 1, g = 2, b = 3,
                              #stretch the values to increase the contrast of the image
                              stretch = "lin",
                              axes = TRUE,
                              main = paste0("composite image stack RGB neighbourhood ", neighbourhood))
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
aerial_rgb
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
dev.off()

#tuinen in buurt
png(paste0(plots.dir,"rs_rgb_",neighbourhood,"_tuinen.png"), bg="white")
par(col.axis = "white", col.lab = "white", tck = 0)
aerial_rgb <- raster::plotRGB(ai_tuinen,
                              r = 1, g = 2, b = 3,
                              #stretch the values to increase the contrast of the image
                              stretch = "lin",
                              axes = TRUE,
                              main = paste0("composite image stack RGB gardens ", neighbourhood))
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
aerial_rgb
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
dev.off()
