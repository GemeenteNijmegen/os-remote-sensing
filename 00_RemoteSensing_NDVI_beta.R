
#-----------------------------------------------------------------------------------------------

# Remote Sensing: Green urban spaces

#-----------------------------------------------------------------------------------------------

# date created: 11-05-2021
# date modified: 19-07-2021

#-----------------------------------------------------------------------------------------------

# Setup environment

#-----------------------------------------------------------------------------------------------

#Run in project environment (to avoid package conflicts)
#FALSE : use current version of packages (recommended)
#TRUE : fresh install of packages in isolated environment

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

# source(here('SRC/functions.R'))

#-----------------------------------------------------------------------------------------------

# Settings

#-----------------------------------------------------------------------------------------------

#id neighbourhood
#neighbourhood <- "BU03638600"
#neighbourhood <- "BU19590202"
neighbourhood <- "BU04411401"

#temp.dir <- "tempdata"

#location geopackages 
#vector layers (polygons buurt, percelen, panden)
#neigh.vec.loc <- file.path(temp.dir, paste0(neighbourhood, "_vector.gpkg"))
#geographic raster data (incl. areial photo, NDVI, NH3?)
#neigh.ras.loc <- file.path(temp.dir, paste0(neighbourhood,  "_raster.gpkg"))
#neigh.ras.loc <- paste0(temp.dir,neighbourhood, "_raster.gpkg")



#-----------------------------------------------------------------------------------------------

# Polygons

#-----------------------------------------------------------------------------------------------

#create geopackage with buurt, percelen and panden polygons
#source(here('SRC/buurt_pand_perceel_request.R'))

#mapview(list(percelen_sf, panden_sf),alpha.regions = 0.6, alpha = 1)

#-----------------------------------------------------------------------------------------------

# percelen disection

#-----------------------------------------------------------------------------------------------

## download gpkg vector file from Stack
path_processed <- file.path("https://datasciencevng.nl/remote.php/webdav/Data/processed", 
                            neighbourhood, paste0(neighbourhood, "_vector.gpkg"))
neigh_vector_gpkg <- R.utils::downloadFile(url      = path_processed,
                                           path     = "processed",
                                           username = "remotesensing", 
                                           password = "VNGRS2021!", 
                                           verbose  = FALSE)

#st_layers(neigh_vector_gpkg)
buurt_sf    <- st_read(neigh_vector_gpkg, layer = "buurt")
percelen_sf <- st_read(neigh_vector_gpkg, layer = "percelen")
panden_sf   <- st_read(neigh_vector_gpkg, layer = "panden")
vbo_sf      <- st_read(neigh_vector_gpkg, layer = "verblijfsobjecten")

## <FIXME>
# tuinen should be percelen minus all panden (not just gebruiksdoel == "woonfunctie")
tuinen_sf   <- st_read(neigh_vector_gpkg, layer = "tuinen")
## </FIXME>


# gardens on percelen with woonfunctie
#woonpercelen_garden_sf <- percelen_garden_sf[percelen_garden_sf$gebruiksdoel %like% "woonfunctie", ]

# <FIXME>
# cast explicitly to polygon
#woonpercelen_garden_sf <- sf::st_cast(woonpercelen_garden_sf, to = "POLYGON")
# </FIXME>


#plot(buurt_sf$geom)
#plot(st_geometry(tuinen_sf), add = TRUE)

#write layer to vector gpkg 
# sf::st_write(woonpercelen_garden_sf, dsn = neigh.vec.loc, layer = 'garden_private',
#              layer_options = "OVERWRITE=YES", append = FALSE)
# sf::st_layers(neigh.vec.loc)


#-----------------------------------------------------------------------------------------------

# Aerial image

#-----------------------------------------------------------------------------------------------
#source(here('SRC/import_image.R'))

## get aerial image from neighbourhood from Stack
path_tif <- paste0("https://datasciencevng.nl/remote.php/webdav/Data/cir2020perbuurt/", neighbourhood,".tif")
tif <- R.utils::downloadFile(url      = path_tif,
                             path     = "tempdata",
                             username = "remotesensing", 
                             password = "VNGRS2021!", 
                             verbose  = FALSE)

# stars based on Tiff
x <- read_stars(tif)
ai <- as(x, "Raster")
rm(x)
#plot layers
#plot(ai)

# mask tuinen
ai_tuinen <- raster::mask(ai, tuinen_sf)


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

plot(ndvi)
#plot(st_geometry(woonpercelen_garden_sf), add = TRUE)



# -------------------------------------------------------------------------

# k-means clustering 

# -------------------------------------------------------------------------
# ndvi scores greater than 0.25455043 are considered high quality vegi. 
ndvi@data@values[ndvi@data@values <= 0.25455043] <- NA


# convert the raster to vector/matrix ('getValues' converts the RasterLAyer to array) )
ndvi_array <- getValues(ndvi)

# keep valid observations only
i <- which(!is.na(ndvi_array))
ndvi_valid_array <- ndvi_array[i]

## this is where the magic happens
# number of clusters
k <- 5
km <- kmeans(ndvi_valid_array, centers = k, iter.max = 200,
             nstart = 5, algorithm = "Lloyd")

# extract cluster means
centers <- km$centers

# order the cluster means
centers <- sort(centers)

# call kmeans again but this time passing the centers calculated in the previous 
# step. In this way the results is neatly ordered.
km <- kmeans(ndvi_valid_array, centers = centers)
#table(km$cluster)

# Copy ndvi layer
gi_km <- ndvi

## replace raster cell values with km$cluster
# array
gi_km[]  <- NA
gi_km[i] <- km$cluster


# boxplots cluster result
tmp <- data.frame(ndvi = ndvi[], gi = gi_km[])

tmp$gi <- factor(tmp$gi)
ndvi_cluster <- Rmisc::summarySE(tmp, measurevar = "ndvi", groupvars = c("gi"))
ndvi_cluster$ndvi <- round(ndvi_cluster$ndvi, digits = 2)
ndvi_cluster <- ndvi_cluster[complete.cases(ndvi_cluster), ]

ggplot(ndvi_cluster, aes(x = gi, y = ndvi)) + 
  geom_bar(position=position_dodge(), stat="identity", fill = "steelblue") +
  geom_text(aes(label = ndvi), vjust = 1.6, color = "black", size = 3.5)+
  geom_errorbar(aes(ymin = ndvi-se, ymax = ndvi+se),
                width = 0.2,                    # Width of the error bars
                position = position_dodge(0.9)) +
  xlab("Cluster")+
  ylab("NDVI") +
  theme_bw()

# create list with upper-bounds per cluster
rng_list <- list()
for (c in 1:k) {
  rng_list[[c]] <- max(range(tmp$ndvi[tmp$gi == c], na.rm = TRUE) )
}

# reclassifying nvdi into clusters
vegi <- raster::reclassify(ndvi, c(-Inf, rng_list[[1]], 1,   
                                   rng_list[[1]], rng_list[[2]], 2,
                                   rng_list[[2]], rng_list[[3]], 3,  
                                   rng_list[[3]], rng_list[[4]], 4,
                                   rng_list[[4]], Inf, 5))
#open land
#land <- raster::reclassify(ndvi, c(-Inf, 0.25, NA,  0.25, 0.3, 1,  0.3, Inf, NA))

#vegetation in classes
#vegc <- raster::reclassify(ndvi, c(-Inf,0.25,1, 0.25,0.3,2, 0.3,0.4,3, 0.4,0.5,4, 0.5,Inf, 5))

#Ratio vegetation index (RVI)
#Indicates amount of vegetation
#Reduces the effects of atmosphere and topography
#rvi <- nir / red


# plot --------------------------------------------------------------------

## visual inspection  
#par(mfrow = c(1,2))
aerial_rgb <- plotRGB(ai,
                      r = 1, g = 2, b = 3,
                      #stretch the values to increase the contrast of the image
                      stretch = "lin",
                      #axes = TRUE,
                      main = paste0("composite image stack ", neighbourhood))

#-----------------------------------------------------------------------------------------------
#create fresh multi-raster GeoPackage (gpkg) containing all green indices (write)

unlink(paste0(temp.dir, neighbourhood, "_green_indices.gpkg"))
#Stars-packagke

#NDVI values
ndvi %>% 
        st_as_stars %>% # convert the RasterLayer to a stars object
        write_stars(paste0(temp.dir, neighbourhood, "_green_indices.gpkg"),
                    driver = "GPKG", options = c("RASTER_TABLE=ndvi", 
                                                 "APPEND_SUBDATASET=YES"))

#subset of substantial green
vegi %>% 
        st_as_stars %>% # convert the RasterLayer to a stars object
        write_stars(paste0(temp.dir, neighbourhood, "_green_indices.gpkg"),
                    driver = "GPKG", options = c("RASTER_TABLE=vegi",
                                                 "APPEND_SUBDATASET=YES"))

#RVI values
# rvi %>% 
#         st_as_stars %>% # convert the RasterLayer to a stars object
#         write_stars(paste0(temp.dir, neighbourhood, "_green_indices.gpkg"),
#                     driver = "GPKG", options = c("RASTER_TABLE=rvi",
#                                                  "APPEND_SUBDATASET=YES"))

#review raster layers in gpkg-file
gdalUtils::gdalinfo(paste0(temp.dir, neighbourhood, "_green_indices.gpkg")) %>% 
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

#-----------------------------------------------------------------------------------------------

# Vegetation plots

#-----------------------------------------------------------------------------------------------
plot(vegi, main = c("ndvi"), col = viridis_pal(option = "D")(3), add = TRUE)

plot(green_indices, main = c("ndvi", "vegi", "rvi"), col = viridis_pal(option = "D")(3))
#source(here('SRC/vegi plots.R'))
gc()
#-----------------------------------------------------------------------------------------------

# Polygon filtering

#-----------------------------------------------------------------------------------------------

#filter ndvi raster by polygon
#https://cran.r-project.org/web/packages/exactextractr/exactextractr.pdf

#projection
crs(vegi) <- crs(percelen_sf)
crs(ndvi) <- crs(percelen_sf)

# surface covered by substantial green per polygon element
ndvi2 <- raster::raster(ndvi)
percelen_sf2 <- sf::st_sf(percelen_sf) 
panden_sf2   <- sf::st_sf(panden_sf)

# memory burden
ndvi_cover <- exactextractr::coverage_fraction(ndvi2, panden_sf2, crop = FALSE)
rm(ndvi2, percelen_sf2)
gc()


#Mean value (NDVI) of cells that intersect the polygon, weighted by the percent of the cell that is covered.
#mean ndvi per polygon element (perceel)
ndvi_avg <- exactextractr::exact_extract(ndvi, panden_sf, 
                                        #the mean cell value, weighted by the fraction of each cell 
                                        #that is covered by the polygon
                                        fun = 'mean',
                                        force_df = TRUE)


#add mean ndvi values to percelen_sf
#percelen_sf$ndvi_avg<-ndvi_avg

#Sum of raster cells covered by the polygon, with each raster value weighted by its coverage fraction 
#and weighting raster value.
#ndvi_weighted_sum<-exactextractr::exact_extract(vegi, woonpercelen_garden_sf, 
#                                             'weighted_sum',
#                                             weights=raster(woonpercelen_garden_sf$geom),
#                                             force_df =TRUE)



#-----------------------------------------------------------------------------------------------

# Unsupervised classification

#-----------------------------------------------------------------------------------------------

#source(here('SRC/classification.R'))

#-----------------------------------------------------------------------------------------------

# Debugging

#-----------------------------------------------------------------------------------------------

rlang::last_error()
rlang::last_trace()
