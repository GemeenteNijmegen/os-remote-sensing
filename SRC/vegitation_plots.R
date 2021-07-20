
#-----------------------------------------------------------------------------------------------

# Vegetation plots

#-----------------------------------------------------------------------------------------------

#NDVI distribution
png(paste0(plots.dir,"rs_ndvi_density_distribution_",neighbourhood,".png"), width=png_height*aspect_ratio, height=png_height)
p1<-rasterVis::densityplot(ndvi)
print(p1)
dev.off()

#lattice-style levelplot NDVI
png(paste0(plots.dir,"rs_ndvi_levelplot_",neighbourhood,".png"), width=png_height*aspect_ratio, height=png_height)
p2<-rasterVis::levelplot(ndvi)
#+ latticeExtra::layer(sp.polygons(percelen_sf, col="white", lwd=0.2))
print(p2)
dev.off()

# plot NDVI
plot_ndvi <- gplot(ndvi) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225)), na.value ="transparent", limits = c(-0.5,1)) +
  #geom_sf(aes(st_sf(st_geometry(tuinen_sf)))) +
  theme_minimal() +
labs(fill = "NDVI")
plot.nme = paste0('rs_ndvi_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)

# plot vegetation classes
plot_vegi <-  gplot(veg_c) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(5)), na.value ="transparent") +
  theme_minimal() +
  labs(fill = "NDVI classes (fixed)")
plot.nme = paste0('rs_ndvi_classes_fixed_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)

# plot vegetation classes
plot_vegi <-  gplot(veg_clus) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(5)), na.value ="transparent") +
  theme_minimal() +
  labs(fill = "NDVI classes (unsupervised)")
plot.nme = paste0('rs_ndvi_classes_unsupervised_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)

# plot substantial green
plot_vegi <-  gplot(veg_s) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225)), na.value ="transparent",limits = c(0.4,1)) +
  theme_minimal() +
  labs(fill = "NDVI")
plot.nme = paste0('rs_ndvi_substantial_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)

# plot rvi
plot_vegi <-  gplot(rvi) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225)), na.value ="transparent",limits = c(0.4,1)) +
  theme_minimal() +
  labs(fill = "RVI")
plot.nme = paste0('rs_rvi_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)

#plot rgb and ndvi
png(paste0(plots.dir,"rs_rgb_ndvi_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio, height=png_height)
par(col.axis = "white", col.lab = "white", tck = 0)
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("composite image stack RGB and NDVI ", neighbourhood))
plot(ndvi, add=TRUE, legend=FALSE)
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#plot rgb and substantial green
png(paste0(plots.dir,"rs_rgb_veg_substantial_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio, height=png_height)
par(col.axis = "white", col.lab = "white", tck = 0)
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("composite image stack RGB and subtantial vegetation ", neighbourhood))
plot(veg_s, add=TRUE, legend=FALSE)
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#plot rgb and classes unsupervised
png(paste0(plots.dir,"rs_rgb_veg_classes_unsupervised_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio, height=png_height)
par(col.axis = "white", col.lab = "white", tck = 0)
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("composite image stack RGB and green classes (unsupervised) ", neighbourhood))
plot(veg_clus, add=TRUE, legend=FALSE)
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#plot rgb and classes fixed
png(paste0(plots.dir,"rs_rgb_veg_classes_fixed_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio, height=png_height)
par(col.axis = "white", col.lab = "white", tck = 0)
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("composite image stack RGB and NDVI classes (fixed) ", neighbourhood))
plot(veg_c, add=TRUE, legend=FALSE)
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()


#plot RVI
png(paste0(plots.dir,"rs_rvi_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio, height=png_height)
par(col.axis = "white", col.lab = "white", tck = 0)
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("composite image stack RGB and RVI ", neighbourhood))
plot(rvi, add=TRUE, legend=FALSE)
plot(percelen_sf$geom, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

plot_ndvi_subset <- plot_ndvi + plot_vegi
plot.nme = paste0('rs_ndvi_substantialgreen_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio*2, dpi=dpi)

