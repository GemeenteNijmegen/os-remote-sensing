# Load required Python libraries
from os import listdir
import runpy

# Load variables
from variables import *

# Create dir temp data
if not os.path.exists(tempdirectory):
    os.makedirs(tempdirectory)

ext = [".gpkg", ".tif"]

for file_name in listdir(tempdirectory):
    if file_name.endswith(tuple(ext)):
        os.remove(tempdirectory + file_name)

runpy.run_module(mod_name='buurt_selection')
runpy.run_module(mod_name='pand_selection')
runpy.run_module(mod_name='perceel_selection')

#Run these two file when using a local ECW file
#runpy.run_module(mod_name='clip_cir_with_buurt')
#runpy.run_module(mod_name='export_red_and_nir_local_ECW')

#Run this file when using pre-processed TIFF's on STACK
runpy.run_module(mod_name='export_red_and_nir_STACK')


runpy.run_module(mod_name='calculateNDVI')