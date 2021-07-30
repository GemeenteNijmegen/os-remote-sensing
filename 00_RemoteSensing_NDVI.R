
#-----------------------------------------------------------------------------------------------

# Remote Sensing: Green urban spaces

#-----------------------------------------------------------------------------------------------

# date created: 11-05-2021
# date modified: 30-07-2021

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
#neighbourhood<-"BU08280002" 
neighbourhood<-"BU04411401" #Sint Maartensvlotbrug, Schagen

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

#prefab geopackage from Python procedure
prefab_polygons <- TRUE #default (T) 

if(prefab_polygons==TRUE) {
#download prefab geopackage from VNG Stack        
 source(here::here('SRC/vector_gpkg_request.R'))       
} else {
#create geopackage
 #under construction
 source(here::here('SRC/buurt_pand_perceel_request.R')) 
}

#centroid perceel
cntrd_perceel <- st_centroid(st_geometry(percelen_sf))

#centroid tuinen
cntrd_tuinen <- st_centroid(st_geometry(tuinen_sf))
#extract coordinates
coord_tuinen<-as.data.frame(st_coordinates(cntrd_tuinen))

#interactive Leaflet presentation of the layers buurt, percelen and panden
mapview(list(buurt_sf,percelen_sf, panden_sf),alpha.regions = 0.6, alpha = 1)

#-----------------------------------------------------------------------------------------------

# Aerial image

#-----------------------------------------------------------------------------------------------

source(here::here('SRC/image.R'))

#assign bands
nir <- ai_tuinen[[1]]
red <- ai_tuinen[[2]]

#plot of aerial image bands
plot(ai_tuinen)

#-----------------------------------------------------------------------------------------------

# Vegetation indices

#-----------------------------------------------------------------------------------------------

#calculate NDVI, EVI2 and RVI using the nir band and red band

#------------------------------------
#Normalized difference vegetation index (NDVI)
#Indicates amount of vegetation, distinguishes veg from soil, minimizes topographic effects
ndvi <- raster::overlay(red, nir, fun = function(x, y) { (y-x) / (y+x) })

png(paste0(plots.dir,"rs_ndvi_raw_",neighbourhood,".png"))
plot(ndvi)
dev.off()
res(ndvi)

#improve resolution
#ndvi_disaggregate <- raster::disaggregate(ndvi, fact=4)
#res(ndvi_disaggregate)
#plot(ndvi_disaggregate)
#ndvi<-ndvi_disaggregate

#unsupervised boundary detection (NDVI classes)
source(here::here('SRC/green_classes.R'))

#ranges according to Deloitte research
#       -1 tot -0.1: Water
#       -0.1 tot 0.2: Zand/Grond/Rots 
#       0.2 tot 0.4: Gras en lage vegetatie (in-scope)
#       0.4 tot 1: Intensieve, en hoge vegetatie (substantial green) (in-scope)

#vegetation (fixed boundary at 0.2)
#create new raster with 1 for vegetation and 0 for non-vegetation.
#classification matrix
reclass_binary <- c(-1, 0.2, 0,
                    0.2, 1, 1)

#reshape the object into a matrix with columns and rows
reclass_binary_m <- matrix(reclass_binary,
                           ncol = 3,
                           byrow = TRUE)

veg_g <- raster::reclassify(ndvi,reclass_binary_m)

#substantial green (fixed boundary at 0.4)
#reclassifying nvdi (all values between negative infinity and 0.4 be NAs)
veg_s <- raster::reclassify(ndvi, cbind(-Inf, 0.4, NA))

#vegetation in classes (Deloitte)
veg_c <- raster::reclassify(ndvi, c(-Inf,0.2,1,0.2,0.4,2,0.4,1,3))

#------------------------------------

#Enhanced vegetation index - Two-band (EVI2)
evi2 <- 2.5*((nir-red)/(nir+2.4*red+1))

#------------------------------------
#Ratio vegetation index (RVI)
#Indicates amount of vegetation
#Reduces the effects of atmosphere and topography
rvi <- nir / red


#-----------------------------------------------------------------------------------------------

#vegetation geopackage

#-----------------------------------------------------------------------------------------------

#store indices in geopackage
source(here::here('SRC/vegetation_gpkg.R'))

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

#vegetation plots

#-----------------------------------------------------------------------------------------------

source(here::here('SRC/vegetation_plots.R'))

#-----------------------------------------------------------------------------------------------

# Polygon filtering, green coverage and mean NDVI calculations 

#-----------------------------------------------------------------------------------------------

#BEGIN under contruction by Mark

#filter ndvi raster by polygon
#https://cran.r-project.org/web/packages/exactextractr/exactextractr.pdf
#https://cran.r-project.org/web/packages/exactextractr/readme/README.html

#Results from exactextractr are more accurate than other methods because raster pixels that are partially 
#covered by polygons are considered. The significance of partial coverage increases for polygons that are 
#small or irregularly shaped.

crs(ndvi)<-crs(percelen_sf)

#Distribution of raster cell NDVI values
png(paste0(plots.dir,"rs_raster_cell_ndvi",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio*2, height=png_height)
hist(ndvi,
     main = paste0("Distribution of raster cell NDVI values ",neighbourhood),
     xlab = "ndvi", ylab = "cells",
     col = "steelblue")
dev.off()

#------------------------------------
#reclassify cell values

#for mean green
#create new raster and remove NDVI value below 0.2.
reclass_value <- c(-Inf, 0.2, NA)

ndvi_above_threshold <- raster::reclassify(ndvi,reclass_value)

reclass_binary <- c(-1, 0.2, 0,
                    0.2, 1, 1)

#reshape the object into a matrix with columns and rows
reclass_binary_m <- matrix(reclass_binary,
                           ncol = 3,
                           byrow = TRUE)

veg_g <- raster::reclassify(ndvi,reclass_binary_m)


#------------------------------------

# Number of cells covered by the polygon (raster values are ignored)
cells_cnt <- exact_extract(ndvi, tuinen_sf, function(values, coverage_fraction)
        sum(coverage_fraction))


tuinen_sf$cells_cnt<-cells_cnt

#Mean value (NDVI) of cells that intersect the polygon, weighted by the percent of the cell that is covered.
#mean ndvi per polygon element (tuin)
ndvi_avg<-exactextractr::exact_extract(ndvi,tuinen_sf,
                                             #the mean cell value, weighted by the fraction of each cell
                                             #that is covered by the polygon
                                             fun ='mean',
                                             force_df =FALSE)

#add mean ndvi values to tuinen_sf
tuinen_sf$ndvi_avg<-round(ndvi_avg,1)


#mean ndvi for vegetataion per polygon element (green in tuin)
ndvi_green_avg<-exactextractr::exact_extract(ndvi_above_threshold,tuinen_sf,
                                       #the mean cell value, weighted by the fraction of each cell
                                       #that is covered by the polygon
                                       fun ='mean',
                                       force_df =FALSE)

#add mean ndvi values vegetation to tuinen_sf
tuinen_sf$ndvi_green_avg<-round(ndvi_green_avg,2)


#vegetation cover per polygon element (tuin)
ndvi_cover<-exactextractr::exact_extract(veg_g,tuinen_sf,
                                       #the mean cell value, weighted by the fraction of each cell
                                       #that is covered by the polygon
                                       fun ='mean',
                                       force_df =FALSE)


tuinen_sf$green_cover<-round(ndvi_cover*100,0)


#------------------------------------

#surface culculation (m2)
tuinen_sf <- tuinen_sf %>%
           mutate(green_surface = round((opp*(green_cover/100)),1),
                  green_potential = opp-green_surface,
                  buurt_selection = neighbourhood
                  )        
        
#compute buurt statistics
buurt_garden_stats <- tuinen_sf %>%
        group_by(buurt_selection)  %>%
        summarise(garden_surface = sum(opp), 
                  green_cover_avg = round(mean(green_cover),1),
                  green_surface_sum = sum(green_surface),
                  green_potential_sum = sum(green_potential),
                  ndvi_avg = round(mean(ndvi_avg,na.rm = TRUE),1),
                  ndvi_green_avg = round(mean(ndvi_green_avg,na.rm = TRUE),1) 
                  ) 
 
buurt_garden_stats <- cbind(buurt_sf,buurt_garden_stats)


#------------------------------------
#plots

#mean NVDI garden
ggplot(data = tuinen_sf) +
        geom_sf(aes(fill = ndvi_avg)) +
        scale_fill_viridis_c(option = "turbo", direction = 1,name = "mean NDVI") +
        #scale_fill_continuous_diverging(palette = "qz_ndvi") +
        geom_point(size = 0.4, aes(x = coord_tuinen$X,y = coord_tuinen$Y), colour="white", shape = 15) +
        geom_text(
                aes(
                        label = tuinen_sf$ndvi_avg,
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
ggsave(plot.store, dpi=dpi)

#mean NVDI for vegetation in garden
ggplot(data = tuinen_sf) +
        geom_sf(aes(fill = ndvi_green_avg)) +
        scale_fill_viridis_c(option = "turbo", direction = 1,name = "mean NDVI") +
        geom_point(size = 0.4, aes(x = coord_tuinen$X,y = coord_tuinen$Y), colour="white", shape = 15) +
        geom_text(
                aes(
                        label = tuinen_sf$ndvi_green_avg,
                        x = coord_tuinen$X,
                        y = coord_tuinen$Y
                ),
                colour = "black",
                size = 1.9,hjust = 0, nudge_x = 0.07
        ) +
        xlab("Longitude") + ylab("Latitude") +
        theme_minimal() 
plot.nme = paste0('NDVI_mean_vegetation_garden.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, dpi=dpi)

#Distribution of gardens over NDVI
png(paste0(plots.dir,"rs_garden_ndvi_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio*2, height=png_height)
hist(tuinen_sf$ndvi_avg,
     breaks=8,
     main = paste0("Distribution of gardens over NDVI ",neighbourhood),
     xlab = "mean ndvi", ylab = "freq",
     col = "steelblue")
dev.off()

#distribution of gardens over NDVI
ggplot(tuinen_sf, aes(x = ndvi_avg)) +  
        geom_histogram(aes(y = (..count..)/sum(..count..)), binwidth = 0.02,color="lightblue", fill="steelblue") +
        stat_bin(aes(y=(..count..)/sum(..count..), 
                     label=paste0(round((..count..)/sum(..count..)*100,1),"%")), 
                 geom="text", size=4, binwidth = 0.08, vjust=-1.5) +
        #scale_x_continuous(breaks = seq(0.2,0.8,0.1))+
        theme_light()
plot.nme = paste0('rs_gardens_distibution_ndvi_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, dpi=dpi)

#green coverage of gardens
ggplot(data = tuinen_sf) +
        geom_sf(aes(fill = ndvi_cover)) +
        scale_fill_viridis_c(option = "viridis", direction = 1,name = "green cover proportion") +
        geom_point(size = 0.4, aes(x = coord_tuinen$X,y = coord_tuinen$Y), colour="white", shape = 15) +
        geom_text(
                aes(
                        label = tuinen_sf$green_cover,
                        x = coord_tuinen$X,
                        y = coord_tuinen$Y
                ),
                colour = "black",
                size = 2.2,hjust = 0, nudge_x = 0.07
        ) +
        xlab("Longitude") + ylab("Latitude") +
        theme_minimal() 
plot.nme = paste0('green_coverage_garden.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, dpi=dpi)

#END under contruction by Mark

end_time <- Sys.time()
end_time - start_time


#-----------------------------------------------------------------------------------------------

# Debugging

#-----------------------------------------------------------------------------------------------

rlang::last_error()
rlang::last_trace()
