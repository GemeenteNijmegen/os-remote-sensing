
#-----------------------------------------------------------------------------------------------

# Unsupervised classification

#-----------------------------------------------------------------------------------------------

#number of clusters
k <- 10

report_opmtimal_k <- FALSE

# convert the raster to vector/matrix ('getValues' converts the RasterLAyer to array) )
nvdi_array <- getValues(ndvi)
#length(nvdi_array)

#keep valid observations only
i <- which(!is.na(nvdi_array))
nvdi_valid_array <- nvdi_array[i]

str(nvdi_valid_array)

#-----------------------------------------------------------------------------------------------
#Kmeans clustering

if(report_opmtimal_k == TRUE) {
# # to reduce the computational time, we use 10% of the data. 
nvdi_valid_array_sub <- sample(nvdi_valid_array, size = length(nvdi_valid_array)/10, replace = FALSE)
par(mfrow = c(1,2))

h1<-hist(nvdi_valid_array)
h2<-hist(nvdi_valid_array_sub)
 
h1+h2

k.max <- 15
data <- nvdi_valid_array_sub
wss <- sapply(1:k.max, 
               function(k) { kmeans(data, k, nstart = 5, iter.max = 500,
                                  algorithm = "Lloyd")$tot.withinss 
                 }
               )
# wss
 plot(1:k.max, wss,
      type = "b", pch = 19, frame = FALSE, 
      xlab = "Number of clusters K",
      ylab = "Total within-clusters sum of squares")

#reset k?
#k= 
}

#create k clusters, allow 500 iterations, start with 5 random sets using 'Lloyd' method
km <- kmeans(nvdi_valid_array, centers = k, iter.max = 500,
             nstart = 5, algorithm = "Lloyd")

#kmeans returns an object of class 'kmeans'
str(km)

#Copy ndvi layer
gi_km <- ndvi

#replace raster cell values with km$cluster
# array
gi_km[] <- NA
gi_km[] <- km$cluster

#-----------------------------------------------------------------------------------------------
## Clara classification (Clustering for Large Applications) 

cl <- clara(nvdi_valid_array, k, samples = 500, metric = "manhattan", pamLike = TRUE)
cl$clusinfo

#clara returns an object of class 'clara'
str(cl)

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
plotRGB(ai_crop, r=1, g=2, b=3, axes=TRUE, stretch="lin", main = "RGB")
plot(gi_km, main = "Kmeans", col = viridis_pal(option = "D")(k))
dev.off()

#panel plot RGB and Clara
plot.nme = paste0('rs_rgb_clara_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
png(plot.store, width = 10, height = 8, units = "in", res = 300)
par(mar = c(10.8, 5, 10.8, 2), mfrow = c(1, 2))
plotRGB(ai_crop, r=1, g=2, b=3, axes=TRUE, stretch="lin", main = "RGB")
plot(gi_cl, main = "Clara", col = viridis_pal(option = "C")(k))
dev.off()

#panel plot NVDI and Kmeans
plot.nme = paste0('rs_ndvi_kmeans_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
png(plot.store, width = 10, height = 8, units = "in", res = 300)
par(mar = c(10.8, 5, 10.8, 2), mfrow = c(1, 2))
plot(ndvi, col = rev(terrain.colors(10)), main = "NDVI", zlim = c(-0.5,1))
plot(st_geometry(percelen_sf), add=TRUE)
plot(gi_km, main = "Kmeans", col = viridis_pal(option = "D")(k))
dev.off()

#panel plot NVDI and Clara
plot.nme = paste0('rs_ndvi_clara_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
png(plot.store, width = 10, height = 8, units = "in", res = 300)
par(mar = c(10.8, 5, 10.8, 2), mfrow = c(1, 2))
plot(ndvi, col = rev(terrain.colors(10)), main = "NDVI", zlim = c(-0.5,1))
plot(st_geometry(percelen_sf), add=TRUE)
plot(gi_cl, main = "Clara", col = viridis_pal(option = "C")(k))
dev.off()

#panel plot Kmeans and Clara
plot.nme = paste0('rs_kmeans_clara_',neighbourhood,'.png')
plot.store <-paste0(plots.dir,plot.nme)
png(plot.store, width = 10, height = 8, units = "in", res = 300)
par(mar = c(10.8, 5, 10.8, 2), mfrow = c(1, 2))
plot(gi_km, main = "Kmeans", col = viridis_pal(option = "D")(k))
plot(gi_cl, main = "Clara", col = viridis_pal(option = "C")(k))
dev.off()


#-----------------------------------------------------------------------------------------------

