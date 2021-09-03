
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

# for testing purposes only
BU_codes <- BU_codes[1:3,, drop = FALSE]

for (i in 1:nrow(BU_codes)) {
  gc()
  #cat("iteration =", i, "\n")
  neighbourhood <- BU_codes$BU_CODE[i]
  source(here::here('00_RemoteSensing_NDVI.R'))
  rm(list=setdiff(ls(), "BU_codes"))
}

  
