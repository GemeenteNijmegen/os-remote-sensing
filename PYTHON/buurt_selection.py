# Load required Python libraries
from utils.area_boundaries import get_buurtgrens

# Load variables
from start import buurtcode, gpkg_vector

## Start buurt selection script

# Select columns
gdf_buurtselection = get_buurtgrens(buurtcode=buurtcode, peiljaar=2020)

# Set projection
gdf_buurtselection = gdf_buurtselection.set_crs("EPSG:28992")

# Write buurt-polygon to geopackage (gpkg)
gdf_buurtselection.to_file(gpkg_vector, driver='GPKG', layer='buurt')