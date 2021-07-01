library(R.utils)

#path_shape  <- "C:/Users/l.vanbrabant/stack/ShapeFiles" # e.g., .shp of .gpkg
#bu_sf <- read_sf(file.path(path_shape, "2020/WijkBuurtkaart_2020_v1.gpkg"), layer = "cbs_buurten_2020")

# set.seed(90210)
# sample.idx <- sample(bu_sf$buurtcode, size = 100, replace = FALSE)
# plot(bu_sf[bu_sf$buurtcode %in% sample.idx, ][1])
# write.csv2(sample.idx, "tempdata/BU_CODE_sample.csv")


#-----------------------------------------------------------------------------------------------

# Unsupervised classification

#-----------------------------------------------------------------------------------------------

# vector with buurtcodes
BU_CODE <- read.csv2("tempdata/BU_CODE_sample.csv")
#BU_CODE <- BU_CODE[BU_CODE$BU_CODE != "BU06779998", ]

BU_CODE <- BU_CODE$BU_CODE#[20:30]

# loop through buurten
result <- data.frame()
for (t in BU_CODE) {
  cat("BU_CODE:", t, "\n")
  
  # download tif from stack
  path_tif <- paste0("https://datasciencevng.nl/remote.php/webdav/Data/cir2020perbuurt/",t,".tif")
  tif <- downloadFile(url      = path_tif,
                      path     = "C:/Users/l.vanbrabant/stack/GGD/VNG/remote-sensing/tempdata",
                      username = "remotesensing", 
                      password = "VNGRS2021!", 
                      verbose  = FALSE)

  kB <- file.info(tif)$size / 1024
  
  # avoid memory issues.
  if (kB < 2000 | kB > 750000) {
   next 
  }
  
  # stars based on Tiff
  x <- read_stars(tif)
  #plot(x)
  ai <- as(x, "Raster")
  rm(x)
  
  #projection
  raster::crs(ai) <- "EPSG:4326"
  
  # near infrared band and red band (als je voor pret bent)
  nir <- ai[[1]]
  red <- ai[[2]]
  
  ndvi <- raster::overlay(red, nir, fun = function(x, y) { (y-x) / (y+x) })
  #plot(ndvi)  
  
  # convert the raster to vector/matrix ('getValues' converts the RasterLAyer to array) )
  ndvi_array <- getValues(ndvi)
  
  # keep valid observations only
  i <- which(!is.na(ndvi_array))
  ndvi_valid_array <- ndvi_array[i]
  #str(nvdi_valid_array)
  
  # start with 3 cluster solution, this separates non-vegi from vegi
  km <- kmeans(ndvi_valid_array, centers = 3, iter.max = 200,
               nstart = 5, algorithm = "Lloyd")
  
  # extract cluster means
  centers <- km$centers
  
  # order the cluster means
  centers <- sort(centers)
  # call kmeans again but this time passing the centers calculated in the previous 
  # step. In this way the results is neatly ordered.
  km <- kmeans(ndvi_valid_array, centers = centers)
  
  # Copy ndvi layer
  gi_km <- ndvi
  
  # replace raster cell values with km$cluster
  # array
  gi_km[] <- NA
  gi_km[i] <- km$cluster
  #table(gi_km[])

  ## visual inspection  
  # par(mfrow = c(1,2))
  # aerial_rgb<-plotRGB(ai,
  #                     r = 1, g = 2, b = 3,
  #                     #stretch the values to increase the contrast of the image
  #                     stretch = "lin",
  #                     #axes = TRUE,
  #                     main = paste0("composite image stack ", t))
  # plot(gi_km, main = "Kmeans", col = viridis_pal(option = "D")(3))
  
  
  # vegi starts from cluster 2
  tmp <- data.frame(ndvi = ndvi[], gi = gi_km[])
  #rng_ndvi_k3$k1 <- range(tmp$ndvi[tmp$gi %in% c(1)], na.rm = TRUE) 
  rng_ndvi_k2 <- range(tmp$ndvi[tmp$gi %in% c(2)], na.rm = TRUE) 
  #rng_ndvi_k3$k3 <- range(tmp$ndvi[tmp$gi %in% c(3)], na.rm = TRUE) 
  
  
  out <- data.frame(BU_CODE = t, ndvi_vegi_min = rng_ndvi_k2[1], ndvi_vegi_max = rng_ndvi_k2[2])
  
  # stack results
  result <- rbind(result, out)
  
  print(result)
  
  # remove tif from environment and from disk
  file.remove(tif)
  rm(tif)
  # empty garbage bin
  gc()
  
  # ## second, remove ndvi scores which are non-vegi (e.g., streets, concreat, etc...)
  # gi2_km <- ndvi
  # gi2_km[][gi2_km[] < min(rng_ndvi_k3$k2)] <- NA
  # 
  # gi2_km_array <- getValues(gi2_km)
  # i2 <- which(!is.na(gi2_km_array))
  # gi2_km_valid_array <- gi2_km_array[i2]
  # 
  # # redo clustering on vegi only ndvi scores
  # # The numbers of clusters still needs some tweaking.
  # km_vegi <- kmeans(gi2_km_valid_array, centers = 5, iter.max = 200,
  #                   nstart = 5, algorithm = "Lloyd")
  # 
  # km_vegi
  # centers_vegi <- km_vegi$centers
  # # order the centers
  # centers_vegi <- sort(centers_vegi)
  # # call kmeans again but this time passing the centers calculated in the previous step
  # km_vegi <- kmeans(gi2_km_valid_array, centers = centers_vegi)
  # 
  # gi2_km[] <- NA
  # gi2_km[i2] <- km_vegi$cluster
  # 
  # 
  # # -------------------------------------------------------------------------
  # 
  # par(mfrow = c(1,2))
  # aerial_rgb<-plotRGB(ai,
  #                     r = 1, g = 2, b = 3,
  #                     #stretch the values to increase the contrast of the image
  #                     stretch = "lin",
  #                     axes = TRUE,
  #                     main = paste0("composite image stack ", t))
  # plot(gi2_km, main = "Kmeans", col = viridis_pal(option = "D")(5))
  
}  



#plot(ndvi)
#plot(percelen_garden_sf, add = TRUE)


