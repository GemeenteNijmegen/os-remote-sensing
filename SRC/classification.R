
#-----------------------------------------------------------------------------------------------

# Unsupervised classification

#-----------------------------------------------------------------------------------------------

#number of clusters
k <- 10

# convert the raster to vector/matrix ('getValues' converts the RasterLAyer to array) )
nvdi_array <- getValues(ndvi)
#length(nvdi_array)
#keep valid observations only
i <- which(!is.na(nvdi_array))
nvdi_valid_array <- nvdi_array[i]
str(nvdi_valid_array)
#length(nvdi_valid_array)
#-----------------------------------------------------------------------------------------------
#Kmeans clustering

# # to reduce the computational time, we use 10% of the data. 
# nvdi_valid_array_sub <- sample(nvdi_valid_array, size = length(nvdi_valid_array)/10, replace = FALSE)
# par(mfrow = c(1,2))
# hist(nvdi_valid_array)
# hist(nvdi_valid_array_sub)
# 
# # number of starts and iter.max has almost no effect on the result
# k.max <- 15
# data <- nvdi_valid_array_sub
# wss <- sapply(1:k.max, 
#               function(k) { kmeans(data, k, nstart = 5, iter.max = 500,
#                                  algorithm = "Lloyd")$tot.withinss 
#                 }
#               )
# wss
# plot(1:k.max, wss,
#      type = "b", pch = 19, frame = FALSE, 
#      xlab = "Number of clusters K",
#      ylab = "Total within-clusters sum of squares")
# 


## first, we differentiate between vegi and non-vegi
## If we make 2 clusters, some bare plain is incorrectly specified als non-vegi.
# create k clusters, allow 500 iterations, start with 5 random sets using 'Lloyd' method
km <- kmeans(nvdi_valid_array, centers = 3, iter.max = 200,
             nstart = 5, algorithm = "Lloyd")

centers <- km$centers

# order the centers
centers <- sort(centers)
# call kmeans again but this time passing the centers calculated in the previous step
km <- kmeans(nvdi_valid_array, centers = centers)

#Copy ndvi layer
gi_km <- ndvi

# replace raster cell values with km$cluster
# array
gi_km[] <- NA
gi_km[i] <- km$cluster
#table(gi_km[])

par(mfrow = c(1,2))
aerial_rgb<-plotRGB(ai_crop,
                    r = 1, g = 2, b = 3,
                    #stretch the values to increase the contrast of the image
                    stretch = "lin",
                    #axes = TRUE,
                    main = paste0("composite image stack ", neighbourhood))
plot(gi_km, main = "Kmeans", col = viridis_pal(option = "D")(k))


# all clusters classified as 1 are assumed to be non-vegi
tmp <- data.frame(ndvi = ndvi[], gi = gi_km[])
rng_novegi <- range(tmp$ndvi[tmp$gi == 1], na.rm = TRUE)


## second, remove ndvi scores which are non-vegi (e.g., streets, concreat, etc...)
gi2_km <- ndvi
gi2_km[][gi2_km[] < max(rng_novegi)] <- NA

gi2_km_array <- getValues(gi2_km)
i2 <- which(!is.na(gi2_km_array))
gi2_km_valid_array <- gi2_km_array[i2]

# redo clustering on vegi only ndvi scores
# The numbers of clusters still needs some tweaking.
km_vegi <- kmeans(gi2_km_valid_array, centers = 5, iter.max = 200,
                  nstart = 5, algorithm = "Lloyd")

km_vegi
centers_vegi <- km_vegi$centers
# order the centers
centers_vegi <- sort(centers_vegi)
# call kmeans again but this time passing the centers calculated in the previous step
km_vegi <- kmeans(gi2_km_valid_array, centers = centers_vegi)

gi2_km[] <- NA
gi2_km[i2] <- km_vegi$cluster

#tmp2 <- data.frame(ndvi = ndvi[], gi = gi2_km[])
# ( rng_vegi1 <- range(tmp2$ndvi[tmp$gi == 1], na.rm = TRUE) )
# ( rng_vegi2 <- range(tmp2$ndvi[tmp$gi == 2], na.rm = TRUE) )
# ( rng_vegi3 <- range(tmp2$ndvi[tmp$gi == 3], na.rm = TRUE) )


# -------------------------------------------------------------------------

par(mfrow = c(1,2))
aerial_rgb<-plotRGB(ai_crop,
                    r = 1, g = 2, b = 3,
                    #stretch the values to increase the contrast of the image
                    stretch = "lin",
                    axes = TRUE,
                    main = paste0("composite image stack ", neighbourhood))
plot(gi2_km, main = "Kmeans", col = viridis_pal(option = "D")(k))


#-----------------------------------------------------------------------------------------------
## Clara classification (Clustering for Large Applications) 
k <- 4
cl <- clara(nvdi_valid_array, k, samples = 500, metric = "manhattan", pamLike = TRUE)
#clara returns an object of class 'clara'
cl$clusinfo
str(cl)
#plot(cl)

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
plotRGB(aerial_rgb, axes = TRUE, stretch = "lin", main = "RGB")
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

