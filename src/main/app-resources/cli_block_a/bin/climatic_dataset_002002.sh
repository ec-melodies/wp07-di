#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Local dynamic degradation D(x)
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
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
#bash /application/bin/ISD5_node/ini.sh
export PATH=/opt/anaconda/bin/:$PATH
export -p DIR=/data/auxdata/ISD/
export -p INDIR=/data/INPUT/
export -p OUTDIR=$DIR/ISD000/
export -p CMDIR=$OUTDIR/CM001/
export -p CMDIR02=$CMDIR/AOI/AOI_DX/C002
export -p ZDIR=$OUTDIR/GEOMS
#-------------------------------------------------------------------------------------# 
for file in $CMDIR02/*.tif ; do 
filename=$(basename $file .tif )
gdal_translate  -of AAIGrid $CMDIR02/${filename}.tif $CMDIR02/${filename}.asc 
#gdalinfo $CMDIR02/${filename}.asc > $CMDIR02/${filename}_ReadMe.txt
awk '$1 ~ /^[0-9]/' $CMDIR02/${filename}.asc > $CMDIR02/${filename}.txt
done 

#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('CMDIR'))
CMDIR = Sys.getenv(c('CMDIR02'))
setwd(CMDIR)
getwd()
# load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")
require("rciop")
require("gtools")

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

# list all files from the current directory
list.files(pattern=".tif$")  
# create a list from these files
list.filenames <- mixedsort(list.files(pattern=".tif$"))
list.filenames
list.filenames02 <- mixedsort(list.files(pattern=".txt$"))
list.filenames02

for (h in 1:length(list.filenames[])){
dt<-paste(path=CMDIR,'/',list.filenames[h],sep ="")
file001<-readGDAL(dt)
xy001=geometry(file001)
xy<-data.frame(xy001)
z<- rep(0,dim(xy)[1])
dt<-paste(path=CMDIR,'/',list.filenames02[h],sep ="")

#-------------------------------------------------------------------------------------#
file003<-read.table(dt)
list.filename = paste(path=CMDIR,'/',pattern="Dx001_32662_",h,".tif",sep ="")
file<-readGDAL(list.filename)

file005 = as.matrix(file003, nrow = file@grid@cells.dim[1], ncol = file@grid@cells.dim[2])
str(file005)
file004 = matrix(0, nrow = file@grid@cells.dim[2], ncol = file@grid@cells.dim[1])
str(file004)
for (i in 1:dim(file005)[1]) {file004[i,]=file005[dim(file005)[1]-i+1,] }

file006<-as.data.frame(t(file004))
sdf003<-stack(file006)
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
sdf0111103 <-cbind(xy01,z,sdf003$values)
write.table(sdf0111103,paste(path=CMDIR,'/' ,'Dx0111103_',h,'.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
}
EOF
#-------------------------------------------------------------------------------------# 
#export -p HDIR=/application/bin/ISD5_node/
export -p HDIR=/home/melodies-ist/wp07-di/src/main/app-resources/parameters/
#-------------------------------------------------------------------------------------# 
for file in $CMDIR02/*.dat; do 
filename=$(basename $file .dat )
awk 'NR > 1 { print $1 }' $HDIR/header.txt > $CMDIR02/${filename}_01.dat
cat $file >> $CMDIR02/${filename}_01.dat
sed -i -e 's/^/ /' $CMDIR02/${filename}_01.dat
#To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
sed -i 's/$/\r/' $CMDIR02/${filename}_01.dat
cp $CMDIR02/${filename}_01.dat $ZDIR/${filename}_01.dat
done

#rm $CMDIR02/Dx001.asc $CMDIR02/Dx001.asc.aux.xml $CMDIR02/Dx001.prj
#rm $CMDIR02/Dx001.txt $CMDIR02/Dx0111103_1.dat $CMDIR02/RPlist04_mean.txt $CMDIR02/RPlist04.txt

#-------------------------------------------------------------------------------------# 
echo "DONE"
exit 0


