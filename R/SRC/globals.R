
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
# use getOption("encoding") to see if things were changed

#turn off R’s automatic conversion of strings into factors
options(stringsAsFactors = FALSE)

#prevent exponential / scientific notation.
options(scipen = 999)

#turn off warnings
if(debug_mode==FALSE) {
  options(warn = -1)
} else {
  options(warn = 0)
}

#turn of dplyr's summarise notifications
options(dplyr.summarise.inform = FALSE)

#R root
r_root <- here::here()
#Python root
py_root <- here::here("Processing")

#directories
#create directories on-the-fly if not exist

#location data
data.dir <- here::here("R", "DATA",'/')
data.loc <- here::here("R","DATA",neighbourhood,'/')

tempdata.dir <- here::here("R","tempdata",'/')

#location plots
plots.dir <- here::here("R","PLOTS",'/')
plots.loc <- here::here("R","PLOTS",neighbourhood,'/')

#aerial photo (local source)
ai.dir <- here::here("R","AI",'/')

#location data
report.dir <- here::here("R","REPORT",'/')
report.loc <- here::here("R","REPORT",neighbourhood,'/')

#create locations if not exist
locations <- c(data.dir, data.loc, plots.dir, plots.loc, ai.dir, tempdata.dir, report.dir, report.loc)

lapply(locations, function(x) {
  if (!dir.exists(x)) {dir.create(x)}
})

#clear graphs and data folder
clear_locations <- c(plots.loc, data.loc)

# get all files in the directories, recursively
f <- list.files(clear_locations, include.dirs = F, full.names = T, recursive = T)
# remove the files
file.remove(f)

#location geopackages
#vector layers (polygons buurt, percelen, panden, tuinen)
gpkg_vector <- paste0(data.loc,neighbourhood,"_vector.gpkg")
#raster data: aerial photo, NH3
gpkg_raster <- paste0(data.loc,neighbourhood,"_raster.gpkg")
#raster data: vegetation indices
gpkg_indices <- paste0(data.loc,neighbourhood,"_green_indices.gpkg")

#dimension and quality plots
graph_height <- 6
png_height <- 400
aspect_ratio <- 1
dpi <- 180 #retina(320)
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
#default value of maxmemory is 5e+09 (4.66GB)
rasterOptions(maxmemory = 6e+09)
