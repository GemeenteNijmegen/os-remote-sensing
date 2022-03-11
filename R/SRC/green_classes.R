
#-----------------------------------------------------------------------------------------------

# Green classes (unsupervised classification)

#-----------------------------------------------------------------------------------------------

message("\nunsupervised classification of NDVI")

ndvi_subset <- ndvi
#class(ndvi_subset)

# NDVI scores greater than or equal to 0.2 are considered vegetation
ndvi_subset@data@values[ndvi_subset@data@values < 0.2] <- NA

# convert the RasterLayer to array
ndvi_array <- getValues(ndvi_subset)

# keep valid observations only
p <- which(!is.na(ndvi_array))
ndvi_valid_array <- ndvi_array[p]

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
gi_km <- ndvi_subset

## replace raster cell values with km$cluster
# array
gi_km[]  <- NA
gi_km[p] <- km$cluster

#-----------------------------------------------------------------------------------------------
# boxplots
tmp <- data.frame(ndvi = ndvi[], gi = gi_km[])

tmp$gi <- factor(tmp$gi)
ndvi_cluster <- Rmisc::summarySE(tmp, measurevar = "ndvi", groupvars = c("gi"))
ndvi_cluster$ndvi <- round(ndvi_cluster$ndvi, digits = 2)
ndvi_cluster <- ndvi_cluster[complete.cases(ndvi_cluster), ]

plot.title = paste0('NDVI cluster boundaries')
ggplot(ndvi_cluster, aes(x = gi, y = ndvi)) +
  #geom_bar(position=position_dodge(), stat="identity", fill="steelblue") +
  geom_text(aes(label = ndvi), vjust = 1.6, color = "black", size = 3.5)+
  geom_errorbar(aes(ymin = ndvi-se, ymax = ndvi+se),
                width = 0.2,                    # Width of the error bars
                position = position_dodge(0.9)) +
  xlab("Cluster")+
  ylab("NDVI") +
  theme_light()
plot.nme = paste0('NDVI_cluster_boundaries_unsupervised.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)


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

#-----------------------------------------------------------------------------------------------
#garbage collecting

rm(tmp, gi_km, ndvi_subset)
