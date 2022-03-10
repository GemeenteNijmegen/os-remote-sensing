import area_object
import pandas as pd
import geopandas as gpd
import os
from osgeo import gdal

# gpkg_vector = os.path.join("..", "..", "output", "BU07721110", "BU07721110_vector.gpkg")
# gdf = gpd.read_file(gpkg_vector, driver='GPKG', layer='tuinen_stats')
#
# ndvi = gdal.Open(os.path.join("..", "..", "output", "BU07721110", "BU07721110_ndvi.tif"))
# im = ndvi.ReadAsArray()


buurt = area_object.Buurt("BU07721110")

# get statistics as DataFrame and transform into percentages
df = pd.DataFrame(buurt.get_stats()).apply(lambda row: row/row.sum(), axis=1)

print(df)

print("finished!")
