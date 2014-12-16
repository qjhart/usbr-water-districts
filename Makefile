#! /usr/bin/make -f

include configure.mk

geo:=water_districts
src:=US_Bureau_Reclamation_water_districts_2012 wdpr24 wdst24
src:=$(patsubst %,src/%.shp,${src})

.PHONY:geojson shp clean postgis

DEFAULT: geojson shp

geojson::${geo}.geojson

${geo}.geojson: src/${geo}.vrt ${src}
	cp src/wdpr24.prj src/wdst24.prj
	ogr2ogr -f GEOJSON  -t_srs WGS84 $@ $< ${geo}

# Here's an Example of materializing that VRT file, for example to
# upload to Google Maps.
shp:shp/${geo}.shp
shp/${geo}.shp:: src/${geo}.vrt ${src}
	ogr2ogr shp $< ${geo}

postgis:: src/${geo}.vrt ${src}
	${OGR} src/${geo}.vrt

define download
# While we may store the original data in the GITHUB repository, we
# also want to show how we got the data.
src/$1:
	[[ -f ${2} ]] || curl ${2} > src/$(notdir ${2})
	unzip -d src -u src/$(notdir ${2})
	rm src/$(notdir ${2})
endef


$(eval $(call download,US_Bureau_Reclamation_water_districts_2012.shp,https://projects.atlas.ca.gov/frs/download.php/15360/usbr_water_districts_2012.zip))
$(eval $(call download,wdpr24.shp,https://projects.atlas.ca.gov/frs/download.php/26/usbr_wat_dist_priv.zip))
$(eval $(call download,wdst24.shp,https://projects.atlas.ca.gov/frs/download.php/245/usbr_wat_dist_state_2003_03_25.zip))


# In order to use our PostGIS import, we include some standard
# configuration file.  This is pulled from a specific version, as a
# github GIST.  This, we probably don't save in our repo.  Want users
# to see where it came from.  Update to newer version if required.
configure.mk:gist:=https://gist.githubusercontent.com/qjhart/052c63d3b1a8b48e4d4f
configure.mk:
	wget ${gist}/raw/e30543c3b8d8ff18a950750a0f340788cc8c1931/configure.mk

# Some convience functions for testing and repreoducing
clean::
	rm -rf configure.mk shp


