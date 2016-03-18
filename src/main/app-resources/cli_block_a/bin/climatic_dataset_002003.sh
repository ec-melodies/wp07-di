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
# source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 

#bash /application/bin/ISD5_node/ini.sh
export PATH=/opt/anaconda/bin/:$PATH

export -p DIR=/data/auxdata/ISD/
export -p INDIR=$DIR/INPUT
export -p OUTDIR=$DIR/ISD000/
export -p C001=$OUTDIR/CM001/AOI/AOI_DX/
export -p C002=$OUTDIR/CM001/AOI/AOI_DX/C002
mkdir $C002

export -p IDIR=/application/
echo $IDIR
#-------------------------------------------------------------------------------------#
# Sample
#-------------------------------------------------------------------------------------#
export -p CXDIR=$IDIR/cli_block_a/bin
export -p CRS32662=$IDIR/parameters/
export -p C2=$IDIR/parameters/CRS32662.txt
#-------------------------------------------------------------------------------------# 
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ "$line" == AOI1 ]] ; then
		export -p CRS326620=$(grep AOI1_32662.txt $C2);

	elif [[ "$line" == AOI2 ]] ; then
		export -p CRS326620=$(grep AOI2_32662.txt $C2);

	elif [[ "$line" == AOI3 ]] ; then
		export -p CRS326620=$(grep AOI3_32662.txt $C2);

	elif [[ "$line" == AOI4 ]] ; then 
		export -p CRS326620=$(grep AOI4_32662.txt $C2);
	else
		echo "AOI out of range"
	fi 
done < "$IDIR/parameters/AOI"
#-------------------------------------------------------------------------------------#
export -p COUNT=0
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $C001/Dx001.tif $C002/Dx001_32662_$COUNT.tif
done < $CRS326620
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
echo "DONE"
exit 0
