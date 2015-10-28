#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Local static degradation CS(x)
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
export PATH=/opt/anaconda/bin/:$PATH
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
# bash /application/bin/ISD5_node/ini.sh
export -p DIR=~/data/ISD/
export PATH=/opt/anaconda/bin/:$PATH
export -p INDIR=~/data/INPUT/
export -p OUTDIR=$DIR/ISD000/
export -p CMDIR=$OUTDIR/CM001/AOI
export -p CMDIR01=$CMDIR/AOI_CX
export -p ZDIR=$OUTDIR/GEOMS
#-------------------------------------------------------------------------------------# 
for file in $CMDIR01/*.tif ; do 
filename=$(basename $file .tif )
gdal_translate  -of AAIGrid $CMDIR01/${filename}.tif $CMDIR01/${filename}.asc 
#gdalinfo $CMDIR01/${filename}.asc > $CMDIR01/${filename}_ReadMe.txt
awk '$1 ~ /^[0-9]/' $CMDIR01/${filename}.asc > $CMDIR01/${filename}.txt
done 
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('CMDIR'))
CMDIR = Sys.getenv(c('CMDIR01'))
setwd(CMDIR)
getwd()

# load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")
require("rciop")

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

# list all files from the current directory
list.files(pattern=".tif$")  
# create a list from these files
list.filenames<-list.files(pattern=".tif$")
list.filenames02<-list.files(pattern=".txt$")

for (h in 1:length(list.filenames[])){
dt<-paste(path=CMDIR,'/',list.filenames[h],sep ="")
file001<-readGDAL(dt)
xy001=geometry(file001)
xy<-data.frame(xy001)
z<- rep(0,dim(xy)[1])
dt<-paste(path=CMDIR,'/',list.filenames02[h],sep ="")
file003<-read.table(dt)
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
list.filename=assign(paste(path=CMDIR,'/',pattern="Cx001",".tif",sep =""),list.files(pattern=paste("Cx001",".*\\.tif",sep="")))
file<-readGDAL(paste(path=CMDIR,'/',list.filename,sep=""))

file005 = as.matrix(file003, nrow = file@grid@cells.dim[1], ncol = file@grid@cells.dim[2])
file004 = matrix(0, nrow = file@grid@cells.dim[2], ncol = file@grid@cells.dim[1])
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
write.table(sdf0111103,paste(path=CMDIR,'/' ,'Cx0111103_',h,'.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
}

EOF
#-------------------------------------------------------------------------------------# 
#export -p HDIR=/application/bin/ISD5_Nx/
export -p HDIR=/home/melodies-ist/wp07-di/src/main/app-resources/bin/ISD5_Nx/

#-------------------------------------------------------------------------------------#
for file in $CMDIR01/*.dat; do 
filename=$(basename $file .dat )
awk 'NR > 1 { print $1 }' $HDIR/header.txt > $CMDIR01/${filename}_01.dat
cat $file >> $CMDIR01/${filename}_01.dat
#add space
sed -i -e 's/^/ /' $CMDIR01/${filename}_01.dat
#To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
sed -i 's/$/\r/' $CMDIR01/${filename}_01.dat
cp $CMDIR01/${filename}_01.dat $ZDIR/${filename}_01.dat
done 

rm $CMDIR01/Cx001.asc $CMDIR01/Cx001.asc.aux.xml $CMDIR01/Cx001.prj
rm $CMDIR01/Cx001.txt $CMDIR01/Cx0111103_1.dat $CMDIR01/RL100601.txt

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
echo "DONE"
exit 0