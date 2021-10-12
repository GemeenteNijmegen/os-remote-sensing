
#-----------------------------------------------------------------------------------------------

#Setup and packages

#-----------------------------------------------------------------------------------------------

#clear console
cat("\014")

#garbage collection
gc(verbose = FALSE, full = TRUE)

#CPU cores (defaults to 1, we use 8)
getOption("Ncpus", 1L)
options(Ncpus = 8)

message("deploy packages")

if(proj_env == TRUE) {
  #  #containerized packages (in case you encounter issue with the current version of packages within your computing set-up)
  if (!require("renv")) install.packages("renv")
  renv::upgrade() # upgrades renv, if new version is available
  renv::update() # updates packages from CRAN and GitHub, within the project
  renv::hydrate(update = "all") # populates the renv cache with copies of-up-to-date packages
  renv::snapshot() # inspect the message before confirming to overwrite renv.lock
  library("renv")
  renv::init()
}

#-----------------------------------------------------------------------------------------------

#shut-up RGDAL
options("rgdal_show_exportToProj4_warnings"="none")

#prevents an auxiliary file being written next to *.gpkg
Sys.setenv(GDAL_PAM_ENABLED = "NO")

# load CRAN packages
packages <- c(
  #external packages (not-being from cran-repo or similar)
  'devtools',
  #Python interface
  #'reticulate'
  #Functions for Base Types and Core R and 'Tidyverse' Features
  'rlang',
  #Relative paths
  'here',
  'scales',
  'R.utils',
  'Rmisc',
  #Environment variables
  #'usethis',
  #'tools',
  'rlist',
  #Essentials
  'tidyverse',
  #datafraem extension
  'data.table',
  #Web client
  'curl','httr',
  #Simple Features
  'sf',
  #Geographic Data Analysis and Modeling
  'raster',
  #replacement for raster (TODO rewrite remaining raster functions to terra)
  'terra',
  #Spatiotemporal Arrays, Raster and Vector Data Cubes
  'stars',
  #calculations vectors
  'units',
  #Bindings for the 'Geospatial' Data Abstraction Library
  'rgdal',
  #Wrappers for the Geospatial Data Abstraction Library (GDAL) Utilities
  'gdalUtils',
  #Interface to Geometry Engine
  'rgeos',
  #bindings to liblwgeom functions for sf
  'lwgeom',
  #Fast Extraction from Raster Datasets using Polygons
  'exactextractr',
  #plotting
  #Visualization Methods for Raster Data
  'rasterVis',
  #Interactive viewing of spatial data
  'mapview',
  #unsupervised segmentation
  'cluster',
  #quantify landscape configuration
  'landscapemetrics',
  # Airborne LiDAR Data Manipulation and Visualization for Forestry Applications
  'lidR',
  # 3D data visualizations
  #'rayshader',
  #color schemes
  'colorspace',
  'viridis',
  #layout plots
  'patchwork',
  #read xlsx
  'openxlsx'
)

#install packages which are not available on the computing setup
has_available   <- packages %in% rownames(installed.packages())
if(any(!has_available)) install.packages(packages[!has_available])

lapply(packages,library,character.only = TRUE
       ,quietly = TRUE
)

#-----------------------------------------------------------------------------------------------

#elevation points or areas of the Netherlands from the Actueel Hoogtebestand Nederland (AHN)
is_rahne_available<-FALSE
is_rahne_available <- require("rAHNextract")

if(is_rahne_available==FALSE) {
  devtools::install_github("Jellest/rAHNextract")
}

library(rAHNextract)

#-----------------------------------------------------------------------------------------------

#Review GDAL setup
#assumes you have GDAL installed on your local machine.
#getOption("gdalUtils_gdalPath")
gdal_setInstallation()

#GDAL available?
valid_gdal <- !is.null(getOption("gdalUtils_gdalPath"))
valid_gdal

#most recent GDAL installation
getOption("gdalUtils_gdalPath")[[1]]

#GDAL version number
getOption("gdalUtils_gdalPath")[[1]]$version

#external dependencies versions of the libraries linked to sf
sf::sf_extSoftVersion()[1:3]
#lwgeom version
sf::sf_extSoftVersion()["lwgeom"]

#review packages loaded
sessionInfo() %>% capture.output(file="session_info.txt")
