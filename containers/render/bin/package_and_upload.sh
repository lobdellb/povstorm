#!/bin/bash

POV_SOURCE_PATH="../earth_moon/"

BUCKET="brycelobdell-terraform-play2-povray"

tar -zcf ${POV_SOURCE_PATH}earth_moon_source.tgz \
	${POV_SOURCE_PATH}1920px-Lambert_cylindrical_equal-area_projection_SW.jpg \
	${POV_SOURCE_PATH}moon.png


gsutil cp ${POV_SOURCE_PATH}earth_moon_source.tgz gs://brycelobdell-terraform-play2-povray/earth_moon_source.tgz
