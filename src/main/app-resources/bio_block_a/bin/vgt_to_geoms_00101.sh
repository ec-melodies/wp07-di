#!/bin/sh
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
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
# # bash /application/bin/ISD5_node/ini.sh
export PATH=/opt/anaconda/bin/:$PATH
export -p DIR=/data/auxdata/ISD/
export -p INDIR=$DIR/INPUT

export -p OUTDIR=$DIR/ISD000
export -p LAND001=$OUTDIR/VITO/
export -p VDIR=$OUTDIR/VM001
export -p NVDIR=$OUTDIR/VM001/class_NDV001/

export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
cd $OUTDIR/VM001/class_NDV001

mkdir ndv_mosaic

export PATH=/opt/anaconda/bin/:$PATH

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

export -p VDIR=$OUTDIR/VM001
export -p NVDIR=$OUTDIR/VM001/class_NDV001/ndv_mosaic
export -p ISD5_Nx=~/wp07-di/src/main/app-resources/parameters/

#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

# set working directory
INDIR = Sys.getenv(c('NVDIR'))
OUTDIR = Sys.getenv(c('ISD5_Nx'))

setwd(INDIR)

require(sp)
require(rgdal)
require(raster)
require(rciop)


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
#write.table(ISD_HSD,paste(path=OUTDIR,'/' ,'ISD_HSD_',j,'.txt',sep = ""),row.names = FALSE, col.names =  FALSE, quote = FALSE, append = FALSE) 
print(ISD_HSD)
ISD_LSD=bps$stats[5] #upper wisker 
#write.table(ISD_LSD,paste(path=OUTDIR,'/' ,'ISD_LSD_',j,'.txt',sep = ""),row.names = FALSE, col.names =  FALSE, quote = FALSE, append = FALSE) 
print(ISD_LSD)

##component=='vegetation'

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


#-------------------------------------------------------------------------------------#
# # calculo do NDVI por classe, normalização 
#1 = 1 Territórios artificializados		
#2 = 2 Agricultura de sequeiro		
#3 = 3 Agricultura de regadio		
#4 = 4 Florestas		
#5 = 5 Matos		
#6 = 6 Vegetação herbácea natural		
#7 = 7 Vegetação esparsa		
#8 = 8 Áreas ardidas		
#9 = 9 Praias, Dunas, Areais e Rocha Nua		
#10 =10  Zonas Húmidas		
#11 =11 Corpos de Água		
#	= NULL
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

# set working directory
INDIR = Sys.getenv(c('NVDIR'))
OUTDIR = Sys.getenv(c('ISD5_Nx'))

VDIR = Sys.getenv(c('VDIR'))
setwd(INDIR)

require(sp)
require(rgdal)
require(raster)
require(rciop)

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
rastD6<-sum(rstack001, na.rm=TRUE)
summary(rastD6)
writeRaster(rastD6, filename=paste("Vx001_",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#}
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
# Vx001 <- rciop.publish(rastD6, recursive=FALSE, metalink=TRUE)
EOF

cp $NVDIR/Vx001_.tif $VDIR/Vx001_.tif

today=$(date)
echo "The date and time are: " $today
#-------------------------------------------------------------------------------------# 
echo "DONE"
echo 0