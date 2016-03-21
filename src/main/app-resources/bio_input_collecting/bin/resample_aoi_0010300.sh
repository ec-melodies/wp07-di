#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: LANDCOVER
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# gdal_calc
# pktools
# gdal_translate 
# R packages: 
# zoo
# rgdal
# raster
# sp
# maptools

#-------------------------------------------------------------------------------------# 
# source the ciop functions
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
export PATH=/opt/anaconda/bin/:$PATH

export -p IDIR=/application/
echo $IDIR

export -p DIR=/data/auxdata/ISD/
export -p INDIR=$DIR/INPUT
export -p OUTDIR=$DIR/ISD000
export -p LAND001=$OUTDIR/VITO
#-------------------------------------------------------------------------------------#
# Sample
#-------------------------------------------------------------------------------------#

#export -p CRS32662=$IDIR/parameters/AOI
CRS32662="$( ciop-getparam AOI)"

export -p C2=$IDIR/parameters/CRS32662.txt
#-------------------------------------------------------------------------------------# 
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ "$line" == AOI1 ]] ; then
		export -p CRS326620=$(grep AOI1 $C2);

	elif [[ "$line" == AOI2 ]] ; then
		export -p CRS326620=$(grep AOI2 $C2);

	elif [[ "$line" == AOI3 ]] ; then
		export -p CRS326620=$(grep AOI3 $C2);

	elif [[ "$line" == AOI4 ]] ; then 
		export -p CRS326620=$(grep AOI4 $C2);
	else
		echo "AOI out of range"
	fi 
done < "$CRS32662"

#-------------------------------------------------------------------------------------#
export -p COUNT=0
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $LAND001/GLOBCOVER_01.tif $LAND001/GLOBCOVER_01_crop_$COUNT.tif
done < $CRS326620
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
echo "DONE"
echo 0


