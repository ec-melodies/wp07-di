#!/bin/sh
############################################################################
#	
# PURPOSE:	Local dynamic draught degradation CD(x)
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
# require("gtools")
###Setting enviroments 

# INDIR = Sys.getenv(c('INDIR'))
# OUTDIR001 = Sys.getenv(c('OUTDIR001'))
# setwd(INDIR)

y1="1989"
y2="2014"

export y1
export y2

R --vanilla --no-readline   -q  <<'EOF'

#R version  3.2.1

INDIR = Sys.getenv(c('INDIR'))
OUTDIR001 = Sys.getenv(c('OUTDIR001'))

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")
require("gtools")

####console setting
###
options(max.print=99999999) 
options("scipen"=100, "digits"=4)

###read data###

setwd(INDIR)

file.grib<-readGDAL(list.files(path=INDIR, pattern="*.grib"))

#####RL1-Amount of days per year with precipitation below 1 mm##########

file.grib_df_t<-t(data.frame(file.grib))
######one value per day
###
Day_2to1_file.grib<-rollapply(file.grib_df_t, FUN=sum,by=2,width=2,na.rm = TRUE)
###calculos das coordenadas
xy001=geometry(file.grib)

#####RL1-Amount of days per year with precipitation below 1 mm###########

Day_2to1_sa2<-data.frame(t(Day_2to1_file.grib))

RL1001<-as.matrix(Day_2to1_sa2[,c(-dim(Day_2to1_sa2)[2])])
RL100401<- as.data.frame(t(RL1001))

############################################
y1=1989
y2=2014

y10=substr(y1, start = 3, stop = 4)
y20=substr(y2, start = 3, stop = 4)

en <- as.Date(paste('30/09','/',y20,sep=""), "%d/%m/%y")
st <- as.Date(paste('01/10','/',y10,sep=""), "%d/%m/%y")
years <- seq(st, en, by="1 day")

years01 <-as.numeric(format(years, "%Y")) 
years02 <-as.numeric(format(years, "%m")) 

years00 <-data.frame(years)

######################################

### all data
RL100403 <- cbind(RL100401,years00)

########################01
for (i in 1989:2014){
ww=assign(paste("RP_",i,sep=""),subset(RL100403, RL100403$years >= paste(i,'-10-01',sep="") & RL100403$years <= paste(i+1,'-09-30',sep="")))
#write.table(ww,paste("PP_",i,".txt", sep=""),row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 
}

RPlist01<-mget(mixedsort(ls(pattern="RP_*")))
########################03
list.data3<-RPlist01

for (i in 1:(length(list.data3)-1)){
ww=assign(paste("RP2_",i,sep=""),as.data.frame(list.data3[[i]][,1:dim(Day_2to1_sa2)[1]]))
#write.table(ww,paste("RP2_",i,".txt", sep=""),row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 
}

RPlist02<-mget(mixedsort(ls(pattern="RP2_*")))
#########################05
list.data3<-RPlist02

for (i in 1:(length(list.data3))){
ww=assign(paste("RP3_",i,sep=""),as.vector(rowSums(t(list.data3[[i]]) <0.001)))
#write.table(ww,paste("RP3_",i,".txt", sep=""),row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 
}

RPlist03<-mget(mixedsort(ls(pattern="RP3_*")))
###########################07
RPlist04<-data.frame(RPlist03)

#check01
write.table(RPlist04,"RPlist04.txt",row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 

PP4mean<-rollapply(t(RPlist04), FUN=mean,by.column=T,width=25,na.rm = TRUE)

#check02
write.table(PP4mean,"RPlist04_mean.txt",row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 

####################moving_window: 10 years#######################
######################dynamic component############

wind10_var<-function(x) 
	{
	wind10_var=rollapply(t(x), FUN=var,by.column=T,width=10,na.rm = TRUE) ##the variance of RL1 for a period of 10 years
	wd10=c(1:dim(wind10_var)[1])#number of moving windows
	slope_wind10_var=lm((wind10_var)~wd10)$coef[2,]#slope of the decadal variance layers
	return (data.frame(slope_wind10_var))
	}

slope_wind10_var_sa_2014<-wind10_var(RPlist04)

###Cd###
#######################################################	
Cd_dynamic<-function(x)
	{
	x=as.vector(x)
	replace(x, x>abs(min(x)), 0)
	x=(abs(min(x))-x)/(2*abs(min(x)))
	Cd_dynamic=x
	return(Cd_dynamic)
	}


Cd_sa_2014<-Cd_dynamic(slope_wind10_var_sa_2014)
head(Cd_sa_2014)
summary(Cd_sa_2014)
#"$out=if($RL1>$min_slope,0,($min_slope-$RL1)/(2*$min_slope))"

#step 3#
###Cs###

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

Cd_df1<-cbind(Cd_sa_2014,data.frame(xy003))


Cd_df10<-data.frame(Cd_df1)
coordinates(Cd_df10)=~x+y
proj4string(Cd_df10)=CRS("+init=epsg:4326") # set it to lat-long
Cd_df10 = spTransform(Cd_df10,CRS("+init=epsg:4326"))
gridded(Cd_df10) = TRUE
rD3 = raster(Cd_df10)
projection(rD3) = CRS("+init=epsg:4326")
writeRaster(rD3,paste(OUTDIR001, '/' ,'Dx001.tif',sep = ""),overwrite=TRUE)

EOF

### ASCII to geoMS

gdal_translate  -of AAIGrid  $OUTDIR001/Dx001.tif   $OUTDIR001/Dx001.asc 
gdalinfo $OUTDIR001/Dx001.asc > $OUTDIR001/ReadMe_Dx001.txt

awk '$1 ~ /^[0-9]/' $OUTDIR001/Dx001.asc > $OUTDIR001/Dx001.txt

head $OUTDIR001/Dx001.asc

R --vanilla --no-readline   -q  <<'EOF'
INDIR = Sys.getenv(c('OUTDIR001'))
OUTDIR001 = Sys.getenv(c('OUTDIR001'))

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")

setwd(INDIR)

list.files(pattern="Dx001.tif") 

# create a list from these files
list.filename<-list.files(pattern="Dx001.tif$")
file<-readGDAL(list.filename)
xy_sa=geometry(file)
xy<-data.frame(xy_sa)
z<- rep(0,dim(xy)[1])

###read data###

dt<-paste(path=OUTDIR001,'/',pattern="Dx001.txt",sep ="")
file_out<-read.table(dt)
sdf <- stack(file_out)

sdf01110 <-cbind(xy, sdf$values)
sdf01111 <-cbind(xy,z,sdf$values)

write.table(sdf01110,paste(path=OUTDIR001,'/' ,'Dx01110.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
write.table(sdf01111,paste(path=OUTDIR001,'/' ,'Dx01111.dat',sep = ""),  row.names = FALSE, col.names = FALSE)

EOF
#add space
sed -i -e 's/^/ /' $OUTDIR001/Dx01110.dat 
sed -i -e 's/^/ /' $OUTDIR001/Dx01111.dat 
#To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)

sed -i 's/$/\r/' $OUTDIR001/Dx01110.dat 
sed -i 's/$/\r/' $OUTDIR001/Dx01111.dat

echo "DONE"
