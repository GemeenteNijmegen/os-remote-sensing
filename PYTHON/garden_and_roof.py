#Load required Python libraries
import geopandas as gpd
import shapely.speedups

# Load variables
from start import gpkg_vector, yearAerialPhoto

## Start garden and roof selection script
#Let’s first enable shapely.speedups which makes some of the spatial queries running faster.
shapely.speedups.enable()

# Read input files from gpkg
gdf_panden = gpd.read_file(gpkg_vector, driver='GPKG', layer='panden')
gdf_woningen = gpd.read_file(gpkg_vector, driver='GPKG', layer='woningen')
gdf_percelen = gpd.read_file(gpkg_vector, driver='GPKG', layer='percelen')

# Rename columns
gdf_woningen =gdf_woningen.rename(index=str, columns={"identificatie":"vbo_identificatie"})
gdf_panden = gdf_panden.rename(index=str, columns={"identificatie":"pand_identificatie"})

#
gdf_panden = gdf_panden[gdf_panden['bouwjaar'] < yearAerialPhoto]


# Filter all panden with status 'in gebruik' and 'verbouwing'
gdf_pandenwoonfunctie = gdf_panden[gdf_panden['status'].str.contains('Pand in gebruik|Verbouwing pand')]

# Filter panden with verblijfsobject with woonfunctie and logiesfunctie
gdf_pandenwoonfunctie = gpd.sjoin(gdf_panden, gdf_woningen[['vbo_identificatie', 'geometry']], how='left', op='intersects')
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie[gdf_pandenwoonfunctie['vbo_identificatie'].notnull()]

# Select columns
gdf_pandenwoonfunctie = gdf_pandenwoonfunctie.loc[:, ['pand_identificatie', 'vbo_identificatie', 'geometry']]

### LAAGBOUW
#Selecteer alleen de panden waarin 1 verblijfsobjecten ligt (zodat apartementen/flats er uit wordt gefilterd)
gdf_laagbouw= gdf_pandenwoonfunctie[gdf_pandenwoonfunctie.groupby('pand_identificatie')['pand_identificatie'].transform('size') == 1]

#Write panden selection to gpkg
gdf_laagbouw.to_file(gpkg_vector, driver='GPKG', layer='laagbouw_woonfunctie')

# Select parcels with minimum of 1 pand with woon- or logiesfunctie
# Make panden a little smaller (negative buffer) in order to get the correct percelen. There are panden who cross the perceel-border
gdf_laagbouw_small = gdf_laagbouw.copy()
gdf_laagbouw_small['geometry'] = gdf_laagbouw_small.geometry.buffer(-1)

gdf_laagbouw_small.to_file(gpkg_vector, driver='GPKG', layer='laagbouw_small')

#gdf_laagbouw_small.to_file(gpkg_vector, driver='GPKG', layer='laagbouw_small')

# Select percelen with pand who contain woonfunctie or logiesfunctie
gdf_percelen_laagbouw = gpd.sjoin(gdf_percelen, gdf_laagbouw_small[['vbo_identificatie', 'geometry']], how='left', op='intersects')
gdf_percelen_laagbouw = gdf_percelen_laagbouw[gdf_percelen_laagbouw['vbo_identificatie'].notnull()]
gdf_percelen_laagbouw = gdf_percelen_laagbouw.drop_duplicates(subset=['identificatieLokaalID'])

gdf_percelen_laagbouw.to_file(gpkg_vector, driver='GPKG', layer='laagbouw_percelen')


### FLATS
## Select parcels with 2 or more verblijfsobjecten
gdf_flats = gdf_pandenwoonfunctie[gdf_pandenwoonfunctie.groupby('pand_identificatie')['pand_identificatie'].transform('size') >= 2]

# Clip verblijfsobjecten with flats
gdf_flats_vo = gpd.clip(gdf_woningen, gdf_flats)

# Select percelen with pand who contain woonfunctie or logiesfunctie
gdf_percelen_flats = gpd.sjoin(gdf_percelen, gdf_flats_vo[['vbo_identificatie', 'geometry']], how='left', op='intersects')
gdf_percelen_flats = gdf_percelen_flats[gdf_percelen_flats['vbo_identificatie'].notnull()]
gdf_percelen_flats = gdf_percelen_flats.drop_duplicates(subset=['identificatieLokaalID'])

gdf_percelen_flats.to_file(gpkg_vector, driver='GPKG', layer='flats_percelen')

### PERCELEN WOONFUNCTIE
gdf_percelenwoonfunctie_totaal = gdf_percelen_laagbouw.append(gdf_percelen_flats)

gdf_percelenwoonfunctie_totaal.to_file(gpkg_vector, driver='GPKG', layer='percelen_woonfunctie_totaal')

# Filter only features with geometry type 'polygon'
gdf_percelenwoonfunctie_totaal = gdf_percelenwoonfunctie_totaal[gdf_percelenwoonfunctie_totaal.geom_type == 'Polygon']
gdf_panden = gdf_panden[gdf_panden.geom_type == 'Polygon']

######### Garden
# Calculate gardens (perceel selection minus de panden)
tuinen = gpd.overlay(gdf_percelenwoonfunctie_totaal, gdf_panden, how="symmetric_difference")

#Bereken oppervlakte tuinen
tuinen_opp = tuinen.area
tuinen_opp = tuinen_opp.round(2)
#Voeg kolom aan tuinen DF toe
tuinen['opp'] = tuinen_opp

large_tuinen = tuinen['opp'].mean() * 100

#Selecteer tuinen groter dan 3 meter
tuinen = tuinen[tuinen['opp'] > 1]
# Selecteer tuinen die kleiner zijn dan 100 keer het gemiddelde van de buurt om percelen van de openbare ruimte er uit te halen
tuinen = tuinen[tuinen['opp'] < large_tuinen]


# A garden needs to have a perceelnummer otherwise the garden selection is likely selected because of an overlay in the previous step.
#TODO methode wellicht verbeteren
tuinen = tuinen[tuinen['perceelnummer'].notnull()]

# Write garden to gpkg
tuinen.to_file(gpkg_vector, driver='GPKG', layer='tuinen')


######### Roof
gdf_percelenwoonfunctie_small = gdf_percelenwoonfunctie_totaal.copy()
gdf_percelenwoonfunctie_small['geometry'] = gdf_percelenwoonfunctie_small.geometry.buffer(-1)
#gdf_percelenwoonfunctie_small.to_file(gpkg_vector, driver='GPKG', layer='percelenwoonfunctie_small')

# Filter panden on parcel with verblijfsobject with woonfunctie and logiesfunctie
gdf_pandenwoonpercelen = gpd.sjoin(gdf_panden, gdf_percelenwoonfunctie_small[['vbo_identificatie', 'geometry']], how='left', op='intersects')
gdf_pandenwoonpercelen = gdf_pandenwoonpercelen[gdf_pandenwoonpercelen['vbo_identificatie'].notnull()]
gdf_pandenwoonpercelen = gdf_pandenwoonpercelen.drop_duplicates(subset=['pand_identificatie'])

daken = gdf_pandenwoonpercelen.copy()

#Bereken oppervlakte daken
daken_opp = daken.area
daken_opp = daken_opp.round(2)
#Voeg kolom aan tuinen DF toe
daken['opp'] = daken_opp

daken.to_file(gpkg_vector, driver='GPKG', layer='daken')