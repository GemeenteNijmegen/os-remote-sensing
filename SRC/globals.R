
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

#turn off warnings
if(debug_mode==FALSE) {
  options(warn = -1)
} else {
  options(warn = 0)  
} 

#turn of dplyr's summarise notifications
options(dplyr.summarise.inform = FALSE)

#directories
#create directories on-the-fly if not exist

#location data
data.dir <- here::here("DATA",'/')

tempdata.dir <- here::here("tempdata",'/')

#location plots
plots.dir <- here::here("PLOTS",'/')

#aerial photo (local source)
ai.dir <- here::here("AI",'/')

#create locations if not exist
locations <- c(data.dir, plots.dir, ai.dir, tempdata.dir)

lapply(locations, function(x) {
  if (!dir.exists(x)) {dir.create(x)}
})

#clear graphs and data folder
clear_locations <- c(plots.dir, data.dir)

# get all files in the directories, recursively
f <- list.files(clear_locations, include.dirs = F, full.names = T, recursive = T)
# remove the files
file.remove(f)

#dimension and quality plots
graph_height <- 12
png_height <- 600
aspect_ratio <- 1
dpi <- 320 #retina
sub_title<-''

#Coordinate reference systems
crs_wgs84 <- st_crs(4326) # WGS84 has EPSG code 4326
crs_wgs84
cat(crs_wgs84$wkt)
crs_wgs84$epsg

#store Stack credentials here and remove below
#file.edit(file.path("~", ".Rprofile"))

#webdav Transip Stack credentials
webdav_hostname <- "https://datasciencevng.nl/remote.php/webdav/"
webdav_login <- "remotesensing"
webdav_password <- "VNGRS2021!"

#Maximum number of cells to read into memory.
#The default value of maxmemory is 5e+09 (4.66GB)
rasterOptions(maxmemory = 7e+09)
