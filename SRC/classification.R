
#-----------------------------------------------------------------------------------------------

# Unsupervised classification

#-----------------------------------------------------------------------------------------------

#number of clusters
k<-10

# convert the raster to vector/matrix ('getValues' converts the RasterLAyer to array) )
nvdi_array <-getValues(ndvi)
#keep valid observations only
i <- which(!is.na(nvdi_array))
nvdi_valid_array <- nvdi_array[i]

str(nvdi_valid_array)

#-----------------------------------------------------------------------------------------------
#Kmeans clustering

#create k clusters, allow 500 iterations, start with 5 random sets using 'Lloyd' method
km <- kmeans(nvdi_valid_array, centers = k, iter.max = 500,
             nstart = 5, algorithm = "Lloyd")
#kmeans returns an object of class 'kmeans'
#str(km)

#Copy ndvi layer
gi_km <- ndvi

#replace raster cell values with km$cluster
# array
gi_km[] <- km$cluster

#-----------------------------------------------------------------------------------------------
## Clara classification (Clustering for Large Applications) 

cl <- clara(nvdi_valid_array,k,samples=500,metric="manhattan",pamLike=T)
#clara returns an object of class 'clara'
#str(cl)

# Copy ndvi layer
gi_cl <- ndvi

# replace raster cell values with cl$clustering
# array
gi_cl[] <- cl$clustering


gi_class_stack <- stack(gi_km,gi_cl)
names(gi_class_stack) <- c("kmeans","clara")


#-----------------------------------------------------------------------------------------------
#plotting classification methods

#panel plot RGB and Kmeans
plot.nme = paste0('rs_rgb_kmeans_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
png(plot.store, width = 10, height = 8, units = "in", res = 300)
par(mar = c(10.8, 5, 10.8, 2), mfrow = c(1, 2))
plotRGB(f1, axes = TRUE, stretch = "lin", main = "RGB")
plot(gi_km, main = "Kmeans", col = viridis_pal(option = "D")(k))
dev.off()

#panel plot NVDI and Kmeans
plot.nme = paste0('rs_nvdi_kmeans_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
png(plot.store, width = 10, height = 8, units = "in", res = 300)
par(mar = c(10.8, 5, 10.8, 2), mfrow = c(1, 2))
plot(ndvi, col = rev(terrain.colors(10)), main = "NDVI")
plot(gi_km, main = "Kmeans", col = viridis_pal(option = "D")(k))
dev.off()

#panel plot NVDI and Clara
plot.nme = paste0('rs_nvdi_clara_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
png(plot.store, width = 10, height = 8, units = "in", res = 300)
par(mar = c(10.8, 5, 10.8, 2), mfrow = c(1, 2))
plot(ndvi, col = rev(terrain.colors(10)), main = "NDVI")
plot(gi_cl, main = "Clara", col = viridis_pal(option = "D")(k))
dev.off()

#panel plot Kmeans and Clara
plot.nme = paste0('rs_kmeans_clara_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
png(plot.store, width = 10, height = 8, units = "in", res = 300)
par(mar = c(10.8, 5, 10.8, 2), mfrow = c(1, 2))
plot(gi_km, main = "Kmeans", col = viridis_pal(option = "D")(k))
plot(gi_cl, main = "Clara", col = viridis_pal(option = "D")(k))
dev.off()


#-----------------------------------------------------------------------------------------------

