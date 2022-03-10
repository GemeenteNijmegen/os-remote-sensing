import area_object
import pandas as pd
import geopandas as gpd
import os
import json
import rasterio
from osgeo import gdal

# maak een buurt aan
buurt = area_object.Buurt("BU07721110")

# haal de grenzen op
buurtgrens = buurt.get_boundaries()

# zet om naar json
json_buurtgrens = json.loads(buurtgrens.to_json())["features"][0]["geometry"]

# definieer pad naar grote luchtfoto (gemapt)
huge_aerial_image_path = os.path.join("Z:", "Data", "raw", "2020_LR_CIR_totaalmozaiek_v2_clip.ecw")
print("Path to raw aerial image exists: {}".format(os.path.exists(huge_aerial_image_path)))

# knip de buurt uit de grote luchtfoto
with rasterio.open(huge_aerial_image_path) as src:
    out_image, out_transform = rasterio.mask.mask(src, json_buurtgrens, crop=True)
    out_meta = src.meta

# sla de buurt op



# def getFeatures(gdf):
#     """Function to parse features from GeoDataFrame in such a manner that rasterio wants them"""
#     import json
#     return [json.loads(gdf.to_json())['features'][0]['geometry']]
#
# #Read buurt polygoon
# coordsbuurt = getFeatures(gdf_buurt)
#
# coordsbuurt
#
# #Clip Luchtfoto with Buurt from Geopackage
# #Source: https://automating-gis-processes.github.io/CSC18/lessons/L6/clipping-raster.html
# with rasterio.open(path_ECW_2020) as src:
#     out_image, out_transform = rasterio.mask.mask(src, coordsbuurt, crop=True)
#     out_meta = src.meta
print("finished!")