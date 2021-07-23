# Load required Python libraries
import os
from os import listdir
import runpy
import pandas as pd

workingdirectory = os.getcwd()
parent = os.path.dirname(workingdirectory)
path_ECW_2020 = parent + "/rasterdata/2020_LR_CIR_totaalmozaiek_v2_clip.ecw"

filename = workingdirectory + "/BU_CODE.csv"
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
    runpy.run_module(mod_name='clip_cir_with_buurt') # use this script (and the one below) when you have a local ECW file
    runpy.run_module(mod_name='export_red_and_nir_local_ECW') # use this script also when you have a local ECW file
    #runpy.run_module(mod_name='export_red_and_nir_STACK') # use this script when preprocessed tif is stored on STACK (webdav)
    runpy.run_module(mod_name='calculateNDVI')