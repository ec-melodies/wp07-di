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
export DIR=/data/auxdata/ISD/

export -p OUTDIR=$DIR/ISD000/

export -p ZDIR=$OUTDIR/GEOMS/
export -p ISDC=$ZDIR/Cx
export -p ISDD=$ZDIR/Dx

export -p HDIR=/application/processing_block_p/bin/
export -p HXDIR=/application/parameters/

export -p LDIR=$OUTDIR/COKC
export -p ADIR=/data/auxdata/AOI
export -p IR=/application/parameters/AOI
#-------------------------------------------------------------------------------------# 
# bash $HDIR/vgt_to_geoms_004.sh

cd $DIR
export -p AOIX=/application/parameters/AOI_ISD.txt
echo $AOI

while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ "$line" == AOI1 ]] ; then	
		grep "Cx_AOI1" $AOIX > $ZDIR/list_isd_cx.txt
		echo $NV
	
	elif [[ "$line" == AOI2 ]] ; then		
		grep "Cx_AOI2" $AOIX > $ZDIR/list_isd_cx.txt
		echo $NV

	elif [[ "$line" == AOI3 ]] ; then		
		grep "Cx_AOI3" $AOIX > $ZDIR/list_isd_cx.txt
		echo $NV

	elif [[ "$line" == AOI4 ]] ; then
		grep "Cx_AOI4" $AOIX > $ZDIR/list_isd_cx.txt
		echo $NV

	else
		echo "AOI out of range"
	fi 
done < "$IR"


while IFS='' read -r line || [[ -n "$line" ]]; do

echo $line
filename=$(basename $line .par)
wine64 $HDIR/krige.exe $line
mv $ISDC/ISD_Kriging_Variance.out $ISDC/ISD_Kriging_Var_${filename}.out
mv $ISDC/ISD_Kriging_Mean.out $ISDC/ISD_Kriging_Mean_${filename}.out
awk 'NR > 3 { print }' $ISDC/ISD_Kriging_Var_${filename}.out > $ISDC/ISDvar_${filename}.txt
awk 'NR > 3 { print }' $ISDC/ISD_Kriging_Mean_${filename}.out > $ISDC/ISDmean_${filename}.txt

done < "$ZDIR/list_isd_cx.txt"
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# .out file to Gtiff
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'
INDIR = Sys.getenv(c('ZDIR'))
ZDIR = Sys.getenv(c('ISDC'))
IDIR= Sys.getenv(c('ADIR'))
AOI= Sys.getenv(c('AOI'))

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")
require("maptools")
require("gtools")
library(digest)
#-------------------------------------------------------------------------------------# 
setwd(INDIR)
getwd()

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
#-------------------------------------------------------------------------------------# 
list.filenames04=list.files(path=ZDIR, pattern=paste("ISDmean",sep=""))
list.filenames04
ISD <-read.table(paste(path=ZDIR,'/', list.filenames04[i],sep =""), header=FALSE, sep="", na.strings="NA", dec=".", strip.white=TRUE)
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
ISD_df<-data.frame(ISDdf01)

rm(ISDdf01)

coordinates(ISD_df)=~x+y
proj4string(ISD_df)=CRS("+init=epsg:32662") # set it to lat-long
ISD_df = spTransform(ISD_df,CRS("+init=epsg:32662"))
gridded(ISD_df) = TRUE
ISD = raster(ISD_df)

writeRaster(ISD,filename=paste(ZDIR, "/" ,"ISDmeanCx001_02",i,".tif",sep = ""),format="GTiff",overwrite=TRUE)

rm(ISD_df)
}

EOF


#-------------------------------------------------------------------------------------#
export -p ZDIR=$OUTDIR/GEOMS/Cx
export -p IDIR=/data/auxdata/AOI

R --vanilla --no-readline   -q  <<'EOF'
SBDIR = Sys.getenv(c('ISDC'))
IDIR = Sys.getenv(c('IDIR'))
AOI = Sys.getenv(c('AOI'))

setwd(SBDIR)
getwd()

require("zoo")
require("rgdal")
require("raster")
require("sp")
require("rciop")
require("gtools")
require("RStoolbox")

options(max.print=99999999) 
options("scipen"=100, "digits"=4)


# list all files from the current directory
list.files(pattern=".tif$") 
list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("ISDmeanCx001_")))
list.filenames 


AOI="AOI4"
AOI.sub<-readOGR(paste(IDIR,sep = ""),AOI)
AOI.sub01 = spTransform(AOI.sub,CRS("+init=epsg:32662"))

# create a list from these files
for (j in 1:length(list.filenames)){ 
isd.sub1 <- crop(raster(list.filenames[j]), extent(AOI.sub01))
isd.sub_i <- mask(isd.sub1, AOI.sub01)
}

TPmlist03<-mget(mixedsort(ls(pattern="isd.sub_")))
for (i in 1:(length(TPmlist03))){
TPm_2=histMatch(TPmlist03[[2]],TPmlist03[[1]])
rastD6<-mosaic(raster(list.filenames[1]),raster(list.filenames[2]), fun=mean)
writeRaster(rastD6,filename=paste(SBDIR, "/" ,"ISD_Cx001",".tif",sep = ""),format="GTiff",overwrite=TRUE)
}

EOF

#-------------------------------------------------------------------------------------# 
echo "DONE"
exit 0