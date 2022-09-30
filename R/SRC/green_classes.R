
#-----------------------------------------------------------------------------------------------

# Green classes (unsupervised classification)

#-----------------------------------------------------------------------------------------------

message("\nunsupervised classification of NDVI")

ndvi_subset <- ndvi
#class(ndvi_subset)

# NDVI scores greater than or equal to 0.2 are considered vegetation
ndvi_subset[ndvi_subset<0.2] <- NA

# convert the RasterLayer to array
ndvi_array <- values(ndvi_subset)

i <- !is.na(ndvi_array)
set.seed(99)
kmncluster <- kmeans(ndvi_array[i], centers = k, iter.max = 500, nstart = 5, algorithm="Lloyd")

ndvi_array[i] <- kmncluster$cluster
knr <- setValues(ndvi, ndvi_array)

#-----------------------------------------------------------------------------------------------
#garbage collecting

rm(ndvi_subset)
