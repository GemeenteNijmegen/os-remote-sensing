"""
Next step is to select all buildings (polygons) which have a living function.
"""
#Load required Python libraries
import pandas as pd
import geopandas as gpd
import shapely.speedups
import numpy as np
import matplotlib.pyplot as plt
import warnings

# Load variables
from start import gpkg_vector

#Let’s first enable shapely.speedups which makes some of the spatial queries running faster.
shapely.speedups.enable()

# Read panden in buurt
gdf_panden = gpd.read_file(gpkg_vector, driver='GPKG', layer='panden')
gdf_woningen = gpd.read_file(gpkg_vector, driver='GPKG', layer='woningen')
gdf_percelen = gpd.read_file(gpkg_vector, driver='GPKG', layer='percelen')

gdf_woningen =gdf_woningen.rename(index=str, columns={"identificatie":"vbo_identificatie"})
gdf_panden =gdf_panden.rename(index=str, columns={"identificatie":"pand_identificatie"})

# Selecteer alleen percelen met een verblijfsobject met woonfunctie
gdf_percelenwoonfunctie = gpd.sjoin(gdf_percelen, gdf_woningen[['vbo_identificatie', 'geometry']], how='left', op='intersects')
gdf_percelenwoonfunctie = gdf_percelenwoonfunctie[gdf_percelenwoonfunctie['vbo_identificatie'].notnull()]

#gdf_percelenwoonfunctie.to_file(gpkg_vector, driver='GPKG', layer='test2')

gdf_percelenwoonfunctie = gdf_percelenwoonfunctie.loc[:, ['identificatieLokaalID', 'kadastraleGemeenteCode', 'sectie', 'perceelnummer', 'geometry']]

# Selecteer alleen panden met een verblijfsobject met woonfunctie
gdf_pandenwoonfunctie = gpd.sjoin(gdf_panden, gdf_woningen[['vbo_identificatie', 'geometry']], how='left', op='intersects')
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie[gdf_pandenwoonfunctie['vbo_identificatie'].notnull()]

gdf_pandenwoonfunctie = gdf_pandenwoonfunctie.loc[:, ['pand_identificatie',  'geometry']]

# Nog checken of dit helemaal klopt en over er geen rijen worden verwijderd
gdf_percelenwoonfunctie = gdf_percelenwoonfunctie.loc[~gdf_percelenwoonfunctie.index.duplicated(), :]
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie.loc[~gdf_pandenwoonfunctie.index.duplicated(), :]

tuinen = gpd.overlay(gdf_percelenwoonfunctie, gdf_pandenwoonfunctie, how="symmetric_difference")

tuinen.to_file(gpkg_vector, driver='GPKG', layer='tuinen')