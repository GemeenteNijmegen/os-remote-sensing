
#-----------------------------------------------------------------------------------------------

# Remote Sensing: Green private urban spaces

#-----------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------

# Setup environment

#-----------------------------------------------------------------------------------------------

#set working directory
#setwd("") #default (de-activated)

#Run in project environment (to avoid package conflicts)
proj_env <- FALSE #default (F)

#debug mode
debug_mode <- FALSE #default (F)

#packages
source('SRC/packages.R')

#-----------------------------------------------------------------------------------------------

# Color-infrared (CIR) aerial photography (TIF or ECW format)

#-----------------------------------------------------------------------------------------------

#read TIFF (TRUE=TIFF, FALSE=ECW)
#make aerial image available in AI-directory
tiff.as.source <- TRUE #default (T)

#year of the aerial photo
yr<-2020

#-----------------------------------------------------------------------------------------------

#PDOK polygons (vectors): percelen, panden, verblijfsobjecten, etc.

#-----------------------------------------------------------------------------------------------

#download fresh PDOK polygons, do not use output from earlier run (except for gemeente, buurt)
gpkg.new <- FALSE #default (F)

#add 3D panden (TU Delft) as layer in (vector) geopackage
buildings_3d <- FALSE #default (F)

#-----------------------------------------------------------------------------------------------

pca.ai <- TRUE #default (F)

#-----------------------------------------------------------------------------------------------

# Batch run neighbourhoods

#-----------------------------------------------------------------------------------------------

#please declare (multiple) buurtcode(s) (covered by CIR aerial photography) in xlsx-sheet:
BU_codes <- read.xlsx('neighbourhoods.xlsx')

for (i in 1:nrow(BU_codes)) {
  #cat("iteration =", i, "\n")
  neighbourhood <- BU_codes$buurtcode[i]
  municipality <- BU_codes$gemeente[i]

  #(re)set globals
  source(here::here('SRC/globals.R'))

  #main procedure
  source(here::here('01_RemoteSensing_NDVI.R'))
}
