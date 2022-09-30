
#-----------------------------------------------------------------------------------------------

#Crowns and tree tops

#-----------------------------------------------------------------------------------------------

#reclassify tree foliage height range
reclass_chm <- c(-Inf, foliage_lb, NA,
                 foliage_ub,Inf, NA)

reclass_chm_m <- matrix(reclass_chm,
                        ncol=3,
                        byrow=TRUE)

chm_m <- class_func(ahn_buurt,reclass_chm_m)

crs(chm_m) <- crs(percelen_sf)

#canopy height model (chm) : vegetation  extend within lower and upper bound of foliage height
chm_mveg <- veg_g * chm_m

rm(chm_m)

#-----------------------------------------------------------------------------------------------

#Tree segmentation

#-----------------------------------------------------------------------------------------------

#detect trees
message("\ntree segmentation")

#1. image pre-processing (non-linear filtering and smoothing for noise removal),
#2. local maxima filtering and selection for apex (local maximum) detection,
#3. image segmentation with a watershed algorithm for crown delineation.

segms <- lidaRtRee::tree_segmentation(chm_mveg,nl_size=ws,dmin=dmin,hmin=ttop_lb,crown_hmin=crown_lb,crown_prop = 0.4)
#dmin :numeric. treetop minimum distance to next higher pixel in meters

#par(mfrow=c(1, 3))
# display pre-processed chm
#terra::plot(segms$smoothed_dem, main="Pre-processed CHM")
# display selected local maxima
#terra::plot(segms$local_maxima, main="Selected local maxima")
# display segments, except ground segment
#dummy <- segms$segments_id
#dummy[dummy == 0] <- NA
#terra::plot(dummy %% 8, main="Segments (random colors)", col=rainbow(8))

# tree extraction
apices <- lidaRtRee::tree_extraction(segms, crown=TRUE)
# convert WKT field to polygons
crowns <- sf::st_as_sf(sf::st_drop_geometry(apices), wkt="crown")
# remove WKT field from apices
apices <- apices[, -which(names(apices)=="crown")]
head(apices)

#id: apex id
#x: easting coordinate of apex
#y: northing coordinate of apex
#h: height of apex
#dom_radius: distance of apex to nearest higher pixel of CHM
#s: crown surface
#v: crown volume
#sp (if plot mask is provided): crown surface inside plot
#vp (if plot mask is provided): crown volume inside plot
#crown (optional): 2D crown polygon in WKT format

#number of trees
trees_n<-nrow(apices)
trees_n

# display initial image
#terra::plot(chm_mveg, col=gray(seq(0, 1, 1 / 255)), main="CHM and detected positions")
# display segments border
#terra::plot(sf::st_geometry(crowns), border="white", add=T, col=NA)
# display plot mask
#terra::plot(mask_plot_v, border="red", add=T)
# display detected apices
#plot(apices["h"], col="blue", cex=apices$h / 20, pch=2, add=TRUE)

#garbage collection
gc()
