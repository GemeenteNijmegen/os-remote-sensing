# Load required Python libraries
import geopandas as gpd

# Load variables
from start import gpkg_vector, path_ECW_2020, files_basename, gpkg_raster


# Read buurt
gdf_buurt = gpd.read_file(gpkg_vector, driver='GPKG', layer='buurt')

# Lijkt alleen op deze volgorde te werken. Liever alle libraries in één keer inladen, maar dat werkt niet goed

#Rest van libraries inladen
from rasterio.mask import mask
import rasterio.mask

def getFeatures(gdf):
    """Function to parse features from GeoDataFrame in such a manner that rasterio wants them"""
    import json
    return [json.loads(gdf.to_json())['features'][0]['geometry']]

#Read buurt polygoon
coordsbuurt = getFeatures(gdf_buurt)

coordsbuurt

#Clip Luchtfoto with Buurt from Geopackage
#Source: https://automating-gis-processes.github.io/CSC18/lessons/L6/clipping-raster.html
with rasterio.open(path_ECW_2020) as src:
    out_image, out_transform = rasterio.mask.mask(src, coordsbuurt, crop=True)
    out_meta = src.meta

out_meta.update({"driver": "GTiff",
                 "height": out_image.shape[1],
                 "width": out_image.shape[2],
                 "transform": out_transform})

#Write clipped tif
with rasterio.open(files_basename + ".tif", "w", **out_meta) as dest:
    dest.write(out_image)

#Write to GPKG
import os
desGPKG = gpkg_raster
sourcetif_cir = files_basename + ".tif"

lyr_cir = "cir"
gdal_string_cir = 'gdal_translate -of GPKG "{}" "{}" -co RASTER_TABLE={} -co APPEND_SUBDATASET=YES'.format(sourcetif_cir, desGPKG, lyr_cir)
os.system(gdal_string_cir)