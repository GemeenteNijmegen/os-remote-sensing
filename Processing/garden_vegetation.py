#import required libraries
import rasterio
from rasterio import plot
import matplotlib.pyplot as plt
import time
import numpy as np

import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, BoundaryNorm
#import xarray as xr
import rioxarray as rxr
#import earthpy as et
#import earthpy.plot as ep

startTime = time.time()

#https://www.earthdatascience.org/courses/use-data-open-source-python/intro-raster-data-python/raster-data-processing/classify-plot-raster-data-in-python/


# figure out how long the script took to run
endTime = time.time()
print ('The script took ' + str(endTime - startTime) + ' seconds')


''''''
#temp voor het testen
import os
import geopandas as gpd
import rasterio
from rasterio.mask import mask
from rasterio.plot import show
import matplotlib.pyplot as plt

buurtcode = "BU04411401"
#buurtcode = "BU03072502"
workingdirectory = os.getcwd()
parent = os.path.dirname(workingdirectory)
tempdirectory = parent + "/tempdata/" + buurtcode + "/"
files_basename = tempdirectory + buurtcode
gpkg_vector = tempdirectory + buurtcode + "_vector.gpkg"
gpkg_raster = tempdirectory + buurtcode + "_raster.gpkg"

###########################################
### Clip only gardens from buurten ndvi ###
###########################################
# http://www.acgeospatial.co.uk/simple-plotting/

# Read NDVI tif
tif_ndvi = files_basename + "_ndvi.tif"
ndvi = rasterio.open(tif_ndvi, driver='GTiff') #RGB
show(ndvi.read(), transform=ndvi.transform)

# Read tuinen vector
gdf_tuinen = gpd.read_file(gpkg_vector, driver='GPKG', layer='tuinen')
gdf_tuinen.plot()

# Plot NDVI and tuinen
fig, ax = plt.subplots(figsize=(12, 10))
show(ndvi.read(), transform=ndvi.transform, ax=ax)
gdf_tuinen.plot(ax=ax, color='white', alpha=.75) ## alpha is the transparency setting
plt.show()

# Clip (called mask in rasterio) tuinen with ndvi
tuinen_ndvi, mask_transform = mask(dataset=ndvi,shapes=gdf_tuinen.geometry,crop=True)
show(tuinen_ndvi, transform=mask_transform)

# Define profile for writing based on NDVI tif profile
profile = ndvi.meta
WIDTH = tuinen_ndvi.shape[2] ## get the dimensions of the image we are writting out
HEIGHT = tuinen_ndvi.shape[1]
profile.update(driver='GTiff', transform=mask_transform, height = HEIGHT, width = WIDTH)
print(profile) ## check on the updated profile

# Write tuinen NDVI
#output_tuinen_ndvi = files_basename + "_tuinen_ndvi.tif"
#with rasterio.open(output_tuinen_ndvi, 'w', **profile) as dst:
#    dst.write(tuinen_ndvi)

####################
### CALCULATIONS ###
####################
# https://www.neonscience.org/resources/learning-hub/tutorials/classify-raster-thresholds-py
import numpy as np
import copy
from osgeo import gdal

chm_filename = files_basename + "_tuinen_ndvi.tif"
chm_dataset = gdal.Open(chm_filename)

raster_arr = np.array(chm_dataset.GetRasterBand(1).ReadAsArray())
nodatamask = raster_arr == nodata

#do your thing and end up with a result_raster that you'd like to save
result_raster[nodatamask] = nodata


cols = chm_dataset.RasterXSize; print('# of columns:',cols)
rows = chm_dataset.RasterYSize; print('# of rows:',rows)

chm_mapinfo = chm_dataset.GetGeoTransform()
xMin = chm_mapinfo[0]
yMax = chm_mapinfo[3]

xMax = xMin + chm_dataset.RasterXSize/chm_mapinfo[1] #divide by pixel width
yMin = yMax + chm_dataset.RasterYSize/chm_mapinfo[5] #divide by pixel height (note sign +/-)
chm_ext = (xMin,xMax,yMin,yMax)
print('chm raster extent:',chm_ext)


with rasterio.open(chm_filename) as src:
    chm_array = src.read(1)

chm_array[chm_array==0] = np.nan

print('SERC CHM Array Statistics:')
print('min:',round(np.nanmin(chm_array),2))
print('max:',round(np.nanmax(chm_array),2))
print('mean:',round(np.nanmean(chm_array),2))

# Calculate the % of pixels that are NaN and non-zero:
pct_nan = np.count_nonzero(np.isnan(chm_array))/(rows*cols)
print('% NaN:',round(pct_nan*100,2))
print('% non-zero:',round(100*np.count_nonzero(chm_array)/(rows*cols),2))

# Plot array
# We can use our plot_band_array function from Day 1
# %load plot_band_array
def plot_band_array(band_array,refl_extent,title,cmap_title,colormap='Spectral'):
    plt.imshow(band_array,extent=refl_extent);
    cbar = plt.colorbar(); plt.set_cmap(colormap);
    cbar.set_label(cmap_title,rotation=270,labelpad=20)
    plt.title(title); ax = plt.gca();
    ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation #
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degrees

plot_band_array(chm_array,chm_ext,'SERC Canopy Height','Canopy Height, m')

#Threshold Based Raster Classification
chm_reclass = copy.copy(chm_array)
chm_reclass[np.where(chm_array <= 0.2)] = 1 # Class 1
chm_reclass[np.where(chm_array > 0.2)] = 2 # Class 2

print('Min:',np.nanmin(chm_reclass))
print('Max:',np.nanmax(chm_reclass))
print('Mean:',round(np.nanmean(chm_reclass),2))



import matplotlib.colors as colors
plt.figure(); #ax = plt.subplots()
cmapCHM = colors.ListedColormap(['lightblue','green'])
plt.imshow(chm_reclass,extent=chm_ext,cmap=cmapCHM)
plt.title('NDVI Classification')
ax=plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation
rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degrees
# forceAspect(ax,aspect=1) # ax.set_aspect('auto')

# Create custom legend to label the four canopy height classes:
import matplotlib.patches as mpatches
class1_box = mpatches.Patch(color='lightblue', label='geen vegetatie')
class2_box = mpatches.Patch(color='green', label='vegetatie')

ax.legend(handles=[class1_box,class2_box],
          handlelength=0.7,bbox_to_anchor=(1.05, 0.4),loc='lower left',borderaxespad=0.)

chm_reclass
count = (chm_reclass == 1).sum()
print('Total occurences of "3" in array: ', count)



### HIER VERDER GAAN
gdf_tuinen.columns

no_vegetation = chm_reclass[np.where(chm_array <= 0.2)] = 1 # Class 1
vegetation = chm_reclass[np.where(chm_array > 0.2)] # Class 2

for identificatieLokaalID  in gdf_tuinen:
    tuinen_ndvi, mask_transform = mask(dataset=ndvi, shapes=gdf_tuinen.geometry, crop=True)
    vegetation = np.where(tuinen_ndvi > THRESHOLD, 1, 0)
    vegetation_count = np.count_nonzero(vegetation)
    total = chm_reclass.shape[0] * chm_reclass.shape[1]
    fractional_cover = vegetation_count / total

show(tuinen_ndvi, transform=mask_transform)


vegetation.head(5)



THRESHOLD = 0.2
vegetation = np.where(chm_reclass > THRESHOLD, 1, 0)
vegetation_count = np.count_nonzero(vegetation)
total = chm_reclass.shape[0]*chm_reclass.shape[1]
fractional_cover = vegetation_count/total
fractional_cover


