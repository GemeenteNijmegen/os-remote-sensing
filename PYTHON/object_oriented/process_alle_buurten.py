import os

import pandas as pd
from webdav3.client import Client
from dotenv import load_dotenv

import area_object


def process_one_buurt(buurtcode: str) -> pd.Series:
    """
    :param buurtcode: the buurtcode to process, of the form 'BU07721110'
    :return: pixel counts of the different NDVI-classes (water, grass, etc) as pandas Series
    """
    print("processing {}".format(buurtcode))

    # create a buurt object
    buurt = area_object.Buurt(buurtcode)

    # save the ndvi image
    buurt.save_ndvi_image()

    # TODO: maybe we have to add the results if the buurt consists of multiple separate areas

    # return a pd.Series
    return pd.Series(buurt.get_stats()[0])


def get_buurtcodes_from_server() -> list:
    """
    Get all buurcodes from the datasciencevng server
    :return:
    """
    # load dotenv for the username and password
    load_dotenv()

    options = {
        'webdav_hostname': "https://datasciencevng.nl/remote.php/webdav/",
        'webdav_login': os.getenv("WEBDAV_USERNAME"),
        'webdav_password': os.getenv("WEBDAV_PASSWORD")
    }
    client = Client(options)

    # find all files
    files = client.list("Data/cir2020perbuurt/")

    # filter files that end on ".tif" and extract the buurtcode
    out = [file.replace(".tif", "") for file in files if file.endswith(".tif")]

    return out


if __name__ == "__main__":
    # get all buurtcodes from server
    buurt_df = pd.DataFrame(get_buurtcodes_from_server(), columns=["buurtcode"])

    # drop buurtcode which is too large
    buurt_df = buurt_df[buurt_df["buurtcode"] != "BU07430701"]

    # read file with which buurten to process
    # buurt_df = pd.read_csv(os.path.join("..", "neighbourhoods2.csv"), sep=",")

    # read leefbaarometer
    leefbaar = pd.read_csv(os.path.join("data", "Leefbaarometer 3.csv"))

    # filter
    leefbaar = leefbaar[leefbaar["jaar"] == 2020]
    leefbaar = leefbaar.dropna()

    # merge
    buurt_df = buurt_df.merge(
        right=leefbaar,
        left_on="buurtcode",
        right_on="bu_code"
    )

    # transform buurcode, if necessary
    if buurt_df["buurtcode"].dtype.kind in "iu":
        buurt_df["buurtcode"] = buurt_df["buurtcode"].apply(lambda x: "BU{:08d}".format(x))

    # process the buurten one by one
    result = buurt_df.apply(
        lambda row: process_one_buurt(row["buurtcode"]),
        axis=1
    )

    # Transform into percentages
    result = result.apply(lambda row: row / row.sum(), axis=1)

    # add buurtcode
    result["Buurtcode"] = buurt_df["buurtcode"]

    # merge
    result = result.merge(
        right=buurt_df,
        left_on="Buurtcode",
        right_on="buurtcode"
    )

    print(result)

    # save the result
    result.to_csv(os.path.join("..", "..", "output", "result.csv"))

    print("finished!")
