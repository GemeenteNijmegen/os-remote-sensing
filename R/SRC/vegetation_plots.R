
#-----------------------------------------------------------------------------------------------

# Vegetation plots

#-----------------------------------------------------------------------------------------------

message("vegetation plots")
#plot function resides in FUNC>green indices

#-----------------------------------------------------------------------------------------------
# Breaks and steps for NDVI

ndvi_min <- round(ndvi@data@min,1)
ndvi_max <- round(ndvi@data@max,1)

brks_ndvi <- seq(ndvi_min, ndvi_max, by=0.1)
cols_terrain <- rev(terrain.colors((length(brks_ndvi)-1)))

#-----------------------------------------------------------------------------------------------

#plot ndvi
plotting_terra(ai_tuinen,ndvi,"NDVI","rs_ndvi",brks_ndvi,brks_ndvi,cols_terrain)

#plot vegetation
plotting_terra(ai_tuinen,veg_g,"vegetation","rs_vegetation",NULL,NULL,cols_terrain)

#plot substantial vegetation
brks_sv <- seq(0.3, ndvi_max, by=0.1)
cols_green<- rev(colorspace::sequential_hcl((length(brks_sv) - 1), palette = "Greens"))

plotting_terra(ai_tuinen,veg_s,"substantial vegetation","rs_vegetation_substantial",brks_sv,brks_sv,cols_green)

#plot unsupervised clusters
if(unsup_cl==TRUE) {
  brks_clu <- seq(1, k, by=1)
  cols_viridis<- colorspace::sequential_hcl(max(brks_clu), palette = "Viridis")

  plotting_terra(ai_tuinen,veg_clus,"NDVI classes (unsupervised)","rs_vegetation_class_unsupervised",brks_clu,brks_clu,cols_viridis)
}

#plot fixed classes
brks_clf <- seq(1, 5, by=1)
cols_viridis<- colorspace::sequential_hcl(max(brks_clf), palette = "Viridis")
labels_clf=c("water","sand/stone","grasses/weed","low veg.","dense veg.")

plotting_terra(ai_tuinen,veg_c,"NDVI classes (fixed)","rs_vegetation_class_fixed",brks_clf,labels_clf,cols_viridis)

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
rvi_min <- round(rvi@data@min,1)
rvi_max <- round(rvi@data@max,1)

brks_rvi <- seq(rvi_min, rvi_max, by=0.5)
cols_terrain <- rev(terrain.colors((length(brks_rvi)-1)))

plotting_terra(ai_tuinen,rvi,"RVI","rs_rvi",brks_rvi,brks_rvi,cols_terrain)

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
plotting_terra(ai_tuinen,veg_t3,"3m+ vegetation","rs_rgb_veg_3m",NULL,NULL,cols_terrain)

#trees (5m and above)
plotting_terra(ai_tuinen,veg_t5,"5m+ vegetation","rs_rgb_veg_5m",NULL,NULL,cols_terrain)
}

#Distribution of gardens over NDVI
png(paste0(plots.loc,"rs_garden_distribution_ndvi_freq_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio*2, height=png_height)
hist(tuinen_sf$ndvi_avg,
     #breaks=4,
     main = paste0("Distribution of gardens over NDVI ",neighbourhood),
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

#-----------------------------------------------------------------------------------------------------------

#NDVI distribution
png(paste0(plots.loc,"rs_ndvi_density_distribution_",neighbourhood,".png"))
mplot_p1<-rasterVis::densityplot(ndvi)
print(mplot_p1)
dev.off()

#lattice-style levelplot NDVI
png(paste0(plots.loc,"rs_ndvi_levelplot_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
mplot_p2<-rasterVis::levelplot(ndvi)
#+ latticeExtra::layer(sp.polygons(percelen_sf, col="white", lwd=0.2))
print(mplot_p2)
dev.off()

#distribution of gardens over NDVI
ggplot(tuinen_sf, aes(x = ndvi_avg)) +
  geom_histogram(aes(y = (..count..)/sum(..count..)), binwidth = 0.08,color="lightblue", fill="steelblue") +
  stat_bin(aes(y=(..count..)/sum(..count..),
               label=paste0(round((..count..)/sum(..count..)*100,1),"%")),
           geom="text", size=4, binwidth = 0.08, vjust=-1.5) +
  #scale_x_continuous(breaks = seq(0.2,0.8,0.1))+
  labs(x = "NDVI", y = "%") +
  theme_light()
plot.nme = paste0('rs_gardens_distribution_ndvi_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

#distribution of gardens over vegetation coverage
ggplot(tuinen_sf, aes(x = green_cover)) +
  geom_histogram(aes(y = (..count..)/sum(..count..)), binwidth = 20,color="lightblue", fill="steelblue") +
  stat_bin(aes(y=(..count..)/sum(..count..),
               label=paste0(round((..count..)/sum(..count..)*100,1),"%")),
           geom="text", size=4, binwidth = 20, vjust=-1.5) +
  #scale_x_continuous(breaks = seq(0.2,0.8,0.1))+
  labs(x = "% vegetation cover tuinen on woonperceel", y = "%") +
  theme_light()
plot.nme = paste0('rs_gardens_distribution_vegetation_coverage_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

#distribution of woningen over vegetation coverage
ggplot(panden_sf, aes(x = green_cover)) +
  geom_histogram(aes(y = (..count..)/sum(..count..)), binwidth = 20,color="lightblue", fill="steelblue") +
  stat_bin(aes(y=(..count..)/sum(..count..),
               label=paste0(round((..count..)/sum(..count..)*100,1),"%")),
           geom="text", size=4, binwidth = 20, vjust=-1.5) +
  #scale_x_continuous(breaks = seq(0.2,0.8,0.1))+
  labs(x = "% vegetation cover panden on woonperceel", y = "%") +
  theme_light()
plot.nme = paste0('rs_woningen_distribution_vegetation_coverage_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

rm(list=ls(pattern="^mplot_"))
rm(list=setdiff(ls(pattern = "^mplot_"), lsf.str()))
