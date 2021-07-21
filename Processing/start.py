"""
Next step is to select all buildings (polygons) which have a living function.
"""
#Load required Python libraries
import geopandas as gpd
import shapely.speedups


# Load variables
from start import gpkg_vector

'''
#temp voor het testen


import os
#buurtcode = "BU04411401"
buurtcode = "BU02000708"
workingdirectory = os.getcwd()
parent = os.path.dirname(workingdirectory)
tempdirectory = parent + "/tempdata/" + buurtcode + "/"
files_basename = tempdirectory + buurtcode
gpkg_vector = tempdirectory + buurtcode + "_vector.gpkg"
'''




#Let’s first enable shapely.speedups which makes some of the spatial queries running faster.
shapely.speedups.enable()

# Read panden in buurt
gdf_panden = gpd.read_file(gpkg_vector, driver='GPKG', layer='panden')
gdf_woningen = gpd.read_file(gpkg_vector, driver='GPKG', layer='woningen')
gdf_percelen = gpd.read_file(gpkg_vector, driver='GPKG', layer='percelen')

gdf_woningen =gdf_woningen.rename(index=str, columns={"identificatie":"vbo_identificatie"})
gdf_panden =gdf_panden.rename(index=str, columns={"identificatie":"pand_identificatie"})

#Selecteren alle panden met de status 'in gebruik' en 'verbouwing'
gdf_pandenwoonfunctie = gdf_panden[gdf_panden['status'].str.contains('Pand in gebruik|Verbouwing pand')]

# Selecteer alleen panden met een verblijfsobject met woonfunctie en logiesfuncties
gdf_pandenwoonfunctie = gpd.sjoin(gdf_panden, gdf_woningen[['vbo_identificatie', 'geometry']], how='left', op='intersects')
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie[gdf_pandenwoonfunctie['vbo_identificatie'].notnull()]

gdf_pandenwoonfunctie = gdf_pandenwoonfunctie.loc[:, ['pand_identificatie', 'vbo_identificatie', 'geometry']]

#Selecteer alleen de panden waarin 1 of 2 verblijfsobjecten liggen (zodat apartementen/flats er uit wordt gefilterd)
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie[gdf_pandenwoonfunctie.groupby('pand_identificatie')['pand_identificatie'].transform('size') >= 1]
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie[gdf_pandenwoonfunctie.groupby('pand_identificatie')['pand_identificatie'].transform('size') <= 2]

#Schrijven panden selectie naar gpkg
gdf_pandenwoonfunctie.to_file(gpkg_vector, driver='GPKG', layer='panden2ofmindervo')

#Panden iets kleiner maken om de juiste selectie van de percelen te maken (er zijn panden die op of net over de perceelgrens lopen)
gdf_pandenwoonfunctie_small = gdf_pandenwoonfunctie.copy()
gdf_pandenwoonfunctie_small['geometry'] = gdf_pandenwoonfunctie_small.geometry.buffer(-1)

#Schrijven panden selectie die gebruikt worden voor de perceel selectie naar gpkg
gdf_pandenwoonfunctie_small.to_file(gpkg_vector, driver='GPKG', layer='panden2ofmindervo_small')

# Selecteer alleen percelen waarop een pand staat met een verblijfsobject met woonfunctie en logiesfunctie
gdf_percelenwoonfunctie = gpd.sjoin(gdf_percelen, gdf_pandenwoonfunctie_small[['vbo_identificatie', 'geometry']], how='left', op='intersects')
gdf_percelenwoonfunctie = gdf_percelenwoonfunctie[gdf_percelenwoonfunctie['vbo_identificatie'].notnull()]

gdf_percelenwoonfunctie = gdf_percelenwoonfunctie.loc[:, ['identificatieLokaalID', 'kadastraleGemeenteCode', 'sectie', 'perceelnummer', 'geometry']]

#TODO Nog checken of dit helemaal klopt en over er geen rijen worden verwijderd
gdf_percelenwoonfunctie = gdf_percelenwoonfunctie.loc[~gdf_percelenwoonfunctie.index.duplicated(), :]
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie.loc[~gdf_pandenwoonfunctie.index.duplicated(), :]

#Schrijven percelen worden panden met een woonfunctie en logiesfunctie naar gpkg
gdf_percelenwoonfunctie.to_file(gpkg_vector, driver='GPKG', layer='percelenwoonfunctie')

#Bereken wat de tuinen zijn (percelen minus de panden)
tuinen = gpd.overlay(gdf_percelenwoonfunctie, gdf_panden, how="symmetric_difference")

import pandas as pd

#Bereken oppervlakte tuinen
tuinen_opp = tuinen.area
tuinen_opp = tuinen_opp.round(2)
#Voeg kolom aan tuinen DF toe
tuinen['opp'] = tuinen_opp

#Selecteer tuinen groter dan 3 meter
tuinen = tuinen[tuinen['opp'] > 3]

#Een tuin moet een perceelnummer bevatten anders zijn het (waarschijnlijk) delen van panden vanwege de overlay in de stap hierboven. Een onjuiste selectie
#TODO methode wellicht verbeteren
tuinen = tuinen[tuinen['perceelnummer'].notnull()]

tuinen.to_file(gpkg_vector, driver='GPKG', layer='tuinen_obv_panden')