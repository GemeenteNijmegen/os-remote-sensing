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

gdf_allpercelenbuurt = pd.concat(empty_df, ignore_index=True)

gdf_allpercelenbuurt = gdf_allpercelenbuurt.set_crs("EPSG:28992")
gdf_allpercelenbuurt = gpd.clip(gdf_allpercelenbuurt, gdf_buurt)

gdf_allpercelenbuurt.to_file(gpkg_vector, driver='GPKG', layer='percelen')