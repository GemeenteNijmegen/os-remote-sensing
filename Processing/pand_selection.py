#Load required Python libraries
import geopandas as gpd
from requests import Request
from owslib.wfs import WebFeatureService

# Load variables
from variables import *

## Start script
# Read buurt
gdf_buurt = gpd.read_file(gpkg_vector, driver='GPKG', layer='buurt')

#BoundingBox
bbox_geom = gdf_buurt.bounds

lowerCorner = bbox_geom['minx'].astype(str) + ' ' + bbox_geom['miny'].astype(str)
upperCorner = bbox_geom['maxx'].astype(str) + ' ' + bbox_geom['maxy'].astype(str)

# URL for WFS backend
url_WFSbagpand = "https://geodata.nationaalgeoregister.nl/bag/wfs/v1_1?"

# Initialize
wfs = WebFeatureService(url=url_WFSbagpand)

# Select layer
layer = 'bag:pand'

filter = ('<ogc:Filter>'
            '<ogc:BBOX>'
                '<ogc:PropertyName>geometry</ogc:PropertyName>'
                    '<gml:Envelope srsName="http://www.opengis.net/gml/srs/epsg.xml#28992"><gml:lowerCorner>' + lowerCorner + '</gml:lowerCorner><gml:upperCorner>' + upperCorner + '</gml:upperCorner></gml:Envelope>'
            '</ogc:BBOX>'
        '</ogc:Filter>')


# Specify the parameters for fetching the data
params = dict(service='WFS', version="2.0.0", request='GetFeature', typeName=layer, filter=filter, outputFormat='json')

# Parse the URL with parameters
q = Request('GET', url_WFSbagpand, params=params).prepare().url

# Read data from URL
gdf_pandenbuurt = gpd.read_file(q)

gdf_pandenbuurt = gdf_pandenbuurt.set_crs("EPSG:28992")
gdf_pandenbuurt = gpd.clip(gdf_pandenbuurt, gdf_buurt)

gdf_pandenbuurt.to_file(gpkg_vector, driver='GPKG', layer='panden')

#gdf_pandenbuurt.to_file("../tempdata/"+buurtcode+"_panden.geojson", driver='GeoJSON')
#gdf_pandenbuurt.to_file("../tempdata/" + buurtcode+"_panden.shp")

#GDPpandenbuurt.plot()
#GDPpandenbuurt.head()
#print(GDPpandenbuurt.columns)
#print(GDPpandenbuurt)