# Remote Sensing: Green private urban spaces

This repository contains the code for detecting vegetation in private gardens of neighbourhoods (The Netherlands). 

The procedure extracts insights based on open data:
- PDOK sources (vector data)
- Aerial photo (raster data)

The procedure is available in both Python and R programming language.


```
├── LICENSE
├── DESCRIPTION
├── README.md         <- Top-level README for developers
├── R
	│
	├── batch_run.R  	 			<- run procedure
	│
	├── 00_RemoteSensing_NDVI      	<- main procedure
	│
	├── AI				  <- input (aerial image)
	│
	├── DATA			  <- output (geopackages)
	│
	├── REPORT            <- output (metrics)
	│
	├── PLOTS             <- output (visualisations) 
	│	
	├── SRC               <- Functions and dedicated procedures
	│

├── PYTHON
    │
	├── ...

```


## Instructions
R:

Python:

## Requirements
Hardware : CPU I7, RAM 16GB (or similar)

QGIS
https://www.qgis.org/en/

GEOS, GDAL, PROJ.4 (included when installing QGIS)

R : 
R 4.0<
Rstudio 1.2.5<, 
Rtools 4<
https://cran.r-project.org/bin/windows/Rtools/

Python:

For development : Git and Gitlab
Repo : https://gitlab.com/datasciencehub/text-analysis-of-short-texts.git

## Issue reporting
Report issues via:
https://gitlab.com/datasciencehub/remote-sensing/-/issues

## Contact
For technical assistance, please contact
Mark Gremmen (mark.gremmen@vng.nl)

## Expertise groep data science
This procedure is a joined effort of VNG, several dutch municipalities and public organisations: Amsterdam, Apeldoorn, Utrecht, Nijmegen, Omgevingsdienst Midden- en West Brabant, VNG West Brabant

## Licence
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons-Licentie" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />Dit werk valt onder een <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Naamsvermelding-NietCommercieel-GelijkDelen 4.0 Internationaal-licentie</a>.

