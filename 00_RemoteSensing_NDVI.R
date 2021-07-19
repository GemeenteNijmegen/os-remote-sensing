
#-----------------------------------------------------------------------------------------------

# Remote Sensing: Green urban spaces

#-----------------------------------------------------------------------------------------------

# date created: 11-05-2021
# date modified: 19-07-2021

#-----------------------------------------------------------------------------------------------

# Setup environment

#-----------------------------------------------------------------------------------------------

#Run in project environment (to avoid package conflicts)
proj_env <- FALSE #default (F)

#debug mode
debug_mode <- FALSE #default (F)

#external dependencies Rtools, GEOS, GDAL, PROJ.4, (Anaconda)

#setup and packages
source('SRC/packages.R')

#globals
source(here::here('SRC/globals.R'))

#-----------------------------------------------------------------------------------------------

# Python

#-----------------------------------------------------------------------------------------------

#Python environment
#source(here('SRC/python.R'))

#-----------------------------------------------------------------------------------------------

# Settings

#-----------------------------------------------------------------------------------------------

#id neighbourhood
neighbourhood<-"BU07530003" #Batadorp in Best
neighbourhood<-"BU04411401" #another neighbourhood

#location geopackages
#vector layers (polygons buurt, percelen, panden, tuinen)
gpkg_vector<-paste0(data.dir,neighbourhood,"_vector.gpkg")
#geographic raster data (incl. aerial photo, NDVI, NHx?)
gpkg_raster<-paste0(data.dir,neighbourhood,"_raster.gpkg")

#-----------------------------------------------------------------------------------------------

# Polygons

#-----------------------------------------------------------------------------------------------

#geopackage with buurt, percelen and panden polygons

prefab_polygons <- TRUE 

if(prefab_polygons==TRUE) {
#download prefab geopackage        
 source(here::here('SRC/vector_gpkg_request.R'))       
} else {
#create geopackage
 source(here::here('SRC/buurt_pand_perceel_request.R')) 
}

#mapview(list(buurt_sf,percelen_sf, panden_sf),alpha.regions = 0.6, alpha = 1)

#-----------------------------------------------------------------------------------------------

# Aerial image

#-----------------------------------------------------------------------------------------------

source(here::here('SRC/image.R'))

#plot layers
plot(ai_tuinen)

#-----------------------------------------------------------------------------------------------

# Vegetation indices

#-----------------------------------------------------------------------------------------------

#calculate NDVI en RVI using the nir band and red band
nir <- ai_tuinen[[1]]
red <- ai_tuinen[[2]]

#Normalized difference vegetation index (NDVI)
#Ranges from -1 to 1
#Indicates amount of vegetation, distinguishes veg from soil, minimizes topographic effects
#Does not eliminate atmospheric effects
ndvi <- raster::overlay(red, nir, fun = function(x, y) { (y-x) / (y+x) })

#plot(ndvi)

source(here::here('SRC/green_classes.R'))

#ranges according to Deloitte research
#-1 tot -0.1: Water
#-0.1 tot 0.2: Zand/Grond/Rots 
#0.2 tot 0.4: Gras en lage vegetatie (in-scope)
#0.4 tot 1: Intensieve, en hoge vegetatie (substantial green) (in-scope)

#substantial green
#reclassifying nvdi (all values between negative infinity and 0.4 be NAs)
#Cells with NDVI values greater than 0.4 are definitely vegetation
veg_s <- raster::reclassify(ndvi, cbind(-Inf, 0.4, NA))

#vegetation in classes (Deloitte)
veg_c <- raster::reclassify(ndvi, c(-Inf,0.2,1,0.2,0.4,2,0.4,1,3))

#Ratio vegetation index (RVI)
#Indicates amount of vegetation
#Reduces the effects of atmosphere and topography
rvi  <- nir / red


#-----------------------------------------------------------------------------------------------
#create fresh multi-raster GeoPackage (gpkg) containing all green indices (write)

unlink(paste0(data.dir,neighbourhood,"_green_indices.gpkg"))
#Stars-packagke

#NDVI 
ndvi %>%
        st_as_stars %>% # convert the RasterLayer to a stars object
        write_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
                    driver = "GPKG",options = c("RASTER_TABLE=ndvi","APPEND_SUBDATASET=YES"))

#substantial green (fixed)
veg_s %>%
        st_as_stars %>% # convert the RasterLayer to a stars object
        write_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
                    driver = "GPKG", options = c("RASTER_TABLE=veg_substantial_fixed","APPEND_SUBDATASET=YES"))

#green classes (fixed)
veg_c %>%
        st_as_stars %>% # convert the RasterLayer to a stars object
        write_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
                    driver = "GPKG", options = c("RASTER_TABLE=veg_classes_fixed","APPEND_SUBDATASET=YES"))

#green classes unsupervised 
veg_clus %>%
        st_as_stars %>% # convert the RasterLayer to a stars object
        write_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
                    driver = "GPKG", options = c("RASTER_TABLE=veg_classes_unsupervised","APPEND_SUBDATASET=YES"))

#RVI
rvi %>%
        st_as_stars %>% # convert the RasterLayer to a stars object
        write_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
                    driver = "GPKG", options = c("RASTER_TABLE=rvi","APPEND_SUBDATASET=YES"))

#review raster layers in gpkg-file
gdalUtils::gdalinfo(paste0(data.dir,neighbourhood,"_green_indices.gpkg")) %>%
        cat(sep = "\n")

#gdalUtils::gdalinfo(paste0(data.dir,neighbourhood,"_green_indices.gpkg"),
                    # provide metadata of first subdataset:
#                    sd=1, #ndvi
                    # the following arguments just control formatting of the output:
#                    approx_stats = TRUE, mm = TRUE, proj4 = TRUE) %>%
#        cat(sep = "\n")


#create RasterBrick (read gpkg)
green_indices <-
        read_stars(paste0(data.dir,neighbourhood,"_green_indices.gpkg")
                   #subsetting
                   #,sub = "ndvi"
                   ,quiet = TRUE
                   ) %>%
        as("Raster")
green_indices

#-----------------------------------------------------------------------------------------------

# Vegetation plots

#-----------------------------------------------------------------------------------------------

source(here::here('SRC/vegitation_plots.R'))

#-----------------------------------------------------------------------------------------------

# Polygon filtering, green coverage and mean NDVI 

#-----------------------------------------------------------------------------------------------


#under contruction by Mark

#filter ndvi raster by polygon
#https://cran.r-project.org/web/packages/exactextractr/exactextractr.pdf

#Distribution of raster cell NDVI values
png(paste0(plots.dir,"rs_raster_cell_ndvi",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio*2, height=png_height)
hist(ndvi,
     main = paste0("Distribution of raster cell NDVI values ",neighbourhood),
     xlab = "ndvi", ylab = "cells",
     col = "steelblue")
dev.off()

#classification matrix
reclass_df <- c(0, 0.2, NA,
                0.2, 1, 1)
reclass_df

#reshape the object into a matrix with columns and rows
reclass_m <- matrix(reclass_df,
                    ncol = 3,
                    byrow = TRUE)
reclass_m


#projection
crs(ndvi)<-crs(percelen_sf)
ndvi_raster<-raster::raster(ndvi)

ndvi_classified <- reclassify(ndvi_raster,
                             reclass_m)

#surface covered by substantial green (ndvi_classified) per polygon element (tuin)
ndvi_cover <- exactextractr::coverage_fraction(ndvi_raster,tuinen_sf, crop = FALSE)
rm(ndvi_raster)

#store green coverage gardens
for (i in length(ndvi_cover)) {
ndvi_cover[[i]] %>%
        st_as_stars %>% # convert the RasterLayer to a stars object
        write_stars(paste0(data.dir,neighbourhood,"_green_coverage_tuinen.gpkg"),
                    driver = "GPKG", options = c("RASTER_TABLE=green_cover","APPEND_SUBDATASET=YES"))
}

#Mean value (NDVI) of cells that intersect the polygon, weighted by the percent of the cell that is covered.
#mean ndvi per polygon element (tuin)
ndvi_avg<-exactextractr::exact_extract(ndvi, tuinen_sf,
                                             #the mean cell value, weighted by the fraction of each cell
                                             #that is covered by the polygon
                                             fun ='mean',
                                             force_df =TRUE)

#add mean ndvi values to tuinen_sf
tuinen_sf$ndvi_avg<-ndvi_avg

plot.title = paste0('mean NDVI garden')
ggplot(data = tuinen_sf) +
        geom_sf(aes(fill = ndvi_avg$mean)) +
        scale_fill_viridis_c(option = "plasma", direction = -1,name = "mean NDVI") +
        #xlab("Longitude") + ylab("Latitude") +
theme_minimal() 
plot.nme = paste0('NDVI_mean_garden.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height , width = graph_height * aspect_ratio, dpi=dpi)


#Sum of raster cells covered by the polygon, with each raster value weighted by its coverage fraction
#and weighting raster value.
#ndvi_weighted_sum<-exactextractr::exact_extract(vegi, woonpercelen_garden_sf,
#                                             'weighted_sum',
#                                             weights=raster(woonpercelen_garden_sf$geom),
#                                             force_df =TRUE)


#under contruction by Mark


#-----------------------------------------------------------------------------------------------

# Debugging

#-----------------------------------------------------------------------------------------------

rlang::last_error()
rlang::last_trace()
