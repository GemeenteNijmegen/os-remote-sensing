
#-----------------------------------------------------------------------------------------------

#Crowns and tree tops

#-----------------------------------------------------------------------------------------------


#reclassify tree foliage range
reclass_chm <- c(-Inf, foliage_lb, NA,
                 foliage_ub,Inf, NA)

reclass_chm_m <- matrix(reclass_chm,
                    ncol = 3,
                    byrow = TRUE)

chm_m <- class_func(ahn_buurt,reclass_chm_m)

raster::crs(chm_m) <- raster::crs(percelen_sf)

#canopy height model (chm) : vegetation within lower and upper bound of foliage height
#veg_g (1=green)
chm_mveg <- veg_g * chm_m

#eliminate spurious local maxima caused by tree branches
chm_mveg_smooth <- rLiDAR::CHMsmoothing(chm_mveg, filter = "mean", ws = 3)

rm(chm_m,chm_mveg)

#detect trees
message("\ntree detection")

#local maximum filter
#windows size of e.g. ws = 5 meters meaning that for a given point the algorithm looks to the neigbourhood points within
#a 2.5m radius circle to figure out if the point is the local highest.
#ttops <- lidR::find_trees(chm_mveg_smooth, lmf(ws=ws))

#tree tops start at least one and a half meter above lower bound crown
hmin<-crown_lb+1.5

#sf version
#ttops <- lidR::locate_trees(chm_mveg_smooth, lmf(ws = ws, hmin = hmin, shape = "circular"))

#sp version
ttops <- lidR::find_trees(chm_mveg_smooth, lmf(ws=ws, hmin = hmin, shape = "circular"))


#-----------------------------------------------------------------------------------------------

#Trees

#-----------------------------------------------------------------------------------------------

#number of trees
trees_n<-max(ttops$treeID)
trees_n

message("\nnumber of trees ", trees_n)

#-----------------------------------------------------------------------------------------------

#Crown deliniation

#-----------------------------------------------------------------------------------------------

if(crowns_trace==TRUE) {
  #detect crowns

  message("\ncrown deliniation")

  #canopy segmentation
  #defaults to raster

  #polygons
  #slow, results in memory leaks
  #crowns <- ForestTools::mcws(treetops = ttops, CHM = chm_mveg, format = "polygons", minHeight = crown_lb, verbose = FALSE)

  #create sf object
  #crowns <- st_as_sf(crowns)

#--------------------------------------------------------
#Alternative (faster) method for vectorizing crowns

  ttops_sf <- sf::st_as_sf(ttops)

  #Apply watershed function to segment (i.e.: outline) crowns from a canopy height model.
  #Segmentation is guided by the treetop location

  crwn_rst <- ForestTools::mcws(treetops=ttops, CHM = chm_mveg_smooth, format = "raster")

  # Convert raster to SpatRaster (from terra package)
  crwn_spatrst <- as(crwn_rst, "SpatRaster")

  # Convert the raster zones to polygons (uses GDAL)
  crwn_spatvec <- terra::as.polygons(crwn_spatrst)

  # Convert SpatVec object to sf (via export to Shapefile)
  tmp_fn <- tempfile(fileext = ".shp")
  terra::writeVector(crwn_spatvec, tmp_fn)
  crwn_sf <- sf::st_read(tmp_fn)

  rm(crwn_rst,crwn_spatrst,crwn_spatvec,chm_mveg)

  # Add crown area and treetop height to the attribute table
  crowns <- crwn_sf %>%
    dplyr::mutate(area = st_area(crwn_sf)) %>%
    sf::st_join(ttops_sf, join = st_intersects)
}

#garbage collection
gc()
