#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Subset CM001 
#-------------------------------------------------------------------------------------# 
# Requires:
# awk
# wine
# geoms.exe
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

export -p DIR=/data/auxdata/ISD/
export -p INDIR=$DIR/INPUT
export -p OUTDIR=$DIR/ISD000/
export -p C001=$OUTDIR/CM001/AOI/AOI_CX/
export -p C002=$OUTDIR/CM001/AOI/AOI_CX/C002
mkdir $C002

#-------------------------------------------------------------------------------------#
# Sample
#-------------------------------------------------------------------------------------#
export -p CXDIR=/application/cli_block_a/bin
export -p CRS32662=/application/parameters/
export -p C2=/application/parameters/CRS32662.txt
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
done < "/application/parameters/AOI"
#-------------------------------------------------------------------------------------#
export -p COUNT=0
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $C001/Cx001_32662.tif $C002/Cx001_32662_$COUNT.tif
done < $CRS326620
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 

echo "DONE"
echo 0