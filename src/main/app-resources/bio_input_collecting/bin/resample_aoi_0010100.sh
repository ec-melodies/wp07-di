#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI LULC
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalwarp
# gdal_translate
#-------------------------------------------------------------------------------------# 
# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VITO=$OUTDIR/VITO
export -p CMDIR=$OUTDIR/CM001
export -p CMDIR01=$CMDIR/AOI/AOI_CX
export -p LULC=$IDIR/parameters/LULC.txt
export -p CR=$IDIR/parameters/AOI_Cx001.txt

export -p INP2=$OUTDIR/AOI.txt
export -p Y2=$(cat $INP2| awk '{ print  $2 }')
export -p ISR=$(cat $INP2| awk '{ print  $3 }')

echo $ISR
echo $Y2

cd $DIR
if [ ! -d "/data/auxdata" ]; then
ciop-copy -o . s3://melodies-wp7/auxdata.tar.gz
tar xopf $DIR/auxdata.tar -C /
chmod -R 777 /data/auxdata
rm -rf $DIR/auxdata.tar
fi

export -p LAND001=$(cat $LULC | awk 'NR == 2')
#-------------------------------------------------------------------------------------#
# CROP LAND/LANDCOVER
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
if [[ "$ISR" == AOI1 ]] ; then
	export -p Cx000=$(grep AOI1_Cx001.txt $CR);

elif [[ "$ISR" == AOI2 ]] ; then
	export -p Cx000=$(grep AOI2_Cx001.txt $CR);

elif [[ "$ISR" == AOI3 ]] ; then
	export -p Cx000=$(grep AOI3_Cx001.txt $CR);

elif [[ "$ISR" == AOI4 ]] ; then 
	export -p Cx000=$(grep AOI4_Cx001.txt $CR);
else
	echo "AOI out of range _globcover"
fi 
#-------------------------------------------------------------------------------------# 
# Get the same boundary information_globcover
ulx=$(cat $Cx000  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx000  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx000  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx000  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')
echo $ulx $uly $lrx $lry 
ciop-log "INFO" "Retrieving $Cx000: $ulx $uly $lrx $lry"
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $LAND001 $VITO/GLOBCOVER02_01.tif
#-------------------------------------------------------------------------------------#
cd $VITO
gdalwarp -t_srs '+init=epsg:32662' $VITO/GLOBCOVER02_01.tif $VITO/GLOBCOVER_01.tif
#-------------------------------------------------------------------------------------# 
rm $VITO/GLOBCOVER02_01.tif
#-------------------------------------------------------------------------------------# 
exit 0

