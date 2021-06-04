#Load required Python libraries
import geopandas as gpd
from requests import Request
from owslib.wfs import WebFeatureService

# Load variables
from start import workingdirectory, buurtcode

## Start script
# Read buurt
gdf_buurt = gpd.read_file(workingdirectory + "/tempdata/" + buurtcode + ".gpkg", driver='GPKG', layer='buurt')

#BoundingBox
bbox_geom = gdf_buurt.bounds

lowerCorner = bbox_geom['minx'].astype(str) + ' ' + bbox_geom['miny'].astype(str)
upperCorner = bbox_geom['maxx'].astype(str) + ' ' + bbox_geom['maxy'].astype(str)

# URL for WFS backend
url_WFSpercelen = "https://geodata.nationaalgeoregister.nl/kadastralekaart/wfs/v4_0?"

# Initialize
wfs = WebFeatureService(url=url_WFSpercelen)

# Select layer
layer = 'kadastralekaartv4:perceel'

filter = ('<ogc:Filter>'
            '<ogc:BBOX>'
                '<ogc:PropertyName>geometry</ogc:PropertyName>'
                    '<gml:Envelope srsName="http://www.opengis.net/gml/srs/epsg.xml#28992"><gml:lowerCorner>' + lowerCorner + '</gml:lowerCorner><gml:upperCorner>' + upperCorner + '</gml:upperCorner></gml:Envelope>'
            '</ogc:BBOX>'
        '</ogc:Filter>')


# Specify the parameters for fetching the data
params = dict(service='WFS', version="2.0.0", request='GetFeature', typeName=layer, filter=filter, outputFormat='json')

# Parse the URL with parameters
q = Request('GET', url_WFSpercelen, params=params).prepare().url

# Read data from URL
gdf_percelenbuurt = gpd.read_file(q)

gdf_percelenbuurt = gdf_percelenbuurt.set_crs("EPSG:28992")
gdf_percelenbuurt = gpd.clip(gdf_percelenbuurt, gdf_buurt)

gdf_percelenbuurt.to_file(workingdirectory + "/tempdata/" + buurtcode + ".gpkg", driver='GPKG', layer='percelen')