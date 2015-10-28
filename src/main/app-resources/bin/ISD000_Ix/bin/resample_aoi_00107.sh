#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Translate HDF to GTiff for EPSG: 4326
#-------------------------------------------------------------------------------------# 
# Requires:
# gdal_translate
# gdalwarp
# awk
# unzip
#-------------------------------------------------------------------------------------# 
#bash /application/bin/ISD5_node/ini.sh
# expor-t PATH=/opt/anaconda/bin/:$PATH 

export -p INSPOT=$1

echo $INSPOT
export -p OUTDIR=~/data/ISD/ISD000/VITO; mkdir -p $OUTDIR
export -p OUTSPOT=~/data/ISD/ISD000/VITO/V2KRNS10.tif

echo $OUTSPOT
#export -p POLYGON=`cat <<END 
#POLYGON (( $2 ))
#END`

#-------------------------------------------------------------------------------------# 
cd $OUTDIR; 
#-------------------------------------------------------------------------------------# 
# set the environment variables to use ESA BEAM toolbox
export BEAM_HOME=/opt/beam-5.0
export PATH=${BEAM_HOME}/bin:${PATH}
#-------------------------------------------------------------------------------------# 
#the ESA BEAM 5.0 toolbox

while IFS='' read -r line || [[ -n "$line" ]]; do						
if [[ "$line" == AOI1 ]] ; then
	echo "${POLYGON=$(echo -11.05384635925293 47.092308044433594, 5.146153926849365 47.092308044433594, 5.146153926849365 34.21538543701172, -11.05384635925293 34.21538543701172, -11.05384635925293 47.092308044433594)}"

elif [[ "$line" == AOI2 ]] ; then
	echo "${POLYGON=$(echo -19.384294509887695 40.15374755859375, 41.53890609741211 40.15374755859375, 41.53890609741211 8.307528495788574, -19.384294509887695 8.307528495788574, -19.384294509887695 40.15374755859375)}"

elif [[ "$line" == AOI3 ]] ; then
	echo "${POLYGON=$(echo 17.592308044433594 -3.8307693004608154, 42.46923065185547 -3.8307693004608154, 42.46923065185547 -32.85384750366211, 17.592308044433594 -32.85384750366211, 17.592308044433594 -3.8307693004608154)}"   

elif [[ "$line" == AOI4 ]] ; then
	echo "${POLYGON=$(echo 20.590909957885742 44.335662841796875, 45.89160919189453 44.335662841796875, 45.89160919189453 33.38461685180664, 20.590909957885742 33.38461685180664, 20.590909957885742 44.335662841796875)}"

else
	echo "AOI out of range"
fi 
done < "$2"

echo $POLYGON
cat $2

subset_aoi=`cat <<EOF
<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>${INSPOT}</file>
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
  <node id="Subset">
    <operator>Subset</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <geoRegion>POLYGON (( ${POLYGON} ))</geoRegion>
      <subSamplingX>1</subSamplingX>
      <subSamplingY>1</subSamplingY>
      <fullSwath>false</fullSwath>
      <tiePointGridNames/>
      <copyMetadata>true</copyMetadata>
    </parameters>
  </node>
</graph>
EOF`

echo $subset_aoi > $OUTDIR/subset_aoi.xml
echo $subset_aoi

gpt.sh $OUTDIR/subset_aoi.xml  -Ssource=$INSPOT -f GeoTIFF -t $OUTSPOT

#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI
#-------------------------------------------------------------------------------------# 
#extract band
#-------------------------------------------------------------------------------------# 
gdal_translate -of Gtiff -b 5 $OUTSPOT $OUTDIR/NDV001.tif
gdal_translate -of Gtiff -b 4 $OUTSPOT $OUTDIR/NIR001.tif
gdal_translate -of Gtiff -b 3 $OUTSPOT $OUTDIR/RED001.tif
#-------------------------------------------------------------------------------------# 
#echo "FASE 1"
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI NDVI, NIR, RED
#-------------------------------------------------------------------------------------# 
# Area de interesse
export -p INDIR001=~/data/ISD//ISD000/CM001/AOI/AOI_CX/
file01=$INDIR001/Cx001.tif
#-------------------------------------------------------------------------------------# 
for file in $OUTDIR/*001.tif ; do 
filename=$(basename $file .tif )
# Get the same boundary information_globcover
ulx=$(gdalinfo $file01  | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo $file01  | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo $file01  | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo $file01  | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')
echo $ulx $uly $lrx $lry  $filename
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $OUTDIR/${filename}.tif $OUTDIR/${filename}_01.tif 
done
rm $OUTDIR/NDV001.tif $OUTDIR/NIR001.tif $OUTDIR/RED001.tif $OUTDIR/V2KRNS10.tif $OUTDIR/subset_aoi.xml
#-------------------------------------------------------------------------------------#


