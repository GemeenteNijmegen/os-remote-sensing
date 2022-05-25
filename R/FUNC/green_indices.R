#-----------------------------------------------------------------------------------------------

# Normalized difference vegetation index (NDVI)

#-----------------------------------------------------------------------------------------------

##Normalized Difference Vegetation Index (NDVI) quantifies vegetation by measuring the difference
#between near-infrared (which vegetation strongly reflects) and red light (which vegetation absorbs).
#NDVI indicates amount of vegetation, distinguishes vegetation from soil, minimizes topographic effects
#NDVI is chlorophyll sensitive, emphasizing the green color of a healthy plant.
#NDVI is slightly distorted by factors including shadowing, air moisture, and variations in the soil

#NDVI = (NIR–R/NIR+R)

ndvi_func <- function(x,y) {
  (y-x) / (y+x)

}

#-----------------------------------------------------------------------------------------------

# transformed normalized difference vegetation index (TNDVI)

#-----------------------------------------------------------------------------------------------

#TNDVI indicates a relation between the amount of green biomass that is found in a pixel.
#It has always positive values and the variances of the ratio are proportional to mean values

#TNDVI = sqrt((NIR–R/NIR+R) +0.5)

tndvi_func <- function(r) {
  sqrt(r + 0.5)
}


#-----------------------------------------------------------------------------------------------

# Modified Soil Adjusted Vegetation Index (MSAVI2)

#-----------------------------------------------------------------------------------------------

#The Modified Soil Adjusted Vegetation Index (MSAVI2) method minimizes the effect of bare soil
#on the SAVI.

#msavi2 = (2 * NIR + 1 - sqrt( (2 * NIR + 1)^2 - 8 * (NIR - RED) )) / 2

msavi2_func <- function(x,y) {
  (2*y+1-sqrt((2*y+1)^2-8*(y-x)))/2
}


#-----------------------------------------------------------------------------------------------

# Enhanced vegetation index - Two-band (EVI2)

#-----------------------------------------------------------------------------------------------

#EVI2 has several advantages over NDVI including the ability to resolve differences
#for vegetation with different background soil reflectance

#evi2 = 2.5*((NIR-RED) / (NIR+2.4*RED+1))

evi2_func <- function(x,y) {
  2.5*((y-x) / (y+2.4*x+1))
}


#-----------------------------------------------------------------------------------------------

# Ratio vegetation index (RVI)

#-----------------------------------------------------------------------------------------------

#Reduces the effects of atmosphere and topography

#rvi = NIR/RED

rvi_func <- function(x,y) {
  (y) / (x)
}

#-----------------------------------------------------------------------------------------------

# (re)Classify raster function

#-----------------------------------------------------------------------------------------------

class_func <- function(rast,bins) {
  raster::reclassify(rast,bins)
}

#-----------------------------------------------------------------------------------------------

# ggplot function

#-----------------------------------------------------------------------------------------------

plotting_gg <- function(input, xx, lab_nme, file_slug, col_scheme, dir, coord) {
  ggplot(data = input) +
    geom_sf(aes(fill = .data[[xx]]),size = 0.001) +
    scale_fill_viridis_c(option = col_scheme, direction = dir,name = lab_nme) +
    #geom_point(size = 0.4, aes(x = coord_panden$X,y = coord_panden$Y), colour="white", shape = 15) +
    geom_text(
      aes(
        label = .data[[xx]],
        x = coord$X,
        y = coord$Y
      ),
      colour = "black",
      size = 2.2,hjust = 0, nudge_x = 0.07
    ) +
    xlab("Longitude") + ylab("Latitude") +
    theme_void()
  plot.store <-paste0(plots.loc,file_slug,"_",neighbourhood,".png")
  ggsave(plot.store, dpi=320)
}

#without label
plotting_gg_clean <- function(input, xx, lab_nme, file_slug, col_scheme) {
  ggplot(data = input) +
    geom_sf(aes(fill = .data[[xx]]),size = 0.001) +
    scale_fill_viridis_c(option = col_scheme, direction = 1,name = lab_nme) +
    theme_void()
  plot.store <-paste0(plots.loc,file_slug,"_",neighbourhood,".png")
  ggsave(plot.store, dpi=320)
}

#distribution plot
plotting_gg_dist <- function(input, xx, lab_nme, file_slug, bin_width) {
ggplot(input, aes(x = .data[[xx]])) +
  geom_histogram(aes(y = (..count..)/sum(..count..)), binwidth = bin_width,color="lightblue", fill="steelblue") +
  stat_bin(aes(y=(..count..)/sum(..count..),
               label=paste0(round((..count..)/sum(..count..)*100,1),"%")),
           geom="text", size=4, binwidth = bin_width, vjust=-1.5) +
  #scale_x_continuous(breaks = seq(0.2,0.8,0.1))+
  labs(x = lab_nme, y = "%") +
  theme_light()
plot.store <-paste0(plots.loc,file_slug,"_",neighbourhood,".png")
ggsave(plot.store, dpi=dpi)
}

#-----------------------------------------------------------------------------------------------

# rastervis plot function

#-----------------------------------------------------------------------------------------------

plotting_rst <- function(rast, lab_nme, file_slug) {
  rasterVis::gplot(rast) +
    geom_tile(aes(fill = value)) +
    scale_fill_gradientn(colours = rev(terrain.colors(225)), na.value ="transparent") +
    #geom_sf(aes(st_sf(st_geometry(tuinen_sf)))) +
    theme_void() +
    coord_fixed() +
    theme(legend.position = "bottom") +
    labs(fill = lab_nme)
  plot.store <- paste0(plots.loc,file_slug, "_",neighbourhood,".png")
  ggsave(plot.store, dpi=dpi)
}

#-----------------------------------------------------------------------------------------------

# terra function

#-----------------------------------------------------------------------------------------------

plotting_terra <- function(ai,rast,lab_nme,file_slug,brks,brks_lab,cols,alpha) {
png(paste0(plots.loc,file_slug, "_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
par(col.lab = "white", tck = 0,mar = c(1,1,1,1))
terra::plotRGB(ai, r=1, g=2, b=3, axes=TRUE, stretch="lin", alpha=alpha,colNA='transparent',main=paste0(lab_nme, " ", neighbourhood))
plot(rast, add=TRUE, legend=TRUE,  breaks=brks, lab.breaks=brks_lab, cex = 0.5, col=cols, na.value ="transparent")
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()
}

#-----------------------------------------------------------------------------------------------

# base function

#-----------------------------------------------------------------------------------------------

plotting_base <- function(ai,rast,lab_nme,file_slug,brks,brks_lab,cols) {
png(paste0(plots.loc,file_slug,"_",neighbourhood,".png"), bg="white", height=1280, width=1280, res=180,units = "px")
par(col.lab = "white", tck = 0,mar = c(1,1,1,1))
raster::plotRGB(ai, r=1, g=2, b=3, axes=TRUE, stretch="lin",colNA='transparent',main=paste0(lab_nme, " ", neighbourhood))
plot(rast, add=TRUE, legend=TRUE, cex = 0.5, breaks=brks, lab.breaks=brks_lab, col=cols,na.value ="transparent")
plot(percelen_sf$geometry, add=TRUE, legend=FALSE)
box(col = "white")
dev.off()
}
