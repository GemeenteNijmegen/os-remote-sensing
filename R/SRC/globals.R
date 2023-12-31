
#-----------------------------------------------------------------------------------------------

#Globals and constants

#-----------------------------------------------------------------------------------------------

message("set globals and constants")

#seed
set.seed(90210)

#OS
system <- Sys.info()['sysname']

# encoding
Sys.getlocale()

options(encoding = "UTF-8")
#getOption("encoding")

#turn-off R’s automatic conversion of strings into factors
options(stringsAsFactors = FALSE)

#prevent exponential / scientific notation.
options(scipen = 999)

#turn off warnings
if(debug_mode==FALSE) {
  options(warn = -1)
} else {
  options(warn = 0)
}

#turn-off dplyr's summarise notifications
options(dplyr.summarise.inform = FALSE)

#R root
r_root <- here::here()

#set working directory
#setwd(r_root)

#Python root
py_root <- here::here("Processing")

#directories
#create directories on-the-fly if not exist

#location data
data.dir <- here::here("DATA")
data.run <- here::here("DATA",neighbourhood)
data.loc <- here::here("DATA",neighbourhood,yr)

#location plots
plots.dir <- here::here("PLOTS")
plots.run <- here::here("PLOTS",neighbourhood)
plots.yr <- here::here("PLOTS",neighbourhood,yr)

if(report_tuinen==TRUE) {
  plots.loc<-paste0(plots.yr,"/TUINEN/")
} else {
  plots.loc<-paste0(plots.yr,"/BUURT/")
}
#aerial photo (local source)
ai.dir <- here::here("AI")

#location data
report.dir <- here::here("REPORT")
report.run <- here::here("REPORT",neighbourhood)
report.loc <- here::here("REPORT",neighbourhood,yr,"/")

#create locations if not exist
locations <- c(data.dir,
               data.run,
               data.loc,
               plots.dir,
               plots.run,
               plots.yr,
               plots.loc,
               ai.dir,
               report.dir,
               report.run,
               report.loc)

lapply(locations, function(x) {
  if (!dir.exists(x)) {dir.create(x)}
})

#clear plots and data directory
clear_locations <- c(plots.loc,data.loc, report.loc)

# get all files in the directories, recursively
f <- list.files(clear_locations, include.dirs = F, full.names = T, recursive = T)

# remove the files
file.remove(f)

#location geopackages
#vector layers (polygons buurt, percelen, panden, tuinen)
gpkg_vector <- here::here(data.loc,"vector.gpkg")

#raster data: aerial photo, NH3
gpkg_raster <- here::here(data.loc,"raster.gpkg")

#raster data: vegetation indices
gpkg_indices <- here::here(data.loc,"green_indices.gpkg")

#dimension and quality plots
graph_height <- 6
png_height <- 400
aspect_ratio <- 1
dpi <- 180 #retina(320)
sub_title<-''

#Coordinate reference systems
#crs_wgs84 <- st_crs(4326) # WGS84 has EPSG code 4326
#crs_wgs84
#cat(crs_wgs84$wkt)
#crs_wgs84$epsg

#store Stack credentials here and remove below
#file.edit(file.path("~", ".Rprofile"))

#webdav Transip Stack credentials (public directory)
webdav_hostname <- "https://datasciencevng.nl/remote.php/webdav/"
webdav_login <- "remotesensing"
webdav_password <- "VNGRS2021!"

#Maximum number of cells to read into memory.
#default value of maxmemory is 5e+09 (4.66GB)
rasterOptions(maxmemory = 6e+09)

#location for temporary raster file (drive with big storage)
#raster::rasterOptions(tmpdir = "path/to/drive/with/space")
