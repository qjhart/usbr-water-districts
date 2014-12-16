#! /usr/bin/make -f 

# THis is good idea, but not used
define geo
geojson::${1}.geojson

${1}.geojson: src/${1}.vrt src/${2}
	ogr2ogr -f GEOJSON  -t_srs WGS84 $$@ $$<

# Here's an Example of materializing that VRT file, for example to
# upload to Google Maps.
shp:: src/${1}.vrt src/$2
	ogr2ogr $$@ $$<

# While we may store the original data in the GITHUB repository, we
# also want to show how we got the data.
src/$2:
	[[ -f ${3} ]] || curl ${3} > src/$(notdir ${3})
	unzip -d src -u src/$(notdir ${3})
	rm src/$(notdir ${3})


# Additionally, we may want to show alternative import strateigies.
# This rule will create a PostGIS version in ${schema}
.PHONY: postgis
postgis:: src/${1}.vrt src/${2}
	${OGR} src/${1}.vrt

clean::
	rm -rf ${1}.geojson


endef

$(eval $(call geo,water_districts,US_Bureau_Reclamation_water_districts_2012.shp,https://projects.atlas.ca.gov/frs/download.php/15360/usbr_water_districts_2012.zip))
$(eval $(call geo,private_water_districts,wdpr24.shp,https://projects.atlas.ca.gov/frs/download.php/26/usbr_wat_dist_priv.zip))
$(eval $(call geo,state_water_districts,wdst24.shp,https://projects.atlas.ca.gov/frs/download.php/245/usbr_wat_dist_state_2003_03_25.zip))



