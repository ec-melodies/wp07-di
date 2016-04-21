#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: Translate HDF to GTiff (PROBA_V)
#-------------------------------------------------------------------------------------# 
# Requires:
# gdal_translate
# gdalwarp
# awk
# unzip
#-------------------------------------------------------------------------------------# 
export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application/
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VITO=$OUTDIR/VITO

export -p AOIP="$( ciop-getparam AOI)"
export AOI=$(awk '{ print $1}' $AOIP)
echo $AOI

#Year
export -p Y2=$1
echo $Y2

#List of images
export -p INP2=$IDIR/parameters/vito
export -p y3=$(grep $Y2 $INP2)
cd $VITO
ciop-copy -o . $y3

export -p Cx001=$OUTDIR/CM001/AOI/AOI_CX/Cx001_info.txt
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# set the environment variables to use ESA BEAM toolbox

export SNAP=/opt/snap-2.0
export PATH=${SNAP}/bin:${PATH}

#-------------------------------------------------------------------------------------# 
#the ESA toolbox
						
if [[ $AOI == AOI1 ]] ; then
	echo "${POLYGON=$(echo -11.05384635925293 47.092308044433594, 5.146153926849365 47.092308044433594, 5.146153926849365 34.21538543701172, -11.05384635925293 34.21538543701172, -11.05384635925293 47.092308044433594)}"

elif [[ $AOI == AOI2 ]] ; then
	echo "${POLYGON=$(echo -19.384294509887695 40.15374755859375, 41.53890609741211 40.15374755859375, 41.53890609741211 8.307528495788574, -19.384294509887695 8.307528495788574, -19.384294509887695 40.15374755859375)}"

elif [[ $AOI == AOI3 ]] ; then
	echo "${POLYGON=$(echo 17.592308044433594 -3.8307693004608154, 42.46923065185547 -3.8307693004608154, 42.46923065185547 -32.85384750366211, 17.592308044433594 -32.85384750366211, 17.592308044433594 -3.8307693004608154)}"   

elif [[ $AOI == AOI4 ]] ; then
	echo "${POLYGON=$(echo 20.590909957885742 44.335662841796875, 45.89160919189453 44.335662841796875, 45.89160919189453 33.38461685180664, 20.590909957885742 33.38461685180664, 20.590909957885742 44.335662841796875)}"

else
	echo "AOI out of range in idcx"
fi 

echo $POLYGON

#-------------------------------------------------------------------------------------# 
cd $OUTDIR
#-------------------------------------------------------------------------------------# 
# set the environment variables to use ESA BEAM toolbox

export SNAP=/opt/snap-2.0
export PATH=${SNAP}/bin:${PATH}

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
while IFS='' read -r line || [[ -n "$line" ]]; do
echo $line
export -p INSPOT=$line
export -p OUTSPOT=$line.tif
export -p filename=$(basename $line .HDF5)
export -p OUTSPOT=$VITO/${filename}.tif
echo $filename
#-------------------------------------------------------------------------------------# 
#the ESA toolbox

subset_aoi_probav=`cat <<EOF
<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>${INSPOT}</file>
    </parameters>
  </node>
  <node id="Subset">
    <operator>Subset</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <sourceBands>NDVI,TOC_REFL_RED,TOC_REFL_NIR</sourceBands>
      <region>0,0,3360,3360</region>
      <geoRegion/>
      <subSamplingX>1</subSamplingX>
      <subSamplingY>1</subSamplingY>
      <fullSwath>false</fullSwath>
      <tiePointGridNames/>
      <copyMetadata>true</copyMetadata>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Subset"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>${OUTSPOT}</file>
      <formatName>GeoTIFF</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="44.0" y="136.0"/>
    </node>
    <node id="Subset">
      <displayPosition x="261.0" y="132.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>
EOF`

echo $subset_aoi_probav > $VITO/subset_aoi_probav.xml
echo $subset_aoi_probav

done < "$VITO/list.txt"
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
export PATH=/opt/anaconda/bin/:$PATH

cd $VITO

for file in /data/auxdata/ESA/AOI/RAD/PROBAV_S1*.tif; do 
#for file in $VITO/PROBAV_S1*.tif; do 
filename=$(basename $file .tif )
echo $file >> list_proba_RAD.txt
gdalbuildvrt V2KRNS0210_RAD.vrt --optfile list_proba_RAD.txt
gdal_translate V2KRNS0210_RAD.vrt V2KRNS0310_RAD.tif
#gdal_merge.py -ot Int32 -o V2KRNS0210.tif -a_nodata 0 --optfile list_proba.txt
done

for file in /data/auxdata/ESA/AOI/NDV/PROBAV_S1*.tif; do 
#for file in $VITO/PROBAV_S1*.tif; do 
filename=$(basename $file .tif )
echo $file >> list_proba_NDV.txt
gdalbuildvrt V2KRNS0210_NDV.vrt --optfile list_proba_NDV.txt
gdal_translate V2KRNS0210_NDV.vrt V2KRNS0310_NDV.tif
#gdal_merge.py -ot Int32 -o V2KRNS0210.tif -a_nodata 0 --optfile list_proba.txt
done


#gdalwarp -t_srs '+init=epsg:32662' $VITO/V2KRNS0310.tif $VITO/V2KRNS10.tif
gdalwarp -t_srs '+init=epsg:32662' $VITO/V2KRNS0310_NDV.tif $VITO/V2KRNS10_NDV.tif
gdalwarp -t_srs '+init=epsg:32662' $VITO/V2KRNS0310_RAD.tif $VITO/V2KRNS10_RAD.tif
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# PURPOSE: NDVI, NIR, RED
#-------------------------------------------------------------------------------------# 
# extract band
#-------------------------------------------------------------------------------------# 
#for file in $VITO/PROBAV_S1*.tif; do 
#rm $file
#done

gdal_translate -of Gtiff -b 2 V2KRNS10_RAD.tif $VITO/RED001.tif
gdal_translate -of Gtiff -b 3 V2KRNS10_RAD.tif $VITO/NIR001.tif
gdal_translate -of Gtiff -b 1 V2KRNS10_NDV.tif $VITO/NDV001.tif
#-------------------------------------------------------------------------------------# 
# echo "FASE 1"
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI NDVI, NIR, RED
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
for file in $VITO/*001.tif ; do 
filename=$(basename $file .tif )
# Getting the same boundary information_globcover
ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

echo $ulx $uly $lrx $lry $filename
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $VITO/${filename}.tif $VITO/${filename}_01.tif 
done

ciop-log "INFO" "Getting the same boundary information of GlobCover: $VITO/${filename}_01.tif "
#rm $VITO/NDV001.tif $VITO/NIR001.tif $VITO/RED001.tif $VITO/V2KRNS10.tif $VITO/subset_aoi.xml
#-------------------------------------------------------------------------------------#
exit 0
