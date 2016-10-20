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
export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application/
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VITO=$OUTDIR/VITO

export -p CXDIR=$IDIR/bio_input_collecting/bin/
export -p CRS32662=$IDIR/parameters
export -p C2=$IDIR/parameters/CRS32662.txt
export -p DAOI=$2

export -p Y2=$1
echo $Y2

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
if [[ $DAOI == AOI1 ]] ; then
	export -p CRS326620=$(grep AOI1 $C2);

elif [[ $DAOI == AOI2 ]] ; then
	export -p CRS326620=$(grep AOI2 $C2);

elif [[ $DAOI == AOI3 ]] ; then
	export -p CRS326620=$(grep AOI3 $C2);

elif [[ $DAOI == AOI4 ]] ; then 
	export -p CRS326620=$(grep AOI4 $C2);
else
	echo "AOI out of range"
fi 
#-------------------------------------------------------------------------------------#
for file in $VITO/*1_01.tif ; do
export -p COUNT=0
filename=$(basename $file .tif )
# Get the same boundary information_globcover
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $VITO/${filename}.tif  $VITO/${filename}_crop_$COUNT.tif 

ciop-log "INFO" "Retrieving: $LAND001/${filename}_crop_$COUNT.tif"
done < $CRS326620
done

rm $VITO/NDV001_01.tif $VITO/NIR001_01.tif $VITO/RED001_01.tif
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
echo "DONE"
echo 0

