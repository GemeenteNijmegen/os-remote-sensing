
#-----------------------------------------------------------------------------------------------

# Remote Sensing: Green private urban spaces

#-----------------------------------------------------------------------------------------------

# date created: 2021-05-11
# date modified: 2022-03-08

#-----------------------------------------------------------------------------------------------

message("start procedure for ", neighbourhood)

#-----------------------------------------------------------------------------------------------

#pipeline timer
start_time <- Sys.time()

#-----------------------------------------------------------------------------------------------

# Polygons

#-----------------------------------------------------------------------------------------------

#geopackage containing gemeente, buurt, percelen, panden and tuinen polygons

#create geopackage vector data
source(here::here('SRC/buurt_pand_perceel_request.R'))

#-----------------------------------------------------------------------------------------------

# Color-infrared (CIR) aerial photography

#-----------------------------------------------------------------------------------------------

source(here::here('SRC/image.R'))

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

# Vegetation indices : NDVI, TNDVI, EVI2, MSAVI2 and RVI

#-----------------------------------------------------------------------------------------------

message("calculate vegetation indices")


#-----------------------------------------------------------------------------------------------

# Normalized difference vegetation index (NDVI)

#-----------------------------------------------------------------------------------------------

#NDVI indicates amount of vegetation, distinguishes vegetation from soil, minimizes topographic effects
#NDVI is chlorophyll sensitive, emphasizing the green color of a healthy plant.
#NDVI is slightly distorted by factors including shadowing, air moisture, and variations in the soil

#NDVI-ranges in this research
#        -1 to -0.1: water
#        -0.1 to 0.2: sand/stone
#        0.2 to 0.3: grasses, weed
#        0.3 to 0.5: low to medium vegetation (substantial vegetation)
#        0.5 to 1: intensive vegetation, high vegetation, trees

message("calculate Normalized difference vegetation index (NDVI)")

ndvi <- raster::overlay(x=red, y=nir, fun = ndvi_func)
names(ndvi) <- "ndvi"

#apply projection
raster::crs(ndvi) <- raster::crs(percelen_sf)

#--------------------------------------------------
#(Re)Classify - unsupervised
#--------------------------------------------------

if(unsup_cl==TRUE) {
message("(Re)Classify NDVI unsupervised")

#unsupervised boundary detection (NDVI classes)
source(here::here('SRC/green_classes.R'))
}

#--------------------------------------------------
#(Re)Classify - fixed
#--------------------------------------------------

message("(Re)Classify NDVI fixed classes")

#--------------------------------------------------
#NDVI classes

ndvi_class<-c(-1,-0.1,1, #water
              -0.1,0.2,2, #sand/stone
              0.2,0.3,3, #grasses, weed
              0.3,0.5,4, #low vegetation
              0.5,1,5 #dense (healthy) vegetation, trees
)

veg_c <- class_func(ndvi,ndvi_class)

#--------------------------------------------------
#vegetation binary

#create new raster with 1 for vegetation and 0 for non-vegetation.
#vegetation fixed boundary at NDVI value 0.2
#classification matrix
reclass_binary <- c(-1, 0.2, 0, #non-vegetation
                    0.2, 1, 1) #vegetation

#reshape the object into a matrix with columns and rows
reclass_binary_m <- matrix(reclass_binary,
                           ncol = 3,
                           byrow = TRUE)

veg_g <- class_func(ndvi,reclass_binary_m)


#contour lines vegetation
veg_contour <- raster::rasterToContour(veg_g)
#transform to polygon
veg_polygon <- veg_contour %>% st_as_sf() %>% st_polygonize()
veg_polygon$oppervlakte <- st_area(veg_polygon$geometry)
#ass layer to geopackage
sf::st_write(veg_polygon, dsn=gpkg_vector, layer='vegetation_contour',layer_options = "OVERWRITE=YES",append=FALSE)

#for mean green
#create new raster and remove NDVI value below 0.2.
reclass_dich <- c(-1, 0.2, NA)

ndvi_above_threshold <- class_func(ndvi,reclass_dich)

#--------------------------------------------------
#Vegetation substantial

#substantial green (fixed boundary at 0.3)
#reclassifying nvdi (all values between negative infinity and 0.3 be NAs)

reclass_dich <- c(-1, 0.3, NA)

veg_s <- class_func(ndvi,reclass_dich)

#--------------------------------------------------
#Stone/sand binary
#NDVI -0.1 to 0.2: Zand/Grond/Rots

stone_class <- c(-1,-0.1,0, #water
                 -0.1,0.2,1, #stone, sand/earth
                 0.2,1,0 #vegetation
                  )

stone_d <- class_func(ndvi,stone_class)

#--------------------------------------------------
#Water binary
#NDVI < -0.1 : Water

water_class<-c(-1,-0.1,1, #water
               -0.1,0.2,0, #stone, sand/earth
               0.2,1,0 #vegetation
              )

water_d <- class_func(ndvi,water_class)

#-----------------------------------------------------------------------------------------------

# Transformed Normalized Difference Vegetation Index (TNDVI)

#-----------------------------------------------------------------------------------------------

#TNDVI indicates a relation between the amount of green biomass that is found in a pixel.
#It has always positive values and the variances of the ratio are proportional to mean values

if(tndvi_calc==TRUE) {
message("calculate Transformed Normalized Difference Vegetation Index (TNDVI)")

tndvi <- raster::overlay(ndvi, fun = tndvi_func)
names(tndvi) <- "tndvi"
}

#-----------------------------------------------------------------------------------------------

# Modified Soil Adjusted Vegetation Index (MSAVI2)

#-----------------------------------------------------------------------------------------------

#The Modified Soil Adjusted Vegetation Index (MSAVI2) method minimizes the effect of bare soil
#on the SAVI.

if(msavi2_calc==TRUE) {
message("calculate Modified Soil Adjusted Vegetation Index (MSAVI2)")

msavi2 <- raster::overlay(x=red, y=nir, fun = msavi2_func)
names(msavi2) <- "msavi2"
}

#-----------------------------------------------------------------------------------------------

# Enhanced vegetation index - Two-band (EVI2)

#-----------------------------------------------------------------------------------------------

#EVI2 has several advantages over NDVI including the ability to resolve differences
#for vegetation with different background soil reflectance

if(evi2_calc==TRUE) {
message("calculate Enhanced vegetation index - Two-band (EVI2)")

evi2 <- raster::overlay(x=red, y=nir, fun = evi2_func)
names(evi2) <- "evi2"
}

#-----------------------------------------------------------------------------------------------

# Ratio vegetation index (RVI)

#-----------------------------------------------------------------------------------------------

#Reduces the effects of atmosphere and topography

if(rvi_calc==TRUE) {
message("calculate Ratio vegetation index (RVI)")

rvi <- raster::overlay(red, nir, fun = rvi_func)
names(rvi) <- "rvi"
}

#-----------------------------------------------------------------------------------------------

# AHN

#-----------------------------------------------------------------------------------------------

if(ahn_calc==TRUE) {
message("apply Actueel Hoogtebestand Nederland (AHN)")

source(here::here('SRC/ahn.R'))


#-----------------------------------------------------------------------------------------------

# Garden above xmeter

#-----------------------------------------------------------------------------------------------



#height 3m and above
reclass_binary <- c(-Inf, 3, 0,
                    3, Inf, 1)

#reshape the object into a matrix with columns and rows
reclass_binary_m <- matrix(reclass_binary,
                           ncol = 3,
                           byrow = TRUE)

garden_3mplus <- raster::reclassify(ahn_buurt,reclass_binary_m)

#---------------------------

#height 5m and above
reclass_binary <- c(-Inf, 5, 0,
                    5, Inf, 1)

#reshape the object into a matrix with columns and rows
reclass_binary_m <- matrix(reclass_binary,
                           ncol = 3,
                           byrow = TRUE)

garden_5mplus <- raster::reclassify(ahn_buurt,reclass_binary_m)

#3m within class vegetation
veg_t3 <- garden_3mplus*veg_g
raster::crs(veg_t3) <- raster::crs(percelen_sf)

#5m within class vegetation (trees)
veg_t5 <- garden_5mplus*veg_g
raster::crs(veg_t5) <- raster::crs(percelen_sf)

rm(reclass_binary, reclass_binary_m)

}

#Distribution of raster cell NDVI values
png(paste0(plots.loc,"rs_ndvi_distibution_raster_cell_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio*2, height=png_height)
hist(ndvi,
     main = paste0("Distribution NDVI values over raster cells ",neighbourhood),
     xlab = "ndvi", ylab = "cells",
     col = "steelblue")
dev.off()

#-----------------------------------------------------------------------------------------------

# Vegetation geopackage

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

# Vegetation coverage

#-----------------------------------------------------------------------------------------------

#indices buurt

if(report_tuinen==FALSE) {

#vegetation cover per polygon element (buurt)
#NOTE: all green in neighbourhood
ndvi_cover_all<-exactextractr::exact_extract(veg_g,buurt_sf,
                                         fun ='mean',
                                         force_df =FALSE)

buurt_sf$green_cover_all<-round(ndvi_cover_all*100,1)

#stone cover per polygon element (buurt)
#NOTE: all stone in neighbourhood
stone_cover_all<-exactextractr::exact_extract(stone_d,buurt_sf,
                                          fun ='mean',
                                          force_df =FALSE)

buurt_sf$stone_cover_all<-round(stone_cover_all*100,1)

#water cover per polygon element (tuin)
#NOTE: all water in neighbourhood
water_cover_all<-exactextractr::exact_extract(water_d,buurt_sf,
                                          fun ='mean',
                                          force_df =FALSE)

buurt_sf$water_cover_all<-round(water_cover_all*100,1)

}

#-----------------------------------------------------------------------------------------------
#indices tuinen

message("calculate green coverage tuinen")

# Number of cells covered by the polygon (raster values are ignored)
cells_cnt <- exactextractr::exact_extract(ndvi, tuinen_sf, function(values, coverage_fraction)
        sum(coverage_fraction))

tuinen_sf$cells_cnt<-cells_cnt

#mean ndvi per polygon element (tuin)
ndvi_avg<-exactextractr::exact_extract(ndvi,tuinen_sf,
                                             fun ='mean',
                                             force_df =FALSE)

tuinen_sf$ndvi_avg<-round(ndvi_avg,1)

#mean ndvi for vegetation per polygon element (green in tuin)
ndvi_green_avg<-exactextractr::exact_extract(ndvi_above_threshold,tuinen_sf,
                                       fun ='mean',
                                       force_df =FALSE)

tuinen_sf$ndvi_green_avg<-round(ndvi_green_avg,2)

#vegetation cover per polygon element (tuin)
ndvi_cover<-exactextractr::exact_extract(veg_g,tuinen_sf,
                                       fun ='mean',
                                       force_df =FALSE)

tuinen_sf$green_cover<-round(ndvi_cover*100,1)

if(ahn_calc==TRUE) {
#medium to high vegetation (3m+) cover per polygon element (tuin)
veg_cover_3m<-exactextractr::exact_extract(veg_t3,tuinen_sf,
                                            fun ='mean',
                                            force_df =FALSE)

tuinen_sf$veg_cover_3m<-round(veg_cover_3m*100,1)

#tree (5m+) cover per polygon element (tuin)
tree_cover_5m<-exactextractr::exact_extract(veg_t5,tuinen_sf,
                                         fun ='mean',
                                         force_df =FALSE)

tuinen_sf$tree_cover_5m<-round(tree_cover_5m*100,1)
}

#stone cover per polygon element (tuin)
stone_cover<-exactextractr::exact_extract(stone_d,tuinen_sf,
                                         fun ='mean',
                                         force_df =FALSE)

tuinen_sf$stone_cover<-round(stone_cover*100,1)


#water cover per polygon element (tuin)
water_cover<-exactextractr::exact_extract(water_d,tuinen_sf,
                                          fun ='mean',
                                          force_df =FALSE)

tuinen_sf$water_cover<-round(water_cover*100,1)


#-----------------------------------------------------------------------------------------------

#surface culculation (m2), tuinen
tuinen_sf <- tuinen_sf %>%
           mutate(
                  #oppervlakte vegetatie
                  green_surface = round((oppervlakte_tuin*(green_cover/100)),1),
                  #oppervlak potentieel vegetatie
                  green_potential = oppervlakte_tuin-green_surface,
                  #oppervlakte versteend
                  stone_surface = round((oppervlakte_tuin*(stone_cover/100)),1),
                  #oppervlakte versteend
                  water_surface = round((oppervlakte_tuin*(water_cover/100)),1),
                  #buurtcode meenemen
                  buurt_selection = neighbourhood
                  )

if(ahn_calc==TRUE) {
  tuinen_sf <- tuinen_sf %>%
    mutate(
      #oppervlak vegetatie 5m of hoger
      tree_surface_5m = round((oppervlakte_tuin*(tree_cover_5m/100)),1),
      #oppervlak vegetatie 3m of hoger
      veg_surface_3m = round((oppervlakte_tuin*(veg_cover_3m/100)),1),
      #oppervlak vegetatie 5m of hoger
      treeingreen_cover = round(tree_surface_5m/green_surface*100,1)
    )
}

sf::st_write(tuinen_sf, dsn=gpkg_vector, layer='tuinen',layer_options = "OVERWRITE=YES",append=FALSE)

#-----------------------------------------------------------------------------------------------
#compute buurt statistics
buurt_garden_stats <- tuinen_sf %>%
        group_by(buurt_selection) %>%
        summarise(
                  #tuin oppervlak
                  garden_surface_sum = sum(oppervlakte_tuin, na.rm = TRUE),
                  #aandeel vegetatie in tuin
                  green_cover_avg = round(mean(green_cover, na.rm = TRUE),1),
                  #oppervlak vegetatie
                  green_surface_sum = sum(green_surface, na.rm = TRUE),
                  #oppervlak potentieel vegetatie
                  green_potential_sum = sum(green_potential, na.rm = TRUE),
                  #aandeel middelhoge en hoge vegetatie in tuin (3m and above)
                  #veg_cover_3m_avg = round(mean(veg_cover_3m, na.rm = TRUE),1),
                  #aandeel bomen in tuin (5m and above)
                  #tree_cover_5m_avg = round(mean(tree_cover_5m, na.rm = TRUE),1),
                  #oppervlak middelhoge en hoge vegetatie (3m and above)
                  #veg3m_surface_sum = sum(veg_surface_3m, na.rm = TRUE),
                  #oppervlak bomen (5m and above)
                  #tree_surface_sum = sum(tree_surface_5m, na.rm = TRUE),
                  #aandeel bomen in vegetatie
                  #treeingreen_cover_avg = round(mean(treeingreen_cover,na.rm = TRUE),1),
                  #aandeel versteend in tuin
                  stone_cover_avg = round(mean(stone_cover, na.rm = TRUE),1),
                  #aandeel versteend in tuin
                  water_cover_avg = round(mean(water_cover, na.rm = TRUE),1),
                  #gemiddelde NDVI waarde tuin
                  ndvi_avg = round(mean(ndvi_avg,na.rm = TRUE),1),
                  #gemiddelde NDVI waarde vegetatie
                  ndvi_green_avg = round(mean(ndvi_green_avg,na.rm = TRUE),1)
                  )






buurt_garden_stats <- cbind(buurt_sf,buurt_garden_stats) %>% rename(geom_tuinen=geometry.1)

write.csv(buurt_garden_stats,file=paste(report.loc,"Buurt_tuinen_statistieken_",neighbourhood,".csv"))

#-----------------------------------------------------------------------------------------------

# Panden

#-----------------------------------------------------------------------------------------------

message("calculate green coverage panden on perceel with woonfunctie")

#Mean value (NDVI) of cells that intersect the polygon, weighted by the percent of the cell that is covered.
#mean ndvi per polygon element (panden)
ndvi_green_avg_panden<-exactextractr::exact_extract(ndvi_above_threshold,panden_sf,
                                              #the mean cell value, weighted by the fraction of each cell
                                              #that is covered by the polygon
                                              fun ='mean',
                                              force_df =FALSE)

panden_sf$ndvi_green_avg<-round(ndvi_green_avg_panden,3)

#vegetation cover per polygon element (pand)
ndvi_cover_panden<-exactextractr::exact_extract(veg_g,panden_sf,
                                         #the mean cell value, weighted by the fraction of each cell
                                         #that is covered by the polygon
                                         fun ='mean',
                                         force_df =FALSE)

panden_sf$green_cover<-round(ndvi_cover_panden*100,1)

panden_sf$oppervlakte_pand_unit = st_area(panden_sf)
panden_sf$oppervlakte_pand = as.numeric(panden_sf$oppervlakte_pand_unit)

#surface calculation (m2)
panden_sf <- panden_sf %>%
        mutate(
                #oppervlakte vegetatie
                green_surface = round((oppervlakte_pand*(green_cover/100)),1),
                #oppervlak potentieel vegetatie
                green_potential = oppervlakte_pand-green_surface,
                #gemiddelde NDVI
                ndvi_green_avg = round(mean(ndvi_green_avg_panden,na.rm = TRUE),3),
                #buurtcode meenemen
                buurt_selection = neighbourhood
        )


sf::st_write(panden_sf, dsn=gpkg_vector, layer='panden',layer_options = "OVERWRITE=YES",append=FALSE)

buurt_roofgarden_stats <- panden_sf %>%
        group_by(buurt_selection) %>%
        summarise(
                #pand oppervlak
                roofgarden_surface_sum = sum(oppervlakte_pand, na.rm = TRUE),
                #aandeel vegetatie in tuin
                green_cover_avg = round(mean(green_cover, na.rm = TRUE),1),
                #oppervlak vegetatie
                green_surface_sum = sum(green_surface, na.rm = TRUE),
                #oppervlak potentieel vegetatie
                green_potential_sum = sum(green_potential, na.rm = TRUE),
                #gemiddelde NDVI
                ndvi_green_avg = round(mean(ndvi_green_avg,na.rm = TRUE),1)
        )

buurt_roofgarden_stats <- cbind(buurt_sf,buurt_roofgarden_stats) %>% rename(geom_panden=geometry.1)

write.csv(buurt_roofgarden_stats,file=paste(report.loc,"Buurt_daken_statistieken_",neighbourhood,".csv"))
write.csv(buurt_sf,file=paste(report.loc,"Buurt_vollediggebeid_statistieken_",neighbourhood,".csv"))

#-----------------------------------------------------------------------------------------------

# Vegetation plots

#-----------------------------------------------------------------------------------------------

source(here::here('SRC/vegetation_plots.R'))

#-----------------------------------------------------------------------------------------------

# Metrics for unsupervised NDVI clusters (Fragmentation analysis)

#-----------------------------------------------------------------------------------------------

if(unsup_cl==TRUE) {
source(here::here('SRC/green_classes_metrics.R'))
}

#-----------------------------------------------------------------------------------------------

# Performance and debugging

#-----------------------------------------------------------------------------------------------

message("exiting procedure for neighbourhood ", neighbourhood)

end_time <- Sys.time()
performance = end_time - start_time
cat("\ntime passed ",performance," minutes\n")

rlang::last_error()
rlang::last_trace()
