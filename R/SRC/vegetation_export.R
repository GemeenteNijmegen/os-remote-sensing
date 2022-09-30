
#-----------------------------------------------------------------------------------------------

# Vegetation geopackage

#-----------------------------------------------------------------------------------------------

#create fresh multi-layer GeoPackage (gpkg) containing all green indices

unlink(gpkg_indices)

#NDVI
write_gpkg(ndvi,gpkg_indices,"ndvi")

terra::writeRaster(ndvi, paste0(plots.loc,"ndvi.tif"), filetype = "GTiff", overwrite = TRUE)


if(tndvi_calc==TRUE) {
#TNDVI
terra::writeRaster(tndvi, paste0(plots.loc,"tndvi.tif"), filetype = "GTiff", overwrite = TRUE)
}


if(unsup_cl==TRUE) {
#green classes (unsupervised, classes)
terra::writeRaster(veg_clus, paste0(plots.loc,"veg_clus.tif"), filetype = "GTiff", overwrite = TRUE)
}

if(ahn_calc==TRUE) {

#high vegetation (above 5m)
terra::writeRaster(veg_t5, paste0(plots.loc,"veg_t5.tif"), filetype = "GTiff", overwrite = TRUE)
}



if(evi2_calc==TRUE) {
#EVI2 (value)
terra::writeRaster(evi2, paste0(plots.loc,"evi2.tif"), filetype = "GTiff", overwrite = TRUE)
}

if(rvi_calc==TRUE) {
#RVI (value)
terra::writeRaster(rvi, paste0(plots.loc,"rvi.tif"), filetype = "GTiff", overwrite = TRUE)
}

