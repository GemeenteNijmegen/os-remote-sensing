# auteur: Leonard Vanbrabant
# datum aangemaakt: 11-05-2021
# datum laatst gewijzigd: 02-06-2021
# note: dit script is een bewerking van een script geschreven door Esmee 
# Kramer & Rik Scharn van de omgevingsdienst midden-en-west Brabant. 

#-----------------------------------------------------------------------------------------------

# Setup environment

#-----------------------------------------------------------------------------------------------

#Run in project environment (to avoid package conflicts)
#FALSE : use current version of packages (recommended)
#TRUE : fresh install of packages in isolated environment

proj_env <- FALSE #default (F)

#requirements: Rtools, PROJ

#setup and packages
source('SRC/setup packages.R')

#setup and packages
source(here('SRC/globals.R'))


#-----------------------------------------------------------------------------------------------
# Aerial image

#aerial infrared from PDOK
site <- "https://geodata.nationaalgeoregister.nl/luchtfoto/infrarood/wmts/Actueel_ortho25IR/EPSG:3857"
#aerial rgb from PDOK
#site <- "https://geodata.nationaalgeoregister.nl/luchtfoto/rgb/wmts/Actueel_ortho25/EPSG:3857"

#-----------------------------------------------------------------------------------------------

# Functions

#-----------------------------------------------------------------------------------------------

source(here('SRC/functions.R'))

#-----------------------------------------------------------------------------------------------

# Polygons

#-----------------------------------------------------------------------------------------------

gemeente<- "Eindhoven"
wijk<-"Oud-Tongelre"
#
buurt<-#'t Hofke"

source(here('SRC/polygon.R'))

#-----------------------------------------------------------------------------------------------

# zoom-niveau luchtfoto - zoom-niveau 19 is de max.
zoom <- 18

# tile coordinates of lat/lon points on various zoom level maps 
tile_x <- xtile_col(centroid[[1]][1], zoom = zoom)
tile_y <- ytile_col(centroid[[1]][2], zoom = zoom)

#testing purposes (overruling polygon)
#lon <- 5.520218
#lat <- 51.44441
#locs <- deg2num(lon,lat, zoom)
#f1 <- aerial_photo(locs[[1]],locs[[2]], zoom, site)

# haal foto op
f1 <- aerial_photo(tile_x,tile_y, zoom, site)

## CIR: green - red - nir
## R = XS3 (NIR band)
## G = XS2 (red band)
## B = XS1 (green band)
## (NIR - Red) / (NIR + Red)

#set layer names
names(f1) <- c("NIR Band","Red Band","Green Band")

#number of layers
nlayers(f1)

#layer names
names(f1)

#plot layers
plot(f1)

#overprocessing reds to locate green (mag eigenlijk niet met RGB)
par(col.axis = "white", col.lab = "white", tck = 0)
plotRGB(f1,
        r = 1, g = 2, b = 3,
        stretch = "lin",
        axes = TRUE,
        main = "composite image stack")
box(col = "white")



#-----------------------------------------------------------------------------------------------

# Vegetation index

#-----------------------------------------------------------------------------------------------

# calculate NDVI en RVI using the red band and nir band
red <- f1[[2]]
nir <- f1[[1]]

#Normalized difference vegetation index (NDVI)
ndvi <- (nir - red)/(nir + red)
#Ratio vegetation index (RVI)
rvi  <- nir / red

# plot NDVI
plot(ndvi,
     axes = FALSE, box = FALSE)

# plot RVI
plot(rvi,
     axes = FALSE, box = FALSE)

#hist(ndvi)

#-----------------------------------------------------------------------------------------------

# Polygon filtering

#-----------------------------------------------------------------------------------------------

#filter aerial image by polygon
ndvi_cover <- coverage_fraction(ndvi, sf)[[1]]

# save  ndvi raster (requires PROJ)
raster::writeRaster(x = ndvi_cover,
                    filename="ndvi_cover.tif",
                    format = "GTiff", # save as a tif
                    datatype='INT2S', # save as a INTEGER
                    overwrite = TRUE)  


## TODO
# laag met polygonen toevoegen aan luchtfoto en per polygoon de ndvi bepalen. 
# hoe gaan we om de randen?, de pixels vallen in meerdere polygonen. 


#-----------------------------------------------------------------------------------------------

# Debugging

#-----------------------------------------------------------------------------------------------


rlang::last_error()
rlang::last_trace()
