#Load required Python libraries
import os
from osgeo import gdal, osr
import numpy as np
import copy
import geopandas as gpd
import rasterio
from rasterio.mask import mask
from rasterio.plot import show

# Load variables
from start import files_basename, gpkg_vector

#Source of code
#https://www.neonscience.org/resources/learning-hub/tutorials/classify-raster-thresholds-py

# Read NDVI tif
chm_filename = files_basename + "_tuinen_ndvi.tif"
chm_dataset = gdal.Open(chm_filename)

#Display the dataset dimensions, number of bands, driver, and geotransform
cols = chm_dataset.RasterXSize; print('# of columns:',cols)
rows = chm_dataset.RasterYSize; print('# of rows:',rows)
print('# of bands:',chm_dataset.RasterCount)
print('driver:',chm_dataset.GetDriver().LongName)

print('projection:',chm_dataset.GetProjection())
print('geotransform:',chm_dataset.GetGeoTransform())

#Get spatial extent
chm_mapinfo = chm_dataset.GetGeoTransform()
xMin = chm_mapinfo[0]
yMax = chm_mapinfo[3]

xMax = xMin + chm_dataset.RasterXSize/chm_mapinfo[1] #divide by pixel width
yMin = yMax + chm_dataset.RasterYSize/chm_mapinfo[5] #divide by pixel height (note sign +/-)
chm_ext = (xMin,xMax,yMin,yMax)
print('chm raster extent:',chm_ext)

#Get stats about raster
chm_raster = chm_dataset.GetRasterBand(1)
noDataVal = chm_raster.GetNoDataValue(); print('no data value:',noDataVal)
scaleFactor = chm_raster.GetScale(); print('scale factor:',scaleFactor)
chm_stats = chm_raster.GetStatistics(True,True)
print('SERC CHM Statistics: Minimum=%.2f, Maximum=%.2f, Mean=%.3f, StDev=%.3f' %
      (chm_stats[0], chm_stats[1], chm_stats[2], chm_stats[3]))

#Convert raster to array
chm_array = chm_dataset.GetRasterBand(1).ReadAsArray(0,0,cols,rows).astype(np.float)
#chm_array[chm_array==int(noDataVal)]= np.nan #Assign CHM No Data Values to NaN
# chm_array=chm_array/scaleFactor
print('SERC CHM Array:\n',chm_array) #display array values

# Display statistics (min, max, mean); numpy.nanmin calculates the minimum without the NaN values.
# print('SERC CHM Array Statistics:')
# print('min:',round(np.nanmin(chm_array),2))
# print('max:',round(np.nanmax(chm_array),2))
# print('mean:',round(np.nanmean(chm_array),2))

# Calculate the % of pixels that are NaN and non-zero:
pct_nan = np.count_nonzero(np.isnan(chm_array))/(rows*cols)
# print('% NaN:',round(pct_nan*100,2))
# print('% non-zero:',round(100*np.count_nonzero(chm_array)/(rows*cols),2))

#Plot alternative
#show(chm_array)

#Plot histogram
chm_nonan_array = copy.copy(chm_array)
chm_nonan_array = chm_nonan_array[~np.isnan(chm_array)]

chm_reclass = copy.copy(chm_array)
chm_reclass[np.where(chm_array< 0.2)] = 20 # NDVI < 0.2
chm_reclass[np.where(chm_array>= 0.2)] = 10 # NDVI >= 0.2

# print('Min:',np.nanmin(chm_reclass))
# print('Max:',np.nanmax(chm_reclass))
# print('Mean:',round(np.nanmean(chm_reclass),2))

#Raster to array
# raster2array.py reads in the first band of geotif file and returns an array and associated
# metadata dictionary containing ...

dataset = gdal.Open(chm_filename)

def raster2array(geotif_file):
    metadata = {}
    dataset = gdal.Open(geotif_file)
    metadata['array_rows'] = dataset.RasterYSize
    metadata['array_cols'] = dataset.RasterXSize
    metadata['bands'] = dataset.RasterCount
    metadata['driver'] = dataset.GetDriver().LongName
    metadata['projection'] = dataset.GetProjection()
    metadata['geotransform'] = dataset.GetGeoTransform()

    mapinfo = dataset.GetGeoTransform()
    metadata['pixelWidth'] = mapinfo[1]
    metadata['pixelHeight'] = mapinfo[5]
#     metadata['xMin'] = mapinfo[0]
#     metadata['yMax'] = mapinfo[3]
#     metadata['xMax'] = mapinfo[0] + dataset.RasterXSize/mapinfo[1]
#     metadata['yMin'] = mapinfo[3] + dataset.RasterYSize/mapinfo[5]

    metadata['ext_dict'] = {}
    metadata['ext_dict']['xMin'] = mapinfo[0]
    metadata['ext_dict']['xMax'] = mapinfo[0] + dataset.RasterXSize/mapinfo[1]
    metadata['ext_dict']['yMin'] = mapinfo[3] + dataset.RasterYSize/mapinfo[5]
    metadata['ext_dict']['yMax'] = mapinfo[3]

    metadata['extent'] = (metadata['ext_dict']['xMin'],metadata['ext_dict']['xMax'],
                          metadata['ext_dict']['yMin'],metadata['ext_dict']['yMax'])

    if metadata['bands'] == 1:
        raster = dataset.GetRasterBand(1)
        metadata['noDataValue'] = raster.GetNoDataValue()
        metadata['scaleFactor'] = raster.GetScale()

        # band statistics
        metadata['bandstats'] = {} #make a nested dictionary to store band stats in same
        stats = raster.GetStatistics(True,True)
        metadata['bandstats']['min'] = round(stats[0],2)
        metadata['bandstats']['max'] = round(stats[1],2)
        metadata['bandstats']['mean'] = round(stats[2],2)
        metadata['bandstats']['stdev'] = round(stats[3],2)

        array = dataset.GetRasterBand(1).ReadAsArray(0,0,metadata['array_cols'],metadata['array_rows']).astype(float)
        #array[array==int(metadata['noDataValue'])]=np.nan
        #array = array/metadata['scaleFactor']
        return array, metadata

    elif metadata['bands'] > 1:
        print('More than one band ... need to modify function for case of multiple bands')

#Use array2raster function
SERC_chm_array, SERC_chm_metadata = raster2array(chm_filename)

# print('SERC CHM Array:\n',SERC_chm_array)
# # print(chm_metadata)
#
# #print metadata in alphabetical order
# for item in sorted(SERC_chm_metadata):
#     print(item + ':', SERC_chm_metadata[item])

#Array to raster
#Let op! De pixel height en width klopt nog niet. staat op 1m lijkt het
def array2raster(newRasterfn,rasterOrigin,pixelWidth,pixelHeight,array,epsg):

    cols = array.shape[1]
    rows = array.shape[0]
    originX = rasterOrigin[0]
    originY = rasterOrigin[1]

    driver = gdal.GetDriverByName('GTiff')
    outRaster = driver.Create(newRasterfn, cols, rows, 1, gdal.GDT_Byte)
    outRaster.SetGeoTransform((originX, pixelWidth, 0, originY, 0, pixelHeight))
    outband = outRaster.GetRasterBand(1)
    outband.WriteArray(array)
    outRasterSRS = osr.SpatialReference()
    outRasterSRS.ImportFromEPSG(epsg)
    outRaster.SetProjection(outRasterSRS.ExportToWkt())
    outband.FlushCache()

#array2raster(newRasterfn,rasterOrigin,pixelWidth,pixelHeight,array)
#Set output filename
classified_gardens = files_basename + "_tuinen_ndvi_2_classes.tif"

epsg = 28992 #RD New
rasterOrigin = (SERC_chm_metadata['ext_dict']['xMin'],SERC_chm_metadata['ext_dict']['yMax'])

#Uitvoeren conversie array > raster + wegschrijven
#Let op!! De resolutie van de uitvoer is in het geval van Beeldmateriaal luchtfoto 25 cm bij 25 cm
array2raster(classified_gardens,rasterOrigin,0.25,-0.25,chm_reclass,epsg)

"""
Hieronder worden de geclassificeerde tuinen nogmaals geclipt. Het effect hiervan
is dat alles buiten de tuinen waarde 0 krijgt (dit was NoData).
"""
# Read NDVI tif
tif_ndvi = files_basename + "_tuinen_ndvi_2_classes.tif"
ndvi = rasterio.open(tif_ndvi, driver='GTiff') #RGB
show(ndvi.read(), transform=ndvi.transform)

# Read tuinen vector
gdf_tuinen = gpd.read_file(gpkg_vector, driver='GPKG', layer='tuinen')
gdf_tuinen.plot()

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
output_tuinen_ndvi = files_basename + "_tuinen_ndvi_3_classes.tif"
with rasterio.open(output_tuinen_ndvi, 'w', **profile) as dst:
    dst.write(tuinen_ndvi)

"""
Ouput values:
0 = geen tuin
10 = wel tuin, vegetatie
20 = wel tuin, geen vegetatie
"""