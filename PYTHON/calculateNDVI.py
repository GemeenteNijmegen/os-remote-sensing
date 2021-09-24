#import required libraries
import rasterio
import numpy as np
import os

from time import process_time
t1_start = process_time()

# Load variables
from start import files_basename, gpkg_raster

# Import bands as separate 1 band raster
band1 = rasterio.open(files_basename + '_red.tif') #red
band2 = rasterio.open(files_basename + '_nir.tif') #nir

# Number of raster rows
band1.height

# Number of raster columns
band1.width
band2.nodatavals

# Type of raster byte
band1.dtypes[0]

# Raster sytem of reference
band1.crs

# Raster transform parameters
band1.transform

# Raster values as matrix array
band1.read(1)

# Generate nir and red objects as arrays in float64 format
red = band1.read(1).astype('float64')
nir = band2.read(1).astype('float64')

#np.seterr(divide='ignore', invalid='ignore')  # Allow division by zero

# NDVI calculation, empty cells or nodata cells are reported as 0
ndvi = np.where( (nir+red) == 0., 0, (nir-red)/(nir+red))

# Export ndvi image
ndviImage = rasterio.open(files_basename + '_ndvi.tif','w', driver='Gtiff',
                          width=band1.width,
                          height = band1.height,
                          count=1, crs=band1.crs,
                          transform=band1.transform,
                          dtype='float64')
ndviImage.write(ndvi,1)
ndviImage.close()

#Write to GPKG
sourcetif_ndvi = files_basename + "_ndvi.tif"
lyr_ndvi = "ndvi"
gdal_string_ndvi = 'gdal_translate -of GPKG "{}" "{}" -co RASTER_TABLE={} -co APPEND_SUBDATASET=YES'.format(sourcetif_ndvi, gpkg_raster, lyr_ndvi)
os.system(gdal_string_ndvi)

# Stop the stopwatch / counter
t1_stop = process_time()
print("Calculate NDVI runtime is ", round(t1_stop - t1_start,1), "seconds")
print("Calculate NDVI process finished")
