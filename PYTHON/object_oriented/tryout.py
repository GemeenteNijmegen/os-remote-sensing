import area_object
import pandas as pd
import geopandas as gpd
import os
import numpy as np
from osgeo import gdal
import matplotlib.pyplot as plt
from webdav3.client import Client
from dotenv import load_dotenv

load_dotenv()
# gpkg_vector = os.path.join("..", "..", "output", "BU07721110", "BU07721110_vector.gpkg")
# gdf = gpd.read_file(gpkg_vector, driver='GPKG', layer='tuinen_stats')
#
# ndvi = gdal.Open(os.path.join("..", "..", "output", "BU07721110", "BU07721110_ndvi.tif"))
# im = ndvi.ReadAsArray()

options = {
    'webdav_hostname': "https://datasciencevng.nl/remote.php/webdav/",
    'webdav_login': os.getenv("WEBDAV_USERNAME"),
    'webdav_password': os.getenv("WEBDAV_PASSWORD")
}
client = Client(options)

files = client.list("Data/cir2020perbuurt/")


buurt = area_object.Buurt("BU07721110")

# get statistics as DataFrame and transform into percentages
df = pd.DataFrame(buurt.get_stats()).apply(lambda row: row/row.sum(), axis=1)

im = buurt.get_NDVI()

fig, ax = plt.subplots(1, 1)
pos = ax.imshow(im, cmap="summer_r")

# add the colorbar using the figure's method,
# telling which mappable we're talking about and
# which axes object it should be near
fig.colorbar(pos, ax=ax)
plt.show()

print(df)

print("finished!")
