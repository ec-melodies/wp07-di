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
export -p DIR=$TMPDIR/data/outDIR/ISD
#export -p DIR=/data/outDIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p OUTDIR01=$DIR/ISD000/VITO
export -p CMDIR=$OUTDIR/CM001
export -p CMDIR01=$CMDIR/AOI/AOI_CX

mkdir -p $OUTDIR01

ciop-log "DEBUG" "Processing the job with ESA/GLOBCOVER_L4_200901_200912_V2.3.tif"

export -p Cx000=$CMDIR01/Cx001.txt
export -p Cx001=$(cat $CMDIR01/Cx001.txt ); echo "$Cx001.txt"

echo "PATH:" $CMDIR01

export -p input=/data/auxdata/ESA/GLOBCOVER_L4_200901_200912_V2.3.tif

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
ciop-log "DEBUG" "Retrieving $CMDIR01/Cx001.txt: $ulx $uly $lrx $lry"

gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input $OUTDIR01/GLOBCOVER02_01.tif

cd $OUTDIR01
#-------------------------------------------------------------------------------------#
gdalwarp -t_srs '+init=epsg:32662' $OUTDIR01/GLOBCOVER02_01.tif $OUTDIR01/GLOBCOVER_01.tif

ciop-publish -m $OUTDIR01/GLOBCOVER01.tif
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
exit 0

