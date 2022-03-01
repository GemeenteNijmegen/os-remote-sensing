#Load required Python libraries
import pandas as pd
import geopandas as gpd
import requests
from requests import Request
from owslib.wfs import WebFeatureService
import xml.etree.ElementTree as ET
import math

# Load variables
from start import gpkg_vector

## Start pand selection script
# Read buurt-polygon
gdf_buurt = gpd.read_file(gpkg_vector, driver='GPKG', layer='buurt')

# WFS general parameters
bbox_geom = gdf_buurt.bounds
lowerCorner = bbox_geom['minx'].astype(str) + ' ' + bbox_geom['miny'].astype(str)
upperCorner = bbox_geom['maxx'].astype(str) + ' ' + bbox_geom['maxy'].astype(str)
url_WFSbagpand = "https://geodata.nationaalgeoregister.nl/bag/wfs/v1_1?"
wfs = WebFeatureService(url=url_WFSbagpand)
layer = 'bag:pand'
filter = ('<ogc:Filter>'
                '<ogc:BBOX>'
                    '<ogc:PropertyName>geometry</ogc:PropertyName>'
                        '<gml:Envelope srsName="http://www.opengis.net/gml/srs/epsg.xml#28992"><gml:lowerCorner>' + lowerCorner + '</gml:lowerCorner><gml:upperCorner>' + upperCorner + '</gml:upperCorner></gml:Envelope>'
                '</ogc:BBOX>'
            '</ogc:Filter>')

# Find number of records in selected area
params_numberofrecords = dict(service='WFS', version="2.0.0", request='GetFeature', typeName=layer, filter=filter, resultType='hits')
q_numberofrecords = Request('GET', url_WFSbagpand, params=params_numberofrecords).prepare().url

numberofrecords = requests.get(q_numberofrecords)
numberofrecords = numberofrecords.text
numberofrecords = ET.fromstring(numberofrecords)
numberofrecords = numberofrecords.attrib
numberofrecords = numberofrecords["numberMatched"]
numberofrecords = int(numberofrecords)


# Define startindex for WFS-request. A maximum of 1000 features return from WFS-request. To receive all features in a buurt the startindex for each request is new.
l = math.ceil(numberofrecords/1000)
loops = list(range(l))
loops = [i * 1000 for i in loops]
#loops = [0,1000,2000,3000,4000,5000]

# Create empty dataframe
empty_df = []  # empty list which will hold your dataframes

# Multiple WFS-requests
for loop in loops:
    startindex = loop
    params = dict(service='WFS', version="2.0.0", request='GetFeature', typeName=layer, filter=filter, startindex=startindex, sortBy='identificatie', outputFormat='json')
    q = Request('GET', url_WFSbagpand, params=params).prepare().url
    gdf_pandenbuurt = gpd.read_file(q)
    empty_df.append(gdf_pandenbuurt)

# Merge all WFS-request in one df
gdf_allpandenbuurt = pd.concat(empty_df, ignore_index=True)

# Set projection
gdf_allpandenbuurt = gdf_allpandenbuurt.set_crs("EPSG:28992")

# Clip panden with buurt
gdf_allpandenbuurt = gpd.clip(gdf_allpandenbuurt, gdf_buurt)

gdf_allpandenbuurt = gdf_allpandenbuurt[gdf_allpandenbuurt.geom_type == 'Polygon']

# Write panden-polygon to gpkg
gdf_allpandenbuurt.to_file(gpkg_vector, driver='GPKG', layer='panden', index=False)
