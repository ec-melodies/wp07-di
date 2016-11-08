#!/bin/bash
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
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
export PATH=/opt/anaconda/bin/:$PATH
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p CMDIR=$OUTDIR/CM001
export -p CMDIR02=$CMDIR/AOI/AOI_DX
export -p ZDIR=$OUTDIR/GEOMS

#-------------------------------------------------------------------------------------# 
export y1=$1
export y2=$2
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'
#R version  3.2.1

INDIR = Sys.getenv(c('CMDIR'))
CMDIR = Sys.getenv(c('CMDIR02'))

y1 = as.numeric(Sys.getenv(c('y1')))
y2 = as.numeric(Sys.getenv(c('y2')))

# load the package
load("/application/parameters/WSP.RData")
xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal",
"uuid", "RColorBrewer", "colorRamps", "rasterVis", "RStoolbox")
lapply(xlist, library, character.only = TRUE)

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

#-------------------------------------------------------------------------------------# 
TPmlist01<-mixedsort(list.files(path=INDIR, pattern="*.grib"))
assign(paste("TPm_",2,sep=""),readGDAL(paste(INDIR,'/',TPmlist01[[1]] ,sep = "")))
xy001=geometry(TPm_2)
str(xy001)

TPmlist06<-mixedsort(list.files(path=CMDIR, pattern=paste("RL100401_",".*\\.txt",sep="")))
for (i in 1:(length(TPmlist06))){ww=assign(paste("RL100401_",i,sep=""),
read.table(paste(CMDIR,'/',TPmlist06[[i]] ,sep = ""), header=FALSE, sep="", na.strings="NA", dec=".", strip.white=TRUE))
}
#-------------------------------------------------------------------------------------# 
TPmlist09<-mget(mixedsort(ls(pattern="RL100401_*")))
file.names <- names(TPmlist09)
RL100501<-do.call(cbind, mget(file.names, envir=.GlobalEnv))

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# RL1-Amount of days per year with precipitation below 1 mm
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
#y1=ciop.getparam(int('y1'))
#y2=ciop.getparam(int('y2'))
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
RL100403 <- cbind(t(RL100501),years00)
setwd(CMDIR)

#-------------------------------------------------------------------------------------# 
# 01
for (i in y1:y2){
ww=assign(paste("RP_",i,sep=""),subset(RL100403, RL100403$years >= paste(i,'-10-01',sep="") & RL100403$years <= paste(i+1,'-09-30',sep="")))
#write.table(ww,paste("PP_",i,".txt", sep=""),row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 
}
RPlist01<-mget(mixedsort(ls(pattern="RP_*")))
#-------------------------------------------------------------------------------------# 
# 03
list.data3<-RPlist01
for (i in 1:(length(list.data3)-1)){
ww=assign(paste("RP2_",i,sep=""),as.data.frame(list.data3[[i]][,1:dim(RL100501)[1]]))
#write.table(ww,paste("RP2_",i,".txt", sep=""),row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 
}
RPlist02<-mget(mixedsort(ls(pattern="RP2_*")))
#-------------------------------------------------------------------------------------# 
# 05
list.data3<-RPlist02
for (i in 1:(length(list.data3))){
ww=assign(paste("RP3_",i,sep=""),as.vector(rowSums(t(list.data3[[i]]) <0.001)))
#write.table(ww,paste("RP3_",i,".txt", sep=""),row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 
}
RPlist03<-mget(mixedsort(ls(pattern="RP3_*")))
str(RPlist03)
#-------------------------------------------------------------------------------------# 
# 07
RPlist04<-data.frame(RPlist03)
#check01
write.table(RPlist04,"RPlist04.txt",row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE)
dim=y2-y1
PP4mean<-rollapply(t(RPlist04), FUN=mean,by.column=T,width=dim,na.rm = TRUE)
#check02
write.table(PP4mean,"RPlist04_mean.txt",row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 
#-------------------------------------------------------------------------------------# 
# moving_window: 10 years 
#-------------------------------------------------------------------------------------# 
wind10_var<-function(x) 
	{
	wind10_var=rollapply(t(x), FUN=var,by.column=T,width=10,na.rm = TRUE) ##the variance of RL1 for a period of 10 years
	wd10=c(1:dim(wind10_var)[1])#number of moving windows
	slope_wind10_var=lm((wind10_var)~wd10)$coef[2,]#slope of the decadal variance layers
	return (data.frame(slope_wind10_var))
	}
slope_wind10_var_sa_2014<-wind10_var(RPlist04)
#-------------------------------------------------------------------------------------# 
Cd_dynamic<-function(x)
	{
	x=as.vector(x)
	x=replace(x, x>abs(min(x)), 0)
	x=(abs(min(x))-x)/(2*abs(min(x)))
	Cd_dynamic=x
	return(Cd_dynamic)
	}
#-------------------------------------------------------------------------------------# 
Cd_sa_2014<-Cd_dynamic(slope_wind10_var_sa_2014)
head(Cd_sa_2014)
summary(Cd_sa_2014)
#"$out=if($RL1>$min_slope,0,($min_slope-$RL1)/(2*$min_slope))"
#-------------------------------------------------------------------------------------# 
# translate_corners
xy002<-data.frame(xy001)
colnames(xy002)[1]<-"x"
colnames(xy002)[2]<-"y"
xy003<-data.frame(cbind(xy002$x,xy002$y))
colnames(xy003)[1]<-"x"
colnames(xy003)[2]<-"y"

for (i in 1:length(xy003$x)){ifelse(xy003$x[i]>180,(xy003$x[i]=xy003$x[i]-360), xy003$x[i])}
for (i in 1:length(xy003$y)){ifelse(xy003$y[i]>180,(xy003$y[i]=xy003$y[i]-360), xy003$y[i])}

Cd_df1<-cbind(Cd_sa_2014,data.frame(xy003))
Cd_df10<-data.frame(Cd_df1)

coordinates(Cd_df10)=~x+y
proj4string(Cd_df10)=CRS("+proj=longlat +datum=WGS84") # set it to lat-long
Cd_df10 = spTransform(Cd_df10,CRS("+init=epsg:32662"))
gridded(Cd_df10) = TRUE
rD3 = raster(Cd_df10)
writeRaster(rD3,paste(CMDIR, '/' ,'Dx001.tif',sep = ""),overwrite=TRUE)

EOF
#-------------------------------------------------------------------------------------# 
echo "DONE"
exit 0



