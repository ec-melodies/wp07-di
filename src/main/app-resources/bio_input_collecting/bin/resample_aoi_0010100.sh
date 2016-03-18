#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI LULC
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# gdal_calc
# gdalwarp
#-------------------------------------------------------------------------------------# 

export PATH=/opt/anaconda/bin/:$PATH
export -p DIR=/data/auxdata/ISD/
export -p OUTDIR=$DIR/ISD000/
export -p OUTDIR01=$DIR/ISD000/VITO

#Cx001=$(grep "Cx001" $1)
#LAND001=$(grep "GLOBCOVER" $1)

mkdir -p $OUTDIR01
export -p Cx001=/data/auxdata/ISD/ISD000/CM001/AOI/AOI_CX/Cx001.txt
export -p LAND001=/data/auxdata/ESA/GLOBCOVER_L4_200901_200912_V2.3.tif
#-------------------------------------------------------------------------------------#
# CROP LAND/LANDCOVER
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# Get the same boundary information_globcover
ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')
echo $ulx $uly $lrx $lry  
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $LAND001 $OUTDIR01/GLOBCOVER02_01.tif 
#-------------------------------------------------------------------------------------#
gdalwarp -t_srs '+init=epsg:32662' $OUTDIR01/GLOBCOVER02_01.tif $OUTDIR01/GLOBCOVER_01.tif

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
exit 0

