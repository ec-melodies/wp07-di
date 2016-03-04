#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Vegetation and Soil status [B(x)]
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# gdal_calc
# pktools
# gdal_translate 
# R packages: 
# zoo
# rgdal
# raster
# sp
# maptools
# rciop
#-------------------------------------------------------------------------------------# 
# source the ciop functions
#source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------# 
#auxiliar data files (tmp): The intermediate indicators:
export -p DIR=/data/auxdata/ISD/
export -p OUTDIR=$DIR/ISD000/
export -p NVDIR=$OUTDIR/VM001/
export -p SBDIR=$OUTDIR/SM001/
export -p LDIR=$OUTDIR/COKC
mkdir -p $LDIR
export -p CDIR=$OUTDIR/SM001
export -p VDIR=$OUTDIR/VM001
export -p ZDIR=$OUTDIR/GEOMS
export -p HDIR=/application/parameters/
export -p LAND001=$OUTDIR/VITO/

export -p ZDIR=$OUTDIR/GEOMS
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'
SBDIR = Sys.getenv(c('LAND001'))

setwd(SBDIR)
getwd()

require("zoo")
require("rgdal")
require("raster")
require("sp")
require("rciop")
require("gtools")
library(digest)

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

TPmlist01<-mixedsort(list.files(path=SBDIR, pattern=paste("LANDC002*",".*\\.tif",sep="")))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(SBDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(SBDIR,'/','INFO_L002',i,'.txt',sep = ""), append=TRUE)
}

EOF

#-------------------------------------------------------------------------------------# 
cd $LAND001

h=1
for file in $LAND001/LANDC002_*.tif; do
filename=$(basename $file .tif )
input001=$LAND001/${filename}.tif
echo $input001

# Get the same boundary information_globcover
h=$((h+1))
Cx001=$LAND001/${filename/#LANDC002_/INFO_L002}.txt
echo $Cx001

ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

echo $ulx $uly $lrx $lry 

output003=$LAND001/${filename/#LANDC002/LANDC003}.tif 
echo $output003 
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input001 $output003
done

#-------------------------------------------------------------------------------------# 
export PATH=/opt/anaconda/bin/:$PATH

for file in $LAND001/LANDC003*.tif; do
filename=$(basename $file .tif )
echo $filename
ls *${filename}.tif >> list_LC.txt
gdalbuildvrt $LAND001/${filename}.vrt --optfile list_LC.txt
gdal_translate $LAND001/${filename}.vrt $LAND001/LC_004.tif
done

# ASCII to geoMS (.OUT or .dat)
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
export -p CRS32662=/application/parameters/AOI
export -p C2=/application/CRS32662_01.txt
#-------------------------------------------------------------------------------------# 
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ "$line" == AOI1 ]] ; then
		export -p CRS326620=$(grep AOI1 $C2);

	elif [[ "$line" == AOI2 ]] ; then
		export -p CRS326620=$(grep AOI2 $C2);

	elif [[ "$line" == AOI3 ]] ; then
		export -p CRS326620=$(grep AOI3 $C2);

	elif [[ "$line" == AOI4 ]] ; then 
		export -p CRS326620=$(grep AOI4 $C2);
	else
		echo "AOI out of range"
	fi 
done < "$CRS32662"
#done < "/application/AOI4_32662_01.txt"
#-------------------------------------------------------------------------------------#
for file in $LAND001/LC_004.tif ; do
export -p COUNT=0
filename=$(basename $file .tif )
# Get the same boundary information_globcover
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $LAND001/${filename}.tif  $LAND001/${filename}_crop_$COUNT.tif
done < $CRS326620
#done < "/application/parameters/AOI4_32662_01.txt"
done

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
echo "DONE"
echo 0
