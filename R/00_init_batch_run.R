
#-----------------------------------------------------------------------------------------------

# Batch run

#-----------------------------------------------------------------------------------------------

#external dependencies Rtools, GEOS, GDAL, PROJ.4

#-----------------------------------------------------------------------------------------------

# Setup environment

#-----------------------------------------------------------------------------------------------

#Run in project environment (to avoid package conflicts)
proj_env <- FALSE #default (F)

#debug mode
debug_mode <- FALSE #default (F)

#spackages
source('SRC/packages.R')

run_batch <- TRUE

#-----------------------------------------------------------------------------------------------

# Color-infrared (CIR) aerial photography (TIF or ECW format)

#-----------------------------------------------------------------------------------------------

#read TIFF (TRUE=TIFF, FALSE=ECW)
#please change accordingly
tiff.as.source <- TRUE

#name of input file (ECW or TIF) (make available in AI-directory)
#please change accordingly
input <- paste0('AI/amsterdam.tif')

#-----------------------------------------------------------------------------------------------

# Buurtcodes

#-----------------------------------------------------------------------------------------------

#please declare (multiple) buurtcode(s) in:
BU_codes <- read.xlsx('neighbourhoods.xlsx')

for (i in 1:nrow(BU_codes)) {

  #cat("iteration =", i, "\n")
  neighbourhood <- BU_codes$buurtcode[i]
  municipality <- BU_codes$gemeente[i]

  #(re)set globals
  source(here::here('SRC/globals.R'))

  #main procedure
  source(here::here('01_RemoteSensing_NDVI.R'))
  #rm(list=setdiff(ls(), "BU_codes"))

}
