import os

import pandas as pd

import area_object


def process_one_buurt(buurtcode: str) -> pd.Series:
    """
    :param buurtcode: the buurtcode to process, of the form 'BU07721110'
    :return: pixel counts of the different NDVI-classes (water, grass, etc) as pandas Series
    """
    print("processing {}".format(buurtcode))

    # create a buurt object
    buurt = area_object.Buurt(buurtcode)

    # TODO: maybe we have to add the results if the buurt consists of multiple separate areas

    # return a pd.Series
    return pd.Series(buurt.get_stats()[0])


if __name__ == "__main__":
    # read file with which buurten to process
    buurt_df = pd.read_csv(os.path.join("..", "neighbourhoods2.csv"), sep=",")

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

    print(result)

    print("finished!")
