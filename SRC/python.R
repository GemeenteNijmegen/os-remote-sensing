
#------------------------------------------------------------------------------

#Python interpreter and environment

#------------------------------------------------------------------------------

#setup requirements:

#needed for installation from GitHub
#install.packages("devtools")
#environment variables
#install.packages("usethis")
#incorporate Python in R
#install.packages("reticulate")

packages <- c('devtools','usethis','reticulate')

#install packages which are not available on the computing setup
has_available   <- packages %in% rownames(installed.packages())
if(any(!has_available)) install.packages(packages[!has_available])

lapply(packages,library,character.only = TRUE
       ,quietly = TRUE
)

#--------------------------------------------------------------------------------------------

#Interpreter

#--------------------------------------------------------------------------------------------

#review paths
#reticulate::py_discover_config()

#By default, reticulate uses the version of Python found on your PATH (environment variables)
#Alternatively you can select the Python environment manually:

#reticulate::use_python("~/anaconda3/bin/python", required = TRUE)  
#reticulate::use_python(python = "/usr/local/bin/python3.9")
#Mark (FOR TESTING!)
reticulate::use_python("C:\\Users\\skiwe\\Anaconda3\\envs\\remotesensing\\python.exe") 
#reticulate::py_discover_config()

#--------------------------------------------------------------------------------------------

#Environment

#--------------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------------

#Python Conda environment (if no conda available)
#https://docs.conda.io/

#conda_install(
#  envname = 'remotesensing',
#  c('numpy','requests', 'geopandas', 'owslib.wfs', 'runpy', 'rasterio', 'pandas'), 
#  pip = TRUE
#)

#create environment (if conda available)
#reticulate::conda_create("remotesensing") 

#list all environments
reticulate::conda_list(conda = "auto")

#indicate that we want to use Conda environment "remotesensing"
reticulate::use_condaenv("remotesensing", required = TRUE)

#--------------------------------------------------------------------------------------------

#Regular Python

#reticulate::virtualenv_install("remotesensing") 

#indicate that we want to use Python environment "remotesensing"
#reticulate::use_virtualenv(virtualenv = "remotesensing")

#--------------------------------------------------------------------------------------------

#Modules

#--------------------------------------------------------------------------------------------

#Conda
#conda_install("remotesensing", "geopandas") #etc

#or manually via (Anaconda) powershell, as administrator
#pip install geopandas


#--------------------------------------------------------------------------------------------

#Regular Python
#reticulate::py_install('geopandas', pip = TRUE, envname="remotesensing")


#--------------------------------------------------------------------------------------------

#Initialization

#--------------------------------------------------------------------------------------------

main <- reticulate::import_main()
sys <- reticulate::import("sys")
os <- reticulate::import("os")
#os$listdir(".")

#python root
setwd(py_root)

source_python("variables.py")

#test Python
#a = "Hello" + " World"
#print(a)

py_run_file("start.py")

#r root (reset)
setwd(r_root)

getwd()
