#!/bin/sh
############################################################################
#	
# PURPOSE:	Local static degradation CS(x)
#
#############################################################################

# Requires:
# gdalwarp
# gdal_translate  
# gdalinfo
# awk
# R
# require("zoo")
# require("rgdal")
# require("raster")
# require("sp")
# 
###Setting enviroments 

# INDIR = Sys.getenv(c('INDIR'))
# OUTDIR001 = Sys.getenv(c('OUTDIR001'))
# setwd(INDIR)

# source the ciop functions (e.g. ciop-log, ciop-getparam)
# source ${ciop_job_include}

######
R --vanilla --no-readline   -q  <<'EOF'

#R version  3.2.1

INDIR = Sys.getenv(c('INDIR'))
OUTDIR001 = Sys.getenv(c('OUTDIR001'))
setwd(INDIR)

y1=Sys.getenv(c('y1'))
y2=Sys.getenv(c('y2'))

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")

####console setting
options(max.print=99999999) 
options("scipen"=100, "digits"=4)

###read data
file.grib<-readGDAL(list.files(path=INDIR, pattern="*.grib"))

#####RL1-Amount of days per year with precipitation below 1 mm##########

file.grib_df_t<-t(data.frame(file.grib))

######one value per day
###
Day_2to1_file.grib<-rollapply(file.grib_df_t, FUN=sum,by=2,width=2,na.rm = TRUE)

###calculo das coordenadas
xy001=geometry(file.grib)

#####RL1-Amount of days per year with precipitation below 1 mm###########

Day_2to1_sa2<-data.frame(t(Day_2to1_file.grib))

RL1001<-as.matrix(Day_2to1_sa2[,c(-dim(Day_2to1_sa2)[2])])
RL100401<- as.data.frame(t(RL1001))

######the average value of RL1 for each pixel########
RL100501<- as.vector(rowSums(t(RL100401) <0.001))
RL100601<- RL100501/(strtoi(y2)-strtoi(y1))

write.table(RL100601,"RL100601.txt",row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 

#step 3#
###Cs###

Cs_static2<-function(x)
		{
		Cs_static2=(x-min(x))/(max(x)-min(x))
		return(as.vector(Cs_static2))
		}
################
Cs_sa2_2014<-Cs_static2(RL100601)

# $out=1-(($max_a-$static)/($max_a-$min_a))
##################################export data ######################
#translate_corners
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

writeRaster(r,file=paste(OUTDIR001,'/', 'Cx001.tif',sep = ""),overwrite=TRUE)


EOF

### ASCII 

gdal_translate  -of AAIGrid  $OUTDIR001/Cx001.tif   $OUTDIR001/Cx001.asc 
gdalinfo $OUTDIR001/Cx001.asc > $OUTDIR001/ReadMe_Cx001.txt

echo "DONE"
######################

#cat $OUTDIR001/Cx001.asc | awk '{if($1 == "NODATA_value") print}'| awk 'NR > 6 { print }' $OUTDIR001/Cx001.asc> $OUTDIR001/Cx001.txt ; 
#cat $OUTDIR001/Cx001.asc | awk '{if($1 != "NODATA_value") print}'| awk 'NR > 5 { print }' $OUTDIR001/Cx001.asc> $OUTDIR001/Cx001.txt 

awk '$1 ~ /^[0-9]/' $OUTDIR001/Cx001.asc > $OUTDIR001/Cx001.txt

#######################
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('OUTDIR001'))
OUTDIR001 = Sys.getenv(c('OUTDIR001'))

setwd(OUTDIR001)

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")

####console setting
###
options(max.print=99999999) 
options("scipen"=100, "digits"=4)

###read data###


dt<-paste(path=OUTDIR001,'/',pattern="Cx001.tif",sep ="")
file001<-readGDAL(dt)
xy001=geometry(file001)
xy<-data.frame(xy001)
dt<-paste(path=OUTDIR001,'/',pattern="Cx001.txt",sep ="")
file002<-read.table(dt)

file003<-as.data.frame(t(file002))
sdf003<-stack(file003)

z<- rep(0,dim(xy)[1])

sdf0111103 <-cbind(xy,z,sdf003$values)

write.table(sdf0111103,paste(path=OUTDIR001,'/' ,'Cx0111103.dat',sep = ""),  row.names = FALSE, col.names = FALSE)

EOF

awk 'NR > 1 { print $1 }' $HDIR/header.txt > $OUTDIR001/Cx0111104.dat
cat $OUTDIR001/Cx0111103.dat >> $OUTDIR001/Cx0111104.dat

#add space
sed -i -e 's/^/ /' $OUTDIR001/Cx0111104.dat
#To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
sed -i 's/$/\r/' $OUTDIR001/Cx0111104.dat

echo "DONE"

