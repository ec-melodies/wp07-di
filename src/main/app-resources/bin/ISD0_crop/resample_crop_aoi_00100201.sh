#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI Di
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# gdal_calc
# gdalwarp
#-------------------------------------------------------------------------------------# 
export -p OUT=~/data/ISD/ISD000/CM001/
export -p OUT001=$OUT/AOI1/AOI1_DX/
mkdir -p $OUT001
export -p BIN=~/wp07-di/src/main/app-resources/bin/

export -p DIR=~/data/ISD/
export -p INDIR=$DIR/INPUT
export -p SPOTIN001=$INDIR/VITO/2000/EU/V1KRNS10__20000901E_EU.tif

export -p INDIR001=$DIR/ISD000/CM001/AOI1/AOI1_DX/


export -p OUTDIR000=$DIR/ISD000/SPPV001/
export -p OUTDIR001=$DIR/ISD000/CM001/AOI1/AOI1_DX/
mkdir -p $OUTDIR001

export -p LAND=$INDIR/LANDCOVER/
export -p LAND000=$LAND/LANDCOVER000
export -p LAND001=$INDIR/LANDCOVER/Globcover2009_V2.3_Global_/GLOBCOVER_L4_200901_200912_V2.3.tif

file01=$OUT/Dx001.tif
file02=$BIN/ISD5_node/AOI1.txt

input000=$SPOTIN001

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
box01=`awk -F"," 'NR==1{print $1}' $file02`
box02=`awk -F"," 'NR==2{print $1}' $file02`
box03=`awk -F"," 'NR==3{print $1}' $file02`
box04=`awk -F"," 'NR==4{print $1}' $file02`

filename=$(basename $OUT001/AOI1.tif .tif )
gdal_translate -projwin $box01 -of GTiff $file01 $OUTDIR001/${filename}_crop_01.tif 
gdal_translate -projwin $box02 -of GTiff $file01 $OUTDIR001/${filename}_crop_02.tif 
gdal_translate -projwin $box03 -of GTiff $file01 $OUTDIR001/${filename}_crop_03.tif 
gdal_translate -projwin $box04 -of GTiff $file01 $OUTDIR001/${filename}_crop_04.tif 
#-------------------------------------------------------------------------------------# 


