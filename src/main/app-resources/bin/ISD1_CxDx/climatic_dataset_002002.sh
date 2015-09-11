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
# source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
#bash /application/bin/ISD5_node/ini.sh
export PATH=/opt/anaconda/bin/:$PATH
export -p DIR=~/data/ISD/
export -p INDIR=~/data/INPUT/
export -p OUTDIR=$DIR/ISD000/
export -p CMDIR=$OUTDIR/CM001/AOI1/AOI1_DX
export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------# 
for file in $CMDIR/*.tif ; do 
filename=$(basename $file .tif )
gdal_translate  -of AAIGrid $CMDIR/${filename}.tif $CMDIR/${filename}_Dx001.asc 
#gdalinfo $CMDIR/${filename}_Dx001.asc > $CMDIR/${filename}_ReadMe_Dx001.txt
awk '$1 ~ /^[0-9]/' $CMDIR/${filename}_Dx001.asc > $CMDIR/${filename}_Dx001.txt
done 

#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'
INDIR = Sys.getenv(c('CMDIR'))
CMDIR = Sys.getenv(c('CMDIR'))

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")
require("rciop")

setwd(INDIR)


options(max.print=99999999) 
options("scipen"=100, "digits"=4)

# list all files from the current directory
list.files(pattern=".tif$")  
# create a list from these files
list.filenames<-list.files(pattern=".tif$")
list.filenames02<-list.files(pattern=".txt$")


for (i in 1:length(list.filenames[])){
dt<-paste(path=CMDIR,'/',list.filenames[i],sep ="")
file<-readGDAL(dt)
xy_sa=geometry(file)
xy<-data.frame(xy_sa)
z<- rep(0,dim(xy)[1])

dt<-paste(path=CMDIR,'/',list.filenames02[i],sep ="")
file_out<-read.table(dt)
sdf <- stack(file_out)
sdf01111 <-cbind(xy,z,sdf$values)
write.table(sdf01111,paste(path=CMDIR,'/' ,'Dx0111103_',i,'.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
}
EOF
#-------------------------------------------------------------------------------------# 
export -p HDIR=/application/bin/ISD5_node/
#-------------------------------------------------------------------------------------# 
for file in $CMDIR/*.dat; do 
filename=$(basename $file .dat )
awk 'NR > 1 { print $1 }' $HDIR/header.txt > $CMDIR/${filename}_01.dat
cat $file >> $CMDIR/${filename}_01.dat
sed -i -e 's/^/ /' $CMDIR/${filename}_01.dat
#To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
sed -i 's/$/\r/' $CMDIR/${filename}_01.dat
done
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
#Dx0111104=ciop.publish($CMDIR/Dx0111104.dat)
echo "DONE"
exit 0


