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

export -p AOIX=/application/parameters/AOI_ISD.txt

echo $AOI

while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ "$line" == AOI1 ]] ; then	
		grep "Dx_AOI1" $AOIX > $ZDIR/list_isd_dx.txt
		echo $NV
	
	elif [[ "$line" == AOI2 ]] ; then		
		grep "Dx_AOI2" $AOIX > $ZDIR/list_isd_dx.txt
		echo $NV

	elif [[ "$line" == AOI3 ]] ; then		
		grep "Dx_AOI3" $AOIX > $ZDIR/list_isd_dx.txt
		echo $NV

	elif [[ "$line" == AOI4 ]] ; then
		grep "Dx_AOI4" $AOIX > $ZDIR/list_isd_dx.txt
		echo $NV

	else
		echo "AOI out of range"
	fi 
done < "$IR"

cd $DIR

while IFS='' read -r line || [[ -n "$line" ]]; do

echo $line
filename=$(basename $line .par)
wine64 $HDIR/krige.exe $line
mv $ISDD/ISD_Kriging_Variance.out $ISDD/ISD_Kriging_Var_${filename}.out
mv $ISDD/ISD_Kriging_Mean.out $ISDD/ISD_Kriging_Mean_${filename}.out
awk 'NR > 3 { print }' $ISDD/ISD_Kriging_Var_${filename}.out > $ISDD/ISDvar_${filename}.txt
awk 'NR > 3 { print }' $ISDD/ISD_Kriging_Mean_${filename}.out > $ISDD/ISDmean_${filename}.txt

done < "$ZDIR/list_isd_dx.txt"

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# .out file to Gtiff
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline -q --min-vsize=10M --min-nsize=500k <<'EOF'
INDIR = Sys.getenv(c('ZDIR'))
ZDIR = Sys.getenv(c('ISDD'))
IDIR= Sys.getenv(c('ADIR'))

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
xy=assign(paste("xy_sa",i,sep=""),data.frame(geometry(file)))

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
rm(xy_sa2)
rm(xy)
#-------------------------------------------------------------------------------------# 
list.filenames04=list.files(path=ZDIR, pattern=paste("ISDmean",".*\\.txt",sep=""))
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
export -p ZDIR=$OUTDIR/GEOMS/Dx
export -p IDIR=/data/auxdata/AOI
export -p AOIP=/application/parameters/AOI
export AOI=$(awk '{ print $1}' $AOIP)
echo $AOI

R --vanilla --no-readline -q --min-vsize=10M --min-nsize=500k <<'EOF'
SBDIR = Sys.getenv(c('ISDD'))
IDIR = Sys.getenv(c('IDIR'))
AOIP = Sys.getenv(c('AOI'))
AOIP
Y2 = Sys.getenv(c('Y2'))
Y2

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
list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("ISDmeanDx001_")))
list.filenames 

AOI.sub<-readOGR(paste(IDIR,sep = ""),AOIP)
AOI.sub01 = spTransform(AOI.sub,CRS("+init=epsg:32662"))

# create a list from these files
for (j in 1:length(list.filenames)){ 
list00=assign(paste("isd.sub00_",j,sep=""), crop(raster(list.filenames[j]), extent(AOI.sub01)))
list01=assign(paste("isd.sub_",j,sep=""), mask(list00, AOI.sub01))
writeRaster(list01,filename=paste(SBDIR, "/" ,"ISD_Dx001_00_",AOIP,Y2,j,".tif",sep = ""),format="GTiff",overwrite=TRUE)
}

TPmlist02<-list.files(pattern=paste("ISD_Dx001_00_",".*\\.tif",sep=""))
TPmlist02

tmp1 <-raster(TPmlist02[1])
tmp2 <-raster(TPmlist02[2])

TPm_2=histMatch(tmp1,tmp2)
rastD6<-mosaic(TPm_2,tmp2, fun=mean)
writeRaster(rastD6,filename=paste(SBDIR, "/" ,"ISD_Dx001",AOIP,Y2,".tif",sep = ""),format="GTiff",overwrite=TRUE)

EOF

#-------------------------------------------------------------------------------------# 
echo "DONE"
exit 0