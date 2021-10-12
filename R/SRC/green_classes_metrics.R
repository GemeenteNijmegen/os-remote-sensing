
#-----------------------------------------------------------------------------------------------

#Metrics for unsupervised NDVI clusters

#-----------------------------------------------------------------------------------------------

message("Metrics for unsupervised NDVI clusters")

#cluster plot of the unsupervised procedure is available in the PLOTS directory
#rs_rgb_veg_classes_unsupervised_BUXXXXXXX.png

#https://cran.r-project.org/web/packages/landscapemetrics/landscapemetrics.pdf

#full list of metrics
#metrics_names<-lsm_abbreviations_names
#view(metrics_names)

#relevant metrics in this research

#lsm_c_ca (oppervlakte)
#Total (class) area (Area and edge metric) (ha)

#lsm_c_contig_mn (samenhangendheid)
#Mean of Contiguity index

#lsm_c_enn_mn (nabijheid)
#Mean of euclidean nearest-neighbor distance (m)

#lsm_l_division (versnippering)
#Landscape division index

#lsm_l_pd (dichtheid)
#patch density

#metrics for class (c) and landscape (l) (neighbourhood)

metrics_lst <- c("lsm_c_ai", # aggregation index
  "lsm_c_ca", # total class area (in hectares)
  "lsm_c_contig_mn", #contiguity index
  "lsm_c_enn_mn", #euclidean nearest neighbor distance (in meters)
  "lsm_l_division",# division index
  "lsm_l_pd" #patch density
)

#number of metrics
metrics_lst_length<-length(metrics_lst)

metrics_class<-calculate_lsm(veg_clus,what=metrics_lst)
#long to wide dataframe (spread)
metrics_class_s<-spread(metrics_class[,c(1:metrics_lst_length)],key =metric,value = value)

#total class area: convert hectares to square meters
metrics_class_s$ca<-metrics_class_s$ca*10000

head(metrics_class_s)

#store metrics
write.csv(metrics_class_s,file=paste(report.loc,"Buurt_unsupervised_clusters_statistieken_",neighbourhood,".csv"))

#-----------------------------------------------------------------------------------------------
#plot clusters

#show_patches(veg_clus,
             #in case of 5 classes, we choose relevant classes (vegie-wise)
             #class = c(2, 3, 4, 5)
#             )

#largest patches
#show_lsm(veg_clus,labels = F,class = 5,what = "lsm_p_area")
