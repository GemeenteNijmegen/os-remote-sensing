#Load required Python libraries
from osgeo import gdal, osr
import os, struct
import numpy as np

from time import process_time
t1_start = process_time()

# Load variables
from start import buurtcode, files_basename, gpkg_raster

# Retrieve CIR-TIF from webdav-connection
from webdav3.client import Client
options = {
 'webdav_hostname': "https://datasciencevng.nl/remote.php/webdav/",
 'webdav_login':    "remotesensing",
 'webdav_password': "VNGRS2021!"
}
client = Client(options)

# Download tif
client.download_sync(remote_path="Data/cir2020perbuurt/" + buurtcode +".tif", local_path=files_basename + ".tif")
clip_cir_path = files_basename + ".tif"
fmttypes = {'Byte':'B', 'UInt16':'H', 'Int16':'h', 'UInt32':'I', 'Int32':'i', 'Float32':'f', 'Float64':'d'}

#Open TIF
dataset = gdal.Open(clip_cir_path)

#Get projection
prj = dataset.GetProjection()

## Retrieve RED-band from TIF
# Setting number band (red in this case)
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

BandType = gdal.GetDataTypeName(band.DataType)

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

# Flattened list of raster values
raster = [ item for element in raster for item in element ]

# Transforming list in array
raster = np.asarray(np.reshape(raster, (rows,columns)))

# Writting output raster
dst_ds.GetRasterBand(1).WriteArray( raster )

# Setting extension of output raster
# Top left x, w-e pixel resolution, rotation, top left y, rotation, n-s pixel resolution
dst_ds.SetGeoTransform(geotransform)

# Setting spatial reference of output raster
srs = osr.SpatialReference(wkt = prj)
dst_ds.SetProjection( srs.ExportToWkt() )

# Close output raster dataset
dst_ds = None
###


## Retrieve NIR-band from TIF
# Setting number band (nir in this case)
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

BandType = gdal.GetDataTypeName(band.DataType)

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

# Flattened list of raster values
raster = [ item for element in raster for item in element ]

# Transforming list in array
raster = np.asarray(np.reshape(raster, (rows,columns)))

# Writting output raster
dst_ds.GetRasterBand(1).WriteArray( raster )

# Setting extension of output raster
# Top left x, w-e pixel resolution, rotation, top left y, rotation, n-s pixel resolution
dst_ds.SetGeoTransform(geotransform)

# Setting spatial reference of output raster
srs = osr.SpatialReference(wkt = prj)
dst_ds.SetProjection( srs.ExportToWkt() )

# Close output raster dataset
dst_ds = None
###

##Close main raster dataset
dataset = None


## Write to GPKG - red-tif
sourcetif_red = files_basename + "_red.tif"
lyr_red = "red"
gdal_string_red = 'gdal_translate -of GPKG "{}" "{}" -co RASTER_TABLE={} -co APPEND_SUBDATASET=YES'.format(sourcetif_red, gpkg_raster, lyr_red)
os.system(gdal_string_red)

# nir-tif
sourcetif_nir = files_basename + "_nir.tif"
lyr_nir = "nir"
gdal_string_nir = 'gdal_translate -of GPKG "{}" "{}" -co RASTER_TABLE={} -co APPEND_SUBDATASET=YES'.format(sourcetif_nir, gpkg_raster, lyr_nir)
os.system(gdal_string_nir)

# Stop the stopwatch / counter
t1_stop = process_time()
print("Export red and nir runtime is ", round(t1_stop - t1_start,1), "seconds")
print("Export red and nir process finished \n")
