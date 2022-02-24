#Load required Python libraries
import geopandas as gpd
import rasterio
from rasterio.mask import mask

# Load variables
from start import gpkg_vector, files_basename

###########################################
### Clip only gardens from buurten ndvi ###
###########################################
# Documentation: http://www.acgeospatial.co.uk/simple-plotting/

# Read NDVI tif
tif_ndvi = files_basename + "_ndvi.tif"
ndvi = rasterio.open(tif_ndvi, driver='GTiff') #RGB

# Read garden vector
gdf_tuinen = gpd.read_file(gpkg_vector, driver='GPKG', layer='tuinen')

# Clip (called mask in rasterio) garden with ndvi
tuinen_ndvi, mask_transform = mask(dataset=ndvi,shapes=gdf_tuinen.geometry,crop=False)

# Define profile for writing based on NDVI tif profile
profile = ndvi.meta
WIDTH = tuinen_ndvi.shape[2] ## get the dimensions of the image we are writting out
HEIGHT = tuinen_ndvi.shape[1]
profile.update(driver='GTiff', transform=mask_transform, height = HEIGHT, width = WIDTH)

# Write tuinen NDVI to tif
output_tuinen_ndvi = files_basename + "_tuinen_ndvi.tif"
with rasterio.open(output_tuinen_ndvi, 'w', **profile) as dst:
    dst.write(tuinen_ndvi)

# TODO: write to GPKG gives some Spatial Reference error
'''
# Write to GPKG, convert to dtype Float32
desGPKG = gpkg_raster
sourcetif_tuinen_ndvi = files_basename + "_tuinen_ndvi.tif"
lyr_ndvi = "tuinen_ndvi"

gdal_string_ndvi = 'gdal_translate -ot Float32 -of GPKG "{}" "{}" -co RASTER_TABLE={} -co APPEND_SUBDATASET=YES'.format(sourcetif_tuinen_ndvi, desGPKG, lyr_ndvi)
os.system(gdal_string_ndvi)
'''