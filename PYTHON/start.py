# Load required Python libraries
import os
from os import listdir
import runpy
import pandas as pd
import time

from datetime import datetime
start_time = datetime.now()
start_time = start_time.strftime("%H:%M:%S")

# Working directory
workingdirectory = os.getcwd()
parent = os.path.dirname(workingdirectory)

# ECW location
# path_ECW_2020 = parent + "/inputdata/2020_LR_CIR_totaalmozaiek_v2_clip.ecw"
# path local raster file = parent + "/inputdata/gemeenteApeldoorn_CIR2020.tif"

# Set location for csv with buurtcodes and declare (multiple) buurtcode(s) in:
filename = workingdirectory + "/neighbourhoods.csv"
df = pd.read_csv(filename)

# Variables
yearAerialPhoto = 2020

# Loop through csv with buurtcodes and run process below for each buurtcode
#for buurtcode, item in df.iteritems():

# Iterate over column names
for index, row in df.iterrows():
    buurtcode = row["buurtcode"]
    workingdirectory = os.getcwd()
    parent = os.path.dirname(workingdirectory)
    outputdirectory = parent + "/output/" + row["buurtcode"] + "/"
    files_basename = outputdirectory + row["buurtcode"]
    gpkg_vector = outputdirectory + row["buurtcode"] + "_vector.gpkg"
    gpkg_raster = outputdirectory + row["buurtcode"] + "_raster.gpkg"
    if not os.path.exists(outputdirectory):
        os.makedirs(outputdirectory)
    ext = [".gpkg", ".tif", ".xml"]
    for file_name in listdir(outputdirectory):
        if file_name.endswith(tuple(ext)):
            os.remove(outputdirectory + file_name)
    runpy.run_module(mod_name='buurt_selection')
    runpy.run_module(mod_name='pand_selection')
    runpy.run_module(mod_name='perceel_selection')
    runpy.run_module(mod_name='verblijfsobject_selection')
    runpy.run_module(mod_name='garden_and_roof')
    #runpy.run_module(mod_name='clip_cir_with_buurt') # use this script (and the one below) when you have a local ECW file
    #runpy.run_module(mod_name='export_red_and_nir_local_ECW') # use this script also when you have a local ECW file
    runpy.run_module(mod_name='export_red_and_nir_STACK') # use this script when preprocessed tif is stored on STACK (webdav)
    runpy.run_module(mod_name='calculateNDVI')
    runpy.run_module(mod_name='garden_vegetation_clip')
    runpy.run_module(mod_name='garden_vegetation_reclassify')
    time.sleep(30)
    runpy.run_module(mod_name='garden_vegetation_cover_stats')
    runpy.run_module(mod_name='roof_vegetation_clip')
    runpy.run_module(mod_name='roof_vegetation_reclassify')
    time.sleep(30)
    runpy.run_module(mod_name='roof_vegetation_cover_stats')
    print("Process finished for " + row["buurtcode"] + "\n")

end_time = datetime.now()
end_time = end_time.strftime("%H:%M:%S")
print("Start time =", start_time)
print("End Time =", end_time)

print("Process finished for all neighbourhoods \n")
quit()