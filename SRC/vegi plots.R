
#-----------------------------------------------------------------------------------------------

# Vegetation plots

#-----------------------------------------------------------------------------------------------

# plot NDVI
plot_ndvi <- gplot(ndvi) + 
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225))) +
  #coord_equal() +
  #geom_sf(data = st_geometry(clip.pand.buurt)) +
  theme_minimal() 
plot.nme = paste0('rs_ndvi_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)

#extent(percelen_sf)
#st_crs(percelen_sf)
#percelen_sf_pr  <- crs_wgs84
#percelen_sf_pr <- st_geometry(percelen_sf_pr)

#crs(percelen_sf_pr)
#extent(percelen_sf_pr)

#mapview(percelen_sf)


# plot vegetation classes
plot_vegi <-  gplot(vegc) + 
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(4))) +
  #coord_equal() +
  theme_minimal() 
plot.nme = paste0('rs_ndvi_classes_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)

# plot substantial green
plot_vegi <-  gplot(vegi) + 
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225))) +
  #coord_equal() +
  theme_minimal() 
plot.nme = paste0('rs_ndvi_substantial_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)

#plot rgb and substantial green
qq<-png(paste0(plots.dir,"rs_rgbplot_vegi_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio, height=png_height)
par(col.axis = "white", col.lab = "white", tck = 0)
plotRGB(f1, r=1, g=2, b=3, axes=TRUE, stretch="lin", main=paste0("composite image stack and subtantial vegetation", neighbourhood))
plot(vegi, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

# plot RVI
plot_rvi <-  gplot(rvi) + 
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225))) +
  #coord_equal() +
  theme_minimal() 
plot.nme = paste0('rs_rvi_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)

plot_ndvi_subset <- plot_ndvi + plot_vegi 
plot.nme = paste0('rs_ndvi_substantialgreen_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio*2, dpi=dpi)