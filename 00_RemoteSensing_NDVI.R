
#-----------------------------------------------------------------------------------------------

# Remote Sensing: Green urban spaces

#-----------------------------------------------------------------------------------------------

# date created: 11-05-2021
# date modified: 18-07-2021

#-----------------------------------------------------------------------------------------------

# Setup environment

#-----------------------------------------------------------------------------------------------

#Run in project environment (to avoid package conflicts)
proj_env <- FALSE #default (F)

#external dependencies Rtools, GEOS, GDAL, PROJ.4, (Anaconda)

#setup and packages
source('SRC/packages.R')

#globals
source(here('SRC/globals.R'))

#-----------------------------------------------------------------------------------------------

# Python

#-----------------------------------------------------------------------------------------------

#Python environment
#source(here('SRC/python.R'))

#-----------------------------------------------------------------------------------------------

# Functions

#-----------------------------------------------------------------------------------------------

source(here('SRC/functions.R'))

#-----------------------------------------------------------------------------------------------

# Settings

#-----------------------------------------------------------------------------------------------

#id neighbourhood
neighbourhood<-"BU07530003" #Batadorp in Best

#location geopackages
#vector layers (polygons buurt, percelen, panden)
gpkg_vector<-paste0(temp.dir,neighbourhood,"_vector.gpkg")
#geographic raster data (incl. areial photo, NDVI, NHx?)
gpkg_raster<-paste0(temp.dir,neighbourhood,"_raster.gpkg")

#-----------------------------------------------------------------------------------------------

# Polygons

#-----------------------------------------------------------------------------------------------

#create geopackage with buurt, percelen and panden polygons
source(here('SRC/buurt_pand_perceel_request.R'))

mapview(list(percelen_sf, panden_sf),alpha.regions = 0.6, alpha = 1)

#-----------------------------------------------------------------------------------------------

# percelen disection

#-----------------------------------------------------------------------------------------------

#cut out buildings (panden) from percelen to discover potential gardens
percelen_garden_sf <- sf::st_difference(percelen_sf,panden_sf)

#gardens on percelen with woonfunctie
woonpercelen_garden_sf <- percelen_garden_sf[percelen_garden_sf$gebruiksdoel %like% "woonfunctie",] %>%
        st_make_valid()

#empty polygons?
any(is.na(st_dimension(woonpercelen_garden_sf)))
#corrupt or invalid?
#any(na.omit(st_is_valid(woonpercelen_garden_sf)) == FALSE)
#reason for invalidity
#st_is_valid(woonpercelen_garden_sf, reason = TRUE)

#cast explicitly to polygon
woonpercelen_garden_sf<-sf::st_cast(woonpercelen_garden_sf,to="MULTIPOLYGON")

#write layer to vector gpkg
sf::st_write(woonpercelen_garden_sf, dsn=gpkg_vector, layer='gardens',layer_options = "OVERWRITE=YES",append=FALSE)
sf::st_layers(gpkg_vector)

#-----------------------------------------------------------------------------------------------

# Aerial image

#-----------------------------------------------------------------------------------------------

source(here('SRC/image.R'))

#plot layers
plot(ai_crop)

#-----------------------------------------------------------------------------------------------

# Vegetation indices

#-----------------------------------------------------------------------------------------------

#calculate NDVI en RVI using the nir band and red band
nir <- ai_crop[[1]]
red <- ai_crop[[2]]

#Normalized difference vegetation index (NDVI)
#Ranges from -1 to 1
#Indicates amount of vegetation, distinguishes veg from soil, minimizes topographic effects
#Does not eliminate atmospheric effects
ndvi <- raster::overlay(red, nir, fun = function(x, y) { (y-x) / (y+x) })

#plot(ndvi)
#plot(st_geometry(woonpercelen_garden_sf), add = TRUE)

#reclassifying nvdi (all values between negative infinity and 0.4 be NAs)
#Cells with NDVI values greater than 0.4 are definitely vegetation
#substantial green
vegi <- raster::reclassify(ndvi, cbind(-Inf, 0.4, NA))

#open land
land <- raster::reclassify(ndvi, c(-Inf, 0.25, NA,  0.25, 0.3, 1,  0.3, Inf, NA))

#vegetation in classes
vegc <- raster::reclassify(ndvi, c(-Inf,0.25,1, 0.25,0.3,2, 0.3,0.4,3, 0.4,0.5,4, 0.5,Inf, 5))

#Ratio vegetation index (RVI)
#Indicates amount of vegetation
#Reduces the effects of atmosphere and topography
rvi  <- nir / red

#-----------------------------------------------------------------------------------------------
#create fresh multi-raster GeoPackage (gpkg) containing all green indices (write)

unlink(paste0(temp.dir,neighbourhood,"_green_indices.gpkg"))
#Stars-packagke

#NDVI values
ndvi %>%
        st_as_stars %>% # convert the RasterLayer to a stars object
        write_stars(paste0(temp.dir,neighbourhood,"_green_indices.gpkg"),
                    driver = "GPKG",options = c("RASTER_TABLE=ndvi","APPEND_SUBDATASET=YES"))

#subset of substantial green
vegi %>%
        st_as_stars %>% # convert the RasterLayer to a stars object
        write_stars(paste0(temp.dir,neighbourhood,"_green_indices.gpkg"),
                    driver = "GPKG", options = c("RASTER_TABLE=vegi","APPEND_SUBDATASET=YES"))

#RVI values
rvi %>%
        st_as_stars %>% # convert the RasterLayer to a stars object
        write_stars(paste0(temp.dir,neighbourhood,"_green_indices.gpkg"),
                    driver = "GPKG", options = c("RASTER_TABLE=rvi","APPEND_SUBDATASET=YES"))

#review raster layers in gpkg-file
gdalUtils::gdalinfo(paste0(temp.dir,neighbourhood,"_green_indices.gpkg")) %>%
        cat(sep = "\n")

#gdalUtils::gdalinfo(paste0(temp.dir,neighbourhood,"_green_indices.gpkg"),
                    # provide metadata of first subdataset:
#                    sd=1, #ndvi
                    # the following arguments just control formatting of the output:
#                    approx_stats = TRUE, mm = TRUE, proj4 = TRUE) %>%
#        cat(sep = "\n")


#create RasterBrick (read)
green_indices <-
        read_stars(paste0(temp.dir,neighbourhood,"_green_indices.gpkg")
                   #subsetting
                   #,sub = "ndvi"
                   ,quiet = TRUE
                   ) %>%
        as("Raster")
green_indices

#-----------------------------------------------------------------------------------------------

# Vegetation plots

#-----------------------------------------------------------------------------------------------

source(here('SRC/vegi plots.R'))

#-----------------------------------------------------------------------------------------------

# Polygon filtering

#-----------------------------------------------------------------------------------------------

#filter ndvi raster by polygon
#https://cran.r-project.org/web/packages/exactextractr/exactextractr.pdf

#projection
crs(vegi)<-crs(percelen_sf)
crs(ndvi)<-crs(percelen_sf)

#surface covered by substantial green per polygon element

ndvi2<-raster::raster(ndvi)
percelen_sf2<-sf::st_sf(percelen_sf)

ndvi_cover <- exactextractr::coverage_fraction(ndvi2,percelen_sf2, crop = FALSE)
rm(ndvi2,percelen_sf2)

#Mean value (NDVI) of cells that intersect the polygon, weighted by the percent of the cell that is covered.
#mean ndvi per polygon element (perceel)
ndvi_avg<-exactextractr::exact_extract(ndvi, percelen_sf,
                                             #the mean cell value, weighted by the fraction of each cell
                                             #that is covered by the polygon
                                             fun ='mean',
                                             force_df =TRUE)


#add mean ndvi values to percelen_sf
percelen_sf$ndvi_avg<-ndvi_avg

#Sum of raster cells covered by the polygon, with each raster value weighted by its coverage fraction
#and weighting raster value.
#ndvi_weighted_sum<-exactextractr::exact_extract(vegi, woonpercelen_garden_sf,
#                                             'weighted_sum',
#                                             weights=raster(woonpercelen_garden_sf$geom),
#                                             force_df =TRUE)



#-----------------------------------------------------------------------------------------------

# Unsupervised classification

#-----------------------------------------------------------------------------------------------

source(here('SRC/classification.R'))

#-----------------------------------------------------------------------------------------------

# Debugging

#-----------------------------------------------------------------------------------------------

rlang::last_error()
rlang::last_trace()
