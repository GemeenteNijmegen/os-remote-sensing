# Load required Python libraries
import os
from os import listdir
import runpy

# Load variables
from variables import *

# Create dir temp data
if not os.path.exists(tempdirectory):
    os.makedirs(tempdirectory)

ext = [buurtcode + ".gpkg", buurtcode + ".tif"]

for file_name in listdir(tempdirectory):
    if file_name.endswith(tuple(ext)):
        os.remove(tempdirectory + file_name)

#runpy.run_module(mod_name='buurt_selection')
#runpy.run_module(mod_name='pand_selection')
#runpy.run_module(mod_name='perceel_selection')
#runpy.run_module(mod_name='clip_lufo_met_buurt')
runpy.run_module(mod_name='exporteren_red_en_nir')