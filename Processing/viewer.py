# import the folium, pandas libraries
import os
import folium
import pandas as pd

import geopandas as gpd
from rasterio.mask import mask
import rasterio.mask

#buurtcode = "BU04411401"
buurtcode = "BU03072502"
workingdirectory = os.getcwd()
parent = os.path.dirname(workingdirectory)
tempdirectory = parent + "/tempdata/" + buurtcode + "/"
files_basename = tempdirectory + buurtcode
gpkg_vector = tempdirectory + buurtcode + "_vector.gpkg"
gpkg_raster = tempdirectory + buurtcode + "_raster.gpkg"


gdf_panden = gpd.read_file(gpkg_vector, driver='GPKG', layer='panden')

# initialize the map and store it in a m object
m = folium.Map(location=[50, 5],  zoom_start=4)
folium.GeoJson(gdf_panden["geometry"]).add_to(m)

# show the map
m.save(files_basename + '.html')