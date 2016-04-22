#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: Translate HDF to GTiff (SPOT)
#-------------------------------------------------------------------------------------# 
# Requires:
# gdal_translate
# gdalwarp
# awk
# unzip
#-------------------------------------------------------------------------------------# 
# source the ciop functions
source ${ciop_job_include}

export PATH=/opt/anaconda/bin/:$PATH

export -p IDIR=/application
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VITO=$OUTDIR/VITO

export AOI=$2
echo $AOI

#Year
export -p Y2=$1
echo $Y2

#List of images
export -p INP2=$IDIR/parameters/vito
export -p y3=$(grep $Y2 $INP2)

cd $VITO
ciop-copy -o . $y3
export -p SPOT=$(ls | grep $Y2)
export -p INSPOT=$VITO/$SPOT
export -p Cx001=$VITO/Cx001_32662.txt
export -p OUTSPOT=$VITO/V2KRNS10.tif
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
cd $VITO
#-------------------------------------------------------------------------------------# 
#the ESA toolbox

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

echo $subset_aoi > $VITO/subset_aoi.xml
echo $subset_aoi
echo $INSPOT
echo $OUTSPOT

gpt $VITO/subset_aoi.xml -Ssource=$INSPOT -f GeoTIFF -t $OUTSPOT

gdalinfo $OUTSPOT

ciop-log "INFO" "SNAP toolbox"
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
ciop-log "INFO" "Gdalwarp -> epsg:32662"
ciop-log "DEBUG" "Gdalwarp -> epsg:32662"

gdalwarp -t_srs '+init=epsg:32662' $OUTSPOT $VITO/V2KRNS100.tif
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# PURPOSE: NDVI, NIR, RED

gdal_translate -of Gtiff -b 2 $VITO/V2KRNS100.tif $VITO/RED001.tif
gdal_translate -of Gtiff -b 3 $VITO/V2KRNS100.tif $VITO/NIR001.tif
gdal_translate -of Gtiff -b 5 $VITO/V2KRNS100.tif $VITO/NDV001.tif

ciop-log "INFO" "BAND: NDV, RED, NIR"

#-------------------------------------------------------------------------------------# 
# echo "FASE 1"
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI NDVI, NIR, RED
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

#R version  3.2.1
# set working directory
CMDIR = Sys.getenv(c('VITO'))

setwd(CMDIR)
getwd()

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)

rb = raster("/data/outDIR/ISD/ISD000/CM001/AOI/AOI_CX/Cx001_32662.tif")
rb
sink(paste(CMDIR,'/', 'Cx001_32662.txt',sep = ""))
rb
sink()

EOF

#-------------------------------------------------------------------------------------# 
ciop-log "INFO" "Getting the same boundary information of GlobCover: $VITO/${filename}_01.tif "

for file in $VITO/*001.tif ; do 
filename=$(basename $file .tif )
echo $Cx001
# Get the same boundary information_globcover
ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')
echo $ulx $uly $lrx $lry $filename
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $VITO/${filename}.tif $VITO/${filename}_01.tif 
done


rm -rf /tmp/snap-mapred/*
rm -rf $INSPOT

ciop-log "INFO" "remover /tmp/snap-mapred/"
#rm $VITO/NDV001.tif $VITO/NIR001.tif $VITO/RED001.tif $VITO/V2KRNS10.tif $VITO/subset_aoi.xml
#-------------------------------------------------------------------------------------#
exit 0
