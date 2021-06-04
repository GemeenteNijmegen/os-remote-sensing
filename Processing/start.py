# Load required Python libraries

#import subprocess
import os
import runpy

# Variabelen
workingdirectory = "J:\DataLAP\Innovatie\VNG_Remote_Sensing\werk"
sourcedirectoryECW = r"J:\DatalAP\Bronnen\beeldmateriaal\2020"

buurtcode = "BU03638601"


# Create dir temp data
if not os.path.exists('../tempdata'):
    os.makedirs('../tempdata')

try:
    os.remove(workingdirectory + "/tempdata/" + buurtcode + ".gpkg")
except OSError:
    pass


runpy.run_module(mod_name='buurt_selection')
runpy.run_module(mod_name='pand_selection')
runpy.run_module(mod_name='perceel_selection')