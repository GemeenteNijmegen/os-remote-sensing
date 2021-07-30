
#-----------------------------------------------------------------------------------------------

# Vegetation plots

#-----------------------------------------------------------------------------------------------

#NDVI distribution
png(paste0(plots.dir,"rs_ndvi_density_distribution_",neighbourhood,".png"))
p1<-rasterVis::densityplot(ndvi)
print(p1)
dev.off()

#lattice-style levelplot NDVI
png(paste0(plots.dir,"rs_ndvi_levelplot_",neighbourhood,".png"))
p2<-rasterVis::levelplot(ndvi)
#+ latticeExtra::layer(sp.polygons(percelen_sf, col="white", lwd=0.2))
print(p2)
dev.off()

#-----------------------------------------------------------------------------------------------
#minimal theme

# plot NDVI
mplot_ndvi <- gplot(ndvi) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225)), na.value ="transparent", limits = c(-0.5,1)) +
  #geom_sf(aes(st_sf(st_geometry(tuinen_sf)))) +
  theme_minimal() +
labs(fill = "NDVI")
plot.nme = paste0('rs_ndvi_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, dpi=dpi)

# plot EVI2
mplot_evi2 <- gplot(evi2) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225)), na.value ="transparent") +
  #geom_sf(aes(st_sf(st_geometry(tuinen_sf)))) +
  theme_minimal() +
  labs(fill = "EVI2")
plot.nme = paste0('rs_evi2_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, dpi=dpi)

# plot RVI
mplot_rvi <- gplot(rvi) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225)), na.value ="transparent") +
  #geom_sf(aes(st_sf(st_geometry(tuinen_sf)))) +
  theme_minimal() +
  labs(fill = "RVI")
plot.nme = paste0('rs_rvi_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, dpi=dpi)

# plot vegetation classes
mplot_veg_c <-  gplot(veg_c) +
  geom_tile(aes(fill = as.factor(value))) +
  #scale_fill_gradientn(colours = rev(terrain.colors(5)), na.value ="transparent") +
  scale_fill_discrete_sequential(palette = "Terrain") +
  theme_minimal() +
  labs(fill = "NDVI classes (fixed)")
plot.nme = paste0('rs_ndvi_classes_fixed_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, dpi=dpi)

# plot vegetation classes
mplot_veg_clus <-  gplot(veg_clus) +
  geom_tile(aes(fill = as.factor(value))) +
  #scale_fill_gradientn(colours = rev(terrain.colors(5)), na.value ="transparent") +
  scale_fill_discrete_sequential(palette = "Terrain") +
  theme_minimal() +
  labs(fill = "NDVI classes (unsupervised)")
plot.nme = paste0('rs_ndvi_classes_unsupervised_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, dpi=dpi)

# plot substantial green
mplot_veg_s <-  gplot(veg_s) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225)), na.value ="transparent",limits = c(0.4,1)) +
  theme_minimal() +
  labs(fill = "NDVI")
plot.nme = paste0('rs_ndvi_substantial_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, dpi=dpi)



#-----------------------------------------------------------------------------------------------
# white background

#plot rgb and ndvi
png(paste0(plots.dir,"rs_rgb_ndvi_",neighbourhood,".png"), bg="white")
par(col.axis = "white", col.lab = "white", tck = 0)
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("NDVI ", neighbourhood))
plot(ndvi, add=TRUE, legend=FALSE)
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#vegetation
png(paste0(plots.dir,"rs_rgb_vegetation_",neighbourhood,".png"), bg="white")
par(col.axis = "white", col.lab = "white", tck = 0)
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("vegetation ", neighbourhood))
plot(veg_g, add=TRUE, legend=FALSE)
#plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#plot rgb and substantial green
png(paste0(plots.dir,"rs_rgb_veg_substantial_",neighbourhood,".png"), bg="white")
par(col.axis = "white", col.lab = "white", tck = 0)
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("subtantial vegetation ", neighbourhood))
plot(veg_s, add=TRUE, legend=FALSE)
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#plot rgb and classes unsupervised
png(paste0(plots.dir,"rs_rgb_veg_classes_unsupervised_",neighbourhood,".png"), bg="white")
par(col.axis = "white", col.lab = "white", tck = 0)
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("NDVI classes (unsupervised) ", neighbourhood))
plot(veg_clus, add=TRUE, legend=FALSE)
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#plot rgb and classes fixed
png(paste0(plots.dir,"rs_rgb_veg_classes_fixed_",neighbourhood,".png"), bg="white")
par(col.axis = "white", col.lab = "white", tck = 0)
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("NDVI classes (fixed) ", neighbourhood))
plot(veg_c, add=TRUE, legend=FALSE)
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#plot RVI
png(paste0(plots.dir,"rs_rvi_",neighbourhood,".png"), bg="white")
par(col.axis = "white", col.lab = "white", tck = 0)
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("RVI ", neighbourhood))
plot(rvi, add=TRUE, legend=FALSE)
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

plot_ndvi_subset <- plot_ndvi + plot_vegi
plot.nme = paste0('rs_ndvi_substantialgreen_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, dpi=dpi)

#bomen
png(paste0(plots.dir,"rs_rgb_veg_5m_",neighbourhood,".png"), bg="white")
par(col.axis = "white", col.lab = "white", tck = 0)
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("5m+ trees ", neighbourhood))
plot(garden_5mplus, add=TRUE, legend=FALSE)
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()
