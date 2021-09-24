#Load required Python libraries
import pandas as pd
import geopandas as gpd
from requests import Request
from owslib.wfs import WebFeatureService

from time import process_time
t1_start = process_time()

# Load variables
from start import gpkg_vector

## Start perceel selection script
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
    url_WFSpercelen = "https://geodata.nationaalgeoregister.nl/kadastralekaart/wfs/v4_0?"
    wfs = WebFeatureService(url=url_WFSpercelen)
    layer = 'kadastralekaartv4:perceel'
    filter = ('<ogc:Filter>'
                '<ogc:BBOX>'
                    '<ogc:PropertyName>geometry</ogc:PropertyName>'
                        '<gml:Envelope srsName="http://www.opengis.net/gml/srs/epsg.xml#28992"><gml:lowerCorner>' + lowerCorner + '</gml:lowerCorner><gml:upperCorner>' + upperCorner + '</gml:upperCorner></gml:Envelope>'
                '</ogc:BBOX>'
            '</ogc:Filter>')
    startindex = loop
    params = dict(service='WFS', version="2.0.0", request='GetFeature', typeName=layer, filter=filter, startindex=startindex, sortBy='identificatieLokaalID', outputFormat='json')
    q = Request('GET', url_WFSpercelen, params=params).prepare().url
    gdf_percelenbuurt = gpd.read_file(q)
    empty_df.append(gdf_percelenbuurt)

# Merge all WFS-rquest in one df
gdf_allpercelenbuurt = pd.concat(empty_df, ignore_index=True)

# Set projection
gdf_allpercelenbuurt = gdf_allpercelenbuurt.set_crs("EPSG:28992")

# Clip percelen with buurt
gdf_allpercelenbuurt = gpd.clip(gdf_allpercelenbuurt, gdf_buurt)

# Filter only features with geometry type 'polygon'
gdf_allpercelenbuurt = gdf_allpercelenbuurt[gdf_allpercelenbuurt.geom_type == 'Polygon']

# Write percelen-polygon to gpkg
gdf_allpercelenbuurt.to_file(gpkg_vector, driver='GPKG', layer='percelen')

# Stop the stopwatch / counter
t1_stop = process_time()
print("Perceel selection runtime is", round(t1_stop - t1_start,1), "seconds")
print("Perceel selection process finished \n")
