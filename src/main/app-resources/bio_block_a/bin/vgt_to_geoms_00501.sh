#!/bin/bash
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
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------# 
#auxiliar data files (tmp): The intermediate indicators:
export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p NVDIR=$OUTDIR/VM001
export -p SBDIR=$OUTDIR/SM001
export -p LDIR=$OUTDIR/COKC
export -p CDIR=$OUTDIR/SM001
export -p VDIR=$OUTDIR/VM001
export -p ZDIR=$OUTDIR/GEOMS
export -p HDIR=$IDIR/parameters
export -p VITO=$OUTDIR/VITO
export -p ZDIR=$OUTDIR/GEOMS

#Year
export -p Y2=$1
echo $Y2
#-------------------------------------------------------------------------------------#
export -p CRS32662=$2
echo $CRS32662
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'
SBDIR = Sys.getenv(c('VITO'))

setwd(SBDIR)
getwd()

load("/application/parameters/WSP.RData")
xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal",
"uuid", "RColorBrewer", "colorRamps", "rasterVis", "RStoolbox")
lapply(xlist, library, character.only = TRUE)


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
cd $VITO

h=1
for file in $VITO/LANDC002_*.tif; do
filename=$(basename $file .tif )
input001=$VITO/${filename}.tif
echo $input001

# Get the same boundary information_globcover
h=$((h+1))
Cx001=$VITO/${filename/#LANDC002_/INFO_L002}.txt
echo $Cx001

ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

echo $ulx $uly $lrx $lry

ulx1=$(awk "BEGIN {print ($ulx+6184.416)}")
uly1=$(awk "BEGIN {print ($uly-6184.416)}")
lrx1=$(awk "BEGIN {print ($lrx-6184.416)}")
lry1=$(awk "BEGIN {print ($lry+6184.416)}")

output003=$VITO/${filename/#LANDC002/LANDC003}.tif 
echo $output003 
gdal_translate -projwin $ulx1 $uly1 $lrx1 $lry1 -of GTiff $input001 $output003
rm $Cx001
done

#-------------------------------------------------------------------------------------#

export PATH=/opt/anaconda/bin/:$PATH

for file in $VITO/LANDC003*.tif; do
filename=$(basename $file .tif )
echo $filename
ls *${filename}.tif >> $VITO/list_LC.txt
gdalbuildvrt $VITO/${filename}.vrt --optfile $VITO/list_LC.txt
gdal_translate $VITO/${filename}.vrt $VITO/LC_004.tif
done
rm $VITO/list_LC.txt

# ASCII to geoMS (.OUT or .dat)
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
export -p C3=$IDIR/parameters/CRS32662_01.txt
#-------------------------------------------------------------------------------------# 
if [[ $CRS32662 == AOI1 ]] ; then
	export -p CRS326620=$(grep AOI1 $C3);

elif [[ $CRS32662 == AOI2 ]] ; then
	export -p CRS326620=$(grep AOI2 $C3);

elif [[ $CRS32662 == AOI3 ]] ; then
	export -p CRS326620=$(grep AOI3 $C3);

elif [[ $CRS32662 == AOI4 ]] ; then 
	export -p CRS326620=$(grep AOI4 $C3);
else
	echo "AOI out of range"
fi 
#-------------------------------------------------------------------------------------#
for file in $VITO/LC_004.tif ; do
export -p COUNT=0
filename=$(basename $file .tif )
# Get the same boundary information_globcover
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $VITO/${filename}.tif  $VITO/${filename}_crop_$COUNT.tif
done < $CRS326620
done

ciop-log "INFO" "vgt_to_geoms_00501.sh"

for file in $VITO/LANDC*; do
echo $file
rm $file
done

rm $VITO/LC_004.tif

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
echo "DONE"
echo 0
