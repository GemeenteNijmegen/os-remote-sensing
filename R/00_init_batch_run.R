
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
#make aerial photo available in AI-directory
tiff.as.source <- TRUE #default (T)

#year of the aerial photo
yr<-2020

#position of near-infrared (NIR) and Red bands in Color-infrared photo

#Near-infrared resides in band:
nir_seq<-1

#color red resides in band:
red_seq<-2

#Report on tuinen of woonpercelen (FALSE for all percelen in buurt)
report_tuinen<-TRUE #default (T)

#-----------------------------------------------------------------------------------------------

# PDOK polygons (vectors): percelen, panden, verblijfsobjecten, etc.

#-----------------------------------------------------------------------------------------------

#download fresh PDOK polygons, do not use output from earlier run (except for gemeente, buurt)
gpkg.new <- FALSE #default (F)

#add 3D panden (TU Delft) as layer in (vector) geopackage
buildings_3d <- FALSE #default (F)

#-----------------------------------------------------------------------------------------------

# Green indices

#-----------------------------------------------------------------------------------------------

#default:
#Normalized difference vegetation index (NDVI) <- metrics are calculated with NDVI
#Ratio vegetation index (RVI)

#-----------------------------------------------------------------------------------------------

# transformed normalized difference vegetation index (TNDVI)

#-----------------------------------------------------------------------------------------------


#TNDVI indicates a relation between the amount of green biomass that is found in a pixel.
#It has always positive values and the variances of the ratio are proportional to mean values

#TNDVI = sqrt((NIR–R/NIR+R) +0.5)

tndvi_calc <- TRUE #default (F)


#-----------------------------------------------------------------------------------------------

# Modified Soil Adjusted Vegetation Index (MSAVI2)

#-----------------------------------------------------------------------------------------------


#The Modified Soil Adjusted Vegetation Index (MSAVI2) method minimizes the effect of bare soil
#on the SAVI.

#MSAVI2 = (0.5)*(2*(NIR + 1) - sqrt((2*NIR + 1)2 - 8*(NIR–R)))

msavi2_calc <- TRUE #default (F)


#-----------------------------------------------------------------------------------------------

# Enhanced vegetation index - Two-band (EVI2)

#-----------------------------------------------------------------------------------------------


#EVI2 has several advantages over NDVI including the ability to resolve differences
#for vegetation with different background soil reflectance

#EVI2 = 2.5 * ( NIR - RED) / ( NIR + 2.4 * RED + 1.0 ).

evi2_calc <- TRUE #default (T)


#-----------------------------------------------------------------------------------------------

# Principal component analysis: summarize the information content of the CIR aerial photo

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
