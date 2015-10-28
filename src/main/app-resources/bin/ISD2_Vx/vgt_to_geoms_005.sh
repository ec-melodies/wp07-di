#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: LANDCOVER
#-------------------------------------------------------------------------------------# 
# Requires:
# gdal_merge.py
# rciop
#-------------------------------------------------------------------------------------# 
# source the ciop functions
# source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
#bash /application/bin/ISD5_node/ini.sh
export PATH=/opt/anaconda/bin/:$PATH

export DIR=~/data/ISD/
export -p INDIR=$DIR/INPUT
export -p OUTDIR=$DIR/ISD000/
#export -p LAND=$INDIR/LANDCOVER/
#export -p LAND000=$INDIR/LANDCOVER/LANDCOVER000
export -p LAND001=$OUTDIR/SPPV001
#-------------------------------------------------------------------------------------#
# LULC
#-------------------------------------------------------------------------------------#
gdal_merge.py -pct -o $LAND001/LULC_mosaic.tif -n 0 -init 0 -a_nodata 0 $LAND001/LANDC*.tif
#-------------------------------------------------------------------------------------#




