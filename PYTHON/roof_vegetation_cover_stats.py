#Load required Python libraries
from rasterstats import zonal_stats
import pandas as pd
import geopandas as gpd

# Load variables
from start import files_basename, gpkg_vector

#Source of code
#https://gis.stackexchange.com/questions/408583/zonal-histogram-python

"""
Calculate percentage green for each roof
"""
#Input tif and roof
raster = files_basename + "_daken_ndvi_classified.tif"
df = gpd.read_file(gpkg_vector, driver='GPKG', layer='daken')

zs = zonal_stats(vectors=df['geometry'], raster=raster, categorical=True)
dfz = pd.DataFrame(zs).fillna(0)

dfz_perc = dfz.apply(lambda x: round(x/x.sum()*100,1), axis=1) #From pixel count to percentage
dfres = pd.merge(left=df, right=dfz_perc, how='left', left_index=True, right_index=True)

#Change column data types to string for all columns
dfres.columns = dfres.columns.astype(str)

if '10' in dfres.columns:
    dfres.rename(columns={'10': 'pGRIJS'}, inplace=True)
    #Afronden kolommen naar 0 decimalen
    dfres['pGRIJS'] = dfres['pGRIJS'].astype(float)
    dfres['pGRIJS'] = dfres['pGRIJS'] + 0.5
    dfres['pGRIJS'] = dfres['pGRIJS'].fillna(0)
    dfres['pGRIJS'] = dfres['pGRIJS'].astype(int)

if '20' in dfres.columns:
    dfres.rename(columns={'20': 'pGROEN'}, inplace=True)
    #Afronden kolommen naar 0 decimalen
    dfres['pGROEN'] = dfres['pGROEN'].astype(float)
    dfres['pGROEN'] = dfres['pGROEN'] + 0.5
    dfres['pGROEN'] = dfres['pGROEN'].fillna(0)
    dfres['pGROEN'] = dfres['pGROEN'].astype(int)

dfres = dfres.loc[dfres['pGROEN'] * dfres['pGROEN'] != 0]

# Write tuinen_stats-polygon to gpkg
dfres.to_file(gpkg_vector, driver='GPKG', layer='daken_stats')
