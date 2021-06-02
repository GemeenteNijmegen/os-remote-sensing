
#------------------------------------------------------------------------------

#Setup and packages

#------------------------------------------------------------------------------

#clear console
cat("\014")  

#garbage collection
gc(verbose = FALSE, full = TRUE)

#CPU cores (defaults to 1, we use 4)
getOption("Ncpus", 1L)
options(Ncpus = 4)

if(proj_env == TRUE) {
  #  #containerized packages (in case you encounter issue with the packages set-up and versions)
  if (!require("renv")) install.packages("renv")
  library("renv")
  renv::init()
}


options(warn = -1)

#shutup RGDAL
options("rgdal_show_exportToProj4_warnings"="none")

# load CRAN packages
packages <- c(
  #external packages (not-being from cran-repo or similar)
  #'devtools',
  #Functions for Base Types and Core R and 'Tidyverse' Features
  'rlang',
  #Relative paths
  'here',
  #Environment variables
  'usethis',
  #'tools',
  #Web client
  'curl',
  #essentials
  'tidyverse',
  #Simple Features 
  'sf',
  #Geographic Data Analysis and Modeling
  'raster',
  #Bindings for the 'Geospatial' Data Abstraction Library
  'rgdal',
  #Interface to Geometry Engine
  #'rgeos',
  #Fast Extraction from Raster Datasets using Polygons
  'exactextractr',
  #plotting
  #Visualization Methods for Raster Data
  'rasterVis'
  #color schemes
  #'RColorBrewer','viridis'
)

#install packages which are not available on the computing setup
has_available   <- packages %in% rownames(installed.packages())
if(any(!has_available)) install.packages(packages[!has_available])

lapply(packages,library,character.only = TRUE
       ,quietly = TRUE
)

#review packages loaded
sessionInfo() %>% capture.output(file="session_info.txt")
