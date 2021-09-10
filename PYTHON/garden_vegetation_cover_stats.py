#Import libraries
from rasterstats import zonal_stats
import pandas as pd
import geopandas as gpd

#from start import files_basename, gpkg_vector

import os
buurtcode = "BU03634002"
workingdirectory = os.getcwd()
parent = os.path.dirname(workingdirectory)
tempdirectory = parent + "/tempdata/" + buurtcode + "/"
files_basename = tempdirectory + buurtcode
gpkg_vector = tempdirectory + buurtcode + "_vector.gpkg"


#Source of code
#https://gis.stackexchange.com/questions/408583/zonal-histogram-python

"""
Hieronder wordt het percentage groen per tuin berekend.
"""
#Input voor percentage groen berekening
raster = files_basename + "_tuinen_ndvi_3_classes.tif"
#zones = files_basename + "_tuinen_polygon.shp"

#Berekening percentage groen dmv dataframe
df = gpd.read_file(gpkg_vector, driver='GPKG', layer='tuinen')
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
#print(dfres.columns.map(type))

#delete column, this column contains 100% - percentage vegetation
#del dfres['20']

if '10' in dfres.columns:
    dfres.rename(columns={'10': 'pGROEN'}, inplace=True)
    #Afronden kolommen naar 0 decimalen
    dfres['pGROEN'] = dfres['pGROEN'].astype(float)
    dfres['pGROEN'] = dfres['pGROEN'] + 0.5
    dfres['pGROEN'] = dfres['pGROEN'].fillna(0)
    dfres['pGROEN'] = dfres['pGROEN'].astype(int)
    dfres['perceelnummer'] = dfres['perceelnummer'].astype(int)

if '20' in dfres.columns:
    dfres.rename(columns={'20': 'pGRIJS'}, inplace=True)
    #Afronden kolommen naar 0 decimalen
    dfres['pGRIJS'] = dfres['pGRIJS'].astype(float)
    dfres['pGRIJS'] = dfres['pGRIJS'] + 0.5
    dfres['pGRIJS'] = dfres['pGRIJS'].fillna(0)
    dfres['pGRIJS'] = dfres['pGRIJS'].astype(int)
    dfres['perceelnummer'] = dfres['perceelnummer'].astype(int)

#Get column names dataframe
#print(dfres.columns.tolist())

#Wegschrijven naar shapefile
#dfres.to_file(zones)

dfres.to_file(gpkg_vector, driver='GPKG', layer='tuinen_stats')

print("Garden vegetation cover stats process finished")