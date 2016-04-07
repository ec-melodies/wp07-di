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
# rciop
#-------------------------------------------------------------------------------------# 
# source the ciop functions
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
#bash /application/bin/ISD5_node/ini.sh
export PATH=/opt/anaconda/bin/:$PATH

export -p IDIR=/application
echo $IDIR
export -p DIR=$TMPDIR/data/outDIR/ISD
#export -p DIR=/data/outDIR/ISD
export -p INDIR=$DIR/INPUT
export -p OUTDIR=$DIR/ISD000
export -p LAND001=$OUTDIR/VITO
#-------------------------------------------------------------------------------------#
# Sample
#-------------------------------------------------------------------------------------#
export -p CXDIR=$IDIR/bio_input_collecting/bin/
export -p CRS32662=$IDIR/parameters/
export -p C2=$IDIR/parameters/CRS32662.txt
#export -p DAOI=$IDIR/parameters/AOI
export -p DAOI="$( ciop-getparam AOI)"

#-------------------------------------------------------------------------------------#
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
done < "$DAOI"

#-------------------------------------------------------------------------------------#

for file in $LAND001/*1_01.tif ; do
export -p COUNT=0
filename=$(basename $file .tif )
# Get the same boundary information_globcover
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $LAND001/${filename}.tif  $LAND001/${filename}_crop_$COUNT.tif 
done < $CRS326620
done

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
echo "DONE"
echo 0
