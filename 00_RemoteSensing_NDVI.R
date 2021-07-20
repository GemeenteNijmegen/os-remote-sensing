
#-----------------------------------------------------------------------------------------------

# Remote Sensing: Green urban spaces

#-----------------------------------------------------------------------------------------------

# date created: 11-05-2021
# date modified: 20-07-2021

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

#pipeline timer
start_time <- Sys.time()

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

#centroid perceel
cntrd_perceel <- st_centroid(st_geometry(percelen_sf))

#centroid perceel
cntrd_tuinen <- st_centroid(st_geometry(tuinen_sf))

coord_tuinen<-as.data.frame(st_coordinates(cntrd_tuinen))
id_perceel <- percelen_sf$perceelnummer
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

#unsupervised boundary detection (classes)
source(here::here('SRC/green_classes.R'))

#ranges according to Deloitte research
#-1 tot -0.1: Water
#-0.1 tot 0.2: Zand/Grond/Rots 
#0.2 tot 0.4: Gras en lage vegetatie (in-scope)
#0.4 tot 1: Intensieve, en hoge vegetatie (substantial green) (in-scope)

#substantial green
#reclassifying nvdi (all values between negative infinity and 0.4 be NAs)
veg_s <- raster::reclassify(ndvi, cbind(-Inf, 0.4, NA))

#vegetation in classes (Deloitte)
veg_c <- raster::reclassify(ndvi, c(-Inf,0.2,1,0.2,0.4,2,0.4,1,3))

#Ratio vegetation index (RVI)
#Indicates amount of vegetation
#Reduces the effects of atmosphere and topography
rvi <- nir / red

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
reclass_df <- c(-Inf, 0.2, NA,
                0.2, Inf, 1)
reclass_df

#reshape the object into a matrix with columns and rows
reclass_m <- matrix(reclass_df,
                    ncol = 3,
                    byrow = TRUE)
reclass_m

ndvi_classified <- reclassify(ndvi,
                             reclass_m)

plot(ndvi_classified)

#surface covered by substantial green (ndvi_classified) per polygon element (tuin)
ndvi_cover <- exactextractr::coverage_fraction(ndvi_classified,tuinen_sf, crop = FALSE)
rm(ndvi_raster)

#store green coverage gardens
for (i in length(ndvi_cover)) {
ndvi_cover[[i]] %>%
        st_as_stars %>% # convert the RasterLayer to a stars object
        write_stars(paste0(data.dir,neighbourhood,"_green_coverage_tuinen.gpkg"),
                    driver = "GPKG", options = c("RASTER_TABLE=green_cover","APPEND_SUBDATASET=YES"))
}


crs(ndvi)<-crs(percelen_sf)
#Mean value (NDVI) of cells that intersect the polygon, weighted by the percent of the cell that is covered.
#mean ndvi per polygon element (tuin)
ndvi_avg<-exactextractr::exact_extract(ndvi, tuinen_sf,
                                             #the mean cell value, weighted by the fraction of each cell
                                             #that is covered by the polygon
                                             fun ='mean',
                                             force_df =FALSE)

#add mean ndvi values to tuinen_sf
tuinen_sf$ndvi_avg<-ndvi_avg

plot.title = paste0('mean NDVI garden')
ggplot(data = tuinen_sf) +
        geom_sf(aes(fill = ndvi_avg)) +
        scale_fill_viridis_c(option = "plasma", direction = -1,name = "mean NDVI") +
        geom_point(size = 0.4, aes(x = coord_tuinen$X,y = coord_tuinen$Y), colour="white", shape = 15) +
        geom_text(
                aes(
                        label = tuinen_sf$perceelnummer,
                        x = coord_tuinen$X,
                        y = coord_tuinen$Y
                ),
                colour = "black",
                size = 1.9,hjust = 0, nudge_x = 0.07
        ) +
        xlab("Longitude") + ylab("Latitude") +
theme_minimal() 
plot.nme = paste0('NDVI_mean_garden.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height , width = graph_height * aspect_ratio, dpi=dpi)

png(paste0(plots.dir,"rs_tuinen_ndvi",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio*2, height=png_height)
hist(tuinen_sf$ndvi_avg,
     breaks=8,
     main = paste0("Distribution of tuinen over NDVI ",neighbourhood),
     xlab = "mean ndvi", ylab = "freq",
     col = "steelblue")
dev.off()

#distribution of gardens over NDVI
p <-  ggplot(tuinen_sf, aes(x = ndvi_avg)) +  
        geom_histogram(aes(y = (..count..)/sum(..count..)), binwidth = 0.02,color="lightblue", fill="steelblue") +
        stat_bin(aes(y=(..count..)/sum(..count..), 
                     label=paste0(round((..count..)/sum(..count..)*100,1),"%")), 
                 geom="text", size=4, binwidth = 0.02, vjust=-1.5) +
        scale_x_continuous(breaks = seq(0,1,0.2), lim = c(0.2,1))+
        theme_minimal()
(p)
plot.nme = paste0('rs_gardens_distibution_ndvi_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * 3, dpi=dpi)


#Sum of raster cells covered by the polygon, with each raster value weighted by its coverage fraction
#and weighting raster value.
#ndvi_weighted_sum<-exactextractr::exact_extract(ndvi, tuinen_sf,
#                                             'weighted_sum',
#                                             weights=raster(ndvi_cover),
#                                             force_df =TRUE)

#under contruction by Mark

end_time <- Sys.time()
end_time - start_time


#-----------------------------------------------------------------------------------------------

# Debugging

#-----------------------------------------------------------------------------------------------

rlang::last_error()
rlang::last_trace()
