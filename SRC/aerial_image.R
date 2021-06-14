#convert coordinates of sf object
buurt_sf_tf<- st_transform(buurt_sf, crs = st_crs(4326))

#centroid buurt
centroid_alt <- sf::st_centroid(buurt_sf_tf)
centroid_alt<- centroid_alt$geom

cen<-unlist(centroid_alt)
x_centroid<-cen[1]
y_centroid<-cen[2]

tile_x <- xtile_col(x_centroid, zoom = zoom)
tile_y <- ytile_col(y_centroid, zoom = zoom)

# haal foto op
f1 <- aerial_photo(tile_x,tile_y, zoom, site)

## CIR: green - red - nir
## R = XS3 (NIR band)
## G = XS2 (red band)
## B = XS1 (green band)

#set layer names
names(f1) <- c("NIR Band","Red Band","Green Band")

#number of layers
nlayers(f1)

#layer names
names(f1)

#bounding box
#@Leonard dit is de bounding box van de eerste feature (subset 1/6) en deze pas je toe op de hele foto
my_extent <- num2deg(tile_x, tile_y, zoom)
extent(f1) <- my_extent
extent(f1)

#projection
crs(f1)
crs(f1) <- "+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"
crs(f1)

#overprocessing NIR and red layers to locate green 
#improve photo quality
qq<-png(paste0(plots.dir,"rs_rgbplot_",neighbourhood,".png"), bg="white", width=png_height*aspect_ratio, height=png_height)
par(col.axis = "white", col.lab = "white", tck = 0)
aerial_rgb<-plotRGB(f1,
        r = 1, g = 2, b = 3,
        #stretch the values to increase the contrast of the image
        stretch = "lin",
        axes = TRUE,
        main = paste0("composite image stack ", neighbourhood))
box(col = "white")
aerial_rgb
dev.off()