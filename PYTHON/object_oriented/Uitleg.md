# Knippen van grote Luchtfoto

Voor het knippen van de grote luchtfoto:

1. Haal de grote luchtfoto op met ftp:
    Adres: 104.47.162.174
    Je hoeft niet in te loggen.
    Het downloaden kan wel 10 uur duren.

2. Plaats de foto op de harde schijf. Dit kan de C-schijf zijn, maar ook een externe harde schijf.
   Deze schijf heeft de volgende directory structuur:

    ├───data                            <- Plek waar de shape files en resultaten worden opgeslagen
    │   │
    │   ├───buurt.cpg
    │   ├───buurt.dbf
    │   ├───buurt.prj
    │   ├───buurt.shp
    │   └───buurt.shx
    │
    └───RemoteSensing
        │
        └───2020_LR_CIR_totaalmozaiek_v2_clip.ecw   <- grote luchtfoto


3. Indien het een externe harde schijf is, zorg dat deze ingeplugd is bij het opstarten van de
   Windows PC, anders wordt de inhoud van de externe harde schijf zometeen niet goed gelezen.

4. Haal deze docker image op via de command line: `docker pull indigoilya/gdal-docker`
    Deze image heeft zowel python als gdal in zich.
    Het heeft ook libraries om *.ecw plaatjes lezen.
    De grote luchtfote is in *.ecw formaat, dus dat hebben we nodig.

5. Check of je toegang hebt tot de (externe) harde schijf vanuit de docker-container:
    `docker run --rm -it --volume //d/RemoteSensing:/rs indigoilya/gdal-docker:latest ls ../rs`

6. Check of de grote luchtfoto gelezen kan worden:
    `docker run --rm -it --volume //d/RemoteSensing:/rs indigoilya/gdal-docker:latest gdalinfo ../rs/2020_LR_CIR_totaalmozaiek_v2_clip.ecw`

7. Maak een knip-bestand aan. Zie `tryout_knip_buurt.py`.
    Sla de bestanden op in de folder `data` op de (externe) harde schijf.

8. Mount zowel de data folder als de RemoteSensing folder:
    `docker run --rm -it --volume //d/data:/data --volume //d/RemoteSensing:/rs indigoilya/gdal-docker:latest ls ../rs`

9. Daadwerkelijk kunippen
    De luchtfoto wordt geknipt met het volgende commando. 
    Het bestand wordt opgeslagen in de `data`-folder op de (externe) harde schijf als *.tif bestand.
       `docker run --rm -it --volume //d/data:/data --volume //d/RemoteSensing:/rs indigoilya/gdal-docker:latest gdalwarp -cutline ../data/buurt.shp -crop_to_cutline  ../rs/2020_LR_CIR_totaalmozaiek_v2_clip.ecw ../data/buurt.tif`