#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: LANDCOVER Subset
#-------------------------------------------------------------------------------------# 
# Requires:
# gdal_translate 
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

export -p ISR=$2
echo $ISR

#Year
export -p Y2=$1
echo $Y2

export -p C2=$IDIR/parameters/CRS32662.txt; echo "$(cat $IDIR/parameters/CRS32662.txt )"
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
if [[ $ISR == AOI1 ]] ; then
	export -p CRS326620=$(grep AOI1 $C2);

elif [[ $ISR == AOI2 ]] ; then
	export -p CRS326620=$(grep AOI2 $C2);

elif [[ $ISR == AOI3 ]] ; then
	export -p CRS326620=$(grep AOI3 $C2);

elif [[ $ISR == AOI4 ]] ; then 
	export -p CRS326620=$(grep AOI4 $C2);
else
	echo "AOI out of range"
fi 

#-------------------------------------------------------------------------------------#
export -p COUNT=0
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $VITO/GLOBCOVER_01.tif $VITO/GLOBCOVER_01_crop_$COUNT.tif

ciop-log "INFO" "Retrieving: $VITO/GLOBCOVER_01_crop_$COUNT.tif"
done < $CRS326620

rm $VITO/GLOBCOVER_01.tif
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
echo "DONE"
echo 0



