
#-----------------------------------------------------------------------------------------------

# Vegetation plots

#-----------------------------------------------------------------------------------------------

message("vegetation plots")

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

#-----------------------------------------------------------------------------------------------
#raster data

# plot NDVI
mplot_ndvi <- rasterVis::gplot(ndvi) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225)), na.value ="transparent", limits = c(-0.5,1)) +
  #geom_sf(aes(st_sf(st_geometry(tuinen_sf)))) +
  theme_void() +
  coord_fixed() +
  theme(legend.position = "bottom") +
labs(fill = "NDVI")
plot.nme = paste0('rs_ndvi_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

if(evi2_calc==TRUE) {
# plot EVI2
mplot_evi2 <- rasterVis::gplot(evi2) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225)), na.value ="transparent") +
  #geom_sf(aes(st_sf(st_geometry(tuinen_sf)))) +
  theme_minimal() +
  coord_fixed() +
  theme(legend.position = "bottom") +
  labs(fill = "EVI2")
plot.nme = paste0('rs_evi2_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)


}

# plot RVI
mplot_rvi <- rasterVis::gplot(rvi) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225)), na.value ="transparent") +
  #geom_sf(aes(st_sf(st_geometry(tuinen_sf)))) +
  theme_minimal() +
  coord_fixed() +
  theme(legend.position = "bottom") +
  labs(fill = "RVI")
plot.nme = paste0('rs_rvi_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

# plot vegetation classes (fixed)
mplot_veg_c <- rasterVis::gplot(veg_c) +
  geom_tile(aes(fill = as.factor(value))) +
  #scale_fill_gradientn(colours = rev(terrain.colors(5)), na.value ="transparent") +
  scale_fill_discrete_sequential(palette = "Terrain") +
  theme_void() +
  coord_fixed() +
  theme(legend.position = "bottom") +
  labs(fill = "NDVI classes (fixed)")
plot.nme = paste0('rs_ndvi_classes_fixed_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

# plot vegetation classes (unsupervised)
mplot_veg_clus <- rasterVis::gplot(veg_clus) +
  geom_tile(aes(fill = as.factor(value))) +
  #scale_fill_gradientn(colours = rev(terrain.colors(5)), na.value ="transparent") +
  scale_fill_discrete_sequential(palette = "Terrain") +
  theme_void() +
  coord_fixed() +
  theme(legend.position = "bottom") +
  labs(fill = "NDVI classes (unsupervised)")
plot.nme = paste0('rs_ndvi_classes_unsupervised_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

# plot substantial green
mplot_veg_s <- rasterVis::gplot(veg_s) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225)), na.value ="transparent",limits = c(0.4,1)) +
  theme_minimal() +
  coord_fixed() +
  theme(legend.position = "bottom") +
  labs(fill = "NDVI")
plot.nme = paste0('rs_ndvi_substantial_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

rm(list=ls(pattern="^mplot_"))
rm(list=setdiff(ls(pattern = "^mplot_"), lsf.str()))

#-----------------------------------------------------------------------------------------------
# white background

ndvi_min <- round(ndvi@data@min,1)
ndvi_max <- round(ndvi@data@max,1)+0.1

#breaks NDVI grey to green
brks <- seq(ndvi_min, ndvi_max, by=0.1)
cols <- rev(terrain.colors((length(brks) - 1)))

#plot ndvi and vegetation contour
png(paste0(plots.loc,"rs_ndvi_raw_vegetation_contours_",neighbourhood,".png"), height = 1280, width = 1280, res = 180, units = "px")
par(col.lab = "white", tck = 0,mar = c(1,1,1,1))
plot(ndvi, axes=FALSE, box=FALSE, legend=TRUE, cex = 0.5, breaks=brks, lab.breaks=brks, col=cols,na.value ="transparent",
     main=paste0("NDVI and vegetation contour ", neighbourhood))
plot(veg_contour, add=TRUE, lwd = 0.1)
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
dev.off()

#plot rgb and ndvi
png(paste0(plots.loc,"rs_rgb_ndvi_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
par(col.lab = "white", tck = 0,mar = c(1,1,1,1))
terra::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("NDVI ", neighbourhood))
plot(ndvi, add=TRUE, legend=TRUE, cex = 0.5, breaks=brks, lab.breaks=brks, col=cols,na.value ="transparent")
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#plot rgb and tndvi
if(tndvi_calc==TRUE) {
png(paste0(plots.loc,"rs_rgb_tndvi_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
par(col.lab = "white", tck = 0,mar = c(1,1,1,1))
terra::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("TNDVI ", neighbourhood))
plot(tndvi, add=TRUE, legend=TRUE, cex = 0.5, col=cols,na.value ="transparent")
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()
}

#plot rgb and msavi2
if(msavi2_calc==TRUE) {
png(paste0(plots.loc,"rs_rgb_msavi2_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
par(col.lab = "white", tck = 0,mar = c(1,1,1,1))
terra::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("MSAVI2 ", neighbourhood))
plot(msavi2, add=TRUE, legend=TRUE, cex = 0.5, col=cols,na.value ="transparent")
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()
}

#plot rgb and vegetation
png(paste0(plots.loc,"rs_rgb_vegetation_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
par(col.axis = "white", col.lab = "white", tck = 0,mar = c(1,1,1,1))
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("vegetation (NDVI >=.2) ", neighbourhood))
plot(veg_g, add=TRUE, legend=FALSE)
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#breaks NDVI lightgreen to darkgreen
brks <- seq(0.3, ndvi_max, by=0.1)
cols<- rev(colorspace::sequential_hcl((length(brks) - 1), palette = "Greens"))

#plot rgb and substantial green
png(paste0(plots.loc,"rs_rgb_veg_substantial_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
par(col.lab = "white", tck = 0,mar = c(1,1,1,1))
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',alpha=0,main=paste0("substantial vegetation (NDVI >=.3) ", neighbourhood))
plot(veg_s, add=TRUE, legend=TRUE, cex = 2, breaks=brks, lab.breaks=brks, col=cols, na.value ="grey")
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#breaks NDVI clusters
brks <- seq(1, k, by=1)
cols<- colorspace::sequential_hcl(max(brks), palette = "Viridis")

#plot rgb and classes (unsupervised)
png(paste0(plots.loc,"rs_rgb_veg_classes_unsupervised_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
par(col.lab = "white", tck = 0,mar = c(1,1,1,1))
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("NDVI classes (unsupervised) ", neighbourhood))
plot(veg_clus, add=TRUE, legend=TRUE, cex = 0.5, breaks=brks, lab.breaks=brks, col=cols,na.value ="transparent")
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#breaks NDVI grey to green
brks <- seq(1, 5, by=1)
cols<- colorspace::sequential_hcl(max(brks), palette = "Viridis")
lab_args <- list(at=c(1,2,3,4,5), labels=c("water","sand/stone","grasses/weed","low veg.","dense veg."))

#plot rgb and classes (fixed)
png(paste0(plots.loc,"rs_rgb_veg_classes_fixed_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
par(col.lab = "white", tck = 0,mar = c(1,1,1,1))
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("NDVI classes (fixed) ", neighbourhood))
plot(veg_c, add=TRUE, legend=TRUE, cex = 0.5, breaks=brks, lab.breaks=brks, col=cols,na.value ="transparent", axis.args=lab_args)
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#breaks RVI grey to green
rvi_min <- round(rvi@data@min,1)
rvi_max <- round(rvi@data@max,1)

brks <- seq(rvi_min, rvi_max, by=0.5)
cols <- rev(terrain.colors((length(brks) - 1)))

#plot RVI
png(paste0(plots.loc,"rs_rvi_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
par(col.lab = "white", tck = 0,mar = c(1,1,1,1))
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0("RVI ", neighbourhood))
plot(rvi, add=TRUE, legend=TRUE, cex = 0.5, breaks=brks, lab.breaks=brks, col=cols,na.value ="transparent")
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

if(ahn_calc==TRUE) {
#vegetation (3m and above)
png(paste0(plots.loc,"rs_rgb_veg_3m_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
par(col.axis = "white", col.lab = "white", tck = 0,mar = c(1,1,1,1))
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin", colNA='transparent', alpha=0,#hide (0), show(255)
                main=paste0("3m+ vegetation ", neighbourhood))
plot(veg_t3, add=TRUE, legend=FALSE)
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()

#trees (5m and above)
png(paste0(plots.loc,"rs_rgb_veg_5m_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
par(col.axis = "white", col.lab = "white", tck = 0,mar = c(1,1,1,1))
raster::plotRGB(ai_tuinen, r=1, g=2, b=3, axes=TRUE, stretch="lin", colNA='transparent', alpha=0,#hide (0), show(255)
                main=paste0("5m+ vegetation (trees) ", neighbourhood))
plot(veg_t5, add=TRUE, legend=FALSE)
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()
}

#mean NVDI garden
ggplot(data = tuinen_sf) +
  geom_sf(aes(fill = ndvi_avg)) +
  scale_fill_viridis_c(option = "turbo", direction = 1,name = "mean NDVI") +
  #scale_fill_continuous_diverging(palette = "qz_ndvi") +
  geom_point(size = 0.4, aes(x = coord_tuinen$X,y = coord_tuinen$Y), colour="white", shape = 15) +
  geom_text(
    aes(
      label = tuinen_sf$ndvi_avg,
      x = coord_tuinen$X,
      y = coord_tuinen$Y
    ),
    colour = "black",
    size = 1.9,hjust = 0, nudge_x = 0.07
  ) +
  xlab("Longitude") + ylab("Latitude") +
  theme_void()
plot.nme = paste0('NDVI_mean_garden.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=320)

#mean NVDI for vegetation in garden
ggplot(data = tuinen_sf) +
  geom_sf(aes(fill = ndvi_green_avg)) +
  scale_fill_viridis_c(option = "turbo", direction = 1,name = "mean NDVI") +
  geom_point(size = 0.4, aes(x = coord_tuinen$X,y = coord_tuinen$Y), colour="white", shape = 15) +
  geom_text(
    aes(
      label = tuinen_sf$ndvi_green_avg,
      x = coord_tuinen$X,
      y = coord_tuinen$Y
    ),
    colour = "black",
    size = 1.9,hjust = 0, nudge_x = 0.07
  ) +
  xlab("Longitude") + ylab("Latitude") +
  theme_void()
plot.nme = paste0('NDVI_mean_vegetation_garden.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=320)

#Distribution of gardens over NDVI
png(paste0(plots.loc,"rs_garden_distibution_ndvi_freq_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio*2, height=png_height)
hist(tuinen_sf$ndvi_avg,
     #breaks=4,
     main = paste0("Distribution of gardens over NDVI ",neighbourhood),
     xlab = "ndvi", ylab = "freq",
     col = "steelblue")
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
plot.nme = paste0('rs_gardens_distibution_ndvi_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

#green coverage of gardens
ggplot(data = tuinen_sf) +
  geom_sf(aes(fill = ndvi_cover)) +
  scale_fill_viridis_c(option = "viridis", direction = 1,name = "green cover proportion") +
  geom_point(size = 0.4, aes(x = coord_tuinen$X,y = coord_tuinen$Y), colour="white", shape = 15) +
  geom_text(
    aes(
      label = tuinen_sf$green_cover,
      x = coord_tuinen$X,
      y = coord_tuinen$Y
    ),
    colour = "black",
    size = 2.2,hjust = 0, nudge_x = 0.07
  ) +
  xlab("Longitude") + ylab("Latitude") +
  theme_void()
plot.nme = paste0('green_coverage_garden.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=320)

#distribution of gardens over vegetation coverage
ggplot(tuinen_sf, aes(x = green_cover)) +
  geom_histogram(aes(y = (..count..)/sum(..count..)), binwidth = 20,color="lightblue", fill="steelblue") +
  stat_bin(aes(y=(..count..)/sum(..count..),
               label=paste0(round((..count..)/sum(..count..)*100,1),"%")),
           geom="text", size=4, binwidth = 20, vjust=-1.5) +
  #scale_x_continuous(breaks = seq(0.2,0.8,0.1))+
  labs(x = "% vegetation cover tuinen on woonperceel", y = "%") +
  theme_light()
plot.nme = paste0('rs_gardens_distibution_vegetation_coverage_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

#stoned coverage of gardens
ggplot(data = tuinen_sf) +
  geom_sf(aes(fill = stone_cover)) +
  scale_fill_viridis_c(option = "inferno", direction = 1,name = "stone cover proportion") +
  geom_point(size = 0.4, aes(x = coord_tuinen$X,y = coord_tuinen$Y), colour="white", shape = 15) +
  geom_text(
    aes(
      label = tuinen_sf$stone_cover,
      x = coord_tuinen$X,
      y = coord_tuinen$Y
    ),
    colour = "black",
    size = 2.2,hjust = 0, nudge_x = 0.07
  ) +
  xlab("Longitude") + ylab("Latitude") +
  theme_minimal()
plot.nme = paste0('stone_coverage_garden.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=320)

#water coverage of gardens
ggplot(data = tuinen_sf) +
  geom_sf(aes(fill = water_cover)) +
  scale_fill_viridis_c(option = "plasma", direction = -1,name = "water cover proportion") +
  geom_point(size = 0.4, aes(x = coord_tuinen$X,y = coord_tuinen$Y), colour="white", shape = 15) +
  geom_text(
    aes(
      label = tuinen_sf$water_cover,
      x = coord_tuinen$X,
      y = coord_tuinen$Y
    ),
    colour = "black",
    size = 2.2,hjust = 0, nudge_x = 0.07
  ) +
  xlab("Longitude") + ylab("Latitude") +
  theme_minimal()
plot.nme = paste0('water_coverage_garden.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=320)

#green coverage of panden

#centroid panden
cntrd_panden <- st_centroid(st_geometry(panden_sf))

#extract coordinates
coord_panden<-as.data.frame(st_coordinates(cntrd_panden))

ggplot(data = panden_sf) +
  geom_sf(aes(fill = ndvi_cover_panden)) +
  scale_fill_viridis_c(option = "viridis", direction = 1,name = "green cover proportion") +
  geom_point(size = 0.4, aes(x = coord_panden$X,y = coord_panden$Y), colour="white", shape = 15) +
  geom_text(
    aes(
      label = panden_sf$green_cover,
      x = coord_panden$X,
      y = coord_panden$Y
    ),
    colour = "black",
    size = 2.2,hjust = 0, nudge_x = 0.07
  ) +
  xlab("Longitude") + ylab("Latitude") +
  theme_void()
plot.nme = paste0('green_coverage_woningen.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=320)


#distribution of woningen over vegetation coverage
ggplot(panden_sf, aes(x = green_cover)) +
  geom_histogram(aes(y = (..count..)/sum(..count..)), binwidth = 20,color="lightblue", fill="steelblue") +
  stat_bin(aes(y=(..count..)/sum(..count..),
               label=paste0(round((..count..)/sum(..count..)*100,1),"%")),
           geom="text", size=4, binwidth = 20, vjust=-1.5) +
  #scale_x_continuous(breaks = seq(0.2,0.8,0.1))+
  labs(x = "% vegetation cover panden on woonperceel", y = "%") +
  theme_light()
plot.nme = paste0('rs_woningen_distibution_vegetation_coverage_',neighbourhood,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, dpi=dpi)

