#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: Local vegetation status [V(x)]
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
export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application/
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VDIR=$OUTDIR/VM001
export -p NVDIR=$VDIR/class_NDV001 
export -p NVDIR1=$NVDIR/ndv_mosaic && mkdir -pm 777 $NVDIR1
#-------------------------------------------------------------------------------------#
#Area of interesse
export -p AOI=$2
echo $AOI

#Year
export -p Y2=$1
echo $Y2

#-------------------------------------------------------------------------------------#
cd $NVDIR

for ((nr=1 ; nr<=9 ; nr++)); do
filename=$(basename 0$nr)
echo $filename
ls *${filename}.tif > list_${filename}.txt
gdalbuildvrt ndv_mosaic/NDV_Mosaic_${filename}.vrt --optfile list_${filename}.txt
gdal_translate ndv_mosaic/NDV_Mosaic_${filename}.vrt ndv_mosaic/NDV_Mosaic2_${filename}.tif
done

for ((nr=10 ; nr<=11 ; nr++)); do
filename=$(basename $nr)
echo $filename
ls *${filename}.tif > list_${filename}.txt
gdalbuildvrt ndv_mosaic/NDV_Mosaic_${filename}.vrt --optfile list_${filename}.txt
gdal_translate ndv_mosaic/NDV_Mosaic_${filename}.vrt ndv_mosaic/NDV_Mosaic2_${filename}.tif
done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

# set working directory
INDIR = Sys.getenv(c('NVDIR1'))

setwd(INDIR)
getwd()

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)

# list all files from the current directory
list.files(pattern=".tif$")

 
# create a list from these files
list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("NDV_Mosaic2_",".*\\.tif",sep="")))
list.filenames

for (j in list.filenames[2:7]){ 

print(j)

class_2<-raster(j)
class_2[class_2<0]<-NA

class_02<-as.matrix(class_2)
bps <- boxplot.stats(class_02) 
#print(boxplot(class_02)$stats[c(1, 5), ])
ISD_HSD=bps$stats[1] #lower wisker
print(ISD_HSD)
ISD_LSD=bps$stats[5] #upper wisker 
print(ISD_LSD)

#component=='vegetation'

class_2<-raster(j)
class_2[class_2<0]<-NA
summary(class_2)

#HS
class_2HS<-class_2
class_2HS[class_2HS<ISD_HSD]<-10000
class_2HS[class_2HS>ISD_HSD]<-NA
summary(class_2HS)

class_2LS<-class_2
class_2LS[class_2LS>ISD_LSD]<-0
class_2LS[class_2LS<ISD_LSD]<-NA
summary(class_2LS)

class_2HSLS<-class_2
class_2HSLS[class_2HSLS>ISD_LSD]<-NA
class_2HSLS[class_2HSLS<ISD_HSD]<-NA
summary(class_2HSLS)

r= (ISD_LSD-class_2HSLS)/(ISD_LSD-ISD_HSD)
writeRaster(r, filename=paste("NrHSLS_",j, sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
}

#-------------------------------------------------------------------------------------#

list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("Nr_LA",".*\\.tif",sep="")))
list.filenames

for (j in list.files(pattern="c2_01.tif")){ 
print(j)
class_2<-raster(j)
Nr_HSLS_1<-raster(class_2)
Nr_HSLS_1[Nr_HSLS_1==5000]=0.5
Nr_HSLS_1[Nr_HSLS_1!=5000]=NA
writeRaster(Nr_HSLS_1, filename=paste("NrHSLS_",j, sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
}

for (j in list.files(pattern="c2_08.tif")){ 
print(j)
class_2<-raster(j)
Nr_HSLS_8<-raster(class_2)
Nr_HSLS_8[Nr_HSLS_8==10000]<-1
Nr_HSLS_8[Nr_HSLS_8!=10000]<-NA
writeRaster(Nr_HSLS_8, filename=paste("NrHSLS_",j, sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
}

for (j in list.files(pattern="c2_09.tif")){ 
print(j)
class_2<-raster(j)
Nr_HSLS_9<-raster(class_2)
Nr_HSLS_9[Nr_HSLS_9==10000]<-1
Nr_HSLS_9[Nr_HSLS_9!=10000]<-NA
writeRaster(Nr_HSLS_9, filename=paste("NrHSLS_",j, sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
}

for (j in list.files(pattern="c2_10.tif")){ 
print(j)
class_2<-raster(j)
Nr_HSLS_10<-raster(class_2)
Nr_HSLS_10[Nr_HSLS_10==1]<-0
Nr_HSLS_10[Nr_HSLS_10!=1]<-NA
writeRaster(Nr_HSLS_10, filename=paste("NrHSLS_",j, sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
}

for (j in list.files(pattern="c2_11.tif")){ 
print(j)
class_2<-raster(j)
Nr_HSLS_11<-raster(class_2)
Nr_HSLS_11[Nr_HSLS_11==1]<-0
Nr_HSLS_11[Nr_HSLS_11!=1]<-NA
writeRaster(Nr_HSLS_11, filename=paste("NrHSLS_",j, sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
}

EOF
#-------------------------------------------------------------------------------------#
# # calculo das medias das classes, normalização 
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

# set working directory
INDIR = Sys.getenv(c('NVDIR1'))
VDIR = Sys.getenv(c('NVDIR1'))
setwd(INDIR)

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)

# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
#for (j in 1:4){ 
#print(j)
list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("NrHSLS_NDV_",".*\\.tif",sep="")))
list.filenames
# load raster data 

rstack001<-stack(raster(list.filenames[1]),
raster(list.filenames[2]),raster(list.filenames[3]),raster(list.filenames[4]),
raster(list.filenames[5]),raster(list.filenames[6]),raster(list.filenames[7]),
raster(list.filenames[8]),raster(list.filenames[9]),raster(list.filenames[10]),
raster(list.filenames[11]))

rastD6<-max(rstack001, na.rm=TRUE)

summary(rastD6)
writeRaster(rastD6, filename=paste("Vx001_",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#}
EOF

#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 

cp $NVDIR1/Vx001_.tif $VDIR/Vx001_.tif
#rm -rf $NVDIR

today=$(date)
echo "The date and time are: " $today

ciop-log "INFO" "vgt_to_geoms_00101.sh"
#-------------------------------------------------------------------------------------# 
echo "DONE"
echo 0