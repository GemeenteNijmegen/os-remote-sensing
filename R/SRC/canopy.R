
#-----------------------------------------------------------------------------------------------

#Canopy and tree tops

#-----------------------------------------------------------------------------------------------

#UNDER CONSTRUCTION
gc()

las.dir <- paste0(r_root,"/AHN_sheets/AHN2/PC/")
las.loc <- paste0(las.dir,"g45en1.laz")

#check existence
ahn.pc.rdy <- list.files(las.dir, pattern = "\\.laz$", full.names = TRUE)
if(length(ahn.pc.rdy) != 0) {

#AHN point clouds
rAHNextract::ahn_pc(name = "BBOX pc", bbox = c(xmin, ymin, xmax, ymax), AHN = "AHN2", gefilterd = TRUE)
}

las <- lidR::readLAS(las.loc, select = "xyz")


#-----------------------------------------------------------------------------------------------

#Canopy height model

#-----------------------------------------------------------------------------------------------

thr <- c(0,2,5,10,15)
edg <- c(0, 1.5)
chm <- lidR::grid_canopy(las, 1, pitfree(thr, edg))

plot(chm)


#-----------------------------------------------------------------------------------------------

#Tree tops

#-----------------------------------------------------------------------------------------------

tree_tops <- lidR::find_trees(las, lmf(ws = 5), uniqueness = "incremental")

#x = plot(las)
#add_treetops3d(x, tree_tops)
