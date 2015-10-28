#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: ISD (Cx)
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
export DIR=~/data/ISD/

export -p OUTDIR=$DIR/ISD000/

export -p ZDIR=$OUTDIR/GEOMS/
export -p ISDC=$ZDIR/Cx
export -p ISDD=$ZDIR/Dx

export -p HDIR=/home/melodies-ist/wp07-di/src/main/app-resources/bin/ISD7_geoms/
export -p HXDIR=/home/melodies-ist/wp07-di/src/main/app-resources/bin/ISD5_node/

export -p LDIR=$OUTDIR/COKC
export -p ADIR=$OUTDIR/=$DIR/INPUT/AOI
#-------------------------------------------------------------------------------------# 
export -p ZDIR=$OUTDIR/GEOMS/

isd01=$ISDD/ISDmeanDx001_1.tif
isd02=$ISDC/ISDmeanCx001_1.tif

gdal_calc.py -A $isd01 -B $isd02 --outfile=$ZDIR/ISD_2000_AOI1.tif --calc="((0.5*A)+(0.5*B))" --overwrite --NoDataValue=-9999 --type=Float32; 

echo "DONE"


