
#-----------------------------------------------------------------------------------------------

# Vegetation plots

#-----------------------------------------------------------------------------------------------


# plot NDVI
gplot(ndvi) + 
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225))) +
  coord_equal() +
  theme_minimal() 
plot.nme = paste0('rs_ndvi.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)

# plot substantial green
gplot(vegi) + 
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225))) +
  coord_equal() +
  theme_minimal() 
plot.nme = paste0('rs_vegi.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)

# plot RVI
gplot(rvi) + 
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225))) +
  coord_equal() +
  theme_minimal() 
plot.nme = paste0('rs_rvi.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height, width = graph_height * aspect_ratio, dpi=dpi)
