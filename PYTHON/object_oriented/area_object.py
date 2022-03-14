# libraries
import os

import geopandas as gpd
import matplotlib.pyplot as plt
import numpy as np
from osgeo import gdal
from rasterio import Affine
from rasterstats import zonal_stats
from webdav3.client import Client
from dotenv import load_dotenv

from PYTHON.utils.area_boundaries import get_buurtgrens


class Buurt:
    """
    This is a class that consists of a (Dutch) neighbourhood.
    """

    def __init__(self, buurtcode: str = 'BU07721110', peiljaar: int = 2020):
        """
        Initialize class
        Creates directory, and several constants that will be used in the methods of this class
        :param buurtcode: string with the buurtcode of the form 'BU07721110'
        :param peiljaar: int with the year the Buurt is considered, important for retrieving the
        correct boundaries, aerial image, etc
        """
        self.buurtcode = buurtcode
        self.peiljaar = peiljaar
        self.boundary = gpd.GeoDataFrame()
        self.aerial_image = None

        # classification categories
        self._bins = [-np.inf, -0.1, 0.2, 0.3, 0.5, np.inf]
        self.ndvi_class = {
            1: "water",
            2: "sand/stone",
            3: "grass/weed",
            4: "substantial vegetation",
            5: "intense vegetation"
        }

        # create directory if it doesn't exist already
        self.output_directory = os.path.join("..", "..", "output", buurtcode)
        if not os.path.exists(self.output_directory):
            os.makedirs(self.output_directory)

    def get_boundaries(self):
        """
        :return: returns geometric boundary of the buurt
        """
        if self.boundary.empty:
            self.boundary = get_buurtgrens(buurtcode=self.buurtcode, peiljaar=self.peiljaar)
        return self.boundary

    def get_aerial_image(self):
        """
        :return: returns aerial image of the buurt
        """
        if self.aerial_image is None:
            filename = os.path.join(self.output_directory, "raw_" + self.buurtcode + ".tif")
            if not os.path.exists(filename):
                # Download using api

                # load dotenv for the username and password
                load_dotenv()

                # The username and password are stored in the ".env" file. See the file
                # ".env_example" on how to store the WEBDAV username and password in a
                # ".env" file. Make sure the ".env" file is excluded from versioning.
                options = {
                    'webdav_hostname': "https://datasciencevng.nl/remote.php/webdav/",
                    'webdav_login': os.getenv("WEBDAV_USERNAME"),
                    'webdav_password': os.getenv("WEBDAV_PASSWORD")
                 }
                client = Client(options)

                # Download tif
                client.download_sync(
                    remote_path="Data/cir2020perbuurt/" + self.buurtcode + ".tif",
                    local_path=filename
                )

            # Open TIF from file
            self.aerial_image = gdal.Open(filename)

        return self.aerial_image

    def get_NDVI(self):
        """
        :return: array with ndvi index as float [-1, 1]
        """
        image = self.get_aerial_image()

        # Import bands as separate 1 band raster
        band_nir = image.GetRasterBand(1)
        band_red = image.GetRasterBand(2)

        # Generate nir and red objects as arrays in float64 format
        red = band_red.ReadAsArray().astype("float64")
        nir = band_nir.ReadAsArray().astype("float64")

        # NDVI calculation, empty cells or nodata cells are reported as 0
        ndvi = np.divide(
            nir-red,
            nir+red,
            # out=np.zeros_like(nir+red, dtype=float),
            out=np.full_like(nir+red, fill_value=np.nan, dtype=float),
            where=(nir+red) != 0
        )

        return ndvi

    def _classify_ndvi(self):
        """
        Function that classifies the ndvi index
        :return: classify ndvi index
        """

        # classify
        classes = np.digitize(self.get_NDVI(), bins=self._bins)

        return classes

    def get_stats(self):
        """
        Function that returns stats on the buurt
        :return: stats
        """

        # calculate the number of pixels in each class
        zs = zonal_stats(
            vectors=self.get_boundaries()["geometry"],
            raster=self._classify_ndvi(),
            affine=Affine.from_gdal(*self.get_aerial_image().GetGeoTransform()),
            categorical=True,
            category_map=self.ndvi_class,
            nodata=-999
        )

        return zs

    def save_ndvi_image(self):
        """
        Saves NDVI image
        :return:
        """
        fig, ax = plt.subplots(1, 1)
        pos = ax.imshow(self.get_NDVI(), cmap="summer_r")
        ax.set_title("NDVI {}".format(self.buurtcode))
        ax.set_axis_off()

        # add the colorbar using the figure's method,
        # telling which mappable we're talking about and
        # which axes object it should be near
        fig.colorbar(pos, ax=ax)
        plt.savefig(os.path.join(self.output_directory, "ndvi_" + self.buurtcode + ".tif"))

        # close current figure
        plt.close()
