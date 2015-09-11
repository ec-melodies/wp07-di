#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# gdal_calc
# gdalwarp
#-------------------------------------------------------------------------------------# 
export OUT=/media/sf_geodata/VM_sandbox_04092015/CM000/AOI3
export SPOTIN000=/media/sf_geodata/VM_sandbox_04092015/VITO_ESA/
export SPOTIN001=$SPOTIN000/2000/AF
export INDIR=/media/sf_geodata/VM_sandbox_04092015/CM000/AOI3/
export OUTDIR=$SPOTIN001/AOI3
export -p LAND000=$INDIR/LANDCOVER/LANDCOVER000

file04=$OUT/AOI3_Cx001.tif
file05=$OUT/AOI3.txt
input000=$SPOTIN001/V1KRNS10__20000901E_AF.tif 

mkdir $OUTDIR

#-------------------------------------------------------------------------------------# 
box01=`awk -F"," 'NR==1{print $1}' $file05`
box02=`awk -F"," 'NR==2{print $1}' $file05`
box03=`awk -F"," 'NR==3{print $1}' $file05`
box04=`awk -F"," 'NR==4{print $1}' $file05`
box05=`awk -F"," 'NR==5{print $1}' $file05`
box06=`awk -F"," 'NR==6{print $1}' $file05`
box07=`awk -F"," 'NR==7{print $1}' $file05`
box08=`awk -F"," 'NR==8{print $1}' $file05`
box09=`awk -F"," 'NR==9{print $1}' $file05`
box10=`awk -F"," 'NR==10{print $1}' $file05`
box11=`awk -F"," 'NR==11{print $1}' $file05`
box12=`awk -F"," 'NR==12{print $1}' $file05`
box13=`awk -F"," 'NR==13{print $1}' $file05`
box14=`awk -F"," 'NR==14{print $1}' $file05`
box15=`awk -F"," 'NR==15{print $1}' $file05`

filename=$(basename $file04 .tif )
gdal_translate -projwin $box01 -of GTiff $file04 $OUT/${filename}_crop_01.tif 
gdal_translate -projwin $box02 -of GTiff $file04 $OUT/${filename}_crop_02.tif 
gdal_translate -projwin $box03 -of GTiff $file04 $OUT/${filename}_crop_03.tif 
gdal_translate -projwin $box04 -of GTiff $file04 $OUT/${filename}_crop_04.tif 
gdal_translate -projwin $box05 -of GTiff $file04 $OUT/${filename}_crop_05.tif 
gdal_translate -projwin $box06 -of GTiff $file04 $OUT/${filename}_crop_06.tif 
gdal_translate -projwin $box07 -of GTiff $file04 $OUT/${filename}_crop_07.tif 
gdal_translate -projwin $box08 -of GTiff $file04 $OUT/${filename}_crop_08.tif
gdal_translate -projwin $box09 -of GTiff $file04 $OUT/${filename}_crop_09.tif 
gdal_translate -projwin $box10 -of GTiff $file04 $OUT/${filename}_crop_10.tif 
gdal_translate -projwin $box11 -of GTiff $file04 $OUT/${filename}_crop_11.tif 
gdal_translate -projwin $box12 -of GTiff $file04 $OUT/${filename}_crop_12.tif
gdal_translate -projwin $box13 -of GTiff $file04 $OUT/${filename}_crop_13.tif 
gdal_translate -projwin $box14 -of GTiff $file04 $OUT/${filename}_crop_14.tif
gdal_translate -projwin $box15 -of GTiff $file04 $OUT/${filename}_crop_15.tif

#-------------------------------------------------------------------------------------# 
#pkcrop 
#resample spot-vgt
#-------------------------------------------------------------------------------------# 
input000=$SPOTIN001/V1KRNS10__20000901E_AF.tif 

gdal_translate -of Gtiff -b 5 $input000 $SPOTIN001/NDV.tif
gdal_translate -of Gtiff -b 4 $input000 $SPOTIN001/NIR.tif
gdal_translate -of Gtiff -b 3 $input000 $SPOTIN001/RED.tif

#-------------------------------------------------------------------------------------# 
for file in $INDIR/*.tif ; do 
filename=$(basename $file .tif )
# Get the same boundary information_globcover
ulx=$(gdalinfo $INDIR/${filename}.tif  | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo $INDIR/${filename}.tif  | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo $INDIR/${filename}.tif  | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo $INDIR/${filename}.tif  | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')

echo $ulx $uly $lrx $lry 

gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $SPOTIN001/NDV.tif $OUTDIR/${filename}_NDV.tif 
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $SPOTIN001/NIR.tif $OUTDIR/${filename}_NIR.tif 
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $SPOTIN001/RED.tif $OUTDIR/${filename}_RED.tif
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $LAND000/LANDC001.tif  $OUTDIR/${filename}_LULC.tif 
done
#-------------------------------------------------------------------------------------# 



