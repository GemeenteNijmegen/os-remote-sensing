#import required libraries
import rasterio
from rasterio import plot
import matplotlib.pyplot as plt
import numpy as np
import os

# Load variables
from start import files_basename, gpkg_raster

#import bands as separate 1 band raster
band4 = rasterio.open(files_basename + '_red.tif') #red
band5 = rasterio.open(files_basename + '_nir.tif') #nir

#number of raster rows
band4.height

#number of raster columns
band4.width
band5.nodatavals


#plot band
#plot.show(band4)

#type of raster byte
band4.dtypes[0]

#raster sytem of reference
band4.crs

#raster transform parameters
band4.transform

#raster values as matrix array
band4.read(1)

#multiple band representation
#fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6))
#plot.show(band4, ax=ax1, cmap='Blues') #red
#plot.show(band5, ax=ax2, cmap='Blues') #nir
#fig.tight_layout()

#generate nir and red objects as arrays in float64 format
red = band4.read(1).astype('float64')
nir = band5.read(1).astype('float64')


#np.seterr(divide='ignore', invalid='ignore')  # Allow division by zero

#

#ndvi calculation, empty cells or nodata cells are reported as 0
ndvi = np.where( (nir+red) == 0., 0, (nir-red)/(nir+red))

#ndvi[:5,:5]

#export ndvi image
ndviImage = rasterio.open(files_basename + '_ndvi.tif','w',driver='Gtiff',
                          width=band4.width,
                          height = band4.height,
                          count=1, crs=band4.crs,
                          transform=band4.transform,
                          dtype='float64')
ndviImage.write(ndvi,1)
ndviImage.close()

#Write to GPKG, convert to dtype Float32
desGPKG = gpkg_raster
sourcetif_ndvi = files_basename + "_ndvi.tif"
lyr_ndvi = "ndvi"

gdal_string_ndvi = 'gdal_translate -ot Float32 -of GPKG "{}" "{}" -co RASTER_TABLE={} -co APPEND_SUBDATASET=YES'.format(sourcetif_ndvi, desGPKG, lyr_ndvi)
os.system(gdal_string_ndvi)



#plot ndvi
#ndvi = rasterio.open(files_basename + '_ndvi.tif')
#fig = plt.figure(figsize=(18,12))
#plot.show(ndvi)