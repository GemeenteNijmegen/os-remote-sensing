#Load required Python libraries
import pandas as pd
import geopandas as gpd
from requests import Request
from owslib.wfs import WebFeatureService

# Load variables
from start import gpkg_vector

## Start verblijfsobject selection script
# Read buurt-polygon
gdf_buurt = gpd.read_file(gpkg_vector, driver='GPKG', layer='buurt')

# Define startindex for WFS-request. A maximum of 1000 features return from WFS-request. To receive all features in a buurt the startindex for each request is new.
loops = [0,1000,2000,3000,4000,5000]

# Create empty dataframe
empty_df = []  # empty list which will hold your dataframes

# Multiple WFS-requests
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
    gdf_vobuurt = gpd.read_file(q)
    empty_df.append(gdf_vobuurt)

# Merge all WFS-rquest in one df
gdf_allvobuurt = pd.concat(empty_df, ignore_index=True)

# Set projection
gdf_allvobuurt = gdf_allvobuurt.set_crs("EPSG:28992")

# Clip verblijfsobjecten with buurt
gdf_allvobuurt = gpd.clip(gdf_allvobuurt, gdf_buurt)

# Write verblijfsobjecten to gpkg
gdf_allvobuurt.to_file(gpkg_vector, driver='GPKG', layer='verblijfsobjecten')

# Filter all verblijfsobjecten with status 'in gebruik' and 'verbouwing'
gdf_vobuurtwoonfunctie = gdf_allvobuurt[gdf_allvobuurt['status'].str.contains('Verblijfsobject in gebruik|Verbouwing verblijfsobject')]

# Filter all verblijfsobjecten which contain the function 'woonfunctie' and 'logiesfunctie'
gdf_vobuurtwoonfunctie = gdf_allvobuurt[gdf_allvobuurt['gebruiksdoel'].str.contains('woonfunctie|logiesfunctie')]


gdf_vobuurtwoonfunctie

# Write woningen to gpkg
if len(gdf_vobuurtwoonfunctie.columns) == 0:
    print("Geen woningen in deze buurt")
    quit()
else:
    gdf_vobuurtwoonfunctie.to_file(gpkg_vector, driver='GPKG', layer='woningen')