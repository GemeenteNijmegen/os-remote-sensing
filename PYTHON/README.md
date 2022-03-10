# Setting up Python environment

Notes made by Hans while setting up the Python environment.

* There is no information on which Python version to use, I've used python 3.10
* The Fiona-package does not install from requirements.txt. This is a common problem, which I have solved by using `conda install -c conda-forge fiona`.
* Using pandas=1.4.1, since the version in requirements.txt was not found
* No matching distriburion for rasterio==1.2.6, manually installing `conda install -c conda-forge rasterio`.
* Scipy==1.7.1 does not install, manually installing scipy==1.8.0
* Installing gdal as follows: `conda install -c conda-forge gdal`
* installing geopandas as `conda install --channel conda-forge geopandas`
* installing owslib as `conda install -c conda-forge owslib`
* installing webdav3 as `conda install -c conda-forge webdavclient3`
* installing rasterstats as `conda install -c conda-forge rasterstats`

Installation from requirements.txt doesn't work very smoothly. I would recommend using 
'environment.yml' and conda.

