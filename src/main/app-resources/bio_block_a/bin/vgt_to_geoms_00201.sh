#!/bin/bash
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
# JOB000
#-------------------------------------------------------------------------------------#
export -p IDIR=/application/
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p CDIR=$OUTDIR/SM001
export -p SBDIR=$OUTDIR/SM001/class_SOIL001
export -p SBDIR1=$SBDIR/soil_msc && mkdir -pm 777 $SBDIR1
#-------------------------------------------------------------------------------------#
#Area of interesse
export -p AOI=$2
echo $AOI

#Year
export -p Y2=$1
echo $Y2
#-------------------------------------------------------------------------------------#
# JOB# resample LULC para o mesmo pixel scale do target (SPOT or PROBA-V)
#-------------------------------------------------------------------------------------#
cd $SBDIR

for ((nr=1 ; nr<=9 ; nr++)); do
filename=$(basename 0$nr)
echo $filename
ls *${filename}.tif > list_${filename}.txt
gdalbuildvrt soil_msc/SOIL_Mosaic_${filename}.vrt --optfile list_${filename}.txt
gdal_translate soil_msc/SOIL_Mosaic_${filename}.vrt soil_msc/SOIL_Mosaic2_${filename}.tif
done


for ((nr=10 ; nr<=11 ; nr++)); do
filename=$(basename $nr)
echo $filename
ls *${filename}.tif > list_${filename}.txt
gdalbuildvrt soil_msc/SOIL_Mosaic_${filename}.vrt --optfile list_${filename}.txt
gdal_translate soil_msc/SOIL_Mosaic_${filename}.vrt soil_msc/SOIL_Mosaic2_${filename}.tif
done

for file in $SBDIR/LANDC01* ; do
rm $file 
done

for file in $SBDIR/Sr_LANDC01*.tif ; do
rm $file 
done

#-------------------------------------------------------------------------------------#
# calculo das medias por classe, normalização
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  --min-vsize=10M --min-nsize=500k <<'EOF'

# set working directory
INDIR = Sys.getenv(c('SBDIR1'))
AOI = Sys.getenv(c('AOI'))
setwd(INDIR)
print(AOI)

load("/application/parameters/WSP.RData")
xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal",
"uuid", "RColorBrewer", "colorRamps", "rasterVis", "RStoolbox")
lapply(xlist, library, character.only = TRUE)

# create a list from these files
list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("SOIL_Mosaic2_",".*\\.tif",sep="")))
list.filenames

reclass_function = function(rs){
r=(rs-as.numeric(ISD_LSD))/(as.numeric(ISD_HSD)-as.numeric(ISD_LSD))
return(r)}

for (j in 2:7){ 
class_2<-raster(list.filenames[j])
class_2[class_2<0]<-NA

class_02<-as.matrix(class_2)/10000
bps <- boxplot.stats(class_02) 
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
if(AOI == "AOI1"){
	ISD_LSD<-list(C02=0.087260689, C03=0.113294896, C04=0.064980925, C05=0.066434902, C06=0.077951811, C07=0.058443751)
	ISD_HSD<-list(C02=0.278400083, C03=0.279439361, C04=0.232853717, C05=0.250524067, C06=0.248077067, C07=0.336479144)
        print(list.filenames[j])
        ISD_LSD=ISD_LSD[j-1]
	ISD_HSD=ISD_HSD[j-1]
	print(ISD_LSD)
	print(ISD_HSD)

} else if(AOI == "AOI2") {
	ISD_LSD<-list(C02=0.080578431, C03=0.148385607, C04=0.069970159, C05=0.052158967, C06=0.068822911, C07=0.098748828)
	ISD_HSD<-list(C02=0.297262694, C03=0.3578117, C04=0.2140101, C05=0.296167311, C06=0.235968256, C07=0.4156091)
        print(list.filenames[j])
        ISD_LSD=ISD_LSD[j-1]
	ISD_HSD=ISD_HSD[j-1]
	print(ISD_LSD)
	print(ISD_HSD)
	 	
} else if(AOI == "AOI3") {
	ISD_LSD<-list(C02=0.072857473, C03=0.108865903, C04=0.079700038, C05=0.077504083, C06=0.068288342, C07=0.078351502)
	ISD_HSD<-list(C02=0.297262694, C03=0.132699931, C04=0.207590522, C05=0.23018375, C06=0.303430189, C07=0.279692239)
        print(list.filenames[j])
        ISD_LSD=ISD_LSD[j-1]
	ISD_HSD=ISD_HSD[j-1]
	print(ISD_LSD)
	print(ISD_HSD)

} else if(AOI == "AOI4") {
	ISD_LSD<-list(C02=0.083670249, C03=0.124212959, C04=0.055015914, C05=0.068408416, C06=0.077681208, C07=0.069858129)
	ISD_HSD<-list(C02=0.300135071, C03=0.282531341, C04=0.249363859, C05=0.276675471, C06=0.254663918, C07=0.369680782)
        
	print(list.filenames[j])
        ISD_LSD=ISD_LSD[j-1]
	ISD_HSD=ISD_HSD[j-1]

	print(ISD_LSD)
	print(ISD_HSD)	
		
} else {
        ISD_LSD=bps$stats[1] #lower wisker
        print(ISD_LSD)

        ISD_HSD=bps$stats[5] #upper wisker 
        print(ISD_HSD)
}

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
##component=='Soil'

x_2<-class_2/10000
x_2[x_2<0]<-NA
x_2[x_2>as.numeric(ISD_HSD)]<-NA
x_2[x_2<as.numeric(ISD_LSD)]<-NA
 
r <- calc(x_2, fun=reclass_function)

writeRaster(r, filename=paste("Sr_HSLS_0",j, sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#writeRaster(r, filename=paste("Sr_HSLS_0",j,".grd", sep=""), bandorder='BIL', overwrite=TRUE, na.rm=TRUE)

file.remove(list.filenames[j])
}
#-------------------------------------------------------------------------------------#

list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("SOIL",".*\\.tif",sep="")))
list.filenames

Sr_HSLS_1<-raster("SOIL_Mosaic2_01.tif")
Sr_HSLS_1[Sr_HSLS_1==5000]=0.5
Sr_HSLS_1[Sr_HSLS_1!=5000]=NA
writeRaster(Sr_HSLS_1, filename=paste("Sr_HSLS_01",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#writeRaster(Sr_HSLS_1, filename=paste("Sr_HSLS_t1",".grd", sep=""), bandorder='BIL', overwrite=TRUE, na.rm=TRUE)
l1=grep(paste(pattern="c2_01.tif"),list.filenames, perl=TRUE, value=TRUE)
l1
file.remove(l1)

Sr_HSLS_8<-raster("SOIL_Mosaic2_08.tif")
Sr_HSLS_8[Sr_HSLS_8==10000]=1
Sr_HSLS_8[Sr_HSLS_8!=10000]=NA
writeRaster(Sr_HSLS_8, filename=paste("Sr_HSLS_08",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#writeRaster(Sr_HSLS_8, filename=paste("Sr_HSLS_08",".grd", sep=""), bandorder='BIL', overwrite=TRUE, na.rm=TRUE)
l1=grep(paste(pattern="c2_08.tif"),list.filenames, perl=TRUE, value=TRUE)
l1
file.remove(l1)

Sr_HSLS_9<-raster("SOIL_Mosaic2_09.tif")
Sr_HSLS_9[Sr_HSLS_9==10000]=1
Sr_HSLS_9[Sr_HSLS_9!=10000]=NA
writeRaster(Sr_HSLS_9, filename=paste("Sr_HSLS_09",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#writeRaster(Sr_HSLS_9, filename=paste("Sr_HSLS_09",".grd", sep=""), bandorder='BIL', overwrite=TRUE, na.rm=TRUE)
l1=grep(paste(pattern="c2_09.tif"),list.filenames, perl=TRUE, value=TRUE)
l1
file.remove(l1)

Sr_HSLS_10<-raster("SOIL_Mosaic2_10.tif")
Sr_HSLS_10[Sr_HSLS_10==1]=0
Sr_HSLS_10[Sr_HSLS_10!=1]=NA
writeRaster(Sr_HSLS_10, filename=paste("Sr_HSLS_10",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#writeRaster(Sr_HSLS_10, filename=paste("Sr_HSLS_10",".grd", sep=""), bandorder='BIL', overwrite=TRUE, na.rm=TRUE)
l1=grep(paste(pattern="c2_10.tif"),list.filenames, perl=TRUE, value=TRUE)
l1
file.remove(l1)

Sr_HSLS_11<-raster("SOIL_Mosaic2_11.tif")
Sr_HSLS_11[Sr_HSLS_11==1]=0
Sr_HSLS_11[Sr_HSLS_11!=1]=NA
writeRaster(Sr_HSLS_11, filename=paste("Sr_HSLS_11",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#writeRaster(Sr_HSLS_11, filename=paste("Sr_HSLS_11",".grd", sep=""), bandorder='BIL', overwrite=TRUE, na.rm=TRUE)
l1=grep(paste(pattern="c2_11.tif"),list.filenames, perl=TRUE, value=TRUE)
l1
file.remove(l1)


INDIR = Sys.getenv(c('SBDIR1'))
setwd(INDIR)


EOF

#-------------------------------------------------------------------------------------#
# # calculo das medias das classes, normalização 
#-------------------------------------------------------------------------------------#

for file in $SBDIR/SOIL_Mosaic2* ; do
echo $file
rm $file
done

#-------------------------------------------------------------------------------------#
export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p CDIR=$OUTDIR/SM001
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
export -p CRS32662=$AOI
echo $CRS32662

export -p C2=$IDIR/parameters/CRS32662_01.txt
export -p C1=$(cat $IDIR/parameters/CRS32662_01.txt ); echo "$C1"

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
echo $CRS326620
#-------------------------------------------------------------------------------------#
CDIR=/data/outDIR/ISD/ISD000/SM001/class_SOIL001/soil_msc

for file in $CDIR/Sr_HSLS* ; do
export -p COUNT=0
filename=$(basename $file .tif )
# Get the same boundary information_globcover
while read -r line; do
COUNT=$(( $COUNT + 1 ))
echo $line
echo $COUNT
gdal_translate -projwin $line -of GTiff $CDIR/${filename}.tif  $CDIR/${filename}_crop_$COUNT.tif 
done < $CRS326620
rm $file
done

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#

R --vanilla --no-readline   -q  <<'EOF'

# set working directory
INDIR = Sys.getenv(c('SBDIR1'))
VDIR = Sys.getenv(c('SBDIR1'))
LINE1 = Sys.getenv(c('CRS326620'))
IDIR = "/data/outDIR/ISD/ISD000/SM001"
setwd(INDIR)

load("/application/parameters/WSP.RData")
xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal",
"uuid", "RColorBrewer", "colorRamps", "rasterVis", "RStoolbox")
lapply(xlist, library, character.only = TRUE)

list.filenames=assign(paste("list.filenames",sep=""),mixedsort(list.files(pattern=paste("Sr_HSLS",".*\\.tif",sep=""))))
list.filenames 

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
list.filename=assign(paste("normndv",i,sep=""),grep(paste("crop_",i,".tif",sep=""),list.filenames, perl=TRUE, value=TRUE))
print(list.filename)
}

normnd =mixedsort(ls(pattern="normndv"))
normnd 

for (i in 1:length(normnd)){ 
print(i)
rstack001<-stack(raster(get(normnd[i])[1]),
raster(get(normnd[i])[2]),raster(get(normnd[i])[3]),raster(get(normnd[i])[4]),raster(get(normnd[i])[5]),raster(get(normnd[i])[6]),raster(get(normnd[i])[7]),
raster(get(normnd[i])[8]),raster(get(normnd[i])[9]),raster(get(normnd[i])[10]),raster(get(normnd[i])[11]))
assign(paste("rstack001_",i,sep=""),rstack001)
rm(rstack001)
}

rstack002 = mixedsort(ls(pattern="rstack001_"))
rstack002


#file.remove(list.filenames1)
#file.remove(list.filenames2)

for (i in 1:length(rstack002)){ 
rastD6 <- calc(get(rstack002[i]),fun=recMax)
writeRaster(rastD6, filename=paste(IDIR,"/", "Sx001__crop_",i,".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
rastD6
rm(rastD6)
l1=grep(paste("crop_",i,".tif",sep=""),list.filenames, perl=TRUE, value=TRUE)
l1
file.remove(l1)
}

file.remove(list.filenames)
EOF

#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 

for file in $SBDIR1/*.tif ; do
mv $file $OUTDIR/SM001
done

for file in $CDIR/SOIL_Mosaic2* ; do
echo $file
rm $file
done

rm -rf $SBDIR

ciop-log "INFO" "vgt_to_geoms_00201.sh"

echo "DONE"
exit 0
#-------------------------------------------------------------------------------------#