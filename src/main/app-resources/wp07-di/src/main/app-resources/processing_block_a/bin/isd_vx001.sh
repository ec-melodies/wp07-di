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

export -p DIR=$TMPDIR/data/outDIR/ISD
export -p OUTDIR=$DIR/ISD000/
export -p ZDIR=$OUTDIR/GEOMS
export -p ISDC=$ZDIR/Cx
export -p ISDD=$ZDIR/Dx

export -p IDIR=/application
echo $IDIR
#-------------------------------------------------------------------------------------# 
export -p IDIR=/data/auxdata/AOI
export -p AOIP=$IDIR/parameters/AOI
export AOI=$(awk '{ print $1}' $AOIP)
echo $AOI
export -p YR1=$IDIR/parameters/year
export -p Y2="$(cat $YR1)"

#-------------------------------------------------------------------------------------# 
D=$(date +"%d%m%Y")


for file in $ISDC/ISD_Cx002MSCAOI*.tif; do 
filename=$(basename $file .tif )
isd01=$ISDC/${filename}.tif
isd02=$ISDD/${filename/#ISD_Cx002MSCAOI/ISD_Dx002MSCAOI}.tif 
gdal_calc.py -A $isd01 -B $isd02 --outfile=$ZDIR/ISD_${Y2}_${D}_$AOI.tif --calc="((0.5*A)+(0.5*B))*10000" --NoDataValue=0 --overwrite  --type=UInt32

ciop-publish -r $ZDIR/ISD_${Y2}_${D}_$AOI.tif

done

#-------------------------------------------------------------------------------------#
echo "DONE"
echo 0