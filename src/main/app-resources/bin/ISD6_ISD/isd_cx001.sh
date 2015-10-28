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

export -p HDIR=/home/melodies-ist/wp07-di/src/main/app-resources/bin/ISD7_geoms/
export -p HXDIR=/home/melodies-ist/wp07-di/src/main/app-resources/bin/ISD5_node/

export -p LDIR=$OUTDIR/COKC
export -p ADIR=$OUTDIR/=$DIR/INPUT/AOI
#-------------------------------------------------------------------------------------# 
# bash $HDIR/vgt_to_geoms_004.sh

for file in $HXDIR/*Cx_AOI1.par; do 
filename=$(basename $file .par )
wine64 $HDIR/geoms.exe $HXDIR/${filename}.par
mv $ISDC/ISD_Kriging_Variance.out $ISDC/ISD_Kriging_Var_${filename}.out
mv $ISDC/ISD_Kriging_Mean.out $ISDC/ISD_Kriging_Mean_${filename}.out
awk 'NR > 3 { print }' $ISDC/ISD_Kriging_Var_${filename}.out > $ISDC/ISDvar_${filename}.txt
awk 'NR > 3 { print }' $ISDC/ISD_Kriging_Mean_${filename}.out > $ISDC/ISDmean_${filename}.txt
done

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# .out file to Gtiff
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'
INDIR = Sys.getenv(c('LDIR'))
ZDIR = Sys.getenv(c('ISDC'))
IDIR="/home/melodies-ist/data/ISD/INPUT/AOI/"

#INDIR
#[1] "/home/melodies-ist/data/ISD//ISD000//COKC"
#ZDIR
#[1] "/home/melodies-ist/data/ISD//ISD000//GEOMS//Cx"

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
list.filenames01=list.files(pattern=paste("Bx001",".*\\.tif",sep=""))
list.filenames02=list.files(pattern=".txt$")

list.filenames01
list.filenames02

# create a list from these file

for (i in 1:length(list.filenames01[])){
#for (i in 1:4){
print(i)

list.filenames03=list.filenames01[]

# load raster data 
file<-readGDAL(list.filenames03[i])
head(file)

ww=assign(paste("xy_sa",i,sep=""),data.frame(geometry(file)))
str(ww)
#write.table(ww,paste("xy_sa",i,".txt", sep=""),row.names = TRUE, col.names = TRUE, quote = FALSE, append = FALSE) 

#-------------------------------------------------------------------------------------# 
list.filenames04=list.files(path=ZDIR, pattern=paste("ISDmean",sep=""))
list.filenames04
ISD <-read.table(paste(path=ZDIR,'/', list.filenames04[i],sep =""), header=FALSE, sep="", na.strings="NA", dec=".", strip.white=TRUE)
file_out<-as.matrix(ISD)
str(file_out)

ISDdf01 <-cbind(file_out, ww)
write.table(ISDdf01,paste(path=ZDIR,'/','sdf01_',i,'_crop.txt',sep = ""),  row.names = TRUE, col.names = TRUE)

head(ISDdf01, n=30)

ISD_df<-data.frame(ISDdf01)
coordinates(ISD_df)=~x+y
proj4string(ISD_df)=CRS("+init=epsg:4326") # set it to lat-long
ISD_df = spTransform(ISD_df,CRS("+init=epsg:4326"))
gridded(ISD_df) = TRUE
rD3 = raster(ISD_df)
projection(rD3) = CRS("+init=epsg:4326")
head(rD3)
AOI.sub<-readOGR(paste(IDIR,sep = ""),"AOI1")
ISD<-rD3
writeRaster(ISD,filename=paste(ZDIR, "/" ,"ISDmeanCx001_02",i,".tif",sep = ""),format="GTiff",overwrite=TRUE)

isd.sub <- crop(ISD, extent(AOI.sub))
isd.sub <- mask(isd.sub, AOI.sub)
writeRaster(isd.sub,filename=paste(ZDIR, "/" ,"ISDmeanCx001_",i,".tif",sep = ""),format="GTiff",overwrite=TRUE)
head(isd.sub)

}
#-------------------------------------------------------------------------------------#
## Using the OGR KML driver
## writeOGR(Cx00101, dsn="ISDvarCx001.kml", layer= "Cx001", driver="KML", dataset_options=c("NameField=name"))
EOF
#-------------------------------------------------------------------------------------# 

#pkcrop -nodata -ot Int16 -e $DIR/melodies.shp -m -i $file -o  melodies$filename
#ciop.publish(melodies$filename)

echo "DONE"
exit 0