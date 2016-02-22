#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: LANDCOVER
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
# the environment variables 
#-------------------------------------------------------------------------------------# 
export PATH=/opt/anaconda/bin/:$PATH

export -p DIR=/data/auxdata/ISD/
export -p INDIR=$DIR/INPUT
export -p OUTDIR=$DIR/ISD000/
export -p LAND001=$OUTDIR/VITO
#-------------------------------------------------------------------------------------#
# Sample
#-------------------------------------------------------------------------------------#
for file in $LAND001/GLOBCOVER_01_crop_*.tif; do 
filename=$(basename $file .tif )
gdal_translate  -of AAIGrid $LAND001/${filename}.tif $LAND001/${filename}.asc
echo $filename
awk '$1 ~ /^[0-9]/' $LAND001/${filename}.asc > $LAND001/${filename}.txt
done

#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

#R version  3.2.1
# set working directory
INDIR = Sys.getenv(c('LAND001'))
CMDIR = Sys.getenv(c('LAND001'))

setwd(INDIR)
getwd()

require(sp)
require(rgdal)
require(raster)
require(rciop)
require("gtools")

#gc()
#gcinfo(TRUE) 

# create a list from these files
list.filenames<-mixedsort(list.files(pattern='GLOBCOVER_01_crop_.*\\.txt'))

# reclassify the values
reclass_function = function(x00){
	for(i in c(11,12,13)) {x00 <- ifelse(x00==i,3,x00)}
	for(i in c(14,15,16,20,21,22)) {x00 <- ifelse(x00==i,2,x00)}
	for(i in c(160,161,162,170,180,181,182,183,184,185,186,187,188)) {x00 <- ifelse(x00==i,10,x00)}
	for(i in c(210,220)) {x00 <- ifelse(x00==i,11,x00)}	 					
	for(i in c(200,201,202,203)) {x00 <- ifelse(x00==i,9,x00)}
	for(i in c(230)) {x00 <- ifelse(x00==i,8,x00)}
	for(i in c(150,151,152,153)) {x00 <- ifelse(x00==i,7,x00)}
	for(i in c(120,140,141,142,143,144,145)) {x00 <- ifelse(x00==i,6,x00)}
	for(i in c(30,31,110,130,131,132,133,134,135,136)) {x00 <- ifelse(x00==i,5,x00)}
	for(i in c(32,40,41,42,50,60,70,90,91,92,100,101,102)) {x00 <- ifelse(x00==i,4,x00)}
	for(i in c(190)) {x00 <- ifelse(x00==i,1,x00)}
	return(x00)}


for (i in 1:length(list.filenames[])){
LANDCrc <-read.table(paste(path=INDIR,'/', list.filenames[i],sep =""), header=FALSE, sep="", na.strings="NA", dec=",", strip.white=TRUE)
LANDCrc01<-as.matrix(LANDCrc)
x00=LANDCrc01 
x01b=reclass_function(x00)
#write.table(x01b,paste(CMDIR,'/' ,'x00_',i,'.txt',sep = ""),row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 
x001<-data.frame(t(x01b))
x0001<-stack(x001)

#list all files from the current directory
list.filenames02<-mixedsort(list.files(pattern='GLOBCOVER_01_crop_.*\\.tif'))

x01=list.filenames02[i]
list.files(pattern=x01) 
list.filename<-list.files(path=INDIR, pattern=x01)
file<-readGDAL(list.filename)
xy_sa=geometry(file)
xy<-data.frame(xy_sa)

rm("LANDCrc")

# df_to_raster=function(x){
r0<-x0001[1]
r1<-cbind(r0,xy)
r10<-data.frame(r1)
coordinates(r10)=~x+y
proj4string(r10)=CRS("+init=epsg:32662") # set it to lat-long
r10 = spTransform(r10,CRS("+init=epsg:32662"))
gridded(r10) = TRUE
rD3 = raster(r10)
projection(rD3) = CRS("+init=epsg:32662")
writeRaster(rD3,paste(CMDIR, '/' ,'LANDC001_',i,'.tif',sep = ""),overwrite=TRUE)

#return(rD3)
gc()
}
EOF
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

TPmlist01<-list.files(path=SBDIR, pattern=paste("LANDC001*",".*\\.tif",sep=""))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(SBDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(SBDIR,'/','INFO_L001',i,'.txt',sep = ""), append=TRUE)
}

EOF

#-------------------------------------------------------------------------------------# 
cd $LAND001

h=1
for file in $LAND001/LANDC001_*.tif; do
filename=$(basename $file .tif )
input001=$LAND001/${filename}.tif
echo $input001

# Get the same boundary information_globcover
h=$((h+1))
Cx001=$LAND001/${filename/#LANDC001_/INFO_L001}.txt
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

output003=$LAND001/${filename/#LANDC001/LANDC002}.tif 
echo $output003 
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input001 $output003
done

#-------------------------------------------------------------------------------------# 
echo "DONE"
echo 0

