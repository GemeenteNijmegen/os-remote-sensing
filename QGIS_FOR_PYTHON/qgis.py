from osgeo import ogr
from qgis.core import QgsProject


# Adjustable parameters
buurtcode = "BU05460002"
workingdirectory = "your_working_directory"

# General parameters
outputdirectory = workingdirectory + "output/" + buurtcode + "/"
qgis_directory = workingdirectory + "qgis/"
files_basename = outputdirectory + buurtcode
gpkg_vector = outputdirectory + buurtcode + "_vector.gpkg"
gpkg_raster = outputdirectory + buurtcode + "_raster.gpkg"

# General setting
project = QgsProject.instance()
project.write(qgis_directory + buurtcode + ".qgis")
root = QgsProject.instance().layerTreeRoot()
path_to_gpkg = os.path.join(QgsApplication.pkgDataPath(), "resources", "data", gpkg_vector)


## Add garden grouplayer
grouplayer_tuinen = root.addGroup("Particulieren tuinen")

gpkg_tuinen_stats = path_to_gpkg + "|layername=tuinen_stats"
vlayer_tuinen_stats = QgsVectorLayer(gpkg_tuinen_stats, "Tuinen statistieken", "ogr")
style_path_tuinen_stats = qgis_directory + "tuinen_stats.qml"
vlayer_tuinen_stats.loadNamedStyle(style_path_tuinen_stats)
iface.layerTreeView().refreshLayerSymbology(vlayer_tuinen_stats.id())
vlayer_tuinen_stats.triggerRepaint()

gpkg_tuinen = path_to_gpkg + "|layername=tuinen"
vlayer_tuinen = QgsVectorLayer(gpkg_tuinen, "Tuinen grenzen", "ogr")
style_path_tuinen_grenzen = qgis_directory + "tuinen_grenzen.qml"
vlayer_tuinen.loadNamedStyle(style_path_tuinen_grenzen)
iface.layerTreeView().refreshLayerSymbology(vlayer_tuinen.id())
vlayer_tuinen.triggerRepaint()

grouplayer_tuinen.addLayer(vlayer_tuinen_stats)
grouplayer_tuinen.addLayer(vlayer_tuinen)
QgsProject.instance().layerTreeRoot().findLayer(vlayer_tuinen.id()).setItemVisibilityChecked(False)

# Load raster garden with style
raster_tuinen_classified = QgsRasterLayer(outputdirectory + buurtcode + "_tuinen_ndvi_classified.tif", "Tuinen NDVI classified")
style_path_tuinen = qgis_directory + "tuinen_classified.qml"
raster_tuinen_classified.loadNamedStyle(style_path_tuinen)
iface.layerTreeView().refreshLayerSymbology(raster_tuinen_classified.id())
raster_tuinen_classified.triggerRepaint()
grouplayer_tuinen.addLayer(raster_tuinen_classified)

raster_tuinen_ndvi = QgsRasterLayer(outputdirectory + buurtcode + "_tuinen_ndvi.tif", "Tuinen NDVI")
grouplayer_tuinen.addLayer(raster_tuinen_ndvi)
QgsProject.instance().layerTreeRoot().findLayer(raster_tuinen_ndvi.id()).setItemVisibilityChecked(False)

## Add roof grouplayer
grouplayer_daken = root.addGroup("Particulieren daken")

gpkg_daken_stats = path_to_gpkg + "|layername=daken_stats"
vlayer_daken_stats = QgsVectorLayer(gpkg_daken_stats, "Daken statistieken", "ogr")
style_daken_stats = qgis_directory + "daken_stats.qml"
vlayer_daken_stats.loadNamedStyle(style_daken_stats)
iface.layerTreeView().refreshLayerSymbology(vlayer_daken_stats.id())
vlayer_daken_stats.triggerRepaint()

gpkg_daken = path_to_gpkg + "|layername=daken"
vlayer_daken = QgsVectorLayer(gpkg_daken, "Daken grenzen", "ogr")
style_daken_grenzen = qgis_directory + "daken_grenzen.qml"
vlayer_daken.loadNamedStyle(style_daken_grenzen)
iface.layerTreeView().refreshLayerSymbology(vlayer_daken.id())
vlayer_daken.triggerRepaint()

grouplayer_daken.addLayer(vlayer_daken_stats)
grouplayer_daken.addLayer(vlayer_daken)
QgsProject.instance().layerTreeRoot().findLayer(vlayer_daken.id()).setItemVisibilityChecked(False)

# Load raster roof with style
style_path_daken = qgis_directory + "daken_classified.qml"
raster_daken_classified = QgsRasterLayer(outputdirectory + buurtcode + "_daken_ndvi_classified.tif", "Daken NDVI classified")

raster_daken_classified.loadNamedStyle(style_path_daken)
iface.layerTreeView().refreshLayerSymbology(raster_daken_classified.id())
raster_daken_classified.triggerRepaint()
grouplayer_daken.addLayer(raster_daken_classified)

raster_daken_ndvi = QgsRasterLayer(outputdirectory + buurtcode + "_daken_ndvi.tif", "Daken NDVI")
grouplayer_daken.addLayer(raster_daken_ndvi)
QgsProject.instance().layerTreeRoot().findLayer(raster_daken_ndvi.id()).setItemVisibilityChecked(False)

## Add grouplayer with all other raster layer
grouplayer_raster = root.addGroup("Overige raster data")

# Load all other raster layers
raster_cir_luchtfoto = QgsRasterLayer(outputdirectory + buurtcode + ".tif", "CIR luchtfoto")
raster_ndvi = QgsRasterLayer(outputdirectory + buurtcode + "_ndvi.tif", "NDVI")
raster_nir = QgsRasterLayer(outputdirectory + buurtcode + "_nir.tif", "NIR")
raster_red = QgsRasterLayer(outputdirectory + buurtcode + "_red.tif", "RED")

grouplayer_raster.addLayer(raster_cir_luchtfoto)
grouplayer_raster.addLayer(raster_ndvi)
grouplayer_raster.addLayer(raster_nir)
grouplayer_raster.addLayer(raster_red)

# Set visibility to layers
QgsProject.instance().layerTreeRoot().findLayer(raster_cir_luchtfoto.id()).setItemVisibilityChecked(False)
QgsProject.instance().layerTreeRoot().findLayer(raster_ndvi.id()).setItemVisibilityChecked(False)
QgsProject.instance().layerTreeRoot().findLayer(raster_nir.id()).setItemVisibilityChecked(False)
QgsProject.instance().layerTreeRoot().findLayer(raster_red.id()).setItemVisibilityChecked(False)

grouplayer_raster.setExpanded(False)

## Add grouplayer with all other vector layer
grouplayer_vector = root.addGroup("Overige vector data")

gpkg_buurt = path_to_gpkg + "|layername=buurt"
vlayer_buurt = QgsVectorLayer(gpkg_buurt, "Buurt", "ogr")
style_path_buurt = qgis_directory + "buurt.qml"
vlayer_buurt.loadNamedStyle(style_path_buurt)
iface.layerTreeView().refreshLayerSymbology(vlayer_buurt.id())
vlayer_buurt.triggerRepaint()
#QgsProject.instance().addMapLayer(vlayer_buurt)

gpkg_flats_percelen = path_to_gpkg + "|layername=flats_percelen"
vlayer_flats_percelen = QgsVectorLayer(gpkg_flats_percelen, "Flats percelen", "ogr")

gpkg_laagbouw_percelen = path_to_gpkg + "|layername=laagbouw_percelen"
vlayer_laagbouw_percelen = QgsVectorLayer(gpkg_laagbouw_percelen, "Laagbouw percelen", "ogr")

gpkg_laagbouw_woonfunctie = path_to_gpkg + "|layername=laagbouw_woonfunctie"
vlayer_laagbouw_woonfunctie = QgsVectorLayer(gpkg_laagbouw_woonfunctie, "Laagbouw woonfunctie", "ogr")

gpkg_panden = path_to_gpkg + "|layername=panden"
vlayer_panden = QgsVectorLayer(gpkg_panden, "Panden", "ogr")

gpkg_percelen = path_to_gpkg + "|layername=percelen"
vlayer_percelen = QgsVectorLayer(gpkg_percelen, "Percelen", "ogr")

gpkg_percelen_woonfunctie_totaal = path_to_gpkg + "|layername=percelen_woonfunctie_totaal"
vlayer_percelen_woonfunctie_totaal = QgsVectorLayer(gpkg_percelen_woonfunctie_totaal, "Percelen woonfunctie alles", "ogr")

grouplayer_vector.addLayer(vlayer_percelen_woonfunctie_totaal)
grouplayer_vector.addLayer(vlayer_flats_percelen)
grouplayer_vector.addLayer(vlayer_laagbouw_percelen)
grouplayer_vector.addLayer(vlayer_laagbouw_woonfunctie)
grouplayer_vector.addLayer(vlayer_panden)
grouplayer_vector.addLayer(vlayer_percelen)
grouplayer_vector.addLayer(vlayer_buurt)

QgsProject.instance().layerTreeRoot().findLayer(vlayer_percelen_woonfunctie_totaal.id()).setItemVisibilityChecked(False)
QgsProject.instance().layerTreeRoot().findLayer(vlayer_flats_percelen.id()).setItemVisibilityChecked(False)
QgsProject.instance().layerTreeRoot().findLayer(vlayer_laagbouw_percelen.id()).setItemVisibilityChecked(False)
QgsProject.instance().layerTreeRoot().findLayer(vlayer_laagbouw_woonfunctie.id()).setItemVisibilityChecked(False)
QgsProject.instance().layerTreeRoot().findLayer(vlayer_panden.id()).setItemVisibilityChecked(False)
QgsProject.instance().layerTreeRoot().findLayer(vlayer_percelen.id()).setItemVisibilityChecked(False)
QgsProject.instance().layerTreeRoot().findLayer(vlayer_buurt.id()).setItemVisibilityChecked(False)

grouplayer_vector.setExpanded(False)

# Add background grouplayer
# Load backgroundlayer
urlWithParams = 'crs=EPSG:28992&format=image/png&layers=opentopoachtergrondkaart&styles=normal&tileMatrixSet=EPSG:28992&url=https://geodata.nationaalgeoregister.nl/tiles/service/wmts/1.0.0/WMTSCapabilities.xml'
backgroundlayer = QgsRasterLayer(urlWithParams, 'opentopoachtergrondkaart', 'wms')
if not backgroundlayer.isValid():
  print("Layer failed to load!")
else:
    print('Layer loaded')
#QgsProject.instance().addMapLayer(backgroundlayer) 

grouplayer_backgroundlayer = root.addGroup("Achtergrondlagen")
grouplayer_backgroundlayer.addLayer(backgroundlayer)

# Save project file
project.write(qgis_directory + buurtcode + ".qgis")

#QgsMapLayerRegistry.instance().addMapLayer(vlayer_tuinen_stats)
#grouplayer_tuinen.insertChildNode(1, QgsLayerTreeLayer(vlayer_tuinen_stats))

#Layers aan en uit zetten
#prj = QgsProject.instance()
#layer = prj.mapLayersByName('daken_stats')[0]
#prj.layerTreeRoot().findLayer(layer.id()).setItemVisibilityCheckedParentRecursive(False)

#QgsProject.instance().clear()


