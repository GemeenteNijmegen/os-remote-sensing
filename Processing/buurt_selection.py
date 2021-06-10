# Load required Python libraries
import geopandas as gpd
from requests import Request
from owslib.wfs import WebFeatureService

# Load variables
from variables import *

# Start script
# URL for WFS backend
url_WFSwijkenbuurt = "https://geodata.nationaalgeoregister.nl/wijkenbuurten2020/wfs?"

# Initialize
wfs = WebFeatureService(url=url_WFSwijkenbuurt)

# Select layer
layer = 'wijkenbuurten2020:cbs_buurten_2020'

# Specify the parameters for fetching the data
params = dict(service='WFS', version="1.0.0", request='GetFeature', typeName=layer, outputFormat='json')

# Parse the URL with parameters
q = Request('GET', url_WFSwijkenbuurt, params=params).prepare().url

# Read data from URL
gdf_buurten = gpd.read_file(q)

# select columns
gdf_buurten = gdf_buurten.loc[:, ['buurtcode', 'buurtnaam', 'gemeentecode', 'geometry']]

# select buurt
gdf_buurtselection = gdf_buurten[gdf_buurten.buurtcode == buurtcode]

gdf_buurtselection = gdf_buurtselection.set_crs("EPSG:28992")
gdf_buurtselection.to_file(gpkg_vector, driver='GPKG', layer='buurt')

# gdf_buurtselection.plot()
# gdf_buurtselection.head()
# print(GDPbuurten)
# print(GDPbuurten.columns)
# GDPbuurten.plot()
# GDPbuurten.head()