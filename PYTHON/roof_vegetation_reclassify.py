#Load required Python libraries
from osgeo import gdal, osr
import numpy as np
import copy
import geopandas as gpd
import rasterio
from rasterio.mask import mask
import os

# Load variables
from start import files_basename, gpkg_vector, gpkg_raster

#Source of code
#https://www.neonscience.org/resources/learning-hub/tutorials/classify-raster-thresholds-py

# Read NDVI tif
chm_filename = files_basename + "_daken_ndvi.tif"
chm_dataset = gdal.Open(chm_filename)

# Get the dataset dimensions, number of bands, driver, and geotransform
cols = chm_dataset.RasterXSize; print('# of columns:',cols)
rows = chm_dataset.RasterYSize; print('# of rows:',rows)

# Get spatial extent
chm_mapinfo = chm_dataset.GetGeoTransform()
xMin = chm_mapinfo[0]
yMax = chm_mapinfo[3]

xMax = xMin + chm_dataset.RasterXSize/chm_mapinfo[1] #divide by pixel width
yMin = yMax + chm_dataset.RasterYSize/chm_mapinfo[5] #divide by pixel height (note sign +/-)
chm_ext = (xMin,xMax,yMin,yMax)

# Get stats about raster
chm_raster = chm_dataset.GetRasterBand(1)
noDataVal = chm_raster.GetNoDataValue(); print('no data value:',noDataVal)
scaleFactor = chm_raster.GetScale(); print('scale factor:',scaleFactor)
chm_stats = chm_raster.GetStatistics(True,True)

# Convert raster to array
chm_array = chm_dataset.GetRasterBand(1).ReadAsArray(0,0,cols,rows).astype(np.float)

# Calculate the % of pixels that are NaN and non-zero:
pct_nan = np.count_nonzero(np.isnan(chm_array))/(rows*cols)

# Plot histogram
chm_nonan_array = copy.copy(chm_array)
chm_nonan_array = chm_nonan_array[~np.isnan(chm_array)]

chm_reclass = copy.copy(chm_array)
chm_reclass[np.where(chm_array< 0.2)] = 10 # NDVI < 0.2 - Not green
chm_reclass[np.where(chm_array>= 0.2)] = 20 # NDVI >= 0.2 - Green

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
        return array, metadata

    elif metadata['bands'] > 1:
        print('More than one band ... need to modify function for case of multiple bands')

#Use array2raster function
SERC_chm_array, SERC_chm_metadata = raster2array(chm_filename)

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
classified_roofs = files_basename + "_daken_ndvi_classified_temp.tif"

epsg = 28992 #RD New
rasterOrigin = (SERC_chm_metadata['ext_dict']['xMin'],SERC_chm_metadata['ext_dict']['yMax'])

#Uitvoeren conversie array > raster + wegschrijven
#Let op!! De resolutie van de uitvoer is in het geval van Beeldmateriaal luchtfoto 25 cm bij 25 cm
array2raster(classified_roofs,rasterOrigin,0.25,-0.25,chm_reclass,epsg)

"""
Hieronder worden de geclassificeerde tuinen nogmaals geclipt. Het effect hiervan
is dat alles buiten de tuinen waarde 0 krijgt (dit was NoData).
"""
# Read NDVI tif
tif_ndvi_temp = files_basename + "_daken_ndvi_classified_temp.tif"
ndvi = rasterio.open(tif_ndvi_temp, driver='GTiff') #RGB
#show(ndvi.read(), transform=ndvi.transform)

# Read tuinen vector
gdf_roofs = gpd.read_file(gpkg_vector, driver='GPKG', layer='daken')

# Clip (called mask in rasterio) tuinen with ndvi
roofs_ndvi, mask_transform = mask(dataset=ndvi,shapes=gdf_roofs.geometry,crop=True)
#show(tuinen_ndvi, transform=mask_transform)

# Define profile for writing based on NDVI tif profile
profile = ndvi.meta
WIDTH = roofs_ndvi.shape[2] ## get the dimensions of the image we are writting out
HEIGHT = roofs_ndvi.shape[1]
profile.update(driver='GTiff', transform=mask_transform, height = HEIGHT, width = WIDTH)
print(profile) ## check on the updated profile

# Write tuinen NDVI
output_roofs_ndvi = files_basename + "_daken_ndvi_classified.tif"
with rasterio.open(output_roofs_ndvi, 'w', **profile) as dst:
    dst.write(roofs_ndvi)

#Write to GPKG
sourcetif_daken_ndvi = files_basename + "_daken_ndvi_classified.tif"
lyr_daken_ndvi = "daken_ndvi"
gdal_string_ndvi_daken = 'gdal_translate -of GPKG "{}" "{}" -co RASTER_TABLE={} -co APPEND_SUBDATASET=YES'.format(sourcetif_daken_ndvi, gpkg_raster, lyr_daken_ndvi)
os.system(gdal_string_ndvi_daken)

#Remove temp file
ndvi.close()
os.remove(tif_ndvi_temp)

"""
Ouput values:
0 = geen dak
10 = dak,  grijs (vergroenings/verblauwingspotentieel)
20 = dak, groen
"""