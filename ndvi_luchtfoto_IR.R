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

#globals
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
#buurt<-"'t Hofke"

source(here('SRC/polygon.R'))

#-----------------------------------------------------------------------------------------------

# zoom-niveau luchtfoto - zoom-niveau 19 is de max.
zoom <- 18

# tile coordinates of lat/lon points on various zoom level maps 
#lon
tile_x <- xtile_col(centroid[[1]][1], zoom = zoom)
#lat
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

#set layer names
names(f1) <- c("NIR Band","Red Band","Green Band")

#number of layers
nlayers(f1)

#layer names
names(f1)

#plot layers
plot(f1)

#overprocessing NIR and red layers to locate green 
#improve photo quality
png(paste0(plots.dir,"rs_rgbplot_",gemeente,"_",wijk,".png"), bg="white", width=png_height*aspect_ratio, height=png_height)
par(col.axis = "white", col.lab = "white", tck = 0)
plotRGB(f1,
        r = 1, g = 2, b = 3,
        #stretch the values to increase the contrast of the image
        stretch = "lin",
        axes = TRUE,
        main = paste0("composite image stack ", gemeente, " ", wijk))
box(col = "white")
dev.off()


#-----------------------------------------------------------------------------------------------

# Vegetation index

#-----------------------------------------------------------------------------------------------

# calculate NDVI en RVI using the red band and nir band
red <- f1[[2]]
nir <- f1[[1]]

#Normalized difference vegetation index (NDVI)
#ndvi <- (nir - red)/(nir + red)

ndvi <- raster::overlay(red, nir, fun = function(x, y) {
        (y-x) / (y+x)
})

#Ratio vegetation index (RVI)
rvi  <- nir / red

# plot NDVI
gplot(ndvi) + 
        geom_tile(aes(fill = value)) +
        scale_fill_gradientn(colours = rev(terrain.colors(225))) +
        coord_equal() +
        theme_minimal() 
plot.nme = paste0('rs_ndvi.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)


# plot RVI
gplot(rvi) + 
        geom_tile(aes(fill = value)) +
        scale_fill_gradientn(colours = rev(terrain.colors(225))) +
        coord_equal() +
        theme_minimal() 
plot.nme = paste0('rs_rvi.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)


#hist(ndvi)

#-----------------------------------------------------------------------------------------------

# Polygon filtering

#-----------------------------------------------------------------------------------------------

#polygon
plot(sf)

#filter ndvi by polygon
#https://cran.r-project.org/web/packages/exactextractr/exactextractr.pdf
ndvi_cover <- exactextractr::coverage_fraction(ndvi, sf, crop = TRUE)

#Extracts the values of cells in Raster* that are covered by polygons in a simple feature collection
#average ndvi per polygon element
ndvi_cover_avg<-exactextractr::exact_extract(ndvi, sf, 
                                             #the mean cell value, weighted by the fraction of each cell 
                                             #that is covered by the polygon
                                             'mean',
                                             force_df =TRUE
                                             )


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
