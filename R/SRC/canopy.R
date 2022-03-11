
#-----------------------------------------------------------------------------------------------

#Crowns and tree tops

#-----------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------

#Raster version

#-----------------------------------------------------------------------------------------------

#
reclass_chm <- c(-Inf, 5, NA,
                  40,Inf, NA)

reclass_chm_m <- matrix(reclass_chm,
                    ncol = 3,
                    byrow = TRUE)

chm_5m <- class_func(ahn_buurt,reclass_chm_m)

raster::crs(chm_5m) <- raster::crs(percelen_sf)

#canopy height model (chm) : vegetation within 5-40m
chm_5mveg <- veg_g * chm_5m

if(tree_trace==TRUE) {
#detect trees

#sp class
ttops <- lidR::find_trees(chm_5mveg, lmf(ws=7))

#number of trees
trees_n<-max(ttops$treeID)
trees_n

message("number of trees ", trees_n)
}

if(crowns_trace==TRUE) {
#detect crowns

  #canopy segmentation
  #tree tops are located above 5m, tree crowns above 2m
  #defaults to raster
  #crowns <- ForestTools::mcws(treetops = ttops, CHM = chm_5mveg, minHeight = 2, verbose = FALSE)

  #polygon version
  crowns <- ForestTools::mcws(treetops = ttops, CHM = chm_5mveg, format = "polygons", minHeight = 2, verbose = FALSE)


  # Compute average crown diameter
  #crowns[["crownDiameter"]] <- sqrt(crowns_polygon[["crownArea"]]/ pi) * 2

  # Mean crown diameter
  #mean(crowns$crownDiameter)

  #plot(crowns)

  if(crown_stats==TRUE) {
  #ompute statistics of the trees’ attributes
  #sp_summarise(crowns_polygon, variables = c("crownArea", "height"))
  }

  #create sf object
  crowns <- st_as_sf(crowns)
  #write to polygon geopackage
  sf::st_write(crowns, dsn=gpkg_vector, layer='crowns',layer_options = "OVERWRITE=YES",append=FALSE)

  # Plot crowns
  cols_rainbow<- sample(rainbow(50), length(unique(crowns[])), replace = TRUE)
  plotting_base(ai_buurt,crowns, "tree crowns", "rs_crown_tops",NULL,NULL,cols_rainbow)

  }



#-----------------------------------------------------------------------------------------------

#LAS-version

#-----------------------------------------------------------------------------------------------


if(ahn_points==TRUE) {



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

#filter height within 5 to 20m
las <- lidR::readLAS(las.loc,select = "xyzr", filter = "-keep_first -drop_z_below 5 -drop_z_above 20")
#las_check(las)
#plot(las)

#-----------------------------------------------------------------------------------------------

#Canopy height model, tree tops

#-----------------------------------------------------------------------------------------------

thr <- c(0,2,5,10,15)
edg <- c(0, 1.5)

chm <- lidR::grid_canopy(las, 1, pitfree(thr, edg))
#plot(chm, bg = "white", size = 4)

#chm = raster("file/to/a/chm/")

ttops <- lidR::find_trees(chm, lmf(4, 2))
last   <- lidR::segment_trees(las, dalponte2016(chm, ttops))

col <- pastel.colors(200)
plot(last, color = "treeID", colorPalette = col)


#-----------------------------------------------------------------------------------------------

#Individual Tree Detection

#-----------------------------------------------------------------------------------------------

#Local Maximum Filter with fixed windows size

#windows size of ws = 5 meters meaning that for a given point the algorithm looks to the neigbourhood points within
#a 2.5 radius circle to figure out if the point is the local highest.
#tree tops
#ttops <- lidR::find_trees(las, lmf(ws = 5), uniqueness = "incremental")
#plot(ttops)

#x <- plot(las, bg = "white", size = 4)
#add_treetops3d(x, ttops)


}

#garbage collection
gc()
