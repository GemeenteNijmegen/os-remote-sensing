
#------------------------------------------------------------------------------

#Python interpreter and environment

#------------------------------------------------------------------------------


#setup requirements:

#needed for installation from GitHub
#install.packages("devtools")
#environment variables
#install.packages("usethis")
#comes with Rtools
#install.packages("Rcpp")
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

#review paths
reticulate::py_discover_config()

#By default, reticulate uses the version of Python found on your PATH (environment variables)
#Alternatively you can select the Python environment manually:

#reticulate::use_python("~/anaconda3/bin/python", required = TRUE)  
#reticulate::use_python(python = "/usr/local/bin/python3.9")
#Mark
#reticulate::use_python("C:\\Users\\skiwe\\Anaconda3\\python.exe", required = TRUE) 

#--------------------------------------------------------------------------------------------
#Environment


#Python Conda environment
#https://docs.conda.io/
#conda_install(
#  envname = 'remotesensing',
#  c('numpy','requests', 'geopandas', 'owslib.wfs', 'runpy'), 
#  pip = TRUE
#)

#reticulate::virtualenv_install("remotesensing", "requests") #etc
#reticulate::virtualenv_install("remotesensing", packages = c("owslib.wfs"))
                               
#or manually via (Anaconda) powershell, as administrator
#pip install geopandas

#or regular Python environment
#reticulate::py_install('geopandas', pip = TRUE)


#create environment
reticulate::conda_create("remotesensing") 

#list all environments
reticulate::conda_list(conda = "auto")

# indicate that we want to use Conda environment "remotesensing"
reticulate::use_condaenv("remotesensing")
# or Python environment 
#reticulate::use_virtualenv(virtualenv = "remotesensing")


#--------------------------------------------------------------------------------------------
#Initialization

main <- import_main()

os <- import(os, geopandas)

source_python('Processing/variables.py')
py_run_file("Processing/start.py")

?import_main