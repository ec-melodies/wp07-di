#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: ISD (Dx)
#-------------------------------------------------------------------------------------# 
# Requires:
# awk
# wine
# geoms.exe
# R package: 
# zoo
# rgdal
# raster
# sp
# maptools
#-------------------------------------------------------------------------------------# 
# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}
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
bash $HDIR/vgt_to_geoms_004.sh
#wine64 /application/bin/ISD7_geoms/geoms.exe $LDIR/ssdirDx.par
wine64 $HDIR/geoms.exe $HXDIR/ssdirDx.par
#-------------------------------------------------------------------------------------# 
#awk 'NR > 3 { print }' $ISDD/ISD_Kriging_Variance.out > $ISDD/ISDvarDx001.txt
# awk 'NR > 3 { print }' $ZDIR/ISD_Dx_Krig_var.out > $ZDIR/ISDvarDx001.txt
awk 'NR > 3 { print }' $ISDD/ISD_Kriging_Mean.out > $ISDD/ISDmeanDx001.txt
#-------------------------------------------------------------------------------------# 
# .out file to Gtiff
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'
INDIR = Sys.getenv(c('LDIR'))
ZDIR = Sys.getenv(c('ISDD'))
ADIR = Sys.getenv(c('ISDD'))

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")
require("maptools")

setwd(INDIR)

list.files(pattern="Bx001rc.tif") 
list.filename<-list.files(pattern="Bx001rc.tif")
file<-readGDAL(list.filename)
xy_sa=geometry(file)
xy<-data.frame(xy_sa)
z<- rep(0,dim(xy)[1])

setwd(ZDIR)

list.filename<-list.files(pattern="Dx001.txt")
file_out<-read.table(list.filename)
sdf01 <-cbind(xy, file_out)

## check 01
write.table(sdf01,paste(path=ZDIR,'/' ,'sdf01.txt',sep = ""),  row.names = TRUE, col.names = TRUE)

Dx00101<-data.frame(sdf01)
coordinates(Dx00101)=~x+y
proj4string(Dx00101)=CRS("+init=epsg:4326") # set it to lat-long
Dx001 = spTransform(Dx00101,CRS("+init=epsg:4326"))
gridded(Dx00101) = TRUE
rD3 = raster(Dx00101)
projection(rD3) = CRS("+init=epsg:4326")
writeRaster(rD3,paste(ZDIR, '/' ,'ISDmeanDx001.tif',sep = ""),overwrite=TRUE)

ZDIR="/home/melodies-ist/data/ISD/INPUT/AOI/"
AOI.sub<-readOGR(paste(ZDIR,sep = ""),"AOI1")
ISD<-rD3
isd.sub <- crop(ISD, extent(AOI.sub))
isd.sub <- mask(isd.sub, AOI.sub)

writeRaster(isd.sub,paste(ADIR, '/' ,'ISDmeanDx001.tif',sep = ""),overwrite=TRUE)

## Using the OGR KML driver
## writeOGR(Dx00101, dsn="ISDvarDx001.kml", layer= "Dx001", driver="KML", dataset_options=c("NameField=name"))

EOF
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
# gdalwarp -cutline $DIR/AOI/AOI1.shp $ISDD/ISDvarDx001.tif

#for file in $LDIR/ISD*Dx001.tif; do 
#   filename=$(basename $file) 
#   pkcrop -nodata -ot Int16 -e $DIR/melodies.shp -m -i $file -o  melodies$filename
#   ciop.publish(melodies$filename)
#done

echo "DONE"
exit 0
