
#-----------------------------------------------------------------------------------------------

# Vegetation plots

#-----------------------------------------------------------------------------------------------

message("\nvegetation plots")
#plot function resides in FUNC>green indices

#-----------------------------------------------------------------------------------------------
# Breaks and steps for NDVI

ndvi_min <- round(ndvi@data@min,1)
ndvi_max <- round(ndvi@data@max,1)

brks_ndvi <- seq(ndvi_min, ndvi_max, by=0.1)
cols_terrain <- rev(terrain.colors((length(brks_ndvi)-1)))

#-----------------------------------------------------------------------------------------------
alpha<-255
#plot ndvi
plotting_terra(ai_tuinen,ndvi,"NDVI","rs_ndvi",brks_ndvi,brks_ndvi,cols_terrain,alpha)

#plot vegetation
plotting_terra(ai_tuinen,veg_g,"vegetation","rs_vegetation",NULL,NULL,cols_terrain,alpha)

#plot substantial vegetation
brks_sv <- seq(0.3, ndvi_max, by=0.1)
cols_green<- rev(colorspace::sequential_hcl((length(brks_sv) - 1), palette = "Greens"))

plotting_terra(ai_tuinen,veg_s,"substantial vegetation","rs_vegetation_substantial",brks_sv,brks_sv,cols_green,alpha)

#plot unsupervised clusters
if(unsup_cl==TRUE) {
  brks_clu <- seq(1, k, by=1)
  cols_viridis<- colorspace::sequential_hcl(max(brks_clu), palette = "Viridis")

  plotting_terra(ai_tuinen,veg_clus,"NDVI classes (unsupervised)","rs_vegetation_class_unsupervised",brks_clu,brks_clu,cols_viridis,alpha)
}

#plot fixed classes
brks_clf <- seq(1, 5, by=1)
cols_viridis<- colorspace::sequential_hcl(max(brks_clf), palette = "Viridis")
labels_clf=c("water","sand/stone","grasses/weed","low veg.","dense veg.")

plotting_terra(ai_tuinen,veg_c,"NDVI classes (fixed)","rs_vegetation_class_fixed",brks_clf,labels_clf,cols_viridis,alpha)

#plot ndvi and vegetation contour
png(paste0(plots.loc,"rs_ndvi_vegetation_contours_",neighbourhood,".png"), height = 1280, width = 1280, res = 180, units = "px")
par(col.lab = "white", tck = 0,mar = c(1,1,1,1))
plot(ndvi, axes=FALSE, box=FALSE, legend=TRUE, cex = 0.5, breaks=brks_ndvi, lab.breaks=brks_ndvi, col=cols_terrain,na.value ="transparent",
     main=paste0("NDVI and vegetation contour ", neighbourhood))
plot(veg_contour, add=TRUE, lwd = 0.1)
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
dev.off()


#-----------------------------------------------------------------------------------------------

#plot rvi
if(rvi_calc==TRUE) {
rvi_min <- round(rvi@data@min,1)
rvi_max <- round(rvi@data@max,1)

brks_rvi <- seq(rvi_min, rvi_max, by=0.5)
cols_terrain <- rev(terrain.colors((length(brks_rvi)-1)))

plotting_terra(ai_tuinen,rvi,"RVI","rs_rvi",brks_rvi,brks_rvi,cols_terrain)
}

#-----------------------------------------------------------------------------------------------

#plot tndvi
if(tndvi_calc==TRUE) {
  tndvi_min <- round(tndvi@data@min,1)
  tndvi_max <- round(tndvi@data@max,1)

  brks_tndvi <- seq(tndvi_min, tndvi_max, by=0.1)
  cols_terrain <- rev(terrain.colors((length(brks_tndvi)-1)))
plotting_terra(ai_tuinen,tndvi,"TNDVI","rs_tndvi",brks_tndvi,brks_tndvi,cols_terrain)
}

#-----------------------------------------------------------------------------------------------

#plot rmsavi2
if(msavi2_calc==TRUE) {
  msavi2_min <- round(msavi2@data@min,1)
  msavi2_max <- round(msavi2@data@max,1)

  brks_msavi2 <- seq(msavi2_min, msavi2_max, by=0.1)
  cols_terrain <- rev(terrain.colors((length(brks_msavi2)-1)))
plotting_terra(ai_tuinen,msavi2,"MSAVI2","rs_msavi2",brks_msavi2,brks_msavi2,cols_terrain)
}

#-----------------------------------------------------------------------------------------------

#plot evi2
if(evi2_calc==TRUE) {
  evi2_min <- round(evi2@data@min,1)
  evi2_max <- round(evi2@data@max,1)

  brks_evi2 <- seq(evi2_min, evi2_max, by=0.1)
  cols_terrain <- rev(terrain.colors((length(brks_evi2)-1)))
  plotting_terra(ai_tuinen,evi2,"EVI2","rs_evi2",brks_evi2,brks_evi2,cols_terrain)
}

#-----------------------------------------------------------------------------------------------

if(ahn_calc==TRUE) {

#vegetation (3m and above)
plotting_terra(ai_tuinen,veg_t3,"3m+ vegetation","rs_vegetation_3m",NULL,NULL,cols_terrain,255)

#trees (5m and above)
plotting_terra(ai_tuinen,veg_t5,"5m+ vegetation","rs_vegetation_5m",NULL,NULL,cols_terrain,255)
}

#Distribution of gardens over NDVI
png(paste0(plots.loc,"rs_tuinen_distribution_ndvi_freq_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio*2, height=png_height)
hist(tuinen_sf$ndvi_avg,
     #breaks=4,
     main = paste0("Distribution of tuinen over NDVI ",neighbourhood),
     xlab = "ndvi", ylab = "freq",
     col = "steelblue")
dev.off()


#-----------------------------------------------------------------------------------------------------------

#coverage of panden and tuinen (GGPLOT)
plotting_gg(tuinen_sf, "ndvi_green_avg", "mean NDVI", "rs_ndvi_mean_tuinen", "turbo", coord_tuinen )
plotting_gg(tuinen_sf, "green_cover", "green cover (%)", "rs_green_cover_tuinen", "viridis", coord_tuinen )
plotting_gg(tuinen_sf, "water_cover", "water cover (%)", "rs_water_cover_tuinen", "plasma", coord_tuinen )
plotting_gg(tuinen_sf, "stone_cover", "stone cover (%)", "rs_stone_cover_tuinen", "inferno", coord_tuinen )
plotting_gg(panden_sf, "green_cover", "green cover (%)", "rs_green_cover_woningen", "viridis", coord_panden )

#buurt
#plotting_gg_clean(buurt_sf, "green_cover_all", "green cover (%)", "rs_green_cover_buurt", "viridis")

#NDVI of crowns
if(crowns_trace==TRUE) {
plotting_gg_clean(crowns, "ndvi_avg", "mean NDVI", "rs_ndvi_mean_crowns", "turbo")
}


#-----------------------------------------------------------------------------------------------------------

#NDVI distribution
#png(paste0(plots.loc,"rs_ndvi_density_distribution_",neighbourhood,".png"))
#mplot_p1<-rasterVis::densityplot(ndvi)
#print(mplot_p1)
#dev.off()

#lattice-style levelplot NDVI
#png(paste0(plots.loc,"rs_ndvi_levelplot_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
#mplot_p2<-rasterVis::levelplot(ndvi)
#print(mplot_p2)
#dev.off()

#distribution of gardens over NDVI
plotting_gg_dist(tuinen_sf, "ndvi_avg", "NDVI", "rs_tuinen_distribution_ndvi",0.08)

#distribution of crowns over NDVI
plotting_gg_dist(crowns_polygon, "ndvi_avg", "NDVI", "rs_crowns_distribution_ndvi",0.08)

if(report_tuinen==TRUE) {
#distribution of gardens over vegetation coverage
plotting_gg_dist(tuinen_sf, "green_cover", "vegetation cover tuinen on woonperceel", "rs_tuinen_distribution_vegetation_coverage",20)
} else {
plotting_gg_dist(buurt_sf, "green_cover", "vegetation buurt", "rs_buurt_distribution_vegetation_coverage",20)
}
#distribution of woningen over vegetation coverage
plotting_gg_dist(panden_sf, "green_cover", "vegetation cover panden on woonperceel", "rs_woningen_distribution_vegetation_coverage", 20)


#Distribution of raster cell NDVI values
#png(paste0(plots.loc,"rs_ndvi_distibution_raster_cell_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio*2, height=png_height)
#hist(ndvi,main = paste0("Distribution NDVI values over raster cells ",neighbourhood),
#     xlab = "ndvi", ylab = "cells",col = "steelblue")
#dev.off()


#-----------------------------------------------------------------------------------------------------------

cols_ahn<-rev(hcl.colors(20, "YlOrRd"))

#ahn buurt
plotting_terra(ai_buurt,ahn_buurt,"AHN buurt (m)","rs_ahn_buurt",NULL,NULL,cols_ahn,alpha)

if(report_tuinen==TRUE) {
#ahn tuinen
plotting_terra(ai_buurt,ahn_tuinen,"AHN tuinen (m)","rs_ahn_tuinen",NULL,NULL,cols_ahn,alpha)
}

#-----------------------------------------------------------------------------------------------------------

if(tree_trace==TRUE) {
#tree tops
png(paste0(plots.loc,"rs_trees_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180, units="px")
par(col.lab = "white", tck = 0,mar = c(1,1,1,1))
aerial_rgb <- terra::plotRGB(ai_buurt,
                             r = 1, g = 2, b = 3,
                             stretch = "lin",
                             alpha=alpha,#hide (0), show(255)
                             axes = TRUE,
                             main = paste0("AHN buurt (m) and tree tops (5m+) ", neighbourhood))
plot(ahn_buurt, add=TRUE, legend=FALSE, col= cols_ahn)
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
#plot(crowns, add=TRUE, legend=FALSE, col=cols_viridis)
plot(ttops, add=TRUE, legend=TRUE)
box(col = "white")
#aerial_rgb
plot(cntrd_perceel, col = 'blue', add = TRUE, cex = .5)
text(1.5, 150, paste("Tree count = ", trees_n), pos = 4)
dev.off()
}

if(crowns_trace==TRUE) {
# crowns
cols_rainbow<- sample(rainbow(50), length(unique(crowns[])), replace = TRUE)
plotting_base(ai_buurt,crowns, "tree crowns", "rs_crown_tops",NULL,NULL,cols_rainbow)

#distrubution of crowns over ndvi
plotting_gg_dist(crowns, "ndvi_avg", "distribution of crowns over NDVI", "rs_crowns_distribution_ndvi", 0.1)


}

rm(list=ls(pattern="^mplot_"))
rm(list=setdiff(ls(pattern = "^mplot_"), lsf.str()))
