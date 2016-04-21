#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI LULC
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# gdal_calc
# gdalwarp
#-------------------------------------------------------------------------------------# 
# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application/
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VITO=$OUTDIR/VITO
export -p CMDIR=$OUTDIR/CM001
export -p CMDIR01=$CMDIR/AOI/AOI_CX
export -p Cx000=$CMDIR01/Cx001.txt

echo  "$(cat $Cx000 )"
echo "PATH:" $CMDIR01

export -p LAND001=/data/auxdata/ESA/GLOBCOVER_L4_200901_200912_V2.3.tif

#-------------------------------------------------------------------------------------#
# CROP LAND/LANDCOVER
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# Get the same boundary information_globcover
ulx=$(cat $Cx000  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx000  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx000  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx000  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')
echo $ulx $uly $lrx $lry 
ciop-log "INFO" "Retrieving $CMDIR01/Cx001.txt: $ulx $uly $lrx $lry"
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $LAND001 $VITO/GLOBCOVER02_01.tif
#-------------------------------------------------------------------------------------#
cd $VITO
gdalwarp -t_srs '+init=epsg:32662' $VITO/GLOBCOVER02_01.tif $VITO/GLOBCOVER_01.tif
ciop-publish -m $VITO/GLOBCOVER_01.tif
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
exit 0

