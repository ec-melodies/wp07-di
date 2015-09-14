#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# gdal_calc
# gdalwarp
#-------------------------------------------------------------------------------------# 
export -p OUT=~/data/ISD/ISD000/CM001/
export -p OUT001=$OUT/AOI/AOI_CX/
mkdir -p $OUT001
export -p BIN=~/wp07-di/src/main/app-resources/bin/

#IMAGENS SPOT 
export -p DIR=~/data/ISD/
export -p INDIR=$DIR/INPUT
export -p SPOTIN001=$INDIR/VITO/2010/EU/V2KRNS10__20100901E_EU.tif

export -p INDIR001=$DIR/ISD000/CM001/AOI/AOI_CX/

export -p SPPV00101=$OUTDIR/SPPV001/AOI1/VX
export -p SPPV00102=$OUTDIR/SPPV001/AOI1/SX

#IMAGENS LAND COVER 
export -p LAND=$INDIR/LANDCOVER/
export -p LAND000=$LAND/LANDCOVER000
export -p LAND001=$INDIR/LANDCOVER/Globcover2009_V2.3_Global_/GLOBCOVER_L4_200901_200912_V2.3.tif

input000=$SPOTIN001

#-------------------------------------------------------------------------------------#
# CROP Cx.tif

export -p OUTDIR000=$DIR/ISD000/SPPV001/
export -p OUTDIR002=$OUTDIR000/AOI1/VX
mkdir -p $OUTDIR001

file01=$OUT001/Cx001.tif
file02=$BIN/ISD5_node/AOI1.txt
#-------------------------------------------------------------------------------------#
box01=`awk -F"," 'NR==1{print $1}' $file02`
box02=`awk -F"," 'NR==2{print $1}' $file02`
box03=`awk -F"," 'NR==3{print $1}' $file02`
box04=`awk -F"," 'NR==4{print $1}' $file02`

filename=$(basename $OUT001/AOI1.tif .tif )
gdal_translate -projwin $box01 -of GTiff $file01 $OUT001/${filename}_crop_01.tif 
gdal_translate -projwin $box02 -of GTiff $file01 $OUT001/${filename}_crop_02.tif 
gdal_translate -projwin $box03 -of GTiff $file01 $OUT001/${filename}_crop_03.tif 
gdal_translate -projwin $box04 -of GTiff $file01 $OUT001/${filename}_crop_04.tif 
#-------------------------------------------------------------------------------------# 
#extract image band
#-------------------------------------------------------------------------------------# 

gdal_translate -of Gtiff -b 5 $input000 $OUTDIR000/NDV.tif
gdal_translate -of Gtiff -b 4 $input000 $OUTDIR000/NIR.tif
gdal_translate -of Gtiff -b 3 $input000 $OUTDIR000/RED.tif


# Get the same boundary information_globcover
ulx=$(gdalinfo $file01  | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo $file01  | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo $file01  | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo $file01  | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')

echo $ulx $uly $lrx $lry  

gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $OUTDIR000/NDV.tif $OUTDIR000/NDV01.tif
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $OUTDIR000/NIR.tif $OUTDIR000/NIR01.tif
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $OUTDIR000/RED.tif $OUTDIR000/RED01.tif

#-------------------------------------------------------------------------------------# 
#resample spot-vgt
#-------------------------------------------------------------------------------------# 
# CROP LAND/LANDCOVER
#-------------------------------------------------------------------------------------# 
for file in $OUT001/AOI1_crop*.tif ; do 
filename=$(basename $file .tif )
# Get the same boundary information_globcover
ulx=$(gdalinfo $INDIR001/${filename}.tif  | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo $INDIR001/${filename}.tif  | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo $INDIR001/${filename}.tif  | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo $INDIR001/${filename}.tif  | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')
echo $ulx $uly $lrx $lry  
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $LAND001  $OUTDIR000/${filename}_LULC.tif 
done
#-------------------------------------------------------------------------------------# 
exit 0


