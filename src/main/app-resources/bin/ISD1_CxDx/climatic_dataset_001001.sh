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
# export PATH=/opt/anaconda/bin/:$PATH
# source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
# bash /application/bin/ISD5_node/ini.sh
export -p DIR=~/data/ISD/
export PATH=/opt/anaconda/bin/:$PATH
export -p INDIR=~/data/INPUT/
export -p OUTDIR=$DIR/ISD000/
export -p CMDIR=$OUTDIR/CM001

#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'
#R version  3.2.1

INDIR = Sys.getenv(c('CMDIR'))
CMDIR = Sys.getenv(c('CMDIR'))
setwd(INDIR)
getwd()
#-------------------------------------------------------------------------------------# 
#y1=rciop.getparam(c('y1'))
#y2=rciop.getparam(c('y2'))
y1=1989
y2=2014
#-------------------------------------------------------------------------------------# 
# load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")
require("rciop")

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

#-------------------------------------------------------------------------------------# 
file.grib<-readGDAL(list.files(path=INDIR, pattern="*.grib"))
#-------------------------------------------------------------------------------------# 
# RL1-Amount of days per year with precipitation below 1 mm
#-------------------------------------------------------------------------------------# 
file.grib_df_t<-t(data.frame(file.grib))
Day_2to1_file.grib<-rollapply(file.grib_df_t, FUN=sum,by=2,width=2,na.rm = TRUE)
xy001=geometry(file.grib)

rm(file.grib)

Day_2to1_sa2<-data.frame(t(Day_2to1_file.grib))
RL1001<-as.matrix(Day_2to1_sa2[,c(-dim(Day_2to1_sa2)[2])])
RL100401<- as.data.frame(t(RL1001))
#-------------------------------------------------------------------------------------# 
# the average value of RL1 for each pixel
#-------------------------------------------------------------------------------------# 
RL100501<- as.vector(rowSums(t(RL100401) <0.001))
RL100601<- RL100501/(strtoi(y2)-strtoi(y1))
write.table(RL100601,"RL100601.txt",row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
Cs_static2<-function(x) {Cs_static2=(x-min(x))/(max(x)-min(x))
		return(as.vector(Cs_static2))}
#-------------------------------------------------------------------------------------# 
Cs_sa2_2014<-Cs_static2(RL100601)
# $out=1-(($max_a-$static)/($max_a-$min_a))
#-------------------------------------------------------------------------------------# 
#translate_corners
#-------------------------------------------------------------------------------------# 
xy002<-data.frame(xy001)
colnames(xy002)[1]<-"x"
colnames(xy002)[2]<-"y"

xy003<-data.frame(cbind(xy002$x,xy002$y))
colnames(xy003)[1]<-"x"
colnames(xy003)[2]<-"y"

for (i in 1:length(xy003$x)){ifelse(xy003$x[i]>180,(xy003$x[i]=xy003$x[i]-360), xy003$x[i])}
for (i in 1:length(xy003$y)){ifelse(xy003$y[i]>180,(xy003$y[i]=xy003$y[i]-360), xy003$y[i])}

CS_df1<-cbind(Cs_sa2_2014,data.frame(xy003))

coordinates(CS_df1)=~x+y
proj4string(CS_df1)=CRS("+init=epsg:4326") # set it to lat-long
CS_df1 = spTransform(CS_df1,CRS("+init=epsg:4326"))
gridded(CS_df1) = TRUE
r = raster(CS_df1)
projection(r) = CRS("+init=epsg:4326")
writeRaster(r,file=paste(CMDIR,'/', 'Cx001.tif',sep = ""),overwrite=TRUE)

EOF
#-------------------------------------------------------------------------------------# 
gdal_translate  -of AAIGrid  $CMDIR/Cx001.tif   $CMDIR/Cx001.asc 
gdalinfo $CMDIR/Cx001.asc > $CMDIR/ReadMe_Cx001.txt

#-------------------------------------------------------------------------------------# 
#cat $CMDIR/Cx001.asc | awk '{if($1 == "NODATA_value") print}'| awk 'NR > 6 { print }' $CMDIR/Cx001.asc> $CMDIR/Cx001.txt ; 
#cat $CMDIR/Cx001.asc | awk '{if($1 != "NODATA_value") print}'| awk 'NR > 5 { print }' $CMDIR/Cx001.asc> $CMDIR/Cx001.txt 
awk '$1 ~ /^[0-9]/' $CMDIR/Cx001.asc > $CMDIR/Cx001.txt


#-------------------------------------------------------------------------------------# 

