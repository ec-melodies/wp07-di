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
#wine64 /application/bin/ISD7_geoms/geoms.exe $HXDIR/ssdirCx.par


for file in $HXDIR/*crop.par; do 
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
R --vanilla --no-readline   -q  <<'EOF'
INDIR = Sys.getenv(c('LDIR'))
ZDIR = Sys.getenv(c('ISDC'))
ADIR = Sys.getenv(c('ISDC'))

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")
require("maptools")

setwd(INDIR)

# list all files from the current directory
list.files(pattern=".tif$")  
# create a list from these files
list.filenames<-list.files(pattern=paste("Bx001",".*\\.tif",sep=""))
list.filenames02<-list.files(pattern=".txt$")



# create a list from these files
for (j in 1:4)
{ 
print(j)
list.filenames=assign(paste("list.filenames_",j,sep=""),list.files(pattern=paste("Bx001_",j,".*\\_crop.tif",sep="")))
# load raster data 
file<-readGDAL(list.filenames)

head(file)

xy_sa=geometry(file)
xy<-data.frame(xy_sa)
z<- rep(0,dim(xy)[1])

setwd(ZDIR)

print(j)
list.filename=assign(paste("list.filenames_",j,sep=""),list.files(pattern=paste("ISDmean_ssdirCx_",j,".*\\crop.txt",sep="")))
file_out<-read.table(list.filename)
sdf01 <-cbind(xy, file_out)
write.table(sdf01,paste(path=ZDIR,'/','sdf01_',j,'.*\\crop.txt',sep = ""),  row.names = TRUE, col.names = TRUE)

Cx00101<-data.frame(sdf01)
coordinates(Cx00101)=~x+y
proj4string(Cx00101)=CRS("+init=epsg:4326") # set it to lat-long
Cx001 = spTransform(Cx00101,CRS("+init=epsg:4326"))
gridded(Cx00101) = TRUE
rD3 = raster(Cx00101)
projection(rD3) = CRS("+init=epsg:4326")

ZDIR="/home/melodies-ist/data/ISD/INPUT/AOI/"
AOI.sub<-readOGR(paste(ZDIR,sep = ""),"AOI1")
ISD<-rD3
isd.sub <- crop(ISD, extent(AOI.sub))
isd.sub <- mask(isd.sub, AOI.sub)
writeRaster(isd.sub,paste(ADIR, '/' ,'ISDmeanCx001',j,'.tif',sep = ""),overwrite=TRUE)
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