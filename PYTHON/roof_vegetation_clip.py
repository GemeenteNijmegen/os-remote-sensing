#Load required Python libraries
import os
import geopandas as gpd
import rasterio
from rasterio.mask import mask

# Load variables
from start import gpkg_vector, files_basename

###########################################
### Clip only roofs from buurten ndvi ###
###########################################
# http://www.acgeospatial.co.uk/simple-plotting/

# Read NDVI tif
tif_ndvi = files_basename + "_ndvi.tif"
ndvi = rasterio.open(tif_ndvi, driver='GTiff') #RGB

# Read panden vector
gdf_daken = gpd.read_file(gpkg_vector, driver='GPKG', layer='daken')
gdf_daken = gdf_daken.rename(index=str, columns={"identificatie":"pand_identificatie"})

# Clip (called mask in rasterio) tuinen with ndvi
daken_ndvi, mask_transform = mask(dataset=ndvi,shapes=gdf_daken.geometry,crop=True)

# Define profile for writing based on NDVI tif profile
profile = ndvi.meta
WIDTH = daken_ndvi.shape[2] ## get the dimensions of the image we are writting out
HEIGHT = daken_ndvi.shape[1]
profile.update(driver='GTiff', transform=mask_transform, height = HEIGHT, width = WIDTH)

# Write tuinen NDVI
output_daken_ndvi = files_basename + "_daken_ndvi.tif"
with rasterio.open(output_daken_ndvi, 'w', **profile) as dst:
    dst.write(daken_ndvi)