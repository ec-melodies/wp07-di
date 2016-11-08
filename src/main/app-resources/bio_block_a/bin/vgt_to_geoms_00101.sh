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
export -p IDIR=/application/
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VDIR=$OUTDIR/VM001
export -p NVDIR=$VDIR/class_NDV001 
export -p NVDIR1=$NVDIR/ndv_msc && mkdir -pm 777 $NVDIR1
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
gdalbuildvrt ndv_msc/NDV_Mosaic_${filename}.vrt --optfile list_${filename}.txt
gdal_translate ndv_msc/NDV_Mosaic_${filename}.vrt ndv_msc/NDV_Mosaic2_${filename}.tif
done

for ((nr=10 ; nr<=11 ; nr++)); do
filename=$(basename $nr)
echo $filename
ls *${filename}.tif > list_${filename}.txt
gdalbuildvrt ndv_msc/NDV_Mosaic_${filename}.vrt --optfile list_${filename}.txt
gdal_translate ndv_msc/NDV_Mosaic_${filename}.vrt ndv_msc/NDV_Mosaic2_${filename}.tif
done

for file in $SBDIR/LANDC01*.tif ; do
rm $file 
done

for file in $SBDIR/Sr_LANDC01*.tif ; do
rm $file 
done
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

# set working directory
INDIR = Sys.getenv(c('NVDIR1'))
AOI = Sys.getenv(c('AOI'))
setwd(INDIR)
getwd()

load("/application/parameters/WSP.RData")
xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal",
"uuid", "RColorBrewer", "colorRamps", "rasterVis", "RStoolbox")
lapply(xlist, library, character.only = TRUE)


# list all files from the current directory
list.files(pattern=".tif$")

 
# create a list from these files
list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("NDV_Mosaic2_",".*\\.tif",sep="")))
list.filenames

for (j in 2:7){ 

print(j)
class_2<-raster(list.filenames[j])
class_2[class_2<0]<-NA
class_02<-as.matrix(class_2)
bps <- boxplot.stats(class_02) 
#print(boxplot(class_02)$stats[c(1, 5), ])
#-------------------------------------------------------------------------------------#
if(AOI == "AOI1"){
	ISD_HSD<-list(C02=260, C03=1068.89, C04=2515.56, C05=422.22, C06=491.11, C07=95.56)
	ISD_LSD<-list(C02=8300, C03=7817.78, C04=9248.89, C05=7520, C06=8522.22, C07=6162.22)
   	print(list.filenames[j])
    	ISD_LSD=ISD_LSD[j-1]
 	ISD_HSD=ISD_HSD[j-1]
 	print(ISD_HSD)
 	print(ISD_LSD)

} else if(AOI == "AOI2") {
 	ISD_HSD<-list(C02=522.22, C03=586.67, C04=1464.44, C05=51.11, C06=942.22, C07=757.78)
   	ISD_LSD<-list(C02=4237.78, C03=2642.22, C04=8795.56, C05=5837.78, C06=5566.67, C07=2460)
   	print(list.filenames[j])
    	ISD_LSD=ISD_LSD[j-1]
 	ISD_HSD=ISD_HSD[j-1]
 	print(ISD_HSD)
	print(ISD_LSD)	
	 	
} else if(AOI == "AOI3") {
 	ISD_HSD<-list(C02=1371.11, C03=2586.67, C04=795.56, C05=1315.56, C06=1104.44, C07=924.44)
   	ISD_LSD<-list(C02=8355.56, C03=3775.56, C04=6984.44, C05=4733.33, C06=3542.22, C07=2231.11)
   	print(list.filenames[j])
    	ISD_LSD=ISD_LSD[j-1]
 	ISD_HSD=ISD_HSD[j-1]
 	print(ISD_HSD)
	print(ISD_LSD)	
	 
} else if(AOI == "AOI4") {
 	ISD_HSD<-list(C02=112.94, C03=2569.41, C04=2237.65, C05=110.59, C06=185.88, C07=303.53)
   	ISD_LSD<-list(C02=7192.94, C03=7555.29, C04=9237.65, C05=6625.88, C06=7162.35, C07=4007.06)
   	print(list.filenames[j])
    	ISD_LSD=ISD_LSD[j-1]
 	ISD_HSD=ISD_HSD[j-1]
 	print(ISD_HSD)
	print(ISD_LSD)	
	
} else {
	ISD_HSD=bps$stats[1] #lower wisker
	print(ISD_HSD)
 	ISD_LSD=bps$stats[5] #upper wisker 
 	print(ISD_LSD)
 	print("out")
}

#-------------------------------------------------------------------------------------#
#component=='vegetation'

class_2[class_2<0]<-NA
summary(class_2)

#HS
class_2HS<-class_2
class_2HS[class_2HS<as.numeric(ISD_HSD)]<-10000
class_2HS[class_2HS>as.numeric(ISD_HSD)]<-NA
summary(class_2HS)

class_2LS<-class_2
class_2LS[class_2LS>as.numeric(ISD_LSD)]<-0
class_2LS[class_2LS<as.numeric(ISD_LSD)]<-NA
summary(class_2LS)

class_2HSLS<-class_2
class_2HSLS[class_2HSLS>as.numeric(ISD_LSD)]<-NA
class_2HSLS[class_2HSLS<as.numeric(ISD_HSD)]<-NA
summary(class_2HSLS)

r= (as.numeric(ISD_LSD)-class_2HSLS)/(as.numeric(ISD_LSD)-as.numeric(ISD_HSD))
writeRaster(r, filename=paste("Nr_HSLS_0",j, sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#writeRaster(r, filename=paste("NrHSLS_",j,".grd", sep=""), bandorder='BIL', overwrite=TRUE, na.rm=TRUE)

file.remove(list.filenames[j])
}

#-------------------------------------------------------------------------------------#

list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("Mosaic",".*\\.tif",sep="")))
list.filenames

for (j in list.files(pattern="c2_01.tif")){ 
print(j)
class_2<-raster(j)
Nr_HSLS_1<-raster(class_2)
Nr_HSLS_1[Nr_HSLS_1==5000]=0.5
Nr_HSLS_1[Nr_HSLS_1!=5000]=NA
writeRaster(Nr_HSLS_1, filename=paste("Nr_HSLS_01", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#writeRaster(Nr_HSLS_1, filename=paste("Nr_HSLS_",".grd", sep=""), bandorder='BIL', overwrite=TRUE, na.rm=TRUE)
l1=grep(paste(pattern="c2_01.tif"),list.filenames, perl=TRUE, value=TRUE)
l1
file.remove(l1)
}

for (j in list.files(pattern="c2_08.tif")){ 
print(j)
class_2<-raster(j)
Nr_HSLS_8<-raster(class_2)
Nr_HSLS_8[Nr_HSLS_8==10000]=1
Nr_HSLS_8[Nr_HSLS_8!=10000]=NA
writeRaster(Nr_HSLS_8, filename=paste("Nr_HSLS_08", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#writeRaster(Nr_HSLS_8, filename=paste("Nr_HSLS_",".grd", sep=""), bandorder='BIL', overwrite=TRUE, na.rm=TRUE)
l1=grep(paste(pattern="c2_08.tif"),list.filenames, perl=TRUE, value=TRUE)
l1
file.remove(l1)

}

for (j in list.files(pattern="c2_09.tif")){ 
print(j)
class_2<-raster(j)
Nr_HSLS_9<-raster(class_2)
Nr_HSLS_9[Nr_HSLS_9==10000]=1
Nr_HSLS_9[Nr_HSLS_9!=10000]=NA
writeRaster(Nr_HSLS_9, filename=paste("Nr_HSLS_09", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#writeRaster(Nr_HSLS_9, filename=paste("Nr_HSLS_",".grd", sep=""), bandorder='BIL', overwrite=TRUE, na.rm=TRUE)
l1=grep(paste(pattern="c2_09.tif"),list.filenames, perl=TRUE, value=TRUE)
l1
file.remove(l1)
}

for (j in list.files(pattern="c2_10.tif")){ 
print(j)
class_2<-raster(j)
Nr_HSLS_10<-raster(class_2)
Nr_HSLS_10[Nr_HSLS_10==1]=0
Nr_HSLS_10[Nr_HSLS_10!=1]=NA
writeRaster(Nr_HSLS_10, filename=paste("Nr_HSLS_10", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#writeRaster(Nr_HSLS_10, filename=paste("Nr_HSLS_",".grd", sep=""), bandorder='BIL', overwrite=TRUE, na.rm=TRUE)
l1=grep(paste(pattern="c2_10.tif"),list.filenames, perl=TRUE, value=TRUE)
l1
file.remove(l1)
}

for (j in list.files(pattern="c2_11.tif")){ 
print(j)
class_2<-raster(j)
Nr_HSLS_11<-raster(class_2)
Nr_HSLS_11[Nr_HSLS_11==1]=0
Nr_HSLS_11[Nr_HSLS_11!=1]=NA
writeRaster(Nr_HSLS_11, filename=paste("Nr_HSLS_11", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#writeRaster(Nr_HSLS_11, filename=paste("Nr_HSLS_11",".grd", sep=""), bandorder='BIL', overwrite=TRUE, na.rm=TRUE)
l1=grep(paste(pattern="c2_11.tif"),list.filenames, perl=TRUE, value=TRUE)
l1
file.remove(l1)
}

EOF
#-------------------------------------------------------------------------------------#

for file in $NVDIR1/NDV_Mosaic* ; do
rm $file
done


for file in $NVDIR/Nr_LANDC01*.tif; do
echo $file
rm $file
done

for file in $NVDIR/LANDC01*.tif; do
echo $file
rm $file
done
#-------------------------------------------------------------------------------------#
export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VDIR=$OUTDIR/VM001
#-------------------------------------------------------------------------------------#
# Samples
#-------------------------------------------------------------------------------------#
export -p CRS32662=$2
echo $CRS32662
#Year
export -p Y2=$1
echo $Y2

export -p C2=$IDIR/parameters/CRS32662_01.txt
export -p C1=$(cat IDIR/parameters/CRS32662.txt ); echo "$C1"
#-------------------------------------------------------------------------------------# 
if [[ $CRS32662 == AOI1 ]] ; then
	export -p CRS326620=$(grep AOI1 $C2);

elif [[ $CRS32662 == AOI2 ]] ; then
	export -p CRS326620=$(grep AOI2 $C2);

elif [[ $CRS32662 == AOI3 ]] ; then
	export -p CRS326620=$(grep AOI3 $C2);

elif [[ $CRS32662 == AOI4 ]] ; then 
	export -p CRS326620=$(grep AOI4 $C2);
else
	echo "AOI out of range"
fi 

#-------------------------------------------------------------------------------------#
VDIR=/data/outDIR/ISD/ISD000/VM001/class_NDV001/ndv_msc

for file in $VDIR/Nr_HSLS* ; do
export -p COUNT=0
filename=$(basename $file .tif )
echo $file
# Get the same boundary information_globcover
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $VDIR/${filename}.tif  $VDIR/${filename}_crop_$COUNT.tif
done < $CRS326620
rm $file
done

#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

# set working directory
INDIR = Sys.getenv(c('NVDIR1'))
VDIR = Sys.getenv(c('NVDIR1'))
LINE1 = Sys.getenv(c('CRS326620'))
IDIR="/data/outDIR/ISD/ISD000/VM001"
setwd(INDIR)

load("/application/parameters/WSP.RData")
xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal",
"uuid", "RColorBrewer", "colorRamps", "rasterVis", "RStoolbox")
lapply(xlist, library, character.only = TRUE)

# load raster data  
list.filenames0=assign(paste("list.filenames",sep=""),list.files(pattern=paste("Nr",".*\\.tif",sep="")))
list.filenames0

recMax <- function(x00){
	recMax0=max(x00, na.rm=TRUE)
	return(recMax0)}

con <- file(LINE1)
lentxt<-length(readLines(con))
close(con)
rm(LINE1)
rm(con)

for (i in 1:lentxt){ 
print(i)
list.filename=assign(paste("normndv",i,sep=""),grep(paste("crop_",i,".tif",sep=""),list.filenames0, perl=TRUE, value=TRUE))
print(list.filename)
}

normnd=mixedsort(ls(pattern="normndv"))
normnd 

for (i in 1:length(normnd)){ 
print(i)
rstack001<-stack(raster(get(normnd[i])[1]),
raster(get(normnd[i])[2]),raster(get(normnd[i])[3]),raster(get(normnd[i])[4]),raster(get(normnd[i])[5]),raster(get(normnd[i])[6]),raster(get(normnd[i])[7]),
raster(get(normnd[i])[8]),raster(get(normnd[i])[9]),raster(get(normnd[i])[10]),raster(get(normnd[i])[11]))
assign(paste("rstack001_",i,sep=""),rstack001)
rstack001
rm(rstack001)
}

rstack002 = mixedsort(ls(pattern="rstack001_"))
rstack002

#file.remove(list.filenames1)
#file.remove(list.filenames2)


for (i in 1:length(rstack002)){ 
rastD6 <- calc(get(rstack002[i]),fun=recMax)
writeRaster(rastD6, filename=paste(IDIR,"/","Vx001__crop_",i,".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
rm(rastD6)
l1=grep(paste("crop_",i,".tif",sep=""),list.filenames, perl=TRUE, value=TRUE)
l1
file.remove(l1)
}

file.remove(list.filenames0)

EOF

#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
for file in $NVDIR1/*.tif ; do
mv $file $OUTDIR/VM001
done

rm -rf $NVDIR

today=$(date)
echo "The date and time are: " $today

ciop-log "INFO" "vgt_to_geoms_00101.sh"
#-------------------------------------------------------------------------------------# 
echo "DONE"
echo 0