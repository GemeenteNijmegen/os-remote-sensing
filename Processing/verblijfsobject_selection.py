#Load required Python libraries
import pandas as pd
import geopandas as gpd
from requests import Request
from owslib.wfs import WebFeatureService

# Load variables
from start import gpkg_vector

## Start script
# Read buurt
gdf_buurt = gpd.read_file(gpkg_vector, driver='GPKG', layer='buurt')

loops = [0,1000,2000,3000,4000,5000]

empty_df = []  # empty list which will hold your dataframes

for loop in loops:
    bbox_geom = gdf_buurt.bounds
    lowerCorner = bbox_geom['minx'].astype(str) + ' ' + bbox_geom['miny'].astype(str)
    upperCorner = bbox_geom['maxx'].astype(str) + ' ' + bbox_geom['maxy'].astype(str)
    url_WFSbagvo = "https://geodata.nationaalgeoregister.nl/bag/wfs/v1_1?"
    wfs = WebFeatureService(url=url_WFSbagvo)
    layer = 'bag:verblijfsobject'
    filter = ('<ogc:Filter>'
                '<ogc:BBOX>'
                    '<ogc:PropertyName>geometry</ogc:PropertyName>'
                        '<gml:Envelope srsName="http://www.opengis.net/gml/srs/epsg.xml#28992"><gml:lowerCorner>' + lowerCorner + '</gml:lowerCorner><gml:upperCorner>' + upperCorner + '</gml:upperCorner></gml:Envelope>'
                '</ogc:BBOX>'
            '</ogc:Filter>')
    startindex = loop
    params = dict(service='WFS', version="2.0.0", request='GetFeature', typeName=layer, filter=filter, startindex=startindex, sortBy='identificatie', outputFormat='json')
    q = Request('GET', url_WFSbagvo, params=params).prepare().url
    gdf_vobuurt = gpd.read_file(q) #Deze runt mogelijk niet op inno pc 21931
    empty_df.append(gdf_vobuurt)

gdf_allvobuurt = pd.concat(empty_df, ignore_index=True)

gdf_allvobuurt = gdf_allvobuurt.set_crs("EPSG:28992")

gdf_allvobuurt = gpd.clip(gdf_allvobuurt, gdf_buurt)

gdf_allvobuurt.to_file(gpkg_vector, driver='GPKG', layer='verblijfsobjecten')

#Selecteren alle verblijfsobjecten met de status 'in gebruik' en 'verbouwing'
gdf_vobuurtwoonfunctie = gdf_allvobuurt[gdf_allvobuurt['status'].str.contains('Verblijfsobject in gebruik|Verbouwing verblijfsobject')]

#Selecteren alle verblijfsobjecten waar 'woonfunctie' en 'logiesfunctie' in voorkomt
gdf_vobuurtwoonfunctie = gdf_allvobuurt[gdf_allvobuurt['gebruiksdoel'].str.contains('woonfunctie|logiesfunctie')]

#Selecteren alle verblijfsobjecten met de status 'in gebruik'
gdf_vobuurtwoonfunctie = gdf_vobuurtwoonfunctie[gdf_vobuurtwoonfunctie['status'].str.contains('Verblijfsobject in gebruik|Verbouwing verblijfsobject')]

#Alle verblijfsobjecten opslaan die 'Woonfunctie' bevatten in het gebruiksdoel
gdf_vobuurtwoonfunctie.to_file(gpkg_vector, driver='GPKG', layer='woningen')