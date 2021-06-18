
#-----------------------------------------------------------------------------------------------

#Globals and constants

#-----------------------------------------------------------------------------------------------

#seed
set.seed(90210)

#OS
system <- Sys.info()['sysname']

# encoding
Sys.getlocale()

options(encoding = "UTF-8")      
# use getOption("encoding") to see if things were changed

options(stringsAsFactors = FALSE)

#directories
#create directories on-the-fly if not exist

#location data
data.dir <- here("DATA",'/')

#location temp data
temp.dir <- here("tempdata",'/')

#location plots
plots.dir <- here("PLOTS",'/')

#create locations if not exist
locations <- c(data.dir, temp.dir, plots.dir)

lapply(locations, function(x) {
  if (!dir.exists(x)) {dir.create(x)}
})

#dimension and quality plots
graph_height <- 9
png_height <- 600
aspect_ratio <- 1
dpi <- 320 #retina
sub_title<-''

#Coordinate reference systems
crs_wgs84 <- st_crs(4326) # WGS84 has EPSG code 4326
crs_wgs84
cat(crs_wgs84$wkt)
crs_wgs84$epsg  

#in case of Rprofile issues
#file.edit(file.path("~", ".Rprofile"))
