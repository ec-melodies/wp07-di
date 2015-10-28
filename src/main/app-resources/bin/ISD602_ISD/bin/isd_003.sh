#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: ISD
#-------------------------------------------------------------------------------------# 
# Requires:
# awk
# gdal_calc
# maptools
#-------------------------------------------------------------------------------------# 
# source the ciop functions
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
anaconda=/opt/anaconda/bin/
export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------# 

export DIR=~/data/ISD/
export -p OUTDIR=$DIR/ISD000/
export -p ZDIR=$OUTDIR/GEOMS/
export -p ISDC=$ZDIR/Cx
export -p ISDD=$ZDIR/Dx

#-------------------------------------------------------------------------------------# 
export -p ZDIR=$OUTDIR/GEOMS/

isd01=$1
isd02=$2

gdal_calc.py -A $isd01 -B $isd02 --outfile=$ZDIR/ISD_2010_AOI.tif --calc="((0.5*A)+(0.5*B))" --overwrite --NoDataValue=-9999 --type=Float32 

echo "DONE"

rm /home/melodies-ist/data/ISD/ISD000/CM001/ecmwf.grib
rm /home/melodies-ist/debug.dbg
rm /home/melodies-ist/Cluster.trn