
#-----------------------------------------------------------------------------------------------

#Canopy and tree tops

#-----------------------------------------------------------------------------------------------

gc()

#UNDER CONSTRUCTION
#https://jean-romain.github.io/lidRbook/itd-its.html

#use all threads for lidR
set_lidr_threads(0)
#get_lidr_threads()

#location of laz-file (points), see procedure ahn.R
las.dir <- paste0(r_root,"/AHN_sheets/AHN2/PC/")
las.loc <- paste0(las.dir,"g45en1.laz")

#-----------------------------------------------------------------------------------------------

#Reading LiDAR data

#-----------------------------------------------------------------------------------------------

#check existence laz
ahn.pc.rdy <- list.files(las.dir, pattern = "\\.laz$", full.names = TRUE)
if(length(ahn.pc.rdy) != 0) {

#AHN point clouds
rAHNextract::ahn_pc(name = "BBOX pc", bbox = c(xmin, ymin, xmax, ymax), AHN = "AHN2", gefilterd = TRUE)
}

#filter height within 4 to 40m
las <- lidR::readLAS(las.loc,select = "xyzr", filter = "-keep_first -drop_z_below 4 -drop_z_above 40")
las_check(las)
#plot(las)

#-----------------------------------------------------------------------------------------------

#Canopy height model

#-----------------------------------------------------------------------------------------------

#thr <- c(0,2,5,10,15)
#edg <- c(0, 1.5)

#chm <- lidR::grid_canopy(las, 1, pitfree(thr, edg))
#chm <- grid_canopy(las, 0.5, pitfree(subcircle = 0.2))
#plot(chm, bg = "white", size = 4)

#-----------------------------------------------------------------------------------------------

#Individual Tree Detection

#-----------------------------------------------------------------------------------------------

#Local Maximum Filter with fixed windows size

#windows size of ws = 5 meters meaning that for a given point the algorithm looks to the neigbourhood points within
#a 2.5 radius circle to figure out if the point is the local highest.
#tree tops
ttops <- find_trees(las, lmf(ws = 5))
plot(ttops)

x <- plot(las, bg = "white", size = 4)
add_treetops3d(x, ttops)

#-----------------------------------------------------------------------------------------------

#Tree tops

#-----------------------------------------------------------------------------------------------

tree_tops <- lidR::find_trees(las, lmf(ws = 5), uniqueness = "incremental")

#x = plot(las)
#add_treetops3d(x, tree_tops)
