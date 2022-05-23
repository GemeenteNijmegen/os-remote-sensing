
#-----------------------------------------------------------------------------------------------

#Crowns and tree tops

#-----------------------------------------------------------------------------------------------

if(ahn_points==FALSE) {

#-----------------------------------------------------------------------------------------------

#Raster version (faster!)

#-----------------------------------------------------------------------------------------------

#reclassify tree range
reclass_chm <- c(-Inf, tree_lb, NA,
                  tree_up,Inf, NA)

reclass_chm_m <- matrix(reclass_chm,
                    ncol = 3,
                    byrow = TRUE)

chm_m <- class_func(ahn_buurt,reclass_chm_m)

raster::crs(chm_m) <- raster::crs(percelen_sf)

#canopy height model (chm) : vegetation within 5-40m
#veg_g (1=green)
chm_mveg <- veg_g * chm_m

rm(chm_m)

#detect trees
message("\ntree detection")

#windows size of ws = 7 meters meaning that for a given point the algorithm looks to the neigbourhood points within
#a 3.5 radius circle to figure out if the point is the local highest.
ttops <- lidR::find_trees(chm_mveg, lmf(ws=7))


} else {

#-----------------------------------------------------------------------------------------------

#LAS-version

#-----------------------------------------------------------------------------------------------

#use all threads for lidR
#Default value 0 means to utilize all CPU available (you'll need it!)
set_lidr_threads(0)
#get_lidr_threads()

#location of laz-file (points), see procedure ahn.R
las.dir <- paste0(r_root,"/AHN_sheets/AHN2/PC/")
las.loc <- paste0(las.dir,"g45en1.laz")

#check existence laz
ahn.pc.rdy <- list.files(las.dir, pattern = "\\.laz$", full.names = TRUE)
if(length(ahn.pc.rdy) == 0) {

#AHN point clouds
rAHNextract::ahn_pc(name = "BBOX pc", bbox = c(xmin, ymin, xmax, ymax), AHN = "AHN2", gefilterd = TRUE)
}

#filter height within 5 to 50m
las <- lidR::readLAS(las.loc,select = "xyzr", filter = "-keep_first -drop_z_below 5 -drop_z_above 50")
#las_check(las)
#plot(las)

#-----------------------------------------------------------------------------------------------

#Canopy height model

#-----------------------------------------------------------------------------------------------

thr <- c(0,2,5,10,15)
edg <- c(0, 1.5)

chm <- lidR::grid_canopy(las, 1, pitfree(thr, edg))
#plot(chm, bg = "white", size = 4)

ttops <- lidR::find_trees(chm, lmf(4, 2))
last   <- lidR::segment_trees(las, dalponte2016(chm, ttops))

col <- pastel.colors(200)
plot(last, color = "treeID", colorPalette = col)

}

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
  #tree tops are located above 5m, tree crowns above 2m
  #defaults to raster

  #polygons
  #slow, results in memory leaks
  #crowns <- ForestTools::mcws(treetops = ttops, CHM = chm_mveg, format = "polygons", minHeight = crown_lb, verbose = FALSE)

  #create sf object
  #crowns <- st_as_sf(crowns)


#--------------------------------------------------------
#Alternative (faster) method for vectorizing crowns

  ttops_sf <- st_as_sf(ttops)

  crwn_rst <- mcws(treetops=ttops, CHM = chm_mveg, format = "raster")

  ## Convert crwn_rst from raster to SpatRaster (from terra package)
  crwn_spatrst <- as(crwn_rst, "SpatRaster")

  ## Convert the raster zones to polygons (uses GDAL, fast)
  crwn_spatvec <- terra::as.polygons(crwn_spatrst)

  ## Convert SpatVec object to sf (via export to Shapefile)
  tmp_fn <- tempfile(fileext = ".shp")
  terra::writeVector(crwn_spatvec, tmp_fn)
  crwn_sf <- sf::st_read(tmp_fn)

  ## Add crown area and treetop height to the attribute table
  crowns <- crwn_sf %>%
    dplyr::mutate(area = st_area(crwn_sf)) %>%
    sf::st_join(ttops_sf, join = st_intersects)
}

#garbage collection
gc()
