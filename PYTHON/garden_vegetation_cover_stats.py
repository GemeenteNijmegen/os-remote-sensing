#Load required Python libraries
from rasterstats import zonal_stats
import pandas as pd
import geopandas as gpd

# Load variables
from start import files_basename, gpkg_vector

#Source of code
#https://gis.stackexchange.com/questions/408583/zonal-histogram-python

"""
Calculate percentage green for each garden
"""
#Input tif and gardens
raster = files_basename + "_tuinen_ndvi_classified.tif"
df = gpd.read_file(gpkg_vector, driver='GPKG', layer='tuinen')

zs = zonal_stats(vectors=df['geometry'], raster=raster, categorical=True)
dfz = pd.DataFrame(zs).fillna(0)

dfz_perc = dfz.apply(lambda x: round(x/x.sum()*100,1), axis=1) #From pixel count to percentage
dfres = pd.merge(left=df, right=dfz_perc, how='left', left_index=True, right_index=True)

#Change column data types to string for all columns
dfres.columns = dfres.columns.astype(str)

if '10' in dfres.columns:
    dfres.rename(columns={'10': 'pWATER'}, inplace=True)
    #Afronden kolommen naar 0 decimalen
    dfres['pWATER'] = dfres['pWATER'].astype(float)
    dfres['pWATER'] = dfres['pWATER'] + 0.5
    dfres['pWATER'] = dfres['pWATER'].fillna(0)
    dfres['pWATER'] = dfres['pWATER'].astype(int)
    dfres['perceelnummer'] = dfres['perceelnummer'].astype(int)

if '20' in dfres.columns:
    dfres.rename(columns={'20': 'pVERGROENINGSPOTENTIE'}, inplace=True)
    #Afronden kolommen naar 0 decimalen
    dfres['pVERGROENINGSPOTENTIE'] = dfres['pVERGROENINGSPOTENTIE'].astype(float)
    dfres['pVERGROENINGSPOTENTIE'] = dfres['pVERGROENINGSPOTENTIE'] + 0.5
    dfres['pVERGROENINGSPOTENTIE'] = dfres['pVERGROENINGSPOTENTIE'].fillna(0)
    dfres['pVERGROENINGSPOTENTIE'] = dfres['pVERGROENINGSPOTENTIE'].astype(int)
    dfres['perceelnummer'] = dfres['perceelnummer'].astype(int)

if '30' in dfres.columns:
    dfres.rename(columns={'30': 'pGROEN'}, inplace=True)
    #Afronden kolommen naar 0 decimalen
    dfres['pGROEN'] = dfres['pGROEN'].astype(float)
    dfres['pGROEN'] = dfres['pGROEN'] + 0.5
    dfres['pGROEN'] = dfres['pGROEN'].fillna(0)
    dfres['pGROEN'] = dfres['pGROEN'].astype(int)
    dfres['perceelnummer'] = dfres['perceelnummer'].astype(int)

dfres = dfres.loc[dfres['pGROEN'] * dfres['pGROEN'] != 0]

# Write tuinen_stats-polygon to gpkg
dfres.to_file(gpkg_vector, driver='GPKG', layer='tuinen_stats', index=False)
