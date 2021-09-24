# Load required Python libraries
import os
from os import listdir
import runpy
import pandas as pd
import time
from time import process_time
total_start = process_time()

# Working directory
workingdirectory = os.getcwd()
parent = os.path.dirname(workingdirectory)

# ECW location
# path_ECW_2020 = parent + "/inputdata/2020_LR_CIR_totaalmozaiek_v2_clip.ecw"

# Set location for csv with buurtcodes and declare (multiple) buurtcode(s) in:
filename = workingdirectory + "/neighbourhoods.csv"
df = pd.read_csv(filename)

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
    # Stop the stopwatch / counter
    total_stop = process_time()
    print("Total process runtime is", round(total_stop - total_start, 1), "seconds")
    print("Process finished for " + row["buurtcode"] + "\n")

import glob
types = ('*ndvi_2_classes.tif', '*.xml') # the tuple of file types
files_grabbed = []
for files in types:
    files_grabbed.extend(glob.glob(files))
    try:
        os.remove(files)
    except OSError as e:
        print("Error: %s : %s" % (files, e.strerror))


# Cleanup all temp files
import glob
outputdir = parent + "/output/"

files = glob.glob(outputdir + "**/*ndvi_2_classes.tif", recursive=True)
for f in files:
    try:
        os.remove(f)
    except OSError as e:
        print("Error: %s : %s" % (f, e.strerror))

print("Process finished for all neighbourhoods \n")
quit()
