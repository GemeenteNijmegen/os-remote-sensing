"""
This script contains functions to retrieve area boundaries
"""

# Load required Python libraries
import geopandas as gpd
import requests


def get_buurtgrens(buurtcode: str = 'BU07721110', peiljaar: int = 2020) -> gpd.geodataframe:
    """
    This function retrieves the boundaries of Dutch 'buurten'.
    :param buurtcode: buurtcode such as 'BU07721110'
    :param peiljaar: year for which the boundaries should be retrieved
    :return: geopandas dataframe with the columns buurtcode, buurtnaam, gemeentecode and geometry
    """

    # some basic checks on the input
    assert isinstance(peiljaar, int), "'peiljaar' should be an integer"
    assert isinstance(buurtcode, str), "'buurtcode' should be a string of the form 'BU077211110'"

    # URL for WFS backend
    url_WFSwijkenbuurt = "https://geodata.nationaalgeoregister.nl/wijkenbuurten2020/wfs?"

    # Select layer
    layer = 'wijkenbuurten{}:cbs_buurten_{}'.format(peiljaar, peiljaar)

    # Specify the parameters for fetching the data
    params = dict(
        service='WFS',
        version="1.0.0",
        request='GetFeature',
        typeName=layer,
        outputFormat='json',
        filter='<Filter><PropertyIsEqualTo><PropertyName>buurtcode</PropertyName><Literal>{}</Literal></PropertyIsEqualTo></Filter>'.format(buurtcode)
    )

    # Parse the URL with parameters
    q = requests.get(url_WFSwijkenbuurt, params=params)

    # Read data from URL
    gdf_buurten = gpd.read_file(q.text)

    # retain relevant columns only
    gdf_buurten = gdf_buurten[['buurtcode', 'buurtnaam', 'gemeentecode', 'geometry']]

    return gdf_buurten
