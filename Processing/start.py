# Load required Python libraries
import os
from os import listdir
import runpy
import pandas as pd

# Load variables
#from variables_loop import *

path_ECW_2020 = "J:/DatalAP/Bronnen/beeldmateriaal/25cm/2020/2020_LR_CIR_totaalmozaiek_v2_clip.ecw"

filename = "J:/DataLAP/Innovatie/VNG_Remote_Sensing/werk/pythonGitlab2/Processing/BU_CODE.csv"
df = pd.read_csv(filename)


for index, row in df.iterrows():
    buurtcode = row["buurtcode"]
    workingdirectory = os.getcwd()
    parent = os.path.dirname(workingdirectory)
    tempdirectory = parent + "/tempdata/" + row["buurtcode"] + "/"
    files_basename = tempdirectory + row["buurtcode"]
    gpkg_vector = tempdirectory + row["buurtcode"] + "_vector.gpkg"
    gpkg_raster = tempdirectory + row["buurtcode"] + "_raster.gpkg"
    if not os.path.exists(tempdirectory):
        os.makedirs(tempdirectory)
    ext = [".gpkg", ".tif"]
    for file_name in listdir(tempdirectory):
        if file_name.endswith(tuple(ext)):
            os.remove(tempdirectory + file_name)
    runpy.run_module(mod_name='buurt_selection')
    runpy.run_module(mod_name='pand_selection')
    runpy.run_module(mod_name='perceel_selection')
    runpy.run_module(mod_name='verblijfsobject_selection')
    runpy.run_module(mod_name='tuinen')
    runpy.run_module(mod_name='clip_cir_with_buurt')
    runpy.run_module(mod_name='export_red_and_nir_local_ECW')
    #runpy.run_module(mod_name='export_red_and_nir_STACK')
    runpy.run_module(mod_name='calculateNDVI')