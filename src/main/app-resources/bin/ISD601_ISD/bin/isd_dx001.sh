#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: ISD (Cx)
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
# source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
#bash /application/bin/ISD5_node/ini.sh
export DIR=~/data/ISD/

export -p OUTDIR=$DIR/ISD000/

export -p ZDIR=$OUTDIR/GEOMS/
export -p ISDC=$ZDIR/Cx
export -p ISDD=$ZDIR/Dx

export -p HDIR=~/wp07-di/src/main/app-resources/bin/ISD700_Gx/
export -p HXDIR=~/wp07-di/src/main/app-resources/bin/ISD5_Nx

export -p LDIR=$OUTDIR/COKC
export -p ADIR=~/data/AOI/
#-------------------------------------------------------------------------------------# 
# bash $HDIR/vgt_to_geoms_004.sh

PAR=$1

filename=$(basename $PAR .par)

wine64 $HDIR/geoms.exe $PAR
mv $ISDD/ISD_Kriging_Variance.out $ISDD/ISD_Kriging_Var_${filename}.out
mv $ISDD/ISD_Kriging_Mean.out $ISDD/ISD_Kriging_Mean_${filename}.out
awk 'NR > 3 { print }' $ISDD/ISD_Kriging_Var_${filename}.out > $ISDD/ISDvar_${filename}.txt
awk 'NR > 3 { print }' $ISDD/ISD_Kriging_Mean_${filename}.out > $ISDD/ISDmean_${filename}.txt

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# .out file to Gtiff
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'
INDIR = Sys.getenv(c('ZDIR'))
ZDIR = Sys.getenv(c('ISDD'))
IDIR= Sys.getenv(c('ADIR'))

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")
require("maptools")
#-------------------------------------------------------------------------------------# 
setwd(INDIR)
getwd()

# list all files from the current directory
list.files(pattern=".tif$")  
# create a list from these files
list.filenames01=list.files(pattern=paste("Bx002",".*\\.tif",sep=""))
list.filenames02=list.files(pattern=".txt$")

list.filenames01
list.filenames02
#-------------------------------------------------------------------------------------# 
# create a list from these file

for (i in 1:length(list.filenames01[])){
#for (i in 1:4){
print(i)

list.filenames03=list.filenames01[]

# load raster data 
file<-readGDAL(list.filenames03[i])
head(file)

xy=assign(paste("xy_sa",i,sep=""),data.frame(geometry(file)))

#-------------------------------------------------------------------------------------# 

#B=xy[1]
x= xy[1]
#x= matrix(, nrow = dim(B)[1], ncol = dim(B)[2])
#for (k in 1:dim(x)[1]) {x[k,]=B[dim(x)[1]-k+1,]}
B=xy[2]
y= matrix(, nrow = dim(B)[1], ncol = dim(B)[2])
for (k in 1:dim(y)[1]) {y[k,]=B[dim(y)[1]-k+1,]}
ww<-cbind(x,y)

#-------------------------------------------------------------------------------------# 
str(ww)
#write.table(ww,paste("xy_sa",i,".txt", sep=""),row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 
rm(file)
rm(xy_sa1)
#-------------------------------------------------------------------------------------# 
list.filenames04=list.files(path=ZDIR, pattern=paste("ISDmean",sep=""))
list.filenames04
ISD <-read.table(paste(path=ZDIR,'/', list.filenames04[1],sep =""), header=FALSE, sep="", na.strings="NA", dec=".", strip.white=TRUE)
file_out000<-as.matrix(ISD)

IC<-function(x00)
	{
	x01=replace(x00, x00 < 0, 0)
	x11=replace(x01, x01 > 1, 1)
	return(x11)
	}

file_out<-IC(file_out000)

rm(ISD)
#-------------------------------------------------------------------------------------# 
ISDdf01 <-cbind(file_out, ww)
#write.table(ISDdf01,paste(path=ZDIR,'/','sdf01_',i,'_crop.txt',sep = ""),  row.names = TRUE, col.names = TRUE)
rm(file_out)
rm(ww)
#-------------------------------------------------------------------------------------# 

i=1

ISD_df<-data.frame(ISDdf01)

rm(ISDdf01)

coordinates(ISD_df)=~x+y
proj4string(ISD_df)=CRS("+init=epsg:4326") # set it to lat-long
ISD_df = spTransform(ISD_df,CRS("+init=epsg:4326"))
gridded(ISD_df) = TRUE
rD3 = raster(ISD_df)

rm(ISD_df)

projection(rD3) = CRS("+init=epsg:4326")
AOI.sub<-readOGR(paste(IDIR,sep = ""),"AOI4")
ISD<-rD3
writeRaster(ISD,filename=paste(ZDIR, "/" ,"ISDmeanDx001_02",i,".tif",sep = ""),format="GTiff",overwrite=TRUE)

isd.sub <- crop(ISD, extent(AOI.sub))
isd.sub <- mask(isd.sub, AOI.sub)

rm(ISD)
writeRaster(isd.sub,filename=paste(ZDIR, "/" ,"ISDmeanDx001_",i,".tif",sep = ""),format="GTiff",overwrite=TRUE)
head(isd.sub)

}
#-------------------------------------------------------------------------------------#
EOF
#-------------------------------------------------------------------------------------# 

echo "DONE"
exit 0