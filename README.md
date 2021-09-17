# Remote Sensing: Green private urban spaces

This repository contains the code for detecting vegetation in private gardens within dutch neighbourhoods.
Vegetation detection is based on Color-infrared (CIR) aerial photography and the NDVI vegetation metric. 

The objective of this repository is to provide a base for developing custom made remote sensing applications for vegetation detection in the urban environment. 
This so-called Minimal Viable Product is an 100-day experiment of the Expertise Group Data Science Dutch Municipalities and acts as a showcase. 

Currently the application is a pre-release version (alpha).

You may test it and use it under the condition that you provide the project with feedback, improvements or extensions. See Creative Commons licence below. 

## Normalized Difference Vegetation Index (NDVI)

Normalized Difference Vegetation Index (NDVI) quantifies vegetation by measuring the difference between near-infrared (which vegetation strongly reflects) 
and red light (which vegetation absorbs). It distinguishes vegetation from soil, minimizes topographic effects
NDVI is chlorophyll sensitive, emphasizing the green color of a healthy plant.

NDVI-ranges vegetation in this research
       -1 to 0.2: non-vegetation; 
        0.2 to 0.3: grasses, weed; 
        0.3 to 0.5: low to medium vegetation (substantial vegetation); 
        0.5 to 1: #intensive vegetation, high vegetation, trees.

NDVI-range 'verstening'
       -0.1 tot 0.2: stone, sand/earth.

## Open Data 
The procedure extracts insights based on open data:
- PDOK, nationaalgeoregister.nl (vector data)
- Aerial photo, opendata.beeldmateriaal.nl (raster data)

## Open Source
The procedure is available in both Python and R programming language. The output can be deployed in QGIS.

## Structure of the procedure

```
├── LICENSE
├── DESCRIPTION
├── README.md         <- Top-level README for developers
├── R
	│
	├── 00_init_batch_run.R  	 	<- run procedure
	│
	├── 01_RemoteSensing_NDVI      	<- main procedure
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
	 ├── start.py  	 	<- run procedure
	 │
	 ...

```

## Instructions

Both the Python and R procedure result in geopackage (gpkg) files with multiples layers which
can be visualized in QGIS or similar (commercial) GIS-software. 

R: Define the neighbourhood code(s) in the neighbourhood.xlsx file. 
You may either use your own aerial photo (must included infrared-band) or extract the region
from the main (119GB) aerail photo of the Netherlands. You may 
use ecw or tif as file-format. Please verify and adjust settings in 
'00_init_batch_run.R'
 
Run the procedure via '00_init_batch_run.R'

If you like to run the Python procedure from Rstudio, read the instructions in SRC>python.R

Python: Define the neighbourhood code(s) in the neighbourhood.csv file.
You may either use your own aerial photo (must included infrared-band) or extract the region
from the main (119GB) aerail photo of the Netherlands. You may
use ecw as file-format. Please verify and adjust settings in
'start.py'

Run the procedure via 'start.py'

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
update Rccp-package 

Python:
Python or Anaconda 

For development : Git and Gitlab
Repo : https://gitlab.com/datasciencehub/remote-sensing.git

## Issue reporting
Report issues via:
https://gitlab.com/datasciencehub/remote-sensing/-/issues

## Contact
For technical assistance and other questions, please contact
Mark Gremmen, mark.gremmen@vng.nl (R), or Stefan van der Hoorn, s.vanderhoorn@apeldoorn.nl (Python)

## Expertise groep data science
This procedure is a joined effort of VNG, several dutch municipalities and public organisations: Amsterdam, Apeldoorn, Utrecht, Nijmegen, Omgevingsdienst Midden- en West Brabant, VNG West Brabant

## Licence
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons-Licentie" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />Dit werk valt onder een <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Naamsvermelding-NietCommercieel-GelijkDelen 4.0 Internationaal-licentie</a>.

