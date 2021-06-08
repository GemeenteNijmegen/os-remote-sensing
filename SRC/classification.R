
#------------------------------------------------------------------------------

#Unsupervised classification

#------------------------------------------------------------------------------


# convert the raster to vector/matrix ('getValues' converts the RasterLAyer to array) )
nvdi_array <-getValues(ndvi)
str(nvdi_array)

# create 10 clusters, allow 500 iterations, start with 5 random sets using 'Lloyd' method
km <- kmeans(na.omit(nvdi_array), centers = 10, iter.max = 500,
             nstart = 5, algorithm = "Lloyd")

# kmeans returns an object of class 'kmeans'
str(km)

# Copy ndvi layer
knr <- ndvi

# replace raster cell values with km$cluster
# array
knr[] <- km$cluster

par(mfrow = c(1, 2))
plot(ndvi, col = rev(terrain.colors(10)), main = "NDVI")
plot(knr, main = "Kmeans", col = viridis_pal(option = "D")(10))


plot.nme = paste0('rs_rgb_kmeans.png')
plot.store <-paste0(plots.dir,plot.nme)

png(plot.store, width = 10, height = 8, units = "in", res = 300)
par(mar = c(10.8, 5, 10.8, 2), mfrow = c(1, 2))
plotRGB(f1, axes = TRUE, stretch = "lin", main = "RGB")
plot(knr, main = "Kmeans", yaxt = 'n', col = viridis_pal(option = "D")(10))
dev.off()