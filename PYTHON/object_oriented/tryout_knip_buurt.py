import geopandas as gpd

# read data
# zipfile = r"zip://C:/Users/hansw/Downloads/WijkBuurtkaart_2020_v2.zip"
buurtshape = "C:/Users/hansw/Downloads/WijkBuurtkaart_2020_v2/WijkBuurtkaart_2020_v2/buurt_2020_v2.shp"

df = gpd.read_file(buurtshape)

# filter buurt
buurtcode = "BU02680100"

# save
df[df["BU_CODE"] == buurtcode].to_file("buurt.shp")

print("finished!")
