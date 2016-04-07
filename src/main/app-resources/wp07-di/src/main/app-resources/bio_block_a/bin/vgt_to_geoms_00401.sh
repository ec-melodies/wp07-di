#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Local soil status [S(x)]
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# gdal_calc
# gdalwarp
# pktools
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
export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
# JOB000
#-------------------------------------------------------------------------------------#
export PATH=/opt/anaconda/bin/:$PATH
export -p DIR=$TMPDIR/data/outDIR/ISD
export -p IDIR=/application
echo $IDIR
export -p INDIR=$DIR/INPUT
export -p OUTDIR=$DIR/ISD000
export -p SBDIR=$OUTDIR/PM001
export -p HDIR=$IDIR/parameters
export -p PDIR=$OUTDIR/PM001
export -p ZDIR=$OUTDIR/GEOMS
export -p LAND001=$OUTDIR/VITO
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'
SBDIR = Sys.getenv(c('SBDIR'))

setwd(SBDIR)
getwd()

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)
options(max.print=99999999) 
options("scipen"=100, "digits"=4)

TPmlist01<-mixedsort(list.files(path=SBDIR, pattern=paste("CR001_03*",".*\\.tif",sep="")))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(SBDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(SBDIR,'/','INFO_CR001_03',i,'.txt',sep = ""), append=TRUE)
}

EOF

#-------------------------------------------------------------------------------------# 
cd $SBDIR

h=1
for file in $SBDIR/CR001_03*.tif; do
filename=$(basename $file .tif )
input001=$SBDIR/${filename}.tif
echo $input001

# Get the same boundary information_globcover
h=$((h+1))
Cx001=$SBDIR/${filename/#CR001_03_/INFO_CR001_03}.txt
echo $Cx001

ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

echo $ulx $uly $lrx $lry 

ulx1=$(awk "BEGIN {print ($ulx+1546.104)}")
uly1=$(awk "BEGIN {print ($uly-1546.104)}")
lrx1=$(awk "BEGIN {print ($lrx-1546.104)}")
lry1=$(awk "BEGIN {print ($lry+1546.104)}")

echo $ulx1 $uly1 $lrx1 $lry1

output003=$SBDIR/${filename/#CR001_03_/CR001_04_}.tif 
echo $output003 
gdal_translate -projwin $ulx1 $uly1 $lrx1 $lry1 -of GTiff $input001 $output003
done

#-------------------------------------------------------------------------------------# 
cd $SBDIR

export PATH=/opt/anaconda/bin/:$PATH

for file in $SBDIR/CR001_04*.tif; do
filename=$(basename $file .tif )
echo $filename
ls *${filename}.tif >> list_CR.txt
gdalbuildvrt $SBDIR/${filename}.vrt --optfile list_CR.txt
gdal_translate $SBDIR/${filename}.vrt $SBDIR/CR_00401.tif
done
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
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

TPmlist01<-mixedsort(list.files(path=SBDIR, pattern=paste("LC_004.tif",sep="")))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(SBDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(SBDIR,'/','INFO_LC_004.txt',sep = ""), append=TRUE)
}

EOF
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
h=1
for file in $PDIR/CR_00401.tif; do
filename=$(basename $file .tif )
input001=$PDIR/${filename}.tif
echo $input001

# Get the same boundary information_globcover
h=$((h+1))
Cx001=$LAND001/INFO_LC_004.txt
echo $Cx001

ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

echo $ulx $uly $lrx $lry 

output003=$SBDIR/CR_004.tif 
echo $output003 
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input001 $output003
done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 

cd $SBDIR

h=1
for file in $SBDIR/CR001_03*.tif; do
filename=$(basename $file .tif )
input001=$SBDIR/${filename}.tif
echo $input001

# Get the same boundary information_globcover
h=$((h+1))
Cx001=$SBDIR/${filename/#CR001_03_/INFO_CR001_03}.txt
echo $Cx001

ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

echo $ulx $uly $lrx $lry 

ulx1=$(awk "BEGIN {print ($ulx+7730.52)}")
uly1=$(awk "BEGIN {print ($uly-7730.52)}")
lrx1=$(awk "BEGIN {print ($lrx-7730.52)}")
lry1=$(awk "BEGIN {print ($lry+7730.52)}")

echo $ulx1 $uly1 $lrx1 $lry1

output003=$SBDIR/${filename/#CR001_03_/CR001_04_}.tif 
echo $output003 
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input001 $output003
done
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# ASCII to geoMS (.OUT or .dat)
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
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
#done < "/home/melodies-ist/wp07-di/src/main/app-resources/parameters/AOI4_32662_01.txt"
#-------------------------------------------------------------------------------------#
for file in $SBDIR/CR_004.tif ; do
export -p COUNT=0
filename=$(basename $file .tif )
# Get the same boundary information_globcover
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $SBDIR/${filename}.tif  $SBDIR/${filename}_crop_$COUNT.tif
done < $CRS326620
#done </home/melodies-ist/wp07-di/src/main/app-resources/parameters/AOI4_32662_01.txt
done
#-------------------------------------------------------------------------------------# 

#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'
SBDIR = Sys.getenv(c('SBDIR'))

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

TPmlist01<-mixedsort(list.files(pattern=paste("CR_004_crop*",".*\\.tif",sep="")))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(SBDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(SBDIR,'/','INFO_CR_004_',i,'.txt',sep = ""), append=TRUE)
}

EOF

#-------------------------------------------------------------------------------------# 
cd $SBDIR

h=1
for file in $SBDIR/CR_004_crop*.tif; do
filename=$(basename $file .tif )
input001=$SBDIR/${filename}.tif
echo $input001

# Get the same boundary information_globcover
h=$((h+1))
Cx001=$SBDIR/${filename/#CR_004_crop/INFO_CR_004}.txt
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

echo $ulx1 $uly1 $lrx1 $lry1

output003=$SBDIR/${filename/#CR_004_crop/CR_005_crop}.tif 
echo $output003 
gdal_translate -projwin $ulx1 $uly1 $lrx1 $lry1 -of GTiff $input001 $output003
done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
export -p PDIR=$OUTDIR/PM001

for file in $PDIR/CR_005_crop_*.tif; do
filename=$(basename $file .tif)
gdal_translate  -of AAIGrid  $PDIR/${filename}.tif  $PDIR/${filename}.asc
awk '$1 ~ /^[+-]?[0-9]/' $PDIR/${filename}.asc > $PDIR/${filename}.txt
done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('PDIR'))
OUTDIR = Sys.getenv(c('PDIR'))
OUTDIR01 = Sys.getenv(c('ZDIR'))

setwd(INDIR)

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")
require("gtools")
require("rciop")

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

#read data#
# list all files from the current directory
list.files(pattern=".tif$")  
# create a list from these files
list.filenames<-mixedsort(list.files(pattern=paste("CR_005_crop",".*\\.tif",sep="")))
list.filenames
list.filenames02<-mixedsort(list.files(pattern=paste("CR_005_crop",".*\\.txt",sep="")))
list.filenames02

for (h in 1:length(list.filenames[])){
h
dt<-paste(path=OUTDIR,'/',list.filenames[h],sep ="")
file001<-readGDAL(dt)
xy001=geometry(file001)
rm(file001)
rm(dt)
xy<-data.frame(xy001)
rm(xy001)
z<- rep(0,dim(xy)[1])
dt<-paste(path=OUTDIR,'/',list.filenames02[h],sep ="")
#-------------------------------------------------------------------------------------#
file003<-read.table(dt)
list.filename = paste(path=OUTDIR,'/',list.filenames[h],sep ="")
file<-readGDAL(list.filename)
rm(dt)
file005 = as.matrix(file003, nrow = file@grid@cells.dim[1], ncol = file@grid@cells.dim[2])
str(file005)
file004 = matrix(0, nrow = file@grid@cells.dim[2], ncol = file@grid@cells.dim[1])
str(file004)
for (i in 1:dim(file005)[1]) {file004[i,]=file005[dim(file005)[1]-i+1,] }
rm(file003)
file006<-as.data.frame(t(file004))
rm(file004)
sdf003<-stack(file006)
rm(file006)
#-------------------------------------------------------------------------------------#
#B=xy[1]
x= xy[1]
#x= matrix(, nrow = dim(B)[1], ncol = dim(B)[2])
#for (i in 1:dim(x)[1]) {x[i,]=B[dim(x)[1]-i+1,]}
B=xy[2]
y= matrix(, nrow = dim(B)[1], ncol = dim(B)[2])
for (i in 1:dim(y)[1]) {y[i,]=B[dim(y)[1]-i+1,]}
xy01<-cbind(x,y)

#-------------------------------------------------------------------------------------# 
sdf01003<-sdf003$values/10000
rm(sdf003)
sdf01111003 <-cbind(xy01,z,sdf01003)
rm(sdf01003)
write.table(sdf01111003[,c(4:4)],paste(path=OUTDIR,'/' ,'CRx0100003_',h,'.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
rm(sdf01111003)
}
EOF

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
for file in $PDIR/*.dat; do 
filename=$(basename $file .dat )
awk 'NR > 1 { print $3 }' $HDIR/header.txt > $PDIR/${filename}_01.dat
cat $file  >> $PDIR/${filename}_01.dat
sed -i '/^[[:space:]]*$/d' $PDIR/${filename}_01.dat  
#sed -i -e 's/^/ /' $PDIR/CR10000.dat 
sed -i -e 's/^/ /' $PDIR/${filename}_01.dat
#To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
#sed -i 's/$/\r/' $PDIR/CR10000.dat 
sed -i 's/$/\r/' $PDIR/${filename}_01.dat
cp $PDIR/${filename}_01.dat $ZDIR/${filename}_01.dat
done
#rm -rf $PDIR
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
# CRx0100004b=ciop.publish($PDIR/CRx0100004b)

echo "DONE"
exit 0
