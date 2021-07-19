
#-----------------------------------------------------------------------------------------------

# Green classes (unsupervised classification)

#-----------------------------------------------------------------------------------------------


# ndvi scores greater than 0.25455043 are considered high quality vegi. 
ndvi@data@values[ndvi@data@values <= 0.25455043] <- NA


# convert the raster to vector/matrix ('getValues' converts the RasterLAyer to array) )
ndvi_array <- getValues(ndvi)

# keep valid observations only
i <- which(!is.na(ndvi_array))
ndvi_valid_array <- ndvi_array[i]

## this is where the magic happens
# number of clusters
k <- 5
km <- kmeans(ndvi_valid_array, centers = k, iter.max = 200,
             nstart = 5, algorithm = "Lloyd")

# extract cluster means
centers <- km$centers

# order the cluster means
centers <- sort(centers)

# call kmeans again but this time passing the centers calculated in the previous 
# step. In this way the results is neatly ordered.
km <- kmeans(ndvi_valid_array, centers = centers)
#table(km$cluster)

# Copy ndvi layer
gi_km <- ndvi

## replace raster cell values with km$cluster
# array
gi_km[]  <- NA
gi_km[i] <- km$cluster

# boxplots cluster result
tmp <- data.frame(ndvi = ndvi[], gi = gi_km[])

tmp$gi <- factor(tmp$gi)
ndvi_cluster <- Rmisc::summarySE(tmp, measurevar = "ndvi", groupvars = c("gi"))
ndvi_cluster$ndvi <- round(ndvi_cluster$ndvi, digits = 2)
ndvi_cluster <- ndvi_cluster[complete.cases(ndvi_cluster), ]

plot.title = paste0('NDVI cluster boundaries')
ggplot(ndvi_cluster, aes(x = gi, y = ndvi)) + 
  geom_bar(position=position_dodge(), stat="identity", fill="steelblue") +
  geom_text(aes(label = ndvi), vjust = 1.6, color = "black", size = 3.5)+
  geom_errorbar(aes(ymin = ndvi-se, ymax = ndvi+se),
                width = 0.2,                    # Width of the error bars
                position = position_dodge(0.9)) +
  xlab("Cluster")+
  ylab("NDVI") +
  theme_minimal() 
  plot.nme = paste0('NDVI_cluster_boundaries.png')
plot.store <-paste0(plots.dir,plot.nme)
ggsave(plot.store, height = graph_height , width = graph_height * aspect_ratio, dpi=dpi)

# create list with upper-bounds per cluster
rng_list <- list()
for (c in 1:k) {
  rng_list[[c]] <- max(range(tmp$ndvi[tmp$gi == c], na.rm = TRUE) )
}

# reclassifying nvdi into clusters
veg_clus <- raster::reclassify(ndvi, c(-Inf, rng_list[[1]], 1,   
                                   rng_list[[1]], rng_list[[2]], 2,
                                   rng_list[[2]], rng_list[[3]], 3,  
                                   rng_list[[3]], rng_list[[4]], 4,
                                   rng_list[[4]], Inf, 5))

rm(tmp)