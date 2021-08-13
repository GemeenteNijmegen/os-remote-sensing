
#-----------------------------------------------------------------------------------------------

# Batch run

#-----------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------

# Setup environment

#-----------------------------------------------------------------------------------------------

#Run in project environment (to avoid package conflicts)
proj_env <- FALSE #default (F)

#debug mode
debug_mode <- FALSE #default (F)

#external dependencies Rtools, GEOS, GDAL, PROJ.4

#setup and packages
source('SRC/packages.R')

#globals
source(here::here('SRC/globals.R'))

#-----------------------------------------------------------------------------------------------

# Buurtcodes

#-----------------------------------------------------------------------------------------------

#please declare (multiple) buurtcodes in:
BU_codes <- read.csv(here::here('Processing/BU_CODE_sample.csv'))

BU_codes <- as.data.frame(BU_codes)

for (i in 1:nrow(BU_codes)) {

neighbourhood <- BU_codes$buurtcode[i]

source(here::here('00_RemoteSensing_NDVI.R'))

}
  