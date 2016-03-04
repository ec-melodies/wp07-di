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
export -p IDIR=/data/auxdata/AOI
export -p AOIP=/application/parameters/AOI
export AOI=$(awk '{ print $1}' $AOIP)
echo $AOI
export -p YR1=/application/parameters/year
export -p Y2="$(cat $YR1)"

#-------------------------------------------------------------------------------------# 
D=$(date +"%d%m%Y")


for file in $ISDC/ISD_Cx001AOI*.tif; do 
filename=$(basename $file .tif )
isd01=$ISDC/${filename}.tif
isd02=$ISDD/${filename/#ISD_Cx001AOI/ISD_Dx001AOI}.tif 
gdal_calc.py -A $isd01 -B $isd02 --outfile=$ZDIR/ISD_${Y2}_${D}_$AOI.tif --calc="((0.5*A)+(0.5*B))" --overwrite --NoDataValue=-9999 --type=Float32 
done

ciop-publish $ZDIR/ISD_${Y}_${D}_AOI.tif

#-------------------------------------------------------------------------------------#
echo "DONE"
echo 0