
# see how ecw file looks like
# docker run --rm -it --volume //c/Users/hansw/OneDrive/Documents/Projects/VNG/ZichtGroen/tryout/data:/data indigoilya/gdal-docker:latest gdalinfo ../data/valencia2002.ecw
"""
Driver: ECW/ERDAS Compressed Wavelets (SDK 5.4)
Files: ../data/valencia2002.ecw
Size is 45899, 37169
Coordinate System is:
LOCAL_CS["LOCAL - (unsupported)",
    UNIT["Meter",1]]
Origin = (720135.515106672421098,4376935.971940883435309)
Pixel Size = (0.299886000000000,-0.299886000000000)
Metadata:
  COLORSPACE=RGB
  COMPRESSION_RATE_TARGET=20
  VERSION=2
Corner Coordinates:
Upper Left  (  720135.515, 4376935.972)
Lower Left  (  720135.515, 4365789.509)
Upper Right (  733899.983, 4376935.972)
Lower Right (  733899.983, 4365789.509)
Center      (  727017.749, 4371362.741)
Band 1 Block=256x256 Type=Byte, ColorInterp=Red
  Description = Red
  Overviews: 22949x18584, 11474x9292, 5737x4646, 2868x2323, 1434x1161, 717x580, 358x290, 179x145
Band 2 Block=256x256 Type=Byte, ColorInterp=Green
  Description = Green
  Overviews: 22949x18584, 11474x9292, 5737x4646, 2868x2323, 1434x1161, 717x580, 358x290, 179x145
Band 3 Block=256x256 Type=Byte, ColorInterp=Blue
  Description = Blue
  Overviews: 22949x18584, 11474x9292, 5737x4646, 2868x2323, 1434x1161, 717x580, 358x290, 179x145
"""

# translate the ecw file to a small tif file:
# docker run --rm -it --volume //c/Users/hansw/OneDrive/Documents/Projects/VNG/ZichtGroen/tryout/data:/data indigoilya/gdal-docker:latest gdal_translate ../data/valencia2002.ecw ../data/valencia.tif -outsize 1% 1%

# read valencia

# plot valencia

# create shapefile
import fiona
from fiona.crs import from_epsg
from shapely.geometry import Polygon, mapping

polygon = [(-1, 0), (0, 1), (1, 0)]
polygon = [
    (727017.749, 4371362.741),
    (728017.749, 4372362.741),
    (726017.749, 4372362.741)
]

outname = "val.shp"
schema = {
    "geometry": "Polygon",
    'properties': {
        'id': 'int'
    }
}

# write your shapefile
with fiona.open(outname, 'w', 'ESRI Shapefile', schema=schema) as out:
    linestring = Polygon(polygon)
    out.write({
      'geometry': mapping(linestring),
      'properties': {'id': 1}
    })


# use this shape-file to cut a triangle out of valencia
# docker run --rm -it --volume //c/Users/hansw/OneDrive/Documents/Projects/VNG/ZichtGroen/tryout/data:/data indigoilya/gdal-docker:latest gdalwarp -cutline ../data/val.shp -crop_to_cutline  ../data/valencia2002.ecw ../data/test.tif

# docker run --rm -it --volume //d/data:/data indigoilya/gdal-docker:latest gdalwarp -cutline ../data/val.shp -crop_to_cutline  ../data/valencia2002.ecw ../data/test.tif
