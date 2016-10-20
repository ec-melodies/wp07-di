#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: ISD (Dx)
#-------------------------------------------------------------------------------------# 
# Requires:
# awk
# wine
# geoms.exe
# R packages: 
# zoo
# rgdal
# raster
# sp
# maptools
#-------------------------------------------------------------------------------------# 
# source the ciop functions
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
export -p IDIR=/application
export PATH=/opt/anaconda/bin/:$PATH

export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000

export -p VITO=$OUTDIR/VITO
export -p ZDIR=$OUTDIR/GEOMS

export -p ISDC=$ZDIR/Cx
export -p ISDD=$ZDIR/Dx

export -p HDIR=$IDIR/processing_block_p/bin/
export -p HXDIR=$IDIR/parameters

export -p LDIR=$OUTDIR/COKC
export -p ADIR=/data/auxdata/AOI

export -p AOIP="$( ciop-getparam aoi )"
ciop-log "AOI: $AOIP"

export -p AOIP=$(awk '{print $1}' $OUTDIR/AOI0.txt)
echo $AOIP
#Year
#export -p Y2=$1
#echo $Y2

export -p Y2=$(awk '{print $2}' $OUTDIR/AOI.txt)
echo $Y2
#-------------------------------------------------------------------------------------# 
cd $ZDIR

#CRS32662="$( ciop-getparam aoi )"
#echo "AOI:" $CRS32662

export -p AOIX=$HXDIR/AOI_ISD.txt
echo $AOIX
#-------------------------------------------------------------------------------------#
#umask 000; touch $ZDIR/list_isd_dx.txt


if [[ $AOIP == AOI1 ]] ; then
	grep "Dx_AOI1" $AOIX > $ZDIR/list_isd_dx.txt;
	echo $AOIP

elif [[ $AOIP == AOI2 ]] ; then
	grep "Dx_AOI2" $AOIX > $ZDIR/list_isd_dx.txt;
	echo $AOIP

elif [[ $AOIP == AOI3 ]] ; then
	grep "Dx_AOI3" $AOIX > $ZDIR/list_isd_dx.txt;
	echo $AOIP

elif [[ $AOIP == AOI4 ]] ; then 
	grep "Dx_AOI4" $AOIX > $ZDIR/list_isd_dx.txt;
	echo $AOIP
else
	echo "AOI out of range"
fi
#-------------------------------------------------------------------------------------# 

while IFS='' read -r line || [[ -n "$line" ]]; do
echo $line
filename=$(basename $line .par)
/usr/bin/wine64 $HDIR/krige.6401.exe $line
mv $ISDD/ISD_Kriging_Variance.out $ISDD/ISD_Kriging_Var_${filename}.out
mv $ISDD/ISD_Kriging_Mean.out $ISDD/ISD_Kriging_Mean_${filename}.out
awk 'NR > 3 { print }' $ISDD/ISD_Kriging_Var_${filename}.out > $ISDD/ISDvar_${filename}.txt
awk 'NR > 3 { print }' $ISDD/ISD_Kriging_Mean_${filename}.out > $ISDD/ISDmean_${filename}.txt
done < "$ZDIR/list_isd_dx.txt"

ciop-log "INFO" "isd_dx"
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# .out file to Gtiff
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline -q --min-vsize=10M --min-nsize=500k <<'EOF'
INDIR = Sys.getenv(c('ZDIR'))
INDIR
ZDIR = Sys.getenv(c('ISDD'))
ZDIR
IDIR= Sys.getenv(c('ADIR'))
IDIR


## load the package
xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)
#-------------------------------------------------------------------------------------# 
setwd(INDIR)
getwd()
gc()
# list all files from the current directory
list.files(pattern=".tif$")  
# create a list from these files
list.filenames01=mixedsort(list.files(pattern=paste("Bx002",".*\\.tif",sep="")))
list.filenames02=mixedsort(list.files(pattern=paste("Bx002",".*\\.txt",sep="")))

list.filenames01
list.filenames02
#-------------------------------------------------------------------------------------# 
# create a list from these file

for (i in 1:length(list.filenames01[])){
print(i)

list.filenames03=list.filenames01[]

# load raster data 
file<-readGDAL(list.filenames03[i])
xy=assign(paste("xy_sa",sep=""),data.frame(geometry(file)))

#-------------------------------------------------------------------------------------# 
gc()
#B=xy[1]
x= xy[1]
#x= matrix(, nrow = dim(B)[1], ncol = dim(B)[2])
#for (k in 1:dim(x)[1]) {x[k,]=B[dim(x)[1]-k+1,]}
B=xy[2]
y= matrix(, nrow = dim(B)[1], ncol = dim(B)[2])
for (k in 1:dim(y)[1]) {y[k,]=B[dim(y)[1]-k+1,]}
ww<-cbind(x,y)
ls()
#-------------------------------------------------------------------------------------# 
rm(file)
rm(x)
rm(y)
rm(xy_sa)
rm(xy)
#-------------------------------------------------------------------------------------# 
list.filenames04=mixedsort(list.files(path=ZDIR, pattern=paste("ISDmean",".*\\.txt",sep="")))
list.filenames04
ISD <-read.table(paste(path=ZDIR,'/', list.filenames04[i],sep =""), header=FALSE, sep="", na.strings="NA", dec=".", strip.white=TRUE)
file_out000<-as.matrix(ISD)
rm(ISD)
IC<-function(x00)
	{
	x01=replace(x00, x00 < 0, 0)
	x11=replace(x01, x01 > 1, 1)
	return(x11)
	}

file_out<-IC(file_out000)
rm(file_out000)
rm(B)
#-------------------------------------------------------------------------------------# 
ISDdf01 <-cbind(file_out, ww)
rm(file_out)
rm(ww)
gc()
#-------------------------------------------------------------------------------------# 
ISD_df<-data.frame(ISDdf01)

rm(ISDdf01)
coordinates(ISD_df)=~x+y
proj4string(ISD_df)=CRS("+init=epsg:32662") # set it to lat-long
ISD_df = spTransform(ISD_df,CRS("+init=epsg:32662"))
gridded(ISD_df) = TRUE
ISD = raster(ISD_df)
rm(ISD_df)
writeRaster(ISD,filename=paste(ZDIR, "/" ,"ISDmeanDx001_02",i,".tif",sep = ""),format="GTiff",overwrite=TRUE)
rm(ISD)
gc()
}

EOF

#-------------------------------------------------------------------------------------#
R --vanilla --no-readline -q --min-vsize=10M --min-nsize=500k <<'EOF'
SBDIR = Sys.getenv(c('ISDD'))
SBDIR
IDIR = Sys.getenv(c('ADIR'))
IDIR
AOIP = Sys.getenv(c('AOIP'))
AOIP
Y2 = Sys.getenv(c('Y2'))
Y2

setwd(SBDIR)
getwd()

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal") 
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)

require("RStoolbox")

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

# list all files from the current directory
list.files(pattern=".tif$") 
list.filenames=assign(paste("list.filenames",sep=""),mixedsort(list.files(pattern=paste("ISDmeanDx001_"))))
list.filenames 

AOI.sub<-readOGR(paste(IDIR,sep = ""),AOIP)
AOI.sub01 = spTransform(AOI.sub,CRS("+init=epsg:32662"))

# create a list from these files
for (j in 1:length(list.filenames)){ 
list00=assign(paste("isd.sub00_",j,sep=""), crop(raster(list.filenames[j]), extent(AOI.sub01)))
list01=assign(paste("isd.sub_",j,sep=""), mask(list00, AOI.sub01))
writeRaster(list01,filename=paste(SBDIR, "/" ,"ISD_Dx001_00_",AOIP,Y2,j,".tif",sep = ""),format="GTiff",overwrite=TRUE)
}

#-------------------------------------------------------------------------------------# 
EOF


R --vanilla --no-readline -q --min-vsize=10M --min-nsize=500k <<'EOF'
SBDIR = Sys.getenv(c('ISDD'))
SBDIR
IDIR = Sys.getenv(c('ADIR'))
IDIR
AOIP = Sys.getenv(c('AOIP'))
AOIP
Y2 = Sys.getenv(c('Y2'))
Y2

setwd(SBDIR)
getwd()

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal") 
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)

require("RStoolbox")

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

ofl<-list.files(pattern=paste("ISD_Dx001_00_",".*\\.tif",sep=""))
s<-lapply(ofl,raster)
len=length(s)
if(len == 6) {
rastD7 <- mosaic(s[[1]],s[[2]],s[[3]],s[[4]],s[[5]],s[[6]], fun=max)
} else if (len == 18) {
rastD7 <- mosaic(s[[1]],s[[2]],s[[3]],s[[4]],s[[5]],s[[6]],s[[7]],s[[8]],s[[9]],s[[10]],s[[11]],s[[12]],s[[13]],s[[14]],s[[15]],s[[16]],s[[17]],s[[18]],fun=max)
} else if (len == 20) {
rastD7 <- mosaic(s[[1]],s[[2]],s[[3]],s[[4]],s[[5]],s[[6]],s[[7]],s[[8]],s[[9]],s[[10]],s[[11]],s[[12]],s[[13]],s[[14]],s[[15]],s[[16]],s[[17]],s[[18]],s[[19]],s[[20]],fun=max)
} else if (len == 10) {
rastD7 <- mosaic(s[[1]],s[[2]],s[[3]],s[[4]],s[[5]],s[[6]],s[[7]],s[[8]],s[[9]],s[[10]],fun=max)
}

AOIP
v1="MSC"

#save the raster

tmp.file1 <- paste(SBDIR, "/" ,"ISD_Dx002",v1,AOIP,Y2,".tif",sep = "")
writeRaster(rastD7,filename=tmp.file1,format="GTiff",datatype='FLT4S',overwrite=TRUE)
rciop.publish(tmp.file1, recursive=FALSE, metalink=TRUE)

EOF


ciop-log "INFO" "isd_dx"
#-------------------------------------------------------------------------------------# 
echo "DONE"
exit 0