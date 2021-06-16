from osgeo import gdal, osr
import os, struct
import numpy as np

# Load variables
from variables import *

#Dit is een QGIS command
#layer = iface.activeLayer()
#provider = layer.dataProvider()
#path = provider.dataSourceUri()


from webdav3.client import Client
options = {
 'webdav_hostname': "https://datasciencevng.nl/remote.php/webdav/",
 'webdav_login':    "remotesensing",
 'webdav_password': "VNGRS2021!"
}
client = Client(options)

client.download_sync(remote_path="Data/cir2020perbuurt/" + buurtcode +".tif", local_path=files_basename + ".tif")

clip_cir_path = files_basename + ".tif"

fmttypes = {'Byte':'B', 'UInt16':'H', 'Int16':'h', 'UInt32':'I', 'Int32':'i', 'Float32':'f', 'Float64':'d'}

#Openen van TIF
dataset = gdal.Open(clip_cir_path)
#print(dataset)

#Get projection
prj = dataset.GetProjection()
print(prj)

## RED

#setting number band (red in this case)
number_band = 2
colour = str("red")

band = dataset.GetRasterBand(number_band)

geotransform = dataset.GetGeoTransform()

# Set name of output raster
if number_band == 2:
    output_file = files_basename + "_" + colour + ".tif"

# Create gtif file with rows and columns from parent raster
driver = gdal.GetDriverByName("GTiff")

columns, rows = (band.XSize, band.YSize)

print ("rows = %d columns = %d" % (columns, rows))

BandType = gdal.GetDataTypeName(band.DataType)

print("Band Type = ", BandType)

raster = []

for y in range(band.YSize):

    scanline = band.ReadRaster(0, y, band.XSize, 1, band.XSize, 1, band.DataType)
    values = struct.unpack(fmttypes[BandType] * band.XSize, scanline)
    raster.append(values)

dst_ds = driver.Create(output_file,
                       columns,
                       rows,
                       1,
                       band.DataType)

#flattened list of raster values
raster = [ item for element in raster for item in element ]

#transforming list in array
raster = np.asarray(np.reshape(raster, (rows,columns)))

##writting output raster
dst_ds.GetRasterBand(1).WriteArray( raster )

#setting extension of output raster
# top left x, w-e pixel resolution, rotation, top left y, rotation, n-s pixel resolution
dst_ds.SetGeoTransform(geotransform)

# setting spatial reference of output raster
srs = osr.SpatialReference(wkt = prj)
dst_ds.SetProjection( srs.ExportToWkt() )

#Close output raster dataset
dst_ds = None
###

### NIR

#setting number band (red in this case)
number_band = 1
colour = str("nir")

band = dataset.GetRasterBand(number_band)

geotransform = dataset.GetGeoTransform()

# Set name of output raster
if number_band == 1:
    output_file = files_basename + "_" + colour + ".tif"

# Create gtif file with rows and columns from parent raster
driver = gdal.GetDriverByName("GTiff")

columns, rows = (band.XSize, band.YSize)

print ("rows = %d columns = %d" % (columns, rows))

BandType = gdal.GetDataTypeName(band.DataType)

print("Band Type = ", BandType)

raster = []

for y in range(band.YSize):

    scanline = band.ReadRaster(0, y, band.XSize, 1, band.XSize, 1, band.DataType)
    values = struct.unpack(fmttypes[BandType] * band.XSize, scanline)
    raster.append(values)

dst_ds = driver.Create(output_file,
                       columns,
                       rows,
                       1,
                       band.DataType)

#flattened list of raster values
raster = [ item for element in raster for item in element ]

#transforming list in array
raster = np.asarray(np.reshape(raster, (rows,columns)))

##writting output raster
dst_ds.GetRasterBand(1).WriteArray( raster )

#setting extension of output raster
# top left x, w-e pixel resolution, rotation, top left y, rotation, n-s pixel resolution
dst_ds.SetGeoTransform(geotransform)

# setting spatial reference of output raster
srs = osr.SpatialReference(wkt = prj)
dst_ds.SetProjection( srs.ExportToWkt() )

#Close output raster dataset
dst_ds = None
###

##Close main raster dataset
dataset = None


## Write to GPKG

# Red
sourcetif_red = files_basename + "_red.tif"
lyr_red = "red"
gdal_string_red = 'gdal_translate -of GPKG "{}" "{}" -co RASTER_TABLE={} -co APPEND_SUBDATASET=YES'.format(sourcetif_red, gpkg_raster, lyr_red)
os.system(gdal_string_red)

#Nir
sourcetif_nir = files_basename + "_nir.tif"
lyr_nir = "nir"
gdal_string_nir = 'gdal_translate -of GPKG "{}" "{}" -co RASTER_TABLE={} -co APPEND_SUBDATASET=YES'.format(sourcetif_nir, gpkg_raster, lyr_nir)
os.system(gdal_string_nir)

#TODO eventueel
#"C:\Program Files\GDAL\gdal_translate.exe" -of GTiff -a_nodata 0 "\\apeldoorn.nl\base$\groupdata\DatalAP\Innovatie\VNG_Remote_Sensing\werk\tempdata\BU03638600_red.tif" "\\apeldoorn.nl\base$\groupdata\DatalAP\Innovatie\VNG_Remote_Sensing\werk\tempdata\BU03638600_rednodata.tif"


input_raster = gdal.Open(sourcetif_red)
output_raster = files_basename + "_red_reproj.tif"

gdal.Warp(output_raster,input_raster,dstSRS="epsg:28992")


input_raster_nir = gdal.Open(sourcetif_nir)
output_raster_nir = files_basename + "_nir_reproj.tif"

gdal.Warp(output_raster_nir,input_raster_nir,dstSRS="epsg:28992")
