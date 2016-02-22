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

export DIR=/data/auxdata/ISD/
export -p OUTDIR=$DIR/ISD000/
export -p ZDIR=$OUTDIR/GEOMS/
export -p ISDC=$ZDIR/Cx
export -p ISDD=$ZDIR/Dx

#-------------------------------------------------------------------------------------# 
export -p ZDIR=$OUTDIR/GEOMS/

isd01=$1
isd02=$2
Y=$3
D=$(date +"%d%m%Y")

gdal_calc.py -A $isd01 -B $isd02 --outfile=$ZDIR/ISD_${Y}_${D}_AOI.tif --calc="((0.5*A)+(0.5*B))" --overwrite --NoDataValue=-9999 --type=Float32 

echo "DONE"
echo 0