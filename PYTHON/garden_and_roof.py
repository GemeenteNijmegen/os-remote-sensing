#Load required Python libraries
import geopandas as gpd
import shapely.speedups

# Load variables
from start import gpkg_vector

'''
#INVOEREN GEWENSTE BUURTCODE
import os
buurtcode = "BU02000102"
workingdirectory = os.getcwd()
parent = os.path.dirname(workingdirectory)
tempdirectory = parent + "/tempdata/" + buurtcode + "/"
files_basename = tempdirectory + buurtcode
gpkg_vector = tempdirectory + buurtcode + "_vector.gpkg"
gpkg_raster = tempdirectory + buurtcode + "_raster.gpkg"
'''

## Start garden and roof selection script
#Let’s first enable shapely.speedups which makes some of the spatial queries running faster.
shapely.speedups.enable()

# Read input files from gpkg
gdf_panden = gpd.read_file(gpkg_vector, driver='GPKG', layer='panden')
gdf_woningen = gpd.read_file(gpkg_vector, driver='GPKG', layer='woningen')
gdf_percelen = gpd.read_file(gpkg_vector, driver='GPKG', layer='percelen')

# Rename columns
gdf_woningen =gdf_woningen.rename(index=str, columns={"identificatie":"vbo_identificatie"})
gdf_panden =gdf_panden.rename(index=str, columns={"identificatie":"pand_identificatie"})

# Filter all panden with status 'in gebruik' and 'verbouwing'
gdf_pandenwoonfunctie = gdf_panden[gdf_panden['status'].str.contains('Pand in gebruik|Verbouwing pand')]

# Filter panden with verblijfsobject with woonfunctie and logiesfunctie
gdf_pandenwoonfunctie = gpd.sjoin(gdf_panden, gdf_woningen[['vbo_identificatie', 'geometry']], how='left', op='intersects')
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie[gdf_pandenwoonfunctie['vbo_identificatie'].notnull()]

# Write roofs to gpkg
#gdf_pandenwoonfunctie.to_file(gpkg_vector, driver='GPKG', layer='daken')

# Select columns
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie.loc[:, ['pand_identificatie', 'vbo_identificatie', 'geometry']]


## Select parcels with 1 or 2 verblijfsobjecten
#Selecteer alleen de panden waarin 1 of 2 verblijfsobjecten liggen (zodat apartementen/flats er uit wordt gefilterd)
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie[gdf_pandenwoonfunctie.groupby('pand_identificatie')['pand_identificatie'].transform('size') >= 1]
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie[gdf_pandenwoonfunctie.groupby('pand_identificatie')['pand_identificatie'].transform('size') <= 2]

#Write panden selection to gpkg
#gdf_pandenwoonfunctie.to_file(gpkg_vector, driver='GPKG', layer='pandenwoonfunctie')

# Make panden a little smaller (negative buffer) in order to get the correct percelen. There are panden who cross the perceel-border
gdf_pandenwoonfunctie_small = gdf_pandenwoonfunctie.copy()
gdf_pandenwoonfunctie_small['geometry'] = gdf_pandenwoonfunctie_small.geometry.buffer(-1)

# Write panden selection which is used for perceel selection to gpkg
#gdf_pandenwoonfunctie_small.to_file(gpkg_vector, driver='GPKG', layer='pandenwoonfunctie_small')

# Select percelen with pand who contain woonfunctie or logiesfunctie
gdf_percelenwoonfunctie = gpd.sjoin(gdf_percelen, gdf_pandenwoonfunctie_small[['vbo_identificatie', 'geometry']], how='left', op='intersects')
gdf_percelenwoonfunctie = gdf_percelenwoonfunctie[gdf_percelenwoonfunctie['vbo_identificatie'].notnull()]

# Select columns
gdf_percelenwoonfunctie = gdf_percelenwoonfunctie.loc[:, ['identificatieLokaalID', 'kadastraleGemeenteCode', 'sectie', 'perceelnummer', 'geometry']]

#TODO Nog checken of dit helemaal klopt en of er geen rijen worden verwijderd
gdf_percelenwoonfunctie = gdf_percelenwoonfunctie.loc[~gdf_percelenwoonfunctie.index.duplicated(), :]
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie.loc[~gdf_pandenwoonfunctie.index.duplicated(), :]


## Select parcels with 3 or more verblijfsobjecten
gdf_flats = gdf_pandenwoonfunctie[gdf_pandenwoonfunctie.groupby('pand_identificatie')['pand_identificatie'].transform('size') >= 3]
gdf_flats

# Clip verblijfsobjecten with flats
gdf_flats_vo = gpd.clip(gdf_woningen, gdf_flats)

# Select percelen with pand who contain woonfunctie or logiesfunctie
gdf_percelenflats = gpd.sjoin(gdf_percelen, gdf_flats_vo[['vbo_identificatie', 'geometry']], how='left', op='intersects')
gdf_percelenflats = gdf_percelenflats[gdf_percelenflats['vbo_identificatie'].notnull()]

# Select columns
gdf_percelenflats = gdf_percelenflats.loc[:, ['identificatieLokaalID', 'kadastraleGemeenteCode', 'sectie', 'perceelnummer', 'geometry']]


gdf_percelenwoonfunctie_totaal = gdf_percelenwoonfunctie.append(gdf_percelenflats)




# Write perceel selection to gpkg
gdf_percelenwoonfunctie_totaal.to_file(gpkg_vector, driver='GPKG', layer='percelenwoonfunctie')

# Calculate gardens (perceel selection minus de panden)
tuinen = gpd.overlay(gdf_percelenwoonfunctie_totaal, gdf_panden, how="symmetric_difference")

#Bereken oppervlakte tuinen
tuinen_opp = tuinen.area
tuinen_opp = tuinen_opp.round(2)
#Voeg kolom aan tuinen DF toe
tuinen['opp'] = tuinen_opp

#Selecteer tuinen groter dan 3 meter
#tuinen = tuinen[tuinen['opp'] > 3]

# A garden needs to have a perceelnummer otherwise the garden selection is likely selected because of an overlay in the previous step.
#TODO methode wellicht verbeteren
tuinen = tuinen[tuinen['perceelnummer'].notnull()]

# Write garden to gpkg
tuinen.to_file(gpkg_vector, driver='GPKG', layer='tuinen')