
#-----------------------------------------------------------------------------------------------

#Canopy

#-----------------------------------------------------------------------------------------------

#UNDER CONSTRUCTION

#AHN point clouds of a BBOX area from the not filtered AHN2 (uitgefilterd)
ahn_points <- ahn_pc(name = "BBOX pc", bbox = c(xmin, ymin, xmax, ymax), AHN = "AHN2", gefilterd = TRUE)

las.loc<-here::here("/AHN_sheets/AHN2/PC/g14cn2.laz")
las <- readLAS(las.loc)

#canopy height model
thr <- c(0,2,5,10,15)
edg <- c(0, 1.5)
chm <- grid_canopy(las, 1, pitfree(thr, edg))

plot(chm)
