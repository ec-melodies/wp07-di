#!/bin/bash
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
export -p IDIR=/application
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p CMDIR=$OUTDIR/CM001
export -p CMDIR01=$CMDIR/AOI/AOI_CX
export -p CXDIR=$IDIR/cli_block_a/bin
#-------------------------------------------------------------------------------------# 

export -p Y1=$1
export -p Y2=$2

#-------------------------------------------------------------------------------------# 

IR="$( ciop-getparam aoi )"
ciop-log "AOI: $IR"
#-------------------------------------------------------------------------------------# 
echo $Y1 $Y2 
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
ciop-log "Year Cs: $Y1"
ciop-log "Year Cs: $Y2"

cd $CMDIR
echo $CMDIR
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'
#R version  3.2.1

INDIR = Sys.getenv(c('CMDIR'))
CMDIR = Sys.getenv(c('CMDIR01'))
setwd(CMDIR)
getwd()
#-------------------------------------------------------------------------------------# 
y1 = as.numeric(Sys.getenv(c('Y1')))
y1
y2 = as.numeric(Sys.getenv(c('Y2')))
y2
#-------------------------------------------------------------------------------------# 
# load the package
xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

TPmlist01<-mixedsort(list.files(path=INDIR, pattern="*.grib"))
TPmlist01
assign(paste("TPm_",1,sep=""),readGDAL(paste(INDIR,'/',TPmlist01[[1]] ,sep = "")))
xy001=geometry(TPm_1)

TPmlist06<-mixedsort(list.files(path=INDIR, pattern="*.txt"))
TPmlist06
for (i in 1:(length(TPmlist06))){ww=assign(paste("RL100401_",i,sep=""),
read.table(paste(INDIR,'/',TPmlist06[[i]] ,sep = ""), header=FALSE, sep="", na.strings="NA", dec=".", strip.white=TRUE))
}
ls()
#-------------------------------------------------------------------------------------# 
TPmlist09<-mget(mixedsort(ls(pattern="RL100401_*")))
file.names <- names(TPmlist09)
RL100501<-do.call(cbind, mget(file.names, envir=.GlobalEnv))
#-------------------------------------------------------------------------------------# 
y10=substr(y1, start = 3, stop = 4)
y20=substr(y2, start = 3, stop = 4)
en <- as.Date(paste('30/09','/',y20,sep=""), "%d/%m/%y")
st <- as.Date(paste('01/10','/',y10,sep=""), "%d/%m/%y")
years <- seq(st, en, by="1 day")
years01 <-as.numeric(format(years, "%Y")) 
years02 <-as.numeric(format(years, "%m")) 
years00 <-data.frame(years)
#-------------------------------------------------------------------------------------# 
#RL100403 <- cbind(RL100501,(years00))
#setwd(CMDIR)
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# RL1-Amount of days per year with precipitation below 1 mm
#-------------------------------------------------------------------------------------# 
RL=(as.vector(rowSums(RL100501<0.001)))/(strtoi(y2)-strtoi(y1))
#-------------------------------------------------------------------------------------# 
setwd(CMDIR)
write.table(RL,"RL100601.txt",row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
Cs_static2<-function(x) {Cs_static2=(x-min(x))/(max(x)-min(x))
		return(as.vector(Cs_static2))}
#-------------------------------------------------------------------------------------# 
Cs_sa2_2014<-Cs_static2(RL)
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

proj4string(CS_df1)=CRS("+proj=longlat +datum=WGS84") # set it to lat-long
CS_df = spTransform(CS_df1,CRS("+init=epsg:32662"))
gridded(CS_df) = TRUE
r = raster(CS_df)
writeRaster(r,file=paste(CMDIR,'/', 'Cx001_32662.tif',sep = ""),overwrite=TRUE)
sink(paste(CMDIR,'/', 'Cx001_info.txt',sep = ""))
r
sink()
rm(r)
gc()

CS_df1<-cbind(Cs_sa2_2014,data.frame(xy003))
coordinates(CS_df1)=~x+y
proj4string(CS_df1)=CRS("+init=epsg:32662") # set it to lat-long
#CS_df1b = spTransform(CS_df1,CRS("+init=epsg:32662"))
gridded(CS_df1) = TRUE
rb = raster(CS_df1)
#projection(rb) = CRS("+init=epsg:32662")
#writeRaster(rb,file=paste(CMDIR,'/', 'Cx001.tif',sep = ""),overwrite=TRUE)
sink(paste(CMDIR,'/', 'Cx001.txt',sep = ""))
rb
sink()

rciop.log("INFO", "Cx001.txt")

ls()

EOF
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
exit 0
