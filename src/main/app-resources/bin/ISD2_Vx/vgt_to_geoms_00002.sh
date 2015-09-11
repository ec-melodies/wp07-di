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
# source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
bash /application/bin/ISD5_node/ini.sh
export PATH=/opt/anaconda/bin/:$PATH

export DIR=~/data/ISD/
export -p INDIR=$DIR/INPUT
export -p OUTDIR=$DIR/ISD000/
#export -p LAND=$INDIR/LANDCOVER/
#export -p LAND000=$INDIR/LANDCOVER/LANDCOVER000
export -p LAND001=$OUTDIR/SPPV001/AOI1/SX

#-------------------------------------------------------------------------------------#
# Sample
#-------------------------------------------------------------------------------------#
for file in $LAND001/*LULC.tif ; do 
filename=$(basename $file .tif )
gdal_translate  -of AAIGrid $LAND001/${filename}.tif $LAND001/${filename}.asc
echo $filename
awk '$1 ~ /^[0-9]/' $LAND001/${filename}.asc > $LAND001/${filename}.txt
#gdalinfo $LAND001/${filename}.asc> $LAND001/${filename}.txt
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

#gc()
#gcinfo(TRUE) 

# create a list from these files
list.filenames<-list.files(pattern="LULC.txt$")

for (i in 1:length(list.filenames[])){
# list all files from the current directory
LANDCrc <-read.table(paste(path=INDIR,'/', list.filenames[i],sep =""), header=FALSE, sep="", na.strings="NA", dec=",", strip.white=TRUE)
LANDCrc01<-as.matrix(LANDCrc)
x00=LANDCrc01 
# reclassify the values
reclass_function = function(x00){
	for(i in c(160,161,162,170,180,181,182,183,184,185,186,187,188)) {x00 <- ifelse(x00==i,10,x00)}
	for(i in c(210)) {x00 <- ifelse(x00==i,11,x00)}	 					
	for(i in c(200,201,202,203)) {x00 <- ifelse(x00==i,9,x00)}
	for(i in c(230)) {x00 <- ifelse(x00==i,8,x00)}
	for(i in c(150,151,152,153)) {x00 <- ifelse(x00==i,7,x00)}
	for(i in c(120,140,141,142,143,144,145)) {x00 <- ifelse(x00==i,6,x00)}
	for(i in c(30,31,110,130,131,132,133,134,135,136)) {x00 <- ifelse(x00==i,5,x00)}
	for(i in c(32,40,41,42,50,60,70,90,91,92,100,101,102)) {x00 <- ifelse(x00==i,4,x00)}
	for(i in c(11,12,13)) {x00 <- ifelse(x00==i,3,x00)}
	for(i in c(14,15,16,20,21,22)) {x00 <- ifelse(x00==i,2,x00)}
	for(i in c(190)) {x00 <- ifelse(x00==i,1,x00)}
	return(x00)}

x01b=reclass_function(x00)

write.table(x01b,paste(CMDIR,'/' ,'x00_',i,'.txt',sep = ""),row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 
x001<-data.frame(t(x01b))
x0001<-stack(x001)
#str(x0001)
#str(x01b)

# list all files from the current directory
list.filenames02<-list.files(pattern="LULC.tif$")  

x01=list.filenames02[i]
# xy_for_raster=function(x){
#	require(rgdal)
	list.files(pattern=x01) 
	list.filename<-list.files(path=INDIR, pattern=x01)
	file<-readGDAL(list.filename)
	xy_sa=geometry(file)
	xy<-data.frame(xy_sa)
#	return(xy)
#}

rm("LANDCrc")
#str(xy)

# df_to_raster=function(x){
r0<-x0001[1]
r1<-cbind(r0,xy)
r10<-data.frame(r1)
coordinates(r10)=~x+y
proj4string(r10)=CRS("+init=epsg:4326") # set it to lat-long
r10 = spTransform(r10,CRS("+init=epsg:4326"))
gridded(r10) = TRUE
rD3 = raster(r10)
projection(rD3) = CRS("+init=epsg:4326")
writeRaster(rD3,paste(CMDIR, '/' ,'LANDC001',i,'.tif',sep = ""),overwrite=TRUE)

#	return(rD3)
#}
#str(rD3)
gc()
#rm(list = ls())

}
#reclass_function(LANDCrc01)
#xy_for_raster("LANDCrc.tif")
#df_to_raster(LANDCrc01)



EOF

#-------------------------------------------------------------------------------------#

#gdalinfo $LAND000/LANDC001.tif > $LAND000/ReadMeLANDC001.txt

echo "DONE"

