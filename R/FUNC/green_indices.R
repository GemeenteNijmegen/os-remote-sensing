#-----------------------------------------------------------------------------------------------

# Normalized difference vegetation index (NDVI)

#-----------------------------------------------------------------------------------------------

#NDVI indicates amount of vegetation, distinguishes vegetation from soil, minimizes topographic effects
#NDVI is chlorophyll sensitive, emphasizing the green color of a healthy plant.
#NDVI is slightly distorted by factors including shadowing, air moisture, and variations in the soil

#NDVI = (NIR–R/NIR+R)

ndvi_func <- function(x,y) {
  (y-x) / (y+x)

}

#-----------------------------------------------------------------------------------------------

# transformed normalized difference vegetation index (TNDVI)

#-----------------------------------------------------------------------------------------------

#TNDVI indicates a relation between the amount of green biomass that is found in a pixel.
#It has always positive values and the variances of the ratio are proportional to mean values

#TNDVI = sqrt((NIR–R/NIR+R) +0.5)

tndvi_func <- function(r) {
  sqrt(r + 0.5)
}


#-----------------------------------------------------------------------------------------------

# Modified Soil Adjusted Vegetation Index (MSAVI2)

#-----------------------------------------------------------------------------------------------

#The Modified Soil Adjusted Vegetation Index (MSAVI2) method minimizes the effect of bare soil
#on the SAVI.

#msavi2 = (2 * NIR + 1 - sqrt( (2 * NIR + 1)^2 - 8 * (NIR - RED) )) / 2

msavi2_func <- function(x,y) {
  (2*y+1-sqrt((2*y+1)^2-8*(y-x)))/2
}


#-----------------------------------------------------------------------------------------------

# Enhanced vegetation index - Two-band (EVI2)

#-----------------------------------------------------------------------------------------------

#EVI2 has several advantages over NDVI including the ability to resolve differences
#for vegetation with different background soil reflectance

#evi2 = 2.5*((NIR-RED) / (NIR+2.4*RED+1))

evi2_func <- function(x,y) {
  2.5*((y-x) / (y+2.4*x+1))
}


#-----------------------------------------------------------------------------------------------

# Ratio vegetation index (RVI)

#-----------------------------------------------------------------------------------------------

#Reduces the effects of atmosphere and topography

#rvi = NIR/RED

rvi_func <- function(x,y) {
  (y) / (x)
}



#-----------------------------------------------------------------------------------------------

# (re)Classify raster function

#-----------------------------------------------------------------------------------------------

class_func <- function(rast,bins) {
  raster::reclassify(rast,bins)
}







