#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: Vegetation and Soil status [C(x)]
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
#auxiliar data files (tmp): The intermediate indicators:
export PATH=/opt/anaconda/bin/:$PATH
export -p DIR=/data/outDIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VITO=$OUTDIR/VITO
export -p NVDIR=$OUTDIR/VM001
export -p CDIR=$OUTDIR/SM001
export -p PBDIR=$OUTDIR/PM001
export -p LDIR=$OUTDIR/COKC
export -p ZDIR=$OUTDIR/GEOMS
export -p HDIR=/application/parameters
#-------------------------------------------------------------------------------------# 
# # Check HSD and LSD (for soil and vegetation)

R --vanilla --no-readline   -q  <<'EOF'
CDIR = Sys.getenv(c('VITO'))

setwd(CDIR)
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

TPmlist01<-list.files(path=CDIR, pattern=paste("LC_004_crop*",".*\\.tif",sep=""))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(CDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(CDIR,'/','INFO_LC_005_',i,'.txt',sep = ""), append=TRUE)
}

EOF
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
export PATH=/opt/anaconda/bin/:$PATH

for file in $NVDIR/Vx002__crop*.tif; do 
filename=$(basename $file .tif )
input001=$NVDIR/${filename}.tif
input002=$VITO/${filename/#Vx002__crop/LC_004_crop}.tif 
for i in {3,4,5}; do
output003=$LDIR/${filename/#Vx002__crop/CVSx002__crop}_0$i.tif
echo $output003
gdal_calc.py -A $input001 -B $input002 --outfile=$output003 --calc="(B==$i)*(A*0+8000)" --overwrite --type=Float32;
done
done

for file in $CDIR/Sx002__crop*.tif; do 
filename=$(basename $file .tif )
input003=$CDIR/${filename}.tif
input002=$VITO/${filename/#Sx002__crop/LC_004_crop}.tif 
for i in {2,6,7}; do 
output003=$LDIR/${filename/#Sx002__crop/CVSx002__crop}_0$i.tif   
echo $output003
gdal_calc.py -A $input003 -B $input002 --outfile=$output003 --calc="(B==$i)*(A*0+8000)" --overwrite --type=Float32;
done
done

for file in $NVDIR/Vx002__crop*.tif; do 
filename=$(basename $file .tif )
input001=$NVDIR/${filename}.tif
input002=$VITO/${filename/#Vx002__crop/LC_004_crop}.tif  
for i in {1,8,9}; do 
output003=$LDIR/${filename/#Vx002__crop/CVSx002__crop}_0$i.tif   
echo $output003
gdal_calc.py -A $input001 -B $input002  --outfile=$output003 --calc="(B==$i)*(A*0)" --overwrite --type=Float32;
done
done

for file in $NVDIR/Vx002__crop*.tif; do 
filename=$(basename $file .tif )
input001=$NVDIR/${filename}.tif
input002=$VITO/${filename/#Vx002__crop/LC_004_crop}.tif 
for i in {10,11}; do
output003=$LDIR/${filename/#Vx002__crop/CVSx002__crop}_$i.tif
echo $output003
gdal_calc.py -A $input001 -B $input002 --outfile=$output003 --calc="(B==$i)*(A*0)" --overwrite --type=Float32;
done
done
#-------------------------------------------------------------------------------------#  

R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('NVDIR'))
OUTDIR = Sys.getenv(c('LDIR'))
VITO = Sys.getenv(c('VITO'))

setwd(OUTDIR)

require(sp)
require(rgdal)
require(raster)
require("rciop")
require("gtools")

# list all files from the current directory
list.files(pattern=".tif$") 
 
ww=assign(paste("list.filenames_",sep=""),mixedsort(list.files(pattern=paste("CVSx002_",".*\\.tif",sep=""))))

setwd(VITO)
n02 <- list.files(pattern=paste("LC_004_crop",".*\\.tif",sep=""))
n03 <- length(n02)


setwd(OUTDIR)
# create a list from these files
for (j in 1:n03){ 
list.filenames=assign(paste("list.filenames_",j,sep=""),mixedsort(list.files(pattern=paste("CVSx002__crop_",j,".*\\.tif",sep=""))))
rstack003<-stack(raster(list.filenames[1]),
raster(list.filenames[2]), raster(list.filenames[3]), raster(list.filenames[4]), raster(list.filenames[5]),
raster(list.filenames[6]), raster(list.filenames[7]), raster(list.filenames[8]), raster(list.filenames[9]),
raster(list.filenames[10]), raster(list.filenames[11]))

rastD6<-sum(rstack003, na.rm=TRUE)
writeRaster(rastD6, filename=paste("Cx001_", j,".tif", sep=""), format="GTiff", overwrite=TRUE)
}

EOF
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# AREA
#-------------------------------------------------------------------------------------#

h=1
for file in $LDIR/Cx001_*.tif; do
filename=$(basename $file .tif )
input001=$LDIR/${filename}.tif
echo $input001

# Get the same boundary information_globcover
h=$((h+1))
Cx001=$VITO/${filename/#Cx001/INFO_LC_005}.txt
echo $Cx001

ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

ulx1=$(awk "BEGIN {print ($ulx+7730.52)}")
uly1=$(awk "BEGIN {print ($uly-7730.52)}")
lrx1=$(awk "BEGIN {print ($lrx-7730.52)}")
lry1=$(awk "BEGIN {print ($lry+7730.52)}")

echo $ulx $uly $lrx $lry
echo $ulx1 $uly1 $lrx1 $lry1  

output003=$LDIR/${filename/#Cx001_/Cx002_}.tif
output004=$ZDIR/${filename/#Cx001_/Cx002_}.tif  
echo $output003 
gdal_translate -projwin $ulx1 $uly1 $lrx1 $lry1 -of GTiff $input001 $output003
cp $output003 $output004
done
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
#  ASCII to geoMS (.OUT or .dat)
#-------------------------------------------------------------------------------------#

export -p LDIR=$OUTDIR/COKC

for file in $LDIR/Cx002_*.tif; do
filename=$(basename $file .tif)
gdal_translate  -of AAIGrid  $LDIR/${filename}.tif   $LDIR/${filename}.asc 
awk '$1 ~ /^[+-]?[0-9]/' $LDIR/${filename}.asc > $LDIR/${filename}.txt
cp $LDIR/${filename}.txt $ZDIR/${filename}.txt
done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('LDIR'))
OUTDIR = Sys.getenv(c('PBDIR'))
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
list.filenames<-mixedsort(list.files(pattern=paste("Cx002_",".*\\.tif",sep="")))
list.filenames
list.filenames02<-mixedsort(list.files(pattern=paste("Cx002_",".*\\.txt",sep="")))
list.filenames02

for (h in 1:length(list.filenames[])){
dt<-paste(path=INDIR,'/',list.filenames[h],sep ="")
dt
file001<-readGDAL(dt)
xy001=geometry(file001)
rm(file001)
rm(dt)
xy<-data.frame(xy001)
rm(xy001)
z<- rep(0,dim(xy)[1])
dt<-paste(path=INDIR,'/',list.filenames02[h],sep ="")

#-------------------------------------------------------------------------------------#
file003<-read.table(dt)
list.filename = paste(path=INDIR,'/',list.filenames[h],sep ="")
list.filename 
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

x=xy[1]
B=xy[2]
y= matrix(, nrow = dim(B)[1], ncol = dim(B)[2])
for (i in 1:dim(y)[1]) {y[i,]=B[dim(y)[1]-i+1,]}
xy01<-cbind(x,y)
#-------------------------------------------------------------------------------------# 
sdf0111103 <-cbind(xy01,(sdf003$values/10000))
rm(sdf003)
write.table(sdf0111103[,c(3:3)],paste(path=OUTDIR,'/' ,'Cx0100003_',h,'.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
#write.table(sdf0111103,paste(path=OUTDIR,'/' ,'Cx0100004_',h,'.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
rm(sdf0111103)
}
EOF
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
for file in $PBDIR/*.dat; do 
filename=$(basename $file .dat )
awk 'NR > 1 { print $2 }' $HDIR/header.txt > $PBDIR/${filename}_001.dat
cat $file >> $PBDIR/${filename}_001.dat
sed -i '/^[[:space:]]*$/d' $PBDIR/${filename}_001.dat 
# add space
sed -i -e 's/^/ /' $PBDIR/${filename}_001.dat
# To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
sed -i 's/$/\r/' $PBDIR/${filename}_001.dat
cp $PBDIR/${filename}_001.dat $ZDIR/${filename}_001.dat
done

ciop-log "INFO" "Step01: vgt_to_geoms_00301.sh" 

#rm -rf $LDIR
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------#
# Bx0100004=ciop.publish($OUTDIR001/Bx0100004.dat)
echo "DONE"
#-------------------------------------------------------------------------------------#
exit 0
