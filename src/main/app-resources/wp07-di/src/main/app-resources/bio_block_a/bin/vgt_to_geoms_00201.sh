#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Local soil status [S(x)]
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
#-------------------------------------------------------------------------------------#
# JOB000
#-------------------------------------------------------------------------------------#
export PATH=/opt/anaconda/bin/:$PATH
export -p DIR=$TMPDIR/data/outDIR/ISD
export -p INDIR=$DIR/INPUT

export -p IDIR=/application/
echo $IDIR

export -p OUTDIR=$DIR/ISD000
export -p LAND001=$OUTDIR/VITO/

export -p CDIR=$OUTDIR/SM001
export -p SBDIR=$OUTDIR/SM001/class_SOIL001/

export -p SBDIR1=$OUTDIR/SM001/class_SOIL001/soil_mosaic
export -p VDIR=$OUTDIR/SM001
export -p ISD5_Nx=$IDIR/parameters/

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# JOB# resample LULC para o mesmo pixel scale do target (SPOT or PROBA-V)
#-------------------------------------------------------------------------------------#
cd $SBDIR

mkdir soil_mosaic

export PATH=/opt/anaconda/bin/:$PATH

for ((nr=1 ; nr<=9 ; nr++)); do
filename=$(basename 0$nr)
echo $filename
ls *${filename}.tif > list_${filename}.txt
gdalbuildvrt soil_mosaic/SOIL_Mosaic_${filename}.vrt --optfile list_${filename}.txt
gdal_translate soil_mosaic/SOIL_Mosaic_${filename}.vrt soil_mosaic/SOIL_Mosaic2_${filename}.tif
done


for ((nr=10 ; nr<=11 ; nr++)); do
filename=$(basename $nr)
echo $filename
ls *${filename}.tif > list_${filename}.txt
gdalbuildvrt soil_mosaic/SOIL_Mosaic_${filename}.vrt --optfile list_${filename}.txt
gdal_translate soil_mosaic/SOIL_Mosaic_${filename}.vrt soil_mosaic/SOIL_Mosaic2_${filename}.tif
done

#-------------------------------------------------------------------------------------#
# calculo das medias por classe, normalização
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  --min-vsize=10M --min-nsize=500k <<'EOF'

# set working directory
INDIR = Sys.getenv(c('SBDIR1'))
OUTDIR = Sys.getenv(c('ISD5_Nx'))
setwd(INDIR)

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)


# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files

#print(j)

list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("SOIL_Mosaic2_",".*\\.tif",sep="")))
list.filenames

for (j in 2:7){ 
class_2<-raster(list.filenames[j])
# set NA values to -9999
#fun <- function(x) { x[is.na(x)] <- -9999; return(x)} 
#rc3 <- calc(rc2, fun)

class_2[class_2<0]<-NA
class_02<-as.matrix(class_2)/10000
bps <- boxplot.stats(class_02) 

ISD_LSD=bps$stats[1] #lower wisker
#write.table(ISD_LSD,paste(path=OUTDIR,'/' ,'ISD_LSDSx_','_'j,'.txt',sep = ""),row.names = FALSE, col.names =  FALSE, quote = FALSE, append = FALSE) 
print(ISD_LSD)

ISD_HSD=bps$stats[5] #upper wisker 
#write.table(ISD_HSD,paste(path=OUTDIR,'/' ,'ISD_HSDSx_',j,'.txt',sep = ""),row.names = FALSE, col.names =  FALSE, quote = FALSE, append = FALSE) 
print(ISD_HSD)

##component=='Soil'

x_2<-class_2/10000
x_2[x_2<0]<-NA
x_2[x_2>ISD_HSD]<-NA
x_2[x_2<ISD_LSD]<-NA
 
summary(x_2)
r=(x_2-ISD_LSD)/(ISD_HSD-ISD_LSD)

n00<-unlist(strsplit(list.filenames[j], "_1_"))
n01<-n00[2]
n02<-unlist(strsplit(n01,"."))
writeRaster(r, filename=paste("Sr_HSLS_0",j, sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)

summary(r)

}

list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("SOIL",".*\\.tif",sep="")))
list.filenames

Sr_HSLS_1<-raster("SOIL_Mosaic2_01.tif")
Sr_HSLS_1[Sr_HSLS_1==5000]<-0.5
Sr_HSLS_1[Sr_HSLS_1!=5000]<-NA
writeRaster(Sr_HSLS_1, filename=paste("Sr_HSLS_01",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)

Sr_HSLS_8<-raster("SOIL_Mosaic2_08.tif")
Sr_HSLS_8[Sr_HSLS_8==10000]<-1
Sr_HSLS_8[Sr_HSLS_8!=10000]<-NA
writeRaster(Sr_HSLS_8, filename=paste("Sr_HSLS_08",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)

Sr_HSLS_9<-raster("SOIL_Mosaic2_09.tif")
Sr_HSLS_9[Sr_HSLS_9==10000]<-1
Sr_HSLS_9[Sr_HSLS_9!=10000]<-NA
writeRaster(Sr_HSLS_9, filename=paste("Sr_HSLS_09",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)

Sr_HSLS_10<-raster("SOIL_Mosaic2_10.tif")
Sr_HSLS_10[Sr_HSLS_10==1]<-0
Sr_HSLS_10[Sr_HSLS_10!=1]<-NA
writeRaster(Sr_HSLS_10, filename=paste("Sr_HSLS_10",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)

Sr_HSLS_11<-raster("SOIL_Mosaic2_11.tif")
Sr_HSLS_11[Sr_HSLS_11==1]<-0
Sr_HSLS_11[Sr_HSLS_11!=1]<-NA
writeRaster(Sr_HSLS_11, filename=paste("Sr_HSLS_11",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
EOF
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# # calculo das medias das classes, normalização 
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

# set working directory
INDIR = Sys.getenv(c('SBDIR1'))
VDIR = Sys.getenv(c('SBDIR1'))
setwd(INDIR)

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)

# list all files from the current directory

list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("Sr_HSLS",".*\\.tif",sep="")))
list.filenames 

# create a list from these files
for (j in 1:length(list.filenames)){ 

# load raster data 
rstack001<-stack(raster(list.filenames[1]),
raster(list.filenames[2]),raster(list.filenames[3]),raster(list.filenames[4]),raster(list.filenames[5]),
raster(list.filenames[6]),raster(list.filenames[7]),raster(list.filenames[8]),raster(list.filenames[9]),
raster(list.filenames[10]),raster(list.filenames[11]))
#rastD6<-sum(rstack001, na.rm=TRUE)
rastD6<-max(rstack001, na.rm=TRUE)
summary(rastD6)
writeRaster(rastD6, filename=paste("Sx001_",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
}

EOF
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
rciop.publish(paste("Sx001_",".tif", sep=""), recursive=FALSE, metalink=TRUE)

export -p CDIR=$OUTDIR/SM001
export -p SBDIR=$CDIR/class_SOIL001/soil_mosaic

cp $SBDIR/Sx001_.tif $CDIR/Sx001_.tif
#rm -rf $SBDIR

echo "DONE"
exit 0
#-------------------------------------------------------------------------------------#