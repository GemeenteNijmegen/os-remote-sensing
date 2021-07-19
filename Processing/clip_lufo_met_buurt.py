# Load required Python libraries
import geopandas as gpd

# Load variables
from variables import *



# Read buurt
gdf_buurt = gpd.read_file(gpkg_vector, driver='GPKG', layer='buurt')

# Lijkt alleen op deze volgorde te werken. Liever allee libraries in één keer inladen, maar dat werkt niet goed

#Rest van libraries inladen
from osgeo import gdal
import rasterio
from rasterio.mask import mask
from rasterio.plot import show
import fiona
import rasterio.mask

def getFeatures(gdf):
    """Function to parse features from GeoDataFrame in such a manner that rasterio wants them"""
    import json
    return [json.loads(gdf.to_json())['features'][0]['geometry']]

#Read buurt polygoon
coordsbuurt = getFeatures(gdf_buurt)

#Clip Luchtfoto with Buurt from Geopackage
#Source: https://automating-gis-processes.github.io/CSC18/lessons/L6/clipping-raster.html
with rasterio.open(path_ECW_2020) as src:
    out_image, out_transform = rasterio.mask.mask(src, coordsbuurt, crop=True)
    out_meta = src.meta

out_meta.update({"driver": "GTiff",
                 "height": out_image.shape[1],
                 "width": out_image.shape[2],
                 "transform": out_transform})

#Write clipped tif
with rasterio.open(files_basename + ".tif", "w", **out_meta) as dest:
    dest.write(out_image)

#Write to GPKG
import os
desGPKG = gpkg_raster
sourcetif_cir = files_basename + ".tif"

lyr_cir = "cir"
gdal_string_cir = 'gdal_translate -of GPKG "{}" "{}" -co RASTER_TABLE={} -co APPEND_SUBDATASET=YES'.format(sourcetif_cir, desGPKG, lyr_cir)
os.system(gdal_string_cir)







#########################
"""
sourcetif = workingdirectory + "/tempdata/" + buurtcode + ".tif"
desGPKG = workingdirectory + "/tempdata/" + buurtcode + "_raster.gpkg"
layername = 'cir'

import subprocess
args ='gdal_translate -of GPKG -co APPEND_SUBDATASET=YES RASTER_TABLE='test''  + sourcetif + ' ' + desGPKG
subprocess.call(args, shell=True)





#Testen
sourcetif = workingdirectory + "/tempdata/" + buurtcode + ".tif"
desGPKG = workingdirectory + "/tempdata/" + buurtcode + ".gpkg"
gdal.Translate(desGPKG, sourcetif, format='GPKG', APPEND_SUBDATASET='YES', RASTER_TABLE='new_table')






# Dit werkt
!gdal_translate -of JPEG "\\apeldoorn.nl\base$\groupdata\DatalAP\Innovatie\VNG_Remote_Sensing\GroeneDaken\Werk\tempdata\BU03638600.tif" "test.jpg"
#

#Dit werkt ook
desJPEG = "test.jpg"
gdal.Translate(desJPEG, sourcetif, format='JPEG')
#


# Dit werkt - convert tif to raster gpkg
srctif = gdal.Open(workingdirectory + "/tempdata/" + buurtcode + ".tif")
desGPKGRaster = workingdirectory + "/tempdata/" + buurtcode + "_raster.gpkg"

gdal.Translate(desGPKGRaster, srctif, format='GPKG')
#


#Testen
sourcetif = workingdirectory + "/tempdata/" + buurtcode + ".tif"
desGPKG = workingdirectory + "/tempdata/" + buurtcode + ".gpkg"
gdal.Translate(desGPKG, sourcetif, format='GPKG', APPEND_SUBDATASET='YES', RASTER_TABLE='new_table')


import subprocess
args ='gdal.Translate -of GPKG -co APPEND_SUBDATASET=YES -co RASTER_TABLE=new_table ' + sourcetif + ' ' + desGPKG
subprocess.call(args, shell=True)


subprocess.call('gdal.Translate -of GPKG -co APPEND_SUBDATASET=YES -co RASTER_TABLE=new_table ', sourcetif, ' ', desGPKG)


sourcetif = '//apeldoorn.nl/base$/groupdata/DatalAP/Innovatie/VNG_Remote_Sensing/werk/tempdata/BU03638600.tif'
sourcetif = workingdirectory + "/tempdata/" + buurtcode + ".tif"




srctif = gdal.Open(workingdirectory + "/tempdata/" + buurtcode + ".tif")
desGPKGRaster = workingdirectory + "/tempdata/" + buurtcode + "_raster.gpkg"

gdal.Translate(desGPKGRaster, srctif, format='GPKG')

desGPKG = workingdirectory + "/tempdata/" + buurtcode + ".gpkg"


args ='ogr2ogr -f gpkg ' + desGPKG + ' ' + desGPKGRaster

ogr2ogr -f gpkg desGPKG.gpkg desGPKGRaster.gpkg

import subprocess
subprocess.call(args, shell=True)




gdal_translate -of GPKG out_image".tif" workingdirectory + "/tempdata/" + buurtcode + ".gpkg".gpkg -co  APPEND_SUBDATASET=YES -co RASTER_TABLE=new_table
"""