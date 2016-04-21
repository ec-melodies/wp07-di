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
export -p IDIR=/application
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p CDIR=$OUTDIR/SM001
#-------------------------------------------------------------------------------------#
export -p CRS32662=$2
echo $CRS32662
#Year
export -p Y2=$1
echo $Y2

export -p C2=$IDIR/parameters/CRS32662_01.txt
export -p C1=$(cat IDIR/parameters/CRS32662_01.txt ); echo "$C1"
#-------------------------------------------------------------------------------------# 
if [[ $CRS32662 == AOI1 ]] ; then
	export -p CRS326620=$(grep AOI1 $C2);

elif [[ $CRS32662 == AOI2 ]] ; then
	export -p CRS326620=$(grep AOI2 $C2);

elif [[ $CRS32662 == AOI3 ]] ; then
	export -p CRS326620=$(grep AOI3 $C2);

elif [[ $CRS32662 == AOI4 ]] ; then 
	export -p CRS326620=$(grep AOI4 $C2);
else
	echo "AOI out of range"
fi 

#-------------------------------------------------------------------------------------#

for file in $CDIR/*001_.tif ; do
export -p COUNT=0
filename=$(basename $file .tif )
# Get the same boundary information_globcover
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $CDIR/${filename}.tif  $CDIR/${filename}_crop_$COUNT.tif 
done < $CRS326620
done

ciop-log "INFO" "vgt_to_geoms_00203.sh"
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#

exit 0

