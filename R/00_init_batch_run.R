
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

run_batch<-TRUE

#-----------------------------------------------------------------------------------------------

# Buurtcodes

#-----------------------------------------------------------------------------------------------

#please declare (multiple) buurtcode(s) in:
BU_codes <- read.xlsx(here::here('neighbourhoods.xlsx'))

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



