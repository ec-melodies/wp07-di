#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: NDVI, NIR, RED
#-------------------------------------------------------------------------------------# 
# extract band
#-------------------------------------------------------------------------------------# 
# Requires:
# gdal_translate
# gdalwarp
# awk
# unzip
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
# source the ciop functions
source ${ciop_job_include}
#-------------------------------------------------------------------------------------#  
export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application/
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VITO=$OUTDIR/VITO

export -p AOI=$2
echo $AOI

#Year
export -p Y2=$1
echo $Y2

rm -rf $INSPOT

cd $VITO
#List of images
#export -p INP2=$IDIR/parameters/vito
#export -p y3=$(grep $Y2 $INP2)

cd $VITO
export -p OUTSPOT=$VITO/V2KRNS110.tif
export -p CR=$IDIR/parameters/AOI_Cx001_32662.txt

#-------------------------------------------------------------------------------------# 
# set the environment variables to use ESA BEAM toolbox

export SNAP=/opt/snap-3.0
export PATH=${SNAP}/bin:${PATH}

rm -rf /tmp/snap-mapred/*
rm -rf $INSPOT

#-------------------------------------------------------------------------------------# 
gdalinfo $OUTSPOT

#-------------------------------------------------------------------------------------# 
ciop-log "INFO" "Epsg:32662"

#gdalwarp -t_srs '+init=epsg:32662' $OUTSPOT $VITO/V2KRNS100.tif
ciop-log "DEBUG" "Gdalwarp -> epsg:32662"
#-------------------------------------------------------------------------------------# 

for file in $VITO/PROBAV_S1*.tif; do 
rm $file
done

for file in $VITO/PROBAV_S1*.HDF5; do 
rm $file
done

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# PURPOSE: NDVI, NIR, RED

gdal_translate -of Gtiff -b 2 $VITO/V2KRNS110.tif $VITO/RED001.tif
gdal_translate -of Gtiff -b 3 $VITO/V2KRNS110.tif $VITO/NIR001.tif
gdal_translate -of Gtiff -b 1 $VITO/V2KRNS110.tif $VITO/NDV001.tif

ciop-log "INFO" "BAND: NDV, RED, NIR"
#-------------------------------------------------------------------------------------# 
# echo "FASE 1"
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI NDVI, NIR, RED
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
if [[ "$AOI" == AOI1 ]] ; then
	export -p Cx001=$(grep AOI1_Cx001_32662.txt $CR);

elif [[ "$AOI" == AOI2 ]] ; then
	export -p Cx001=$(grep AOI2_Cx001_32662.txt $CR);

elif [[ "$AOI" == AOI3 ]] ; then
	export -p Cx001=$(grep AOI3_Cx001_32662.txt $CR);

elif [[ "$AOI" == AOI4 ]] ; then 
	export -p Cx001=$(grep AOI4_Cx001_32662.txt $CR);
else
	echo "$AOI out of range"
fi
#-------------------------------------------------------------------------------------# 
ciop-log "INFO" "Getting the same boundary information of GlobCover: $VITO/${filename}_01.tif "

for file in $VITO/*001.tif ; do 
filename=$(basename $file .tif )
echo $Cx001
# Get the same boundary information_globcover
ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')
echo $ulx $uly $lrx $lry $filename
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $VITO/${filename}.tif $VITO/${filename}_01.tif 
done

rm -rf /tmp/snap-mapred/*

ciop-log "INFO" "remover /tmp/snap-mapred/"
rm $VITO/NDV001.tif $VITO/NIR001.tif $VITO/RED001.tif $VITO/V2KRNS110.tif $VITO/V2KRNS0310.tif $VITO/subset_aoi_probav.xml
#-------------------------------------------------------------------------------------#
exit 0