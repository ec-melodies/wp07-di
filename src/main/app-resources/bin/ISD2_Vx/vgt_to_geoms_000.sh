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
bash /application/bin/ISD5_node/ini.sh
#-------------------------------------------------------------------------------------#
# Sample
#-------------------------------------------------------------------------------------#

input002=$INDIR/LANDCOVER/Globcover2009_V2.3_Global_/GLOBCOVER_L4_200901_200912_V2.3.tif

ulx=$(gdalinfo $CMDIR/Cx001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo $CMDIR/Cx001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo $CMDIR/Cx001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo $CMDIR/Cx001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')

gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input002 $INDIR/LANDCOVER/LANDCrc.tif
gdal_translate  -of AAIGrid  $INDIR/LANDCOVER/LANDCrc.tif $INDIR/LANDCOVER/LANDCrc.asc
awk '$1 ~ /^[0-9]/' $INDIR/LANDCOVER/LANDCrc.asc > $INDIR/LANDCOVER/LANDCrc.txt
gdalinfo $INDIR/LANDCOVER/LANDCrc.asc > $INDIR/LANDCOVER/ReadMeLANDGLOB.txt

#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

#R version  3.2.1
# set working directory
INDIR = Sys.getenv(c('LAND'))
CMDIR = Sys.getenv(c('LAND'))

setwd(INDIR)

require(sp)
require(rgdal)
require(raster)
require(rciop)

#gc()
#gcinfo(TRUE) 
 
   
# list all files from the current directory
LANDCrc <-read.table(list.files(path=INDIR, pattern="LANDCrc.txt"), header=FALSE, sep="", na.strings="NA", dec=",", strip.white=TRUE)
LANDCrc01<-as.matrix(LANDCrc)

x00=LANDCrc01 

rm("LANDCrc")

# reclassify the values
# reclass_function = function(x00){
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
write.table(x00,paste(CMDIR,'/' ,'x00.txt',sep = ""),row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 

#	return(x00)
#}


#x00 <-read.table(paste(CMDIR,'/' ,'x00.txt',sep = ""))

x001<-data.frame(t(x00))

x0001<-stack(x001)
str(x0001)

str(x00)

x01="LANDCrc.tif"
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
str(xy)

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
writeRaster(rD3,paste(CMDIR, '/' ,'LANDC001.tif',sep = ""),overwrite=TRUE)

#	return(rD3)
#}
str(rD3)

#reclass_function(LANDCrc01)
#xy_for_raster("LANDCrc.tif")
#df_to_raster(LANDCrc01)

rm(list = ls())
EOF

#-------------------------------------------------------------------------------------#

gdalinfo $LAND/LANDC001.tif > $LAND/ReadMeLANDC001.txt

echo "DONE"

