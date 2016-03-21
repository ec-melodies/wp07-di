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
export -p DIR=/data/auxdata/ISD
export -p OUTDIR=$DIR/ISD000/
export -p OUTDIR01=$DIR/ISD000/VITO

mkdir -p $OUTDIR01

ciop-log "DEBUG" "Processing the job with ESA/GLOBCOVER_L4_200901_200912_V2.3.tif"

export -p Cx000=/data/auxdata/ISD/ISD000/CM001/AOI/AOI_CX/Cx001.txt
Cx001=$( ciop-copy $Cx000)

export -p input=/data/auxdata/ESA/GLOBCOVER_L4_200901_200912_V2.3.tif
LAND001=$( ciop-copy $input)

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

gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input $TMPDIR/GLOBCOVER02_01.tif
cd $OUTDIR01
ciop-copy $TMPDIR/GLOBCOVER02_01.tif $OUTDIR01/GLOBCOVER02_01.tif
ciop-publish $TMPDIR/GLOBCOVER02_01.tif

ciop-log "DEBUG" "Projecting data with gdalwarp: epsg:32662"
#-------------------------------------------------------------------------------------#
gdalwarp -t_srs '+init=epsg:32662' $OUTDIR01/GLOBCOVER02_01.tif $OUTDIR01/GLOBCOVER_01.tif

ciop-publish $OUTDIR01/GLOBCOVER_01.tif
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
exit 0

