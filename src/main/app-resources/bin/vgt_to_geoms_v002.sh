###CERENA

###Biophysics datasets
#Calcula a componente de vegetação V(x) reclassificando os valores de NDVI de acordo com as classes de Ocupação do Solo e valores de LSD e HSD;
#
###JOB#001_environment settings
export INDIR=/media/sf_geodata/Melodies/isd/test/test_datasets
export OUTDIR=/media/sf_geodata/Melodies/VM004
 
mkdir $OUTDIR

cd $OUTDIR


## Select Area: IOA1, IOA2a, IOA2b, IOA3 from climatic datasets
########################################################################NDVI
##JOB#002_resampling pixel
##data provider: 
## VITO >> wget -r --user=demouser --password=xxxx http://www.vito-eodata.be/PDF/datapool/Free_Data/PROBA-V_1km/S1_TOA_1km/2014/1/15/PV_S1_TOA-20140115_1KM_V002/?coord=...
## VITO: for file in *.tar.gz  ; do tar zxvf $file ; done
## VITO: gdal_translate HDF5 or HDF4 to Gtiff

#query: IOA1
input001=$INDIR/VITO/PV_S10_TOC_20140901_333M_V001_ib/*NDVI.tif

##data provider: 
#ESA >> http://due.esrin.esa.int/files/Globcover2009_V2.3_Global_.zip
#ESA: for file in *.tar.gz  ; do tar zxvf $file ; done
#ESA: reclass.sh
#CSW >> somewhere in the cloud

#query: IOA1
input002=$INDIR/globcover2009_ioa/IOA1/*reclassify.tif

z001="$(gdalinfo $input001 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"

###JOB#003 resample LULC para o mesmo pixel scale do target
gdalwarp -tr $z001 $z001 -r bilinear $input002 input002001.tif

###JOB#004 Get the same boundary information...crop
ulx=$(gdalinfo input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')

gdal_calc.py -A $input001 --outfile=input001000i.tif --calc="(((A*0.004)-0.08)*10000.0)" --overwrite --NoDataValue=255 --type=UInt32; 
pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i input001000i.tif -o input001002.tif

####JOB#005 Extrair as classes por land cover [1:11] e calc os valores de HSD and LSD
mkdir class_NDV001

for i in {1..11}; do  
gdal_calc.py -A input001002.tif -B input002001.tif --outfile=$OUTDIR/class_NDV001/input003001_0$i.tif --calc="(B==$i)*(A)" --overwrite --NoDataValue=0 --type=UInt32; 
#zLSD="$(oft-mm -um $OUTDIR/class_temp/input003001_$i.tif $OUTDIR/class_temp/input003001_$i.tif| grep "Band 1 min"|  awk '{ gsub ("[(),]","") ; print $5  }')"
echo $i
done

cd $OUTDIR/class_NDV001/
mv input003001_010.tif  input003001_10.tif
mv input003001_011.tif  input003001_11.tif
########calculo das medias das classes, normalização 
R --vanilla --no-readline   -q  <<'EOF'

#R version  3.2.1
# set working directory
INDIR = Sys.getenv(c('INDIR'))
OUTDIR = Sys.getenv(c('OUTDIR'))

#getwd()

require(sp)
require(rgdal)
require(raster)
    
# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
list.filenames<-list.files(pattern=".tif$")

# create a loop to read in your data
for (i in 1:length(list.filenames))
{
# load raster data 
rastD = raster(list.filenames[i])
rastDi = raster(list.filenames[i])
# calculate Mean
rastD[rastD <= 0] = -9999
rastDi[rastDi <= 0] = -9999
rastD3<-((rastD>-9999)*(rastD[]=(cellStats(brick(rastD), mean))))
rastD5<-(maxValue(rastDi)-rastD3)/(maxValue(rastDi)-minValue(rastDi))
print(i)
writeRaster(rastD5, filename=paste("st0",i,"_classNDV.tif", sep=""), format="GTiff", overwrite=TRUE)
}

EOF

#############integração................................Vx
R --vanilla --no-readline   -q  <<'EOF'

require(sp)
require(rgdal)
require(raster)
    
# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
list.filenames<-list.files(pattern="NDV.tif$")

# load raster data 

rstack001<-stack(raster(list.filenames[1]),
raster(list.filenames[2]),
raster(list.filenames[3]),
raster(list.filenames[4]),
raster(list.filenames[5]),
raster(list.filenames[6]),
raster(list.filenames[7]),
raster(list.filenames[8]),
raster(list.filenames[9]),
raster(list.filenames[10]),
raster(list.filenames[11]))
rastD6<-sum(rstack001, na.rm=TRUE)

writeRaster(rastD6, filename="Vx003.tif", format="GTiff", overwrite=TRUE)

EOF

cd ..
### ASCII to geoMS
#gdal_translate  -of AAIGrid Vx003.tif   Vx003.asc 
 
##############################################################################
#### JOBXX3

##############################################################SOIL BRIGHTNESS.......................................................

##JOB000_resampling pixel
export INDIR=/media/sf_geodata/Melodies/isd/test/test_datasets
export OUTDIR=/media/sf_geodata/Melodies/isd/test/test_datasets/VM004

input006=$INDIR/VITO/PV_S10_TOC_20140901_333M_V001_ib/*NIR.tif 
input007=$INDIR/VITO/PV_S10_TOC_20140901_333M_V001_ib/*RED.tif
input002=$INDIR/globcover2009_ioa/IOA1/globcove_reclassify.tif

z001="$(gdalinfo $input006 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"

###JOB#001 resample LULC para o mesmo pixel scale do target
gdalwarp -tr $z001 $z001 -r bilinear $input002 input002001.tif

###JOB#002 Get the same boundary information_globcover
ulx=$(gdalinfo input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')

pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $input006 -o input006002.tif
pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $input007 -o input007002.tif

####JOB#003 Extrair as class per land cover [1:11] e 
#################aplicar o factor de escala imagens PROBA-V or SPOT-VGT
gdal_calc.py -A input006002.tif --outfile=input006003.tif --calc="(0.0005*A)*10000" --overwrite --NoDataValue=-1 --type=UInt32;
gdal_calc.py -A input007002.tif --outfile=input007003.tif --calc="(0.0005*A)*10000" --overwrite --NoDataValue=-1 --type=UInt32;

####### calculo do BRIGHTNESS
gdal_calc.py -A input006003.tif -B input007003.tif --outfile=input008001.tif --calc="sqrt(A*A+B*B)" --overwrite --type=UInt32;

####### calculo dos valores para a parametrização: HSD and LSD

export SDIR=/media/sf_geodata/Melodies/VM004/class_SOIL001
mkdir  $SDIR
for i in {1..11}; do 
gdal_calc.py -A input008001.tif -B input002001.tif --outfile=$SDIR/input008001s_0$i.tif --calc="(B==$i)*(A)" --overwrite --NoDataValue=0 --type=UInt32; 
# $zLSD="$(oft-mm -um input003001_$i.tif input003001_$i.tif| grep "Band 1 min"|  awk '{ gsub ("[(),]","") ; print $5  }')"
# $zLSD="$(oft-mm -um input003001_$i.tif input003001_$i.tif| grep "Band 1 max"|  awk '{ gsub ("[(),]","") ; print $5  }')"
# echo $zLSD $zHSD >> zLSDzHSD_Sx.txt 
done
###################################################
cd $SDIR
########calculo das medias por classe, normalização 
R --vanilla --no-readline   -q  <<'EOF'

#R version  3.2.1
# set working directory
INDIR = Sys.getenv(c('INDIR'))
OUTDIR = Sys.getenv(c('OUTDIR'))

#getwd()

require(sp)
require(rgdal)
require(raster)
    
# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
list.filenames<-list.files(pattern=".tif$")

# create a loop to read in your data
for (i in 1:length(list.filenames))
{
# load raster data 
rastD = raster(list.filenames[i])
rastDi = raster(list.filenames[i])
# calculate Mean
rastD[rastD <= 0] = -9999
rastDi[rastDi <= 0] = -9999
rastD3<-((rastD>-9999)*(rastD[]=(cellStats(brick(rastD), mean))))
rastD5<-(rastD3-minValue(rastDi))/(maxValue(rastDi)-minValue(rastDi))
print(i)
writeRaster(rastD5, filename=paste("st0",i,"_classSOIL.tif", sep=""), format="GTiff", overwrite=TRUE)
}

EOF

#############integração................................Sx
R --vanilla --no-readline   -q  <<'EOF'

require(sp)
require(rgdal)
require(raster)
    
# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
list.filenames<-list.files(pattern="SOIL.tif$")

# load raster data 

rstack002<-stack(raster(list.filenames[1]),
raster(list.filenames[2]),
raster(list.filenames[3]),
raster(list.filenames[4]),
raster(list.filenames[5]),
raster(list.filenames[6]),
raster(list.filenames[7]),
raster(list.filenames[8]),
raster(list.filenames[9]),
raster(list.filenames[10]),
raster(list.filenames[11]))

rastD7<-sum(rstack002, na.rm=TRUE)

writeRaster(rastD7, filename="Sx003.tif", format="GTiff", overwrite=TRUE)

EOF
################################################### 
###tif2toasc 
#gdal_translate  -of AAIGrid  Sx003.tif   Sx003.asc 

cd ..
################################.............................................BX
export VDIR=/media/sf_geodata/Melodies/VM004/Bx006
mkdir  $VDIR 

for i in {2,3,4,5,7}; do 
gdal_calc.py -A class_NDV001/Vx003.tif -B input002001.tif --outfile=$VDIR/Vx003002_0$i.tif --calc="(B==$i)*(A*10000)" --overwrite --NoDataValue=0 --type=UInt32;
done

# class 6
gdal_calc.py -A class_SOIL001/Sx003.tif -B input002001.tif --outfile=$VDIR/Sx003002_06.tif --calc="(B==$i)*(A*10000)" --overwrite --NoDataValue=0 --type=UInt32;


for i in {1,8,9,10,11}; do 
gdal_calc.py -A class_SOIL001/Sx003.tif -B input002001.tif --outfile=$VDIR/VxSx003002_0$i.tif --calc="(B==$i)*(A*0+5000)" --overwrite  --NoDataValue=0 --type=UInt32;
done

mv $VDIR/VxSx003002_010.tif  $VDIR/VxSx003001_10.tif
mv $VDIR/VxSx003002_011.tif  $VDIR/VxSx003001_11.tif
####################################  

cd $VDIR 
#############integração................................Bx
R --vanilla --no-readline   -q  <<'EOF'

require(sp)
require(rgdal)
require(raster)
    
# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
list.filenames<-list.files(pattern=".tif$")

# load raster data 

rstack003<-stack(raster(list.filenames[1]),
raster(list.filenames[2]),
raster(list.filenames[3]),
raster(list.filenames[4]),
raster(list.filenames[5]),
raster(list.filenames[6]),
raster(list.filenames[7]),
raster(list.filenames[8]),
raster(list.filenames[9]),
raster(list.filenames[10]),
raster(list.filenames[11]))

rastD6<-sum(rstack003, na.rm=TRUE)
writeRaster(rastD6, filename="Bx003.tif", format="GTiff", overwrite=TRUE)

EOF

##################################VGT to GeoMS (ASCII)

gdal_translate  -of AAIGrid  Bx003.tif   Bx003.asc 

echo "DONE"
