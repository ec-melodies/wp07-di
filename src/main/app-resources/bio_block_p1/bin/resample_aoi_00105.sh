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
export -p IDIR=/application/
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VITO=$OUTDIR/VITO
#-------------------------------------------------------------------------------------#
# Sample
#-------------------------------------------------------------------------------------#
rm -rf /data/outDIR/ISD/ISD000/VITO/V2KRNS100.tif

for file in $VITO/GLOBCOVER_01_crop_*.tif; do 
filename=$(basename $file .tif )
gdal_translate  -of AAIGrid $VITO/${filename}.tif $VITO/${filename}.asc
echo $filename
awk '$1 ~ /^[0-9]/' $VITO/${filename}.asc > $VITO/${filename}.txt
done

#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

#R version  3.2.1
# set working directory
INDIR = Sys.getenv(c('VITO'))
CMDIR = Sys.getenv(c('VITO'))

setwd(INDIR)
getwd()

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(xlist, require, character.only = TRUE)

#gc()
#gcinfo(TRUE) 

# create a list from these files
list.filenames<-mixedsort(list.files(pattern='GLOBCOVER_01_crop_.*\\.tif'))

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
LANDCrc01<- raster(list.filenames[[i]])
x01b <- calc(LANDCrc01,fun=reclass_function)
rm(LANDCrc01)
projection(x01b) = CRS("+init=epsg:32662")
writeRaster(x01b,paste(CMDIR, '/' ,'LANDC002_',i,'.tif',sep = ""),overwrite=TRUE)
}

EOF
#-------------------------------------------------------------------------------------#
ciop-log "INFO" "resample_aoi_00105.sh"

for file in $VITO/GLOBCOVER_01_crop_*; do 
echo $file
rm $file
done
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
echo "DONE"
echo 0

