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
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
bash /application/bin/ISD5_node/ini.sh
export DIR=~/data/ISD/
export -p ISDC=$ZDIR/Cx
export -p HDIR=$DIR/scripts
export -p LDIR=$OUTDIR/COKC
export -p ADIR=$DIR/AOI
#-------------------------------------------------------------------------------------# 
bash $HDIR/vgt_to_geoms_004.sh
#wine64 /application/bin/ISD7_geoms/geoms.exe $LDIR/ssdirCx.par
wine64 $HDIR/geoms.exe $HDIR/ssdirCx.par
#-------------------------------------------------------------------------------------# 

awk 'NR > 3 { print }' $ISDC/ISD_Kriging_Variance.out > $ISDC/ISDvarCx001.txt
# awk 'NR > 3 { print }' $ZDIR/ISD_Cx_Krig_var.out > $ZDIR/ISDvarCx001.txt
#-------------------------------------------------------------------------------------# 
# .out file to Gtiff
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'
INDIR = Sys.getenv(c('LDIR'))
ZDIR = Sys.getenv(c('ISDC'))
ADIR = Sys.getenv(c('ADIR'))

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
list.filename<-list.files(pattern="Cx001.txt")
file_out<-read.table(list.filename)
sdf01 <-cbind(xy, file_out)
write.table(sdf01,paste(path=ZDIR,'/' ,'sdf01.txt',sep = ""),  row.names = TRUE, col.names = TRUE)

Cx00101<-data.frame(sdf01)
coordinates(Cx00101)=~x+y
proj4string(Cx00101)=CRS("+init=epsg:4326") # set it to lat-long
Cx001 = spTransform(Cx00101,CRS("+init=epsg:4326"))
gridded(Cx00101) = TRUE
rD3 = raster(Cx00101)
projection(rD3) = CRS("+init=epsg:4326")

AOI.sub<-readOGR(paste(ZDIR,sep = ""),"AOI1")
ISD<-rD3
isd.sub <- crop(ISD, extent(AOI.sub))
isd.sub <- mask(isd.sub, AOI.sub)

#writeRaster(isd.sub,paste(ZDIR, '/' ,'ISDvarCx001.tif',sep = ""),overwrite=TRUE)

#-------------------------------------------------------------------------------------#
## Using the OGR KML driver
## writeOGR(Cx00101, dsn="ISDvarCx001.kml", layer= "Cx001", driver="KML", dataset_options=c("NameField=name"))

EOF
#-------------------------------------------------------------------------------------# 

#pkcrop -nodata -ot Int16 -e $DIR/melodies.shp -m -i $file -o  melodies$filename
#ciop.publish(melodies$filename)

echo "DONE"
exit 0