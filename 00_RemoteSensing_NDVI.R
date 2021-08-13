
#-----------------------------------------------------------------------------------------------

# Remote Sensing: Green private urban spaces in neighbourhoods

#-----------------------------------------------------------------------------------------------

# date created: 2021-05-11
# date modified: 2021-08-13

#-----------------------------------------------------------------------------------------------

#id neighbourhood
neighbourhood <- "BU08280002" #Oss
#name municipality
municipality <- "Oss"

#neighbourhood <- "BU04411401" #Sint Maartensvlotbrug, Schagen
#municipality <- "Schagen"

message("start procedure for ", neighbourhood)

#-----------------------------------------------------------------------------------------------

# Setup environment

#-----------------------------------------------------------------------------------------------

#Run in project environment (to avoid package conflicts)
proj_env <- FALSE #default (F)

#debug mode
debug_mode <- FALSE #default (F)

#external dependencies Rtools, GEOS, GDAL, PROJ.4

#setup and packages
source('SRC/packages.R')

#globals
source(here::here('SRC/globals.R'))

#-----------------------------------------------------------------------------------------------

# Python

#-----------------------------------------------------------------------------------------------

#Python environment
#needed when opting for re-creating the polygon geopackage(s) via the Python procedure ('Processing' dir)
#within Rstudio

#read instructions in 'SRC/python.R' first

#source(here('SRC/python.R'))

#-----------------------------------------------------------------------------------------------

# Settings

#-----------------------------------------------------------------------------------------------

#location geopackages
#vector layers (polygons buurt, percelen, panden, tuinen)
gpkg_vector <- paste0(data.loc,neighbourhood,"_vector.gpkg")
#raster data: aerial photo, NH3
gpkg_raster <- paste0(data.loc,neighbourhood,"_raster.gpkg")
#raster data: vegetation indices
gpkg_indices <- paste0(data.loc,neighbourhood,"_green_indices.gpkg")

#pipeline timer
start_time <- Sys.time()

#-----------------------------------------------------------------------------------------------

# Polygons

#-----------------------------------------------------------------------------------------------

#geopackage containing gemeente, buurt, percelen, panden and tuinen polygons

#prefab geopackage (from Python procedure)
prefab_polygons <- FALSE #default (T) 

if(prefab_polygons==TRUE) {
#download prefab geopackage from VNG Stack        
 source(here::here('SRC/vector_gpkg_request.R'))       
} else {
#create geopackage
 source(here::here('SRC/buurt_pand_perceel_request.R')) 
}

#-----------------------------------------------------------------------------------------------
#extend and bounding box

buurt_extend <- sf::st_bbox(buurt_sf$geom)

xmin <- buurt_extend[1]
xmax <- buurt_extend[3]
ymin <- buurt_extend[2]
ymax <- buurt_extend[4]
bbox <- paste(xmin, ymin, xmax, ymax, sep=",")

#centroid perceel
cntrd_perceel <- st_centroid(st_geometry(percelen_sf))

#centroid tuinen
cntrd_tuinen <- st_centroid(st_geometry(tuinen_sf))

#extract coordinates
coord_tuinen<-as.data.frame(st_coordinates(cntrd_tuinen))

#-----------------------------------------------------------------------------------------------

# Aerial image 

#-----------------------------------------------------------------------------------------------

#read TIFF or ECW image
source(here::here('SRC/image.R'))

#assign bands (CIR)
nir <- ai_tuinen[[1]]
red <- ai_tuinen[[2]]

#-----------------------------------------------------------------------------------------------

# Vegetation indices : NDVI, EVI2 and RVI

#-----------------------------------------------------------------------------------------------

message("calculate vegetation indices")

#--------------------------------------------------

#Normalized difference vegetation index (NDVI)

#--------------------------------------------------

#Indicates amount of vegetation, distinguishes vegetation from soil, minimizes topographic effects

#NDVI-ranges according to Deloitte research, e.o. 
#       -1 tot -0.1: Water
#       -0.1 tot 0.2: Zand/Grond/Rots 
#       0.2 tot 0.4: Gras en lage vegetatie
#       0.4 tot 1: Intensieve, en hoge vegetatie


# NOTE: we differ from this list, except for the boundary of vegetation/non-vegetation (.2)

#NDVI-ranges in this research
#       -Inf to 0.2: Non-vegetation
#        0.2 to 0.3: Grasses, weed
#        0.3 to 0.5: Low vegetation
#        0.5 to 1: #intensive vegetation, trees

#vegetation (fixed boundary at 0.2)

ndvi <- raster::overlay(red, nir, fun = function(x, y) { (y-x) / (y+x) })
names(ndvi) <- "ndvi"

#unsupervised boundary detection (NDVI classes)
source(here::here('SRC/green_classes.R'))

#create new raster with 1 for vegetation and 0 for non-vegetation.
#classification matrix
reclass_binary <- c(-1, 0.2, 0,
                    0.2, 1, 1)

#reshape the object into a matrix with columns and rows
reclass_binary_m <- matrix(reclass_binary,
                           ncol = 3,
                           byrow = TRUE)

veg_g <- raster::reclassify(ndvi,reclass_binary_m)

#contour lines vegetation
veg_contour <- raster::rasterToContour(veg_g)
#transform to polygon
veg_polygon <- veg_contour %>% st_as_sf() %>% st_polygonize()
veg_polygon$oppervlakte <- st_area(veg_polygon$geometry) 

sf::st_write(veg_polygon, dsn=gpkg_vector, layer='vegetation_contour',layer_options = "OVERWRITE=YES",append=FALSE)

png(paste0(plots.loc,"rs_ndvi_raw_vegetation_contours_",neighbourhood,".png"), height = 1280,width=1280,res=180,units = "px")
plot(ndvi)
plot(veg_contour, add=TRUE)
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
dev.off()

#vegetation in classes
veg_c <- raster::reclassify(ndvi, c(-Inf,0.2,1, #no vegetation
                                    0.2,0.3,2, #grasses, weed
                                    0.3,0.5,3, #low vegetation
                                    0.5,1,4 #intensive vegetation, trees
                                    ))

#substantial green (fixed boundary at 0.3)
#reclassifying nvdi (all values between negative infinity and 0.3 be NAs)
veg_s <- raster::reclassify(ndvi, cbind(-Inf, 0.3, NA))

#--------------------------------------------------

#Enhanced vegetation index - Two-band (EVI2)

#--------------------------------------------------

evi2 <- raster::overlay(red, nir, fun = function(x, y) { 2.5*((y-x) / (y+2.4*x+1)) })
names(evi2) <- "evi2"

#--------------------------------------------------

#Ratio vegetation index (RVI)

#--------------------------------------------------

#Indicates amount of vegetation
#Reduces the effects of atmosphere and topography
rvi <- raster::overlay(red, nir, fun = function(x, y) { (y) / (x) })
names(rvi) <- "rvi"

#garbage collecting
rm(nir,red)

#-----------------------------------------------------------------------------------------------

# AHN

#-----------------------------------------------------------------------------------------------

source(here::here('SRC/ahn.R'))

#-----------------------------------------------------------------------------------------------

#Garden above xmeter

#-----------------------------------------------------------------------------------------------

#garden 3m and above
reclass_binary <- c(-Inf, 3, 0,
                    3, Inf, 1)

#reshape the object into a matrix with columns and rows
reclass_binary_m <- matrix(reclass_binary,
                           ncol = 3,
                           byrow = TRUE)

garden_3mplus <- raster::reclassify(ahn_buurt,reclass_binary_m)

rm(reclass_binary, reclass_binary_m)

#---------------------------

#garden 5m and above
reclass_binary <- c(-Inf, 5, 0,
                    5, Inf, 1)

#reshape the object into a matrix with columns and rows
reclass_binary_m <- matrix(reclass_binary,
                           ncol = 3,
                           byrow = TRUE)

garden_5mplus <- raster::reclassify(ahn_buurt,reclass_binary_m)

rm(reclass_binary, reclass_binary_m, ahn_buurt, ahn_panden)

#-----------------------------------------------------------------------------------------------

# Polygon filtering, green coverage and mean NDVI calculations 

#-----------------------------------------------------------------------------------------------

#filter ndvi raster by polygon
#https://cran.r-project.org/web/packages/exactextractr/exactextractr.pdf
#https://cran.r-project.org/web/packages/exactextractr/readme/README.html

#Results from exactextractr are more accurate than other methods because raster pixels that are partially 
#covered by polygons are considered. The significance of partial coverage increases for polygons that are 
#small or irregularly shaped.

raster::crs(ndvi) <- raster::crs(percelen_sf)

#Distribution of raster cell NDVI values
png(paste0(plots.loc,"rs_raster_cell_ndvi",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio*2, height=png_height)
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
raster::crs(veg_g) <- raster::crs(percelen_sf)

#3m within class vegetation
veg_t3 <- garden_3mplus*veg_g
raster::crs(veg_t3) <- raster::crs(percelen_sf)

#5m within class vegetation (trees)
veg_t5 <- garden_5mplus*veg_g
raster::crs(veg_t5) <- raster::crs(percelen_sf)

#-----------------------------------------------------------------------------------------------

#vegetation geopackage

#-----------------------------------------------------------------------------------------------

message("store green indices in geopackage")

#store green indices in geopackage
source(here::here('SRC/vegetation_gpkg.R'))

vegetation_rasterbrick <- FALSE

if(vegetation_rasterbrick==TRUE) {
#read geopackage, create RasterBrick 
green_indices <-
        read_stars(paste0(data.loc,neighbourhood,"_green_indices.gpkg")
                   #subsetting
                   #,sub = "ndvi"
                   ,quiet = TRUE
        ) %>%
        as("Raster")
green_indices
}

#-----------------------------------------------------------------------------------------------

#vegetation coverage

#-----------------------------------------------------------------------------------------------



#-----------------------------------------------------------------------------------------------

#tuinen

#-----------------------------------------------------------------------------------------------


message("calculate green coverage tuinen")

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

tuinen_sf$ndvi_avg<-round(ndvi_avg,1)


#mean ndvi for vegetation per polygon element (green in tuin)
ndvi_green_avg<-exactextractr::exact_extract(ndvi_above_threshold,tuinen_sf,
                                       #the mean cell value, weighted by the fraction of each cell
                                       #that is covered by the polygon
                                       fun ='mean',
                                       force_df =FALSE)

tuinen_sf$ndvi_green_avg<-round(ndvi_green_avg,2)


#vegetation cover per polygon element (tuin)
ndvi_cover<-exactextractr::exact_extract(veg_g,tuinen_sf,
                                       #the mean cell value, weighted by the fraction of each cell
                                       #that is covered by the polygon
                                       fun ='mean',
                                       force_df =FALSE)

tuinen_sf$green_cover<-round(ndvi_cover*100,1)


#3m+ tree cover per polygon element (tuin) 
tree_cover_3m<-exactextractr::exact_extract(veg_t3,tuinen_sf,
                                            #the mean cell value, weighted by the fraction of each cell
                                            #that is covered by the polygon
                                            fun ='mean',
                                            force_df =FALSE)

tuinen_sf$tree_cover_3m<-round(tree_cover_3m*100,1)

#5m+ tree cover per polygon element (tuin) 
tree_cover_5m<-exactextractr::exact_extract(veg_t5,tuinen_sf,
                                         #the mean cell value, weighted by the fraction of each cell
                                         #that is covered by the polygon
                                         fun ='mean',
                                         force_df =FALSE)

tuinen_sf$tree_cover_5m<-round(tree_cover_5m*100,1)

#------------------------------------

#make sure the surface is the effective garden area after geometric operations (and not perceel as in 'opp' from PDOK source)
tuinen_sf$oppervlakte_tuin_unit <- st_area(tuinen_sf$geom) #keep for unit translations
#change data type to numeric (from 'S3: units' with m^2 suffix)
tuinen_sf$oppervlakte_tuin <- as.numeric(tuinen_sf$oppervlakte_tuin_unit)


#surface culculation (m2)
tuinen_sf <- tuinen_sf %>%
           mutate(
                  #oppervlakte vegetatie 
                  green_surface = round((oppervlakte_tuin*(green_cover/100)),1),
                  #oppervlak bomen (5m and above)
                  tree_surface_5m = round((oppervlakte_tuin*(tree_cover_5m/100)),1),
                  #oppervlak bomen (3m and above)
                  tree_surface_3m = round((oppervlakte_tuin*(tree_cover_3m/100)),1),
                  #aandeel bomen in vegetatie (3m and above)
                  treeingreen_cover = round(tree_surface_3m/green_surface*100,1),
                  #oppervlak potentieel vegetatie
                  green_potential = oppervlakte_tuin-green_surface,
                  #buurtcode meenemen
                  buurt_selection = neighbourhood
                  )        
 
#gardens with 5m and above, but no vegetation cover (todo: tackle in polygon section!) : infinite to Na
#is.na(tuinen_sf$treeingreen_cover) <- sapply(tuinen_sf$treeingreen_cover, is.infinite)
       
#compute buurt statistics
buurt_garden_stats <- tuinen_sf %>%
        group_by(buurt_selection)  %>%
        summarise(
                  #tuin oppervlak
                  garden_surface_sum = sum(oppervlakte_tuin, na.rm = TRUE), 
                  #aandeel vegetatie in tuin
                  green_cover_avg = round(mean(green_cover, na.rm = TRUE),1),
                  #aandeel bomen in tuin (3m and above)
                  tree_cover_3m_avg = round(mean(tree_cover_3m, na.rm = TRUE),1),
                  #aandeel bomen in tuin (5m and above)
                  tree_cover_5m_avg = round(mean(tree_cover_5m, na.rm = TRUE),1),
                  #oppervlak vegetatie
                  green_surface_sum = sum(green_surface, na.rm = TRUE),
                  #oppervlak bomen (3m and above)
                  tree_surface_sum = sum(tree_surface_3m, na.rm = TRUE),
                  #aandeel bomen in vegetatie
                  treeingreen_cover_avg = round(mean(treeingreen_cover,na.rm = TRUE),1),
                  #oppervlak potentieel vegetatie
                  green_potential_sum = sum(green_potential, na.rm = TRUE),
                  #gemiddelde NDVI waarde tuin
                  ndvi_avg = round(mean(ndvi_avg,na.rm = TRUE),1),
                  #gemiddelde NDVI waarde vegetatie
                  ndvi_green_avg = round(mean(ndvi_green_avg,na.rm = TRUE),1) 
                  ) 
 


buurt_garden_stats <- cbind(buurt_sf,buurt_garden_stats)

write.csv(buurt_garden_stats,file=paste(report.loc,"Buurt_tuinen_statistieken_",neighbourhood,".csv"))

#-----------------------------------------------------------------------------------------------

#panden

#-----------------------------------------------------------------------------------------------

message("calculate green coverage panden met woonfunctie")

#vegetation cover per polygon element (tuin)
ndvi_cover_panden<-exactextractr::exact_extract(veg_g,panden_polygons,
                                         #the mean cell value, weighted by the fraction of each cell
                                         #that is covered by the polygon
                                         fun ='mean',
                                         force_df =FALSE)

panden_polygons$green_cover<-round(ndvi_cover_panden*100,1)

panden_polygons$oppervlakte_pand_unit = st_area(panden_polygons)

panden_polygons$oppervlakte_pand = as.numeric(panden_polygons$oppervlakte_pand_unit)

#surface culculation (m2)
panden_polygons <- panden_polygons %>%
        mutate(
                #oppervlakte vegetatie 
                green_surface = round((oppervlakte_pand*(green_cover/100)),1),

                #oppervlak potentieel vegetatie
                green_potential = oppervlakte_pand-green_surface,
                #buurtcode meenemen
                buurt_selection = neighbourhood
        )   

buurt_roofgarden_stats <- panden_polygons %>%
        group_by(buurt_selection)  %>%
        summarise(
                #tuin oppervlak
                roofgarden_surface_sum = sum(oppervlakte_pand, na.rm = TRUE), 
                #aandeel vegetatie in tuin
                green_cover_avg = round(mean(green_cover, na.rm = TRUE),1),
                
                #oppervlak vegetatie
                green_surface_sum = sum(green_surface, na.rm = TRUE),
                #oppervlak potentieel vegetatie
                green_potential_sum = sum(green_potential, na.rm = TRUE)
               
        ) 




buurt_roofgarden_stats <- cbind(buurt_sf,buurt_roofgarden_stats)

write.csv(buurt_roofgarden_stats,file=paste(report.loc,"Buurt_daken_statistieken_",neighbourhood,".csv"))

#-----------------------------------------------------------------------------------------------

#vegetation plots

#-----------------------------------------------------------------------------------------------

source(here::here('SRC/vegetation_plots.R'))

#-----------------------------------------------------------------------------------------------

#green classes metrics 

#-----------------------------------------------------------------------------------------------
#under construction

#source(here::here('SRC/green_classes_metrics.R'))


#-----------------------------------------------------------------------------------------------

# Debugging

#-----------------------------------------------------------------------------------------------

message("exiting procedure for neighbourhood ", neighbourhood)

end_time <- Sys.time()
end_time - start_time

rlang::last_error()
rlang::last_trace()


