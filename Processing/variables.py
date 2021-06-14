# Load required Python libraries
import os

# Variabelen
buurtcode = "BU02000102"
#buurtcode = "BU03638600"

#directory and filenames
workingdirectory = os.getcwd()
parent = os.path.dirname(workingdirectory)
tempdirectory = parent + "/tempdata/" + buurtcode + "/"

path_ECW_2020 = "C:\bron\2020_LR_CIR_totaalmozaiek_v2_clip.ecw"

#buurt
files_basename = tempdirectory + buurtcode
gpkg_vector = tempdirectory + buurtcode + "_vector.gpkg"
gpkg_raster = tempdirectory + buurtcode + "_raster.gpkg"