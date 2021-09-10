
#-----------------------------------------------------------------------------------------------

#Fragmentation analysis (on unsupervised classes)

#-----------------------------------------------------------------------------------------------

#UNDER CONSTRUCTION

library(landscapemetrics)

clus_metrics<-calculate_lsm(veg_clus, level = "class")
#clus_metrics_agg <- calculate_lsm(veg_clus, level = c("class", "landscape"), type = "aggregation metric")

#show_patches(veg_clus)
