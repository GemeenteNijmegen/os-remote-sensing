# auteur: Leonard Vanbrabant
# datum aangemaakt: 11-05-2021
# datum laatst gewijzigd: 07-06-2021
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
# Aerial image source

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

#R based polygons (still in use for centroid extraction, please use input from buurt_pand_selectie.R)
gemeente<- "Amsterdam"
wijk<-"Overtoomse Veld"
buurt<-""

#source(here('SRC/polygon.R'))

#----------------------------
#Geopackage based polygons (new, preferred)

#id neighbourhood
neighbourhood<-"BU03638600"

#temporary solution (for graph title)
wijk<- neighbourhood

#location geopackage 
neigh.loc<-paste0(temp.dir,neighbourhood,".gpkg")

source(here('SRC/buurt_pand_perceel_selectie.R'))


#-----------------------------------------------------------------------------------------------

# percelen disection

#-----------------------------------------------------------------------------------------------


# Filter-out invalid and unneeded features, calculate surface area
percelen_sf <- percelen_sf  %>% 
        #make sure shapes are valid  
        st_make_valid()  %>%
        #filter() %>%
        #feature area calculation (m^2)
        mutate(area = st_area(percelen_sf))

#add id to rownames
rownames(percelen_sf)<-percelen_sf$identificatieLokaalID
head(percelen_sf)

mapview(percelen_sf)


#cut out buildings (panden) to discover potential gardens
#panden
#percelen_panden_intersect_sf<- st_difference(percelen_sf,panden_py)
#percelen_garden_sf<- st_difference(percelen_sf,panden_py)

#mapview(percelen_garden_sf)
percelen_garden_sf<-percelen_sf

#write garden surface as geopackage to temdata dir
st_write(percelen_garden_sf,
         dsn = paste0(temp.dir,neighbourhood,"_percelen_gardens.gpkg"), 
         layer="percelen", 
         delete_dsn = TRUE
)

#populate or substitute "sf" 


#-----------------------------------------------------------------------------------------------

# Aerial image

#-----------------------------------------------------------------------------------------------


buurt_sf_tf<- st_transform(buurt_sf, crs = st_crs(4326))

#centroid buurt
centroid_alt <- sf::st_centroid(buurt_sf_tf)
centroid_alt<- centroid_alt$geom

cen<-unlist(centroid_alt)
x_centroid<-cen[1]
y_centroid<-cen[2]

# zoom-niveau luchtfoto - zoom-niveau 19 is de max.
zoom <- 14

tile_x <- xtile_col(x_centroid, zoom = zoom)
tile_y <- ytile_col(y_centroid, zoom = zoom)

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


#bounding box
#@Leonard dit is de bounding box van de eerste feature (subset 1/6) en deze pas je toe op de hele foto
my_extent <- num2deg(tile_x, tile_y, zoom)
extent(f1) <- my_extent
extent(f1)

#projection
crs(f1)
crs(f1) <- "+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"
crs(f1)

mapview(f1)

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

ndvi <- raster::overlay(red, nir, fun = function(x, y) { (y-x) / (y+x) })

plot(ndvi)
plot(sf, add = TRUE)

# reclassifying nvdi (all values between negative infinity and 0.4 be NAs)
# aka substantial green
vegi <- raster::reclassify(ndvi, cbind(-Inf, 0.4, NA))

#Ratio vegetation index (RVI)
rvi  <- nir / red

#-----------------------------------------------------------------------------------------------

# Vegetation plots

#-----------------------------------------------------------------------------------------------

source(here('SRC/vegi plots.R'))

#hist(ndvi)

#-----------------------------------------------------------------------------------------------

# Polygon filtering

#-----------------------------------------------------------------------------------------------

plot(sf)
#plot(sf[[1]])

#crop
#t <- rasterize(st_as_sf(sf), ndvi)

#filter ndvi vegi by polygon
#https://cran.r-project.org/web/packages/exactextractr/exactextractr.pdf

#set crop to true once positioning of areal image is correct
ndvi_cover <- exactextractr::coverage_fraction(vegi, sf, crop = FALSE)

#Extracts the values of cells in Raster* that are covered by polygons in a simple feature collection
#average ndvi vegi per polygon element
ndvi_cover_avg<-exactextractr::exact_extract(vegi, sf, 
                                             #the mean cell value, weighted by the fraction of each cell 
                                             #that is covered by the polygon
                                             'mean',
                                             force_df =TRUE
                                             )




# save  ndvi raster (requires PROJ)
#raster::writeRaster(x = ndvi_cover,
#                    filename="ndvi_cover.tif",
#                    format = "GTiff", # save as a tif
#                    datatype='INT2S', # save as a INTEGER
#                    overwrite = TRUE)  


## TODO
# laag met polygonen toevoegen aan luchtfoto en per polygoon de ndvi bepalen. 
# hoe gaan we om de randen?, de pixels vallen in meerdere polygonen. 

#-----------------------------------------------------------------------------------------------

# Unsupervised classification

#-----------------------------------------------------------------------------------------------

source(here('SRC/classification.R'))

#-----------------------------------------------------------------------------------------------

# Debugging

#-----------------------------------------------------------------------------------------------

rlang::last_error()
rlang::last_trace()
