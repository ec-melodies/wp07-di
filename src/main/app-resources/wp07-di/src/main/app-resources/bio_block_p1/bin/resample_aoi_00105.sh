#!/bin/bash
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

export -p DIR=$TMPDIR/data/outDIR/ISD
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

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)


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
writeRaster(rD3,paste(CMDIR, '/' ,'LANDC002_',i,'.tif',sep = ""),overwrite=TRUE)
gc()
rm(rD3)
}
EOF
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
echo "DONE"
echo 0

