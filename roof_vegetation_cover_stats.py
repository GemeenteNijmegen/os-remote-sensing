#Import libraries
import os
from rasterstats import zonal_stats
import pandas as pd
import geopandas as gpd

from start import files_basename #werkt niet, zit ergens een lock op een tif uit start.py
from start import gpkg_vector #werkt niet, zit ergens een lock op een tif uit start.py

#Source of code
#https://gis.stackexchange.com/questions/408583/zonal-histogram-python

"""
Hieronder wordt het percentage groen per dak berekend.
"""
#Input voor percentage groen berekening
raster = files_basename + "_roofs_ndvi_3_classes.tif"
#zones = files_basename + "_tuinen_polygon.shp"

#Berekening percentage groen dmv dataframe
df = gpd.read_file(gpkg_vector, driver='GPKG', layer='daken')
zs = zonal_stats(vectors=df['geometry'], raster=raster, categorical=True)
dfz = pd.DataFrame(zs).fillna(0)

dfz_perc = dfz.apply(lambda x: round(x/x.sum()*100,1), axis=1) #From pixel count to percentage
dfres = pd.merge(left=df, right=dfz_perc, how='left', left_index=True, right_index=True)

#Hernoemen kolom '10'
#'10' = perc_groen (percentage groen)
# '20' = overige percentage (totaal - percentage groen)

#Change column data types to string for all columns
dfres.columns = dfres.columns.astype(str)

#Get data type for each column
print(dfres.columns.map(type))

#delete column, this column contains 100% - percentage vegetation
del dfres['20']

dfres.rename(columns={'10': 'pGROEN'}, inplace=True)

#Afronden kolommen naar 0 decimalen
dfres['pGROEN'] = dfres['pGROEN'].astype(float)
dfres['pGROEN'] = dfres['pGROEN'] + 0.5
dfres['pGROEN'] = dfres['pGROEN'].astype(int)
# dfres['perceelnummer'] = dfres['perceelnummer'].astype(int)

#Get column names dataframe
print(dfres.columns.tolist())

#Wegschrijven naar shapefile
#dfres.to_file(zones)

dfres.to_file(gpkg_vector, driver='GPKG', layer='roofs_stats')