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
    url_WFSbagpand = "https://geodata.nationaalgeoregister.nl/bag/wfs/v1_1?"
    wfs = WebFeatureService(url=url_WFSbagpand)
    layer = 'bag:pand'
    filter = ('<ogc:Filter>'
                '<ogc:BBOX>'
                    '<ogc:PropertyName>geometry</ogc:PropertyName>'
                        '<gml:Envelope srsName="http://www.opengis.net/gml/srs/epsg.xml#28992"><gml:lowerCorner>' + lowerCorner + '</gml:lowerCorner><gml:upperCorner>' + upperCorner + '</gml:upperCorner></gml:Envelope>'
                '</ogc:BBOX>'
            '</ogc:Filter>')
    startindex = loop
    params = dict(service='WFS', version="2.0.0", request='GetFeature', typeName=layer, filter=filter, startindex=startindex, sortBy='identificatie', outputFormat='json')
    q = Request('GET', url_WFSbagpand, params=params).prepare().url
    gdf_pandenbuurt = gpd.read_file(q)
    empty_df.append(gdf_pandenbuurt)

gdf_allpandenbuurt = pd.concat(empty_df, ignore_index=True)

gdf_allpandenbuurt = gdf_allpandenbuurt.set_crs("EPSG:28992")
gdf_allpandenbuurt = gpd.clip(gdf_allpandenbuurt, gdf_buurt)

gdf_allpandenbuurt.to_file(gpkg_vector, driver='GPKG', layer='panden')

#gdf_pandenbuurt.to_file("../tempdata/"+buurtcode+"_panden.geojson", driver='GeoJSON')
#gdf_pandenbuurt.to_file("../tempdata/" + buurtcode+"_panden.shp")

#GDPpandenbuurt.plot()
#GDPpandenbuurt.head()
#print(GDPpandenbuurt.columns)
#print(GDPpandenbuurt)