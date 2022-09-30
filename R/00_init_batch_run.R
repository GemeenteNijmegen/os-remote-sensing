
#-----------------------------------------------------------------------------------------------

# Remote Sensing of green (private) urban spaces of neigbourhoods in the Netherlands

#-----------------------------------------------------------------------------------------------

#Spatial distribution analysis of urban green-grey-blue spaces

#!!Please initiate the procedure, via the .proj file in the R directory!

#-----------------------------------------------------------------------------------------------

# Setup environment

#-----------------------------------------------------------------------------------------------

#Run in project environment (to avoid package conflicts)
proj_env<-FALSE #default (F)

#packages
source('SRC/packages.R')

#functions for calculating and plotting green indices
source(here::here('FUNC/green_indices.R'))

#-----------------------------------------------------------------------------------------------

# Color-infrared (CIR) aerial photography

#-----------------------------------------------------------------------------------------------

#read TIFF (TRUE=TIFF, FALSE=ECW)
#make airborne imagery available in AI-directory
tif.as.source<-TRUE #default (T)

#year of the aerial photo (also used for Pdok polygon requests)
yr<-2020

#position of near-infrared (NIR) and Red bands in Color-infrared (CIR) photo
#make sure your photo is a CIR photo

#Near-infrared resides in band number:
nir_seq<-1

#color red resides in band number:
red_seq<-2

#band names
band_nms<-c("nir","red","green")

#Coordinate Reference System
#Amersfoort projection (28992)
#https://www.spatialreference.org/ref/epsg/amersfoort-rd-new/
crs_sp<-28992

#projection
crs_str<-paste0("EPSG:",crs_sp)

#Report woonpercelen, or all percelen within buurt)
report_tuinen<-FALSE #default (T)

#aerial image as base image for (raster) plots
alpha<-0 # 255 is visible, 0 is invisible

#-----------------------------------------------------------------------------------------------

# Green indices

#-----------------------------------------------------------------------------------------------

#generate png plots
plots_create<-TRUE

#-----------------------------------------------------------------------------------------------

# Normalized difference vegetation index (NDVI)

#-----------------------------------------------------------------------------------------------

##Normalized Difference Vegetation Index (NDVI) quantifies vegetation by measuring the difference
#between near-infrared (which vegetation strongly reflects) and red light (which vegetation absorbs).
#NDVI indicates amount of vegetation, distinguishes vegetation from soil, minimizes topographic effects
#NDVI is chlorophyll sensitive, emphasizing the green color of a healthy plant.
#NDVI is slightly distorted by factors including shadowing, air moisture, and variations in the soil

#metrics (area, coverage) are calculated based on NDVI

#NDVI = (NIR–R/NIR+R)

#-----------------------------------------------------------------------------------------------

# #Ratio vegetation index (RVI)

#-----------------------------------------------------------------------------------------------

#rvi = NIR/RED
rvi_calc<-FALSE #default (F)

#-----------------------------------------------------------------------------------------------

# transformed normalized difference vegetation index (TNDVI)

#-----------------------------------------------------------------------------------------------

#TNDVI indicates a relation between the amount of green biomass that is found in a pixel.
#It has always positive values and the variances of the ratio are proportional to mean values

#TNDVI = sqrt((NIR–R/NIR+R) +0.5)
tndvi_calc<-FALSE #default (F)

#-----------------------------------------------------------------------------------------------

# Modified Soil Adjusted Vegetation Index (MSAVI2)

#-----------------------------------------------------------------------------------------------

#The Modified Soil Adjusted Vegetation Index (MSAVI2) method minimizes the effect of bare soil
#on the SAVI.

#MSAVI2 = (0.5)*(2*(NIR + 1) - sqrt((2*NIR + 1)2 - 8*(NIR–R)))
msavi2_calc<-FALSE #default (F)

#-----------------------------------------------------------------------------------------------

# Enhanced vegetation index - Two-band (EVI2)

#-----------------------------------------------------------------------------------------------

#EVI2 has several advantages over NDVI including the ability to resolve differences
#for vegetation with different background soil reflectance

#EVI2 = 2.5 * ( NIR - RED) / ( NIR + 2.4 * RED + 1.0 ).
evi2_calc<-FALSE #default (F)

#-----------------------------------------------------------------------------------------------

# Unsupervised classification of NDVI

#-----------------------------------------------------------------------------------------------

unsup_cl<-FALSE #default (T)

#number of clusters
k<-5

#-----------------------------------------------------------------------------------------------

# Principal component analysis: summarize the content of the CIR aerial photo

#-----------------------------------------------------------------------------------------------

pca.ai<-FALSE #default (F)

#-----------------------------------------------------------------------------------------------

# 3D Panden

#-----------------------------------------------------------------------------------------------

#add 3D panden (TU Delft) as layer in (vector) geopackage
buildings_3d<-FALSE #default (F)

#-----------------------------------------------------------------------------------------------

#Current Dutch Elevation (Actueel Hoogtebestand Nederland, AHN)

#-----------------------------------------------------------------------------------------------

#apply height of objects
ahn_calc<-TRUE #default (T)

#nationaalgeoregister.nl as direct source (aka not being package rAHNextract)
ngr_source<-FALSE #FALSE (default), is faster


#-----------------------------------------------------------------------------------------------

#Trees and crowns

#-----------------------------------------------------------------------------------------------

#tree segmentation
tree_trace<-TRUE

#in this research we consider trees to be at least 5m high.

#tree foliage lower and upper bound (m)
foliage_lb<-2 #lower bound (default: 2)
foliage_ub<-50 #upper bound (default: 50)

#crown lower bound (m)
crown_lb<-foliage_lb+1 #lower bound (default: 1)

#tree tops
ttop_lb<-crown_lb+2 #lower bound (default: 2)

#treetop minimum distance to next local high in meters
dmin<-1.5 #(default: 1.5)

#local maximum filter
#window size for detecting tree tops (local high)
#windows size of e.g. ws = 5 meters meaning that for a given point the algorithm looks to the neigbourhood
#points within a 2.5m radius circle to figure out if the point is the local highest.

ws<-5 #in meters (default ; 5)

#-----------------------------------------------------------------------------------------------

# Batch run neighbourhoods

#-----------------------------------------------------------------------------------------------

#please declare (multiple) buurtcode(s) (covered by CIR aerial photography) in xlsx-sheet:
BU_codes<-read.xlsx('neighbourhoods.xlsx')

for (i in 1:nrow(BU_codes)) {
  #cat("iteration =", i, "\n")
  neighbourhood<-BU_codes$buurtcode[i]
  municipality<-BU_codes$gemeente[i]

  #(re)set globals
  source(here::here('SRC/globals.R'))

  #main procedure
  source(here::here('01_RemoteSensing_NDVI.R'))
}
