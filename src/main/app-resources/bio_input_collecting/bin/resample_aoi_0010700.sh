#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Translate HDF to GTiff for EPSG: 4326 (SPOT)
#-------------------------------------------------------------------------------------# 
# Requires:
# gdal_translate
# gdalwarp
# awk
# unzip
#-------------------------------------------------------------------------------------# 
#bash /application/bin/ISD5_node/ini.sh
export -p PATH=/opt/anaconda/bin/:$PATH 

export -p Cx001=$1
export -p AOI=$3
echo $AOI

export -p OUTDIR=/data/auxdata/ISD/ISD000/VITO; mkdir -p $OUTDIR

#-------------------------------------------------------------------------------------# 
cd $OUTDIR
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

#POLYGON=$(echo 20.590909957885742 44.335662841796875, 45.89160919189453 44.335662841796875, 45.89160919189453 33.38461685180664, 20.590909957885742 33.38461685180664, 20.590909957885742 44.335662841796875)
echo $POLYGON
#cat $1


#-------------------------------------------------------------------------------------# 
# set the environment variables to use ESA BEAM toolbox

export SNAP=/opt/snap-2.0
export PATH=${SNAP}/bin:${PATH}

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
OUTDIR=/data/auxdata/ISD/ISD000/VITO/

#-------------------------------------------------------------------------------------# 
while IFS='' read -r line || [[ -n "$line00" ]]; do
echo $line00
line = $(ciop-copy -o ./ $line00)
export -p INSPOT=$line
export -p filename=$(basename $line .zip)
echo $filename
export -p OUTSPOT=$OUTDIR/V2KRNS10.tif 

#-------------------------------------------------------------------------------------# 

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
  <node id="Subset">
    <operator>Subset</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <sourceBands/>
      <region>0,0,40320,14673</region>
      <geoRegion>POLYGON (( ${POLYGON} ))</geoRegion>
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
            <displayPosition x="37.0" y="134.0"/>
    </node>
    <node id="Subset">
      <displayPosition x="268.0" y="134.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>

EOF`

echo $subset_aoi > $OUTDIR/subset_aoi.xml
echo $subset_aoi

gpt $OUTDIR/subset_aoi.xml  -Ssource=$line -f GeoTIFF -t $OUTSPOT
done < "/data/auxdata/ISD/ISD000/list.txt"

cd $OUTDIR
#-------------------------------------------------------------------------------------# 
gdalwarp -t_srs '+init=epsg:32662' $OUTSPOT $OUTDIR/V2KRNS100.tif
#-------------------------------------------------------------------------------------# 
# PURPOSE: NDVI, NIR, RED
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
gdal_translate -of Gtiff -b 2 $OUTDIR/V2KRNS100.tif $OUTDIR/RED001.tif
gdal_translate -of Gtiff -b 3 $OUTDIR/V2KRNS100.tif $OUTDIR/NIR001.tif
gdal_translate -of Gtiff -b 5 $OUTDIR/V2KRNS100.tif $OUTDIR/NDV001.tif

#-------------------------------------------------------------------------------------# 
# echo "FASE 1"
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI NDVI, NIR, RED

#-------------------------------------------------------------------------------------#

R --vanilla --no-readline   -q  <<'EOF'

#R version  3.2.1
# set working directory
CMDIR = Sys.getenv(c('OUTDIR'))

setwd(CMDIR)
getwd()

require(sp)
require(rgdal)
require(raster)
require(rciop)
require("gtools")

rb = raster("/data/auxdata/ISD/ISD000/CM001/AOI/AOI_CX/Cx001_32662.tif")
sink(paste(CMDIR,'/', 'Cx001_32662.txt',sep = ""))
rb
sink()

EOF

export -p Cx001=/data/auxdata/ISD/ISD000/VITO/Cx001_32662.txt
#-------------------------------------------------------------------------------------# 

for file in $OUTDIR/*001.tif ; do 
filename=$(basename $file .tif )
echo $Cx001
# Get the same boundary information_globcover
ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')
echo $ulx $uly $lrx $lry $filename
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $OUTDIR/${filename}.tif $OUTDIR/${filename}_01.tif 
done

#rm $OUTDIR/NDV001.tif $OUTDIR/NIR001.tif $OUTDIR/RED001.tif $OUTDIR/V2KRNS10.tif $OUTDIR/subset_aoi.xml
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 

exit 0


