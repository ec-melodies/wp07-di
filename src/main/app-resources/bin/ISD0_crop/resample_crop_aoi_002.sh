#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# gdal_calc
# gdalwarp
#-------------------------------------------------------------------------------------# 
export OUT=/media/sf_geodata/VM_sandbox_04092015/CM000/AOI2
export SPOTIN000=/media/sf_geodata/VM_sandbox_04092015/VITO_ESA/
export SPOTIN001=$SPOTIN000/2000/AF
export INDIR=/media/sf_geodata/VM_sandbox_04092015/CM000/AOI2/
export OUTDIR=$SPOTIN001/AOI2
export -p LAND000=$INDIR/LANDCOVER/LANDCOVER000

file03=$OUT/AOI2_Cx001.tif
file04=$OUT/AOI2.txt
input000=$SPOTIN001/V1KRNS10__20000901E_AF.tif 

mkdir $OUTDIR

#-------------------------------------------------------------------------------------# 
box_01=`awk -F"," 'NR==1{print $1}' $file04`
box_02=`awk -F"," 'NR==2{print $1}' $file04`
box_03=`awk -F"," 'NR==3{print $1}' $file04`
box_04=`awk -F"," 'NR==4{print $1}' $file04`
box_05=`awk -F"," 'NR==5{print $1}' $file04`
box_06=`awk -F"," 'NR==6{print $1}' $file04`
box_07=`awk -F"," 'NR==7{print $1}' $file04`
box_08=`awk -F"," 'NR==8{print $1}' $file04`
box_09=`awk -F"," 'NR==9{print $1}' $file04`
box_10=`awk -F"," 'NR==10{print $1}' $file04`
box_11=`awk -F"," 'NR==11{print $1}' $file04`
box_12=`awk -F"," 'NR==12{print $1}' $file04`
box_13=`awk -F"," 'NR==13{print $1}' $file04`
box_14=`awk -F"," 'NR==14{print $1}' $file04`
box_15=`awk -F"," 'NR==15{print $1}' $file04`
box_16=`awk -F"," 'NR==16{print $1}' $file04`
box_17=`awk -F"," 'NR==17{print $1}' $file04`
box_18=`awk -F"," 'NR==18{print $1}' $file04`
box_19=`awk -F"," 'NR==19{print $1}' $file04`
box_20=`awk -F"," 'NR==20{print $1}' $file04`
box_21=`awk -F"," 'NR==21{print $1}' $file04`
box_22=`awk -F"," 'NR==22{print $1}' $file04`
box_23=`awk -F"," 'NR==23{print $1}' $file04`
box_24=`awk -F"," 'NR==24{print $1}' $file04`
box_25=`awk -F"," 'NR==25{print $1}' $file04`
box_26=`awk -F"," 'NR==26{print $1}' $file04`
box_27=`awk -F"," 'NR==27{print $1}' $file04`
box_28=`awk -F"," 'NR==28{print $1}' $file04`
box_29=`awk -F"," 'NR==29{print $1}' $file04`
box_30=`awk -F"," 'NR==30{print $1}' $file04`
box_31=`awk -F"," 'NR==31{print $1}' $file04`
box_32=`awk -F"," 'NR==32{print $1}' $file04`
box_33=`awk -F"," 'NR==33{print $1}' $file04`
box_34=`awk -F"," 'NR==34{print $1}' $file04`
box_35=`awk -F"," 'NR==35{print $1}' $file04`

filename=$(basename $file03 .tif )
gdal_translate -projwin $box_01 -of GTiff $file03 $OUT/${filename}_crop_01.tif
gdal_translate -projwin $box_02 -of GTiff $file03 $OUT/${filename}_crop_02.tif
gdal_translate -projwin $box_03 -of GTiff $file03 $OUT/${filename}_crop_03.tif
gdal_translate -projwin $box_04 -of GTiff $file03 $OUT/${filename}_crop_04.tif
gdal_translate -projwin $box_05 -of GTiff $file03 $OUT/${filename}_crop_05.tif
gdal_translate -projwin $box_06 -of GTiff $file03 $OUT/${filename}_crop_06.tif
gdal_translate -projwin $box_07 -of GTiff $file03 $OUT/${filename}_crop_07.tif
gdal_translate -projwin $box_08 -of GTiff $file03 $OUT/${filename}_crop_08.tif
gdal_translate -projwin $box_09 -of GTiff $file03 $OUT/${filename}_crop_09.tif
gdal_translate -projwin $box_10 -of GTiff $file03 $OUT/${filename}_crop_10.tif
gdal_translate -projwin $box_11 -of GTiff $file03 $OUT/${filename}_crop_11.tif
gdal_translate -projwin $box_12 -of GTiff $file03 $OUT/${filename}_crop_12.tif
gdal_translate -projwin $box_13 -of GTiff $file03 $OUT/${filename}_crop_13.tif
gdal_translate -projwin $box_14 -of GTiff $file03 $OUT/${filename}_crop_14.tif
gdal_translate -projwin $box_15 -of GTiff $file03 $OUT/${filename}_crop_15.tif
gdal_translate -projwin $box_16 -of GTiff $file03 $OUT/${filename}_crop_16.tif
gdal_translate -projwin $box_17 -of GTiff $file03 $OUT/${filename}_crop_17.tif
gdal_translate -projwin $box_18 -of GTiff $file03 $OUT/${filename}_crop_18.tif
gdal_translate -projwin $box_19 -of GTiff $file03 $OUT/${filename}_crop_19.tif
gdal_translate -projwin $box_20 -of GTiff $file03 $OUT/${filename}_crop_20.tif
gdal_translate -projwin $box_21 -of GTiff $file03 $OUT/${filename}_crop_21.tif
gdal_translate -projwin $box_22 -of GTiff $file03 $OUT/${filename}_crop_22.tif
gdal_translate -projwin $box_23 -of GTiff $file03 $OUT/${filename}_crop_23.tif
gdal_translate -projwin $box_24 -of GTiff $file03 $OUT/${filename}_crop_24.tif
gdal_translate -projwin $box_25 -of GTiff $file03 $OUT/${filename}_crop_25.tif
gdal_translate -projwin $box_26 -of GTiff $file03 $OUT/${filename}_crop_26.tif
gdal_translate -projwin $box_27 -of GTiff $file03 $OUT/${filename}_crop_27.tif
gdal_translate -projwin $box_28 -of GTiff $file03 $OUT/${filename}_crop_28.tif
gdal_translate -projwin $box_29 -of GTiff $file03 $OUT/${filename}_crop_29.tif
gdal_translate -projwin $box_30 -of GTiff $file03 $OUT/${filename}_crop_30.tif
gdal_translate -projwin $box_31 -of GTiff $file03 $OUT/${filename}_crop_31.tif
gdal_translate -projwin $box_32 -of GTiff $file03 $OUT/${filename}_crop_32.tif
gdal_translate -projwin $box_33 -of GTiff $file03 $OUT/${filename}_crop_33.tif
gdal_translate -projwin $box_34 -of GTiff $file03 $OUT/${filename}_crop_34.tif
gdal_translate -projwin $box_35 -of GTiff $file03 $OUT/${filename}_crop_35.tif

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
#pkcrop 
#resample spot-vgt
#-------------------------------------------------------------------------------------# 
gdal_translate -of Gtiff -b 5 $input000 $SPOTIN001/NDV.tif
gdal_translate -of Gtiff -b 4 $input000 $SPOTIN001/NIR.tif
gdal_translate -of Gtiff -b 3 $input000 $SPOTIN001/RED.tif

#input002=$LAND000/LANDC001.tif
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



