#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: C(x)
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
export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p CMDIR=$OUTDIR/CM001
export -p CMDIR01=$CMDIR/AOI/AOI_CX
export -p ZDIR=$OUTDIR/GEOMS
export -p CXDIR=$IDIR/cli_block_a/bin
export -p CRS32662=$IDIR/parameters/
export -p C2=$IDIR/CRS32662_01.txt
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
for file in $CMDIR01/Cx001_32662*.tif ; do 
filename=$(basename $file .tif )
gdal_translate  -of AAIGrid $CMDIR01/${filename}.tif $CMDIR01/${filename}.asc 
#gdalinfo $CMDIR01/${filename}.asc > $CMDIR01/${filename}_ReadMe.txt
awk '$1 ~ /^[+-]?[0-9]/' $CMDIR01/${filename}.asc > $CMDIR01/${filename}.txt
done 

#rm $CMDIR01/Cx001_32662.tif
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'

CMDIR = Sys.getenv(c('CMDIR01'))
setwd(CMDIR)
getwd()

# load the package
load("/application/parameters/WSP.RData")
xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal",
"uuid", "RColorBrewer", "colorRamps", "rasterVis", "RStoolbox")
lapply(xlist, library, character.only = TRUE)

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

# list all files from the current directory
list.files(pattern=".tif$")  
# create a list from these files

list.filenames <- mixedsort(list.files(pattern=paste("Cx001_32662*",".*\\.tif",sep="")))
list.filenames
list.filenames02 <- mixedsort(list.files(pattern=paste("Cx001_32662*",".*\\.txt",sep="")))
list.filenames02

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
list.filename = paste(path=CMDIR,'/',pattern="Cx001_32662",".tif",sep ="")
file<-readGDAL(list.filename)

file005 = as.matrix(file003, nrow = file@grid@cells.dim[1], ncol = file@grid@cells.dim[2])
str(file005)
file004 = matrix(0, nrow = file@grid@cells.dim[2], ncol = file@grid@cells.dim[1])
str(file004)

for (i in 1:dim(file005)[1]) {file004[i, ]=file005[dim(file005)[1]-i+1, ] }

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
rciop.publish(paste(CMDIR,"sdf0111103", sep="/"), recursive=FALSE, metalink=TRUE)
EOF
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
for file in $CMDIR01/*.dat; do 
filename=$(basename $file .dat )
awk 'NR > 1 { print $1 }' $CRS32662/header.txt > $CMDIR01/${filename}_01.dat
cat $file >> $CMDIR01/${filename}_01.dat
#add space
sed -i -e 's/^/ /' $CMDIR01/${filename}_01.dat
#To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
sed -i 's/$/\r/' $CMDIR01/${filename}_01.dat
cp $CMDIR01/${filename}_01.dat $ZDIR/${filename}_001.dat

#ciop-publish -m $ZDIR/${filename}_001.dat
done 
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
echo "DONE"
exit 0
