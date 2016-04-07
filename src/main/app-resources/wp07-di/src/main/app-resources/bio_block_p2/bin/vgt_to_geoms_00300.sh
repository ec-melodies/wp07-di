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
export -p DIR=$TMPDIR/data/outDIR/ISD
export -p OUTDIR=$DIR/ISD000/
export -p NVDIR=$OUTDIR/VM001/
export -p SBDIR=$OUTDIR/SM001/
export -p PBDIR=$OUTDIR/PM001/
export -p LDIR=$OUTDIR/COKC
mkdir -p $LDIR
export -p CDIR=$OUTDIR/SM001
export -p VDIR=$OUTDIR/VM001
export -p ZDIR=$OUTDIR/GEOMS
export -p HDIR=~/wp07-di/src/main/app-resources/parameters/
export -p LAND001=$OUTDIR/VITO/

export -p ZDIR=$OUTDIR/GEOMS
#-------------------------------------------------------------------------------------# 
# # Check HSD and LSD (for soil and vegetation)

R --vanilla --no-readline   -q  <<'EOF'
SBDIR = Sys.getenv(c('LAND001'))

setwd(SBDIR)
getwd()

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

TPmlist01<-list.files(path=SBDIR, pattern=paste("LC_004_crop*",".*\\.tif",sep=""))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(SBDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(SBDIR,'/','INFO_LC_004_',i,'.txt',sep = ""), append=TRUE)
}

EOF
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
cd $SBDIR

h=1
for file in $NVDIR/Vx001__crop*.tif; do
filename=$(basename $file .tif )
input001=$NVDIR/${filename}.tif
echo $input001

# Get the same boundary information_globcover
h=$((h+1))
Cx001=$LAND001/${filename/#Vx001__crop/INFO_LC_004}.txt
echo $Cx001

ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

echo $ulx $uly $lrx $lry 

output003=$NVDIR/${filename/#Vx001__crop/Vx002__crop}.tif 
echo $output003 
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input001 $output003
done

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
cd $SBDIR

h=1
for file in $SBDIR/Sx001__crop*.tif; do
filename=$(basename $file .tif )
input001=$SBDIR/${filename}.tif
echo $input001

# Get the same boundary information_globcover
h=$((h+1))
Cx001=$LAND001/${filename/#Sx001__crop/INFO_LC_004}.txt
echo $Cx001

ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

echo $ulx $uly $lrx $lry 

output003=$SBDIR/${filename/#Sx001__crop/Sx002__crop}.tif 
echo $output003 
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input001 $output003
done

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
export PATH=/opt/anaconda/bin/:$PATH

for file in $NVDIR/Vx002__crop*.tif; do 
filename=$(basename $file .tif )
input001=$NVDIR/${filename}.tif
input002=$LAND001/${filename/#Vx002__crop/LC_004_crop}.tif 
for i in {3,4,5}; do
output003=$LDIR/${filename/#Vx002__crop/VSx002__crop}_0$i.tif
echo $output003
gdal_calc.py -A $input001 -B $input002 --outfile=$output003 --calc="(B==$i)*(A)" --overwrite --type=Float32;
done
done

for file in $SBDIR/Sx002__crop*.tif; do 
filename=$(basename $file .tif )
input003=$SBDIR/${filename}.tif
input002=$LAND001/${filename/#Sx002__crop/LC_004_crop}.tif 
for i in {2,6,7}; do 
output003=$LDIR/${filename/#Sx002__crop/VSx002__crop}_0$i.tif   
echo $output003
gdal_calc.py -A $input003 -B $input002 --outfile=$output003 --calc="(B==$i)*(A)" --overwrite --type=Float32;
done
done

for file in $NVDIR/Vx002__crop*.tif; do 
filename=$(basename $file .tif )
input001=$NVDIR/${filename}.tif
input002=$LAND001/${filename/#Vx002__crop/LC_004_crop}.tif  
for i in {1,8,9}; do 
output003=$LDIR/${filename/#Vx002__crop/VSx002__crop}_0$i.tif   
echo $output003
gdal_calc.py -A $input001 -B $input002  --outfile=$output003 --calc="(B==$i)*(A)" --overwrite --type=Float32;
done
done

for file in $NVDIR/Vx002__crop*.tif; do 
filename=$(basename $file .tif )
input001=$NVDIR/${filename}.tif
input002=$LAND001/${filename/#Vx002__crop/LC_004_crop}.tif 
for i in {10,11}; do
output003=$LDIR/${filename/#Vx002__crop/VSx002__crop}_$i.tif
echo $output003
gdal_calc.py -A $input001 -B $input002 --outfile=$output003 --calc="(B==$i)*(A)" --overwrite --type=Float32;
done
done
#-------------------------------------------------------------------------------------#  

R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('VDIR'))
OUTDIR = Sys.getenv(c('LDIR'))
LAND001 = Sys.getenv(c('LAND001'))

setwd(OUTDIR)

require(sp)
require(rgdal)
require(raster)
require("rciop")
require("gtools")

# list all files from the current directory
list.files(pattern=".tif$") 
 
ww=assign(paste("list.filenames_",sep=""),mixedsort(list.files(pattern=paste("VSx002_",".*\\.tif",sep=""))))

setwd(LAND001)
n02 <- list.files(pattern=paste("LC_004_crop",".*\\.tif",sep=""))
n03 <- length(n02)


setwd(OUTDIR)
# create a list from these files
for (j in 1:n03){ 
list.filenames=assign(paste("list.filenames_",j,sep=""),mixedsort(list.files(pattern=paste("VSx002__crop_",j,".*\\.tif",sep=""))))
rstack003<-stack(raster(list.filenames[1]),
raster(list.filenames[2]), raster(list.filenames[3]), raster(list.filenames[4]), raster(list.filenames[5]),
raster(list.filenames[6]), raster(list.filenames[7]), raster(list.filenames[8]), raster(list.filenames[9]),
raster(list.filenames[10]), raster(list.filenames[11]))

rastD6<-sum(rstack003, na.rm=TRUE)
writeRaster(rastD6, filename=paste("Bx001_", j,".tif", sep=""), format="GTiff", overwrite=TRUE)
}

EOF
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# AREA
#-------------------------------------------------------------------------------------#

h=1
for file in $LDIR/Bx001_*.tif; do
filename=$(basename $file .tif )
input001=$LDIR/${filename}.tif
echo $input001

# Get the same boundary information_globcover
h=$((h+1))
Cx001=$LAND001/${filename/#Bx001/INFO_LC_004}.txt
echo $Cx001

ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

echo $ulx $uly $lrx $lry 

output003=$LDIR/${filename/#Bx001_/Bx00101_}.tif 
echo $output003 
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input001 $output003
done
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
# CR_005_crop_
cd $PBDIR
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'
SBDIR = Sys.getenv(c('PBDIR'))

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

TPmlist01<-mixedsort(list.files(pattern=paste("CR_005_crop*",".*\\.tif",sep="")))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(SBDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(SBDIR,'/','INFO_CR_005_',i,'.txt',sep = ""), append=TRUE)
}

EOF

#-------------------------------------------------------------------------------------# 
cd $LDIR

h=1
for file in $LDIR/Bx00101_*.tif; do
filename=$(basename $file .tif )
input001=$LDIR/${filename}.tif
echo $input001

# Get the same boundary information_globcover
h=$((h+1))
Cx001=$PBDIR/${filename/#Bx00101/INFO_CR_005}.txt
echo $Cx001
cat $Cx001

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

output003=$LDIR/${filename/#Bx00101_/Bx002_}.tif
output004=$ZDIR/${filename/#Bx00101_/Bx002_}.tif  
echo $output003 
gdal_translate -projwin $ulx1 $uly1 $lrx1 $lry1 -of GTiff $input001 $output003
cp $output003 $output004 
done

#-------------------------------------------------------------------------------------# 

#for file in $LDIR/Bx00101_*.tif; do 
#filename=$(basename $file .tif )
#input001=$LDIR/${filename}.tif
#input002=$LDIR/${filename/#Bx00101_/Bx002_}.tif 
#input003=$ZDIR/${filename/#Bx00101_/Bx002_}.tif 
#cp $input001 $input002
#cp $input002 $input003
#done
#-------------------------------------------------------------------------------------#
#  ASCII to geoMS (.OUT or .dat)
#-------------------------------------------------------------------------------------#

export -p LDIR=$OUTDIR/COKC

for file in $LDIR/Bx002_*.tif; do
filename=$(basename $file .tif)
gdal_translate  -of AAIGrid  $LDIR/${filename}.tif   $LDIR/${filename}.asc 
awk '$1 ~ /^[+-]?[0-9]/' $LDIR/${filename}.asc > $LDIR/${filename}.txt
cp $LDIR/${filename}.txt $ZDIR/${filename}.txt
done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('LDIR'))
OUTDIR = Sys.getenv(c('LDIR'))
setwd(INDIR)

# load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")
require("gtools")
require("rciop")

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

# list all files from the current directory

# create a list from these files
list.filenames<-mixedsort(list.files(pattern=paste("Bx002_",".*\\.tif",sep="")))
list.filenames
list.filenames02<-mixedsort(list.files(pattern=paste("Bx002_",".*\\.txt",sep="")))
list.filenames02

for (h in 1:length(list.filenames[])){
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
rm(dt)
file<-readGDAL(list.filename)
file005 = as.matrix(file003, nrow = file@grid@cells.dim[1], ncol = file@grid@cells.dim[2])
str(file005)
rm(file003)
file004 = matrix(0, nrow = file@grid@cells.dim[2], ncol = file@grid@cells.dim[1])
str(file004)
for (i in 1:dim(file005)[1]) {file004[i,]=file005[dim(file005)[1]-i+1,] }

file006<-as.data.frame(t(file004))
sdf003<-stack(file006)
rm(file004)
#-------------------------------------------------------------------------------------#
rm(file005)
x= xy[1]
B=xy[2]
y= matrix(, nrow = dim(B)[1], ncol = dim(B)[2])
for (i in 1:dim(y)[1]) {y[i,]=B[dim(y)[1]-i+1,]}
xy01<-cbind(x,y)

#-------------------------------------------------------------------------------------# 
sdf0111103 <-cbind(xy01,z,sdf003$values)
rm(sdf003)
write.table(sdf0111103[,c(4:4)],paste(path=OUTDIR,'/' ,'Bx0100003_',h,'.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
rm(sdf0111103)
}
EOF
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
for file in $LDIR/*.dat; do 
filename=$(basename $file .dat )
awk 'NR > 1 { print $2 }' $HDIR/header.txt > $LDIR/${filename}_01.dat
cat $file >> $LDIR/${filename}_01.dat
sed -i '/^[[:space:]]*$/d' $LDIR/${filename}_01.dat 
# add space
sed -i -e 's/^/ /' $LDIR/${filename}_01.dat
# To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
sed -i 's/$/\r/' $LDIR/${filename}_01.dat
cp $LDIR/${filename}_01.dat $ZDIR/${filename}_01.dat
done

#rm -rf $LDIR
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------#
# Bx0100004=ciop.publish($OUTDIR001/Bx0100004.dat)
echo "DONE"
#-------------------------------------------------------------------------------------#
exit 0
