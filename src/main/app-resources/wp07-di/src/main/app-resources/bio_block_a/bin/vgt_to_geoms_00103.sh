#!/bin/sh
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
# source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
#bash /application/bin/ISD5_node/ini.sh
export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application/
echo $IDIR

export -p DIR=$TMPDIR/data/outDIR/ISD
export -p INDIR=$DIR/INPUT
export -p OUTDIR=$DIR/ISD000/
export -p Vx001=$OUTDIR/VM001/
#-------------------------------------------------------------------------------------#
# Samples
#-------------------------------------------------------------------------------------#
CRS32662="$( ciop-getparam aoi )"
echo $CRS32662

export -p C2=$IDIR/parameters/CRS32662.txt
export -p C1=$(cat IDIR/parameters/CRS32662.txt ); echo "$C1"
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

for file in $Vx001/*01_.tif ; do
export -p COUNT=0
filename=$(basename $file .tif )
# Get the same boundary information_globcover
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $Vx001/${filename}.tif  $Vx001/${filename}_crop_$COUNT.tif 
done < $CRS326620
done

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
exit 0