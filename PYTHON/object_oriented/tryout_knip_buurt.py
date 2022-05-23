import geopandas as gpd

# parameters

# de data is afkomstig van:
# https://www.cbs.nl/nl-nl/dossier/nederland-regionaal/geografische-data/wijk-en-buurtkaart-2020
buurtshape = "C:/Users/hansw/Downloads/WijkBuurtkaart_2020_v2/WijkBuurtkaart_2020_v2/buurt_2020_v2.shp"

# filter buurt
buurtcode = "BU02680100"

# lees de data
df = gpd.read_file(buurtshape)

# sla de relevante buurt op
df[df["BU_CODE"] == buurtcode].to_file("buurt.shp")

print("finished!")
