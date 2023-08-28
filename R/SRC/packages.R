
#-----------------------------------------------------------------------------------------------

#Setup and packages

#-----------------------------------------------------------------------------------------------

#clear console
cat("\014")

#garbage collection
gc(verbose = FALSE, full = TRUE)

#Ncpus: The number of parallel processes to use for a parallel install of more than one source package.
options(Ncpus = 8) #we use 8 instead of 1
#getOption("Ncpus", 1L)

message("deploy packages")

if(proj_env == TRUE) {
  #containerized packages (in case you encounter issue with the current version of packages within your computing set-up)
  if (!require("renv")) install.packages("renv")
  library("renv")
  renv::upgrade() # upgrades renv, if new version is available
  renv::update() # updates packages from CRAN and GitHub, within the project
  renv::hydrate(update = "all") # populates the renv cache with copies of-up-to-date packages
  renv::snapshot() # inspect the message before confirming to overwrite renv.lock
  renv::init() #let's go!
}

#-----------------------------------------------------------------------------------------------

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
  #mics. utilities
  'scales',
  'R.utils','utils',
  'Rmisc',
  #environment variables
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
  #'raster',
  #replacement for raster (TODO rewrite remaining raster functions to terra)
  'terra',
  #tidyverse methods for terra objects
  'tidyterra',
  #Spatiotemporal Arrays, Raster and Vector Data Cubes
  #'stars',
  #calculations vectors
  'units',
  #Bindings for the 'Geospatial' Data Abstraction Library (expires end of 2023)
  #'rgdal',
  #Wrappers for the Geospatial Data Abstraction Library (GDAL) Utilities
  #'gdalUtils', #CHECK ON CRAN
  #'gdalUtilities',
  #Interface to Geometry Engine
  'rgeos',
  #interface to the PROJ.4 cartographic projections library
  #'proj4',
  #bindings to liblwgeom functions for sf
  'lwgeom',
  #Fast Extraction from Raster Datasets using Polygons
  'exactextractr',
  #plotting
  #Visualization Methods for Raster Data
  'rasterVis',
  #Interactive viewing of spatial data
  #'mapview',
  #gtable is a layout engine built on top of the grid package
  'gtable',
  #unsupervised segmentation
  'cluster',
  #tools for Remote Sensing Data Analysis
  #'RStoolbox',
  #functions to analyze remotely sensed forest data
  'ForestTools',
  #satellite images processing and functions
  #'RGISTools',
  #quantify landscape configuration
  'landscapemetrics',
  # Airborne LiDAR Data Manipulation and Visualization for Forestry Applications
  #'lidR','rLiDAR',
  'lidaRtRee',
  # 3D data visualizations
  #'rayshader',
  #color schemes
  'colorspace',
  'viridis',
  #layout plots
  #'patchwork',
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

#in case certain packages are not yet aviable on cran for your R-version, specify here
#the package name and location on GitHub

# List of package names and their corresponding GitHub repositories
packages_to_install <- list(
  "gdalUtils" = "gearslaboratory/gdalUtils",
  "RStoolbox" = "bleutner/RStoolbox"
)

# Function to install and load packages from GitHub
install_and_load_packages_from_github <- function(packages) {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }

  for (package_name in names(packages)) {
    github_repo <- packages[[package_name]]

    if (!requireNamespace(package_name, quietly = TRUE)) {
      message("Installing package '", package_name, "' from GitHub repository '", github_repo, "'.")
      remotes::install_github(github_repo, dependencies = TRUE)
      message("Installation of '", package_name, "' complete.")
    } else {
      message("Package '", package_name, "' is already installed.")
    }

    # Load the installed package
    library(package_name, character.only = TRUE)
    message("Package '", package_name, "' loaded.")
  }
}

# Call the function to install and load packages from GitHub
install_and_load_packages_from_github(packages_to_install)



#-----------------------------------------------------------------------------------------------

#elevation points or areas of the Netherlands from the Actueel Hoogtebestand Nederland (AHN)
#is_rahne_available<-FALSE
#is_rahne_available <- require("rAHNextract")

#if(is_rahne_available==FALSE) {
#  devtools::install_github("Jellest/rAHNextract")
#}

#library(rAHNextract)

#-----------------------------------------------------------------------------------------------

#Review GDAL setup
#assumes you have GDAL installed on your local machine.
#getOption("gdalUtils_gdalPath")
#gdal_setInstallation()

#GDAL available?
#valid_gdal <- !is.null(getOption("gdalUtils_gdalPath"))
#valid_gdal

#most recent GDAL installation
#getOption("gdalUtils_gdalPath")[[1]]

#GDAL version number
#getOption("gdalUtils_gdalPath")[[1]]$version

#external dependencies versions of the libraries linked to sf
#sf::sf_extSoftVersion()[1:3]
#lwgeom version
#sf::sf_extSoftVersion()["lwgeom"]

#-----------------------------------------------------------------------------------------------

#review packages loaded (store active-packages set-up)
sessionInfo() %>% capture.output(file="session_info.txt")
