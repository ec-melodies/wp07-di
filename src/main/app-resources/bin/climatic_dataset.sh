#!/bin/bash
# Produce Climatic maps 
# CERENA


##climatic datasets

export INDIR=//ewmcf/INPUT
export OUTDIR=//ewmcf/OUTPUT
 
mkdir $INDIR
mkdir $OUTDIR

cd $INDIR

# step 1#
######import data from ecmwf###
# sudo pip install https://software.ecmwf.int/wiki/download/attachments/23694554/ecmwf-api-client-python.tgz

cat <<EOF | python - 

##!/usr/bin/python 2.7.6
##

date= "1989-10-01/to/2014-09-30"
area= "44.0/-10.0/35.5/3.5"
target= "teste_Iberian8914.grib"

from ecmwfapi import ECMWFDataServer
server = ECMWFDataServer()
server.retrieve({
    "class": "ei",
    "dataset": "interim",
    "date": date,
    "expver": "1",
    "levtype": "sfc",
    "param": "228.128",
    "step": "12",
    "area": area,
    "grid": "0.75/0.75",
    "stream": "oper",
    "target": target,
    "time": "00/12",
    "type": "fc",
})

EOF

cd $OUTDIR

cat <<EOF | python 
##!/usr/bin/python 2.7.6
##

date= "1989-10-01"
area= "44.0/-10.0/35.5/3.5"
target= "OUT000.grib"

from ecmwfapi import ECMWFDataServer
server = ECMWFDataServer()
server.retrieve({
    "class": "ei",
    "dataset": "interim",
    "date": date,
    "expver": "1",
    "levtype": "sfc",
    "param": "228.128",
    "step": "12",
    "area": area,
    "grid": "0.75/0.75",
    "stream": "oper",
    "target": target,
    "time": "00",
    "type": "fc",
})
EOF

#!/usr/bin/gdal 1.11.1
gdal_translate -of AAIGrid $OUTDIR/OUT000.grib $OUTDIR/OUT000.asc  
head $OUTDIR/OUT000.asc -n 5 > $OUTDIR/OUT002.asc

R --vanilla --no-readline   -q  <<'EOF'

##!/usr/bin/R version  3.2.1

INDIR = Sys.getenv(c('INDIR'))
OUTDIR = Sys.getenv(c('OUTDIR'))

## load the package
require("zoo")
require("rgdal")
require("sp")
require("matrixStats")

####console setting
###
options(max.print=99999999) 
#options("scipen"=100, "digits"=4)

###read data###

file.grib<-readGDAL(list.files(path=INDIR, pattern="*.grib"))

#####RL1-Amount of days per year with precipitation below 1 mm##########

file.grib_df_t<-t(data.frame(file.grib))
######one value per day
###
Day_2to1_file.grib<-rollapply(file.grib_df_t, FUN=sum,by=2,width=2,na.rm = TRUE)
###calculos das coordenadas
xy_sa=geometry(file.grib)

aa<-c(1989:2013)
ab<-c(1990:2014)

anos<- paste("A",aa,ab,sep="")
#####RL1-Amount of days per year with precipitation below 1 mm###########

Day_2to1_sa2<-data.frame(t(Day_2to1_file.grib))

A19891990	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(1:365)	]<0.001)))
A19901991	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(366:730)	]<0.001)))
A19911992	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(731:1095)	]<0.001)))
A19921993	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(1096:1461)	]<0.001)))
A19931994	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(1462:1826)	]<0.001)))
A19941995	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(1827:2191)	]<0.001)))
A19951996	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(2192:2556)	]<0.001)))
A19961997	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(2557:2922)	]<0.001)))
A19971998	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(2923:3287)	]<0.001)))
A19981999	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(3288:3652)	]<0.001)))
A19992000	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(3653:4017)	]<0.001)))
A20002001	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(4018:4383)	]<0.001)))
A20012002	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(4384:4748)	]<0.001)))
A20022003	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(4749:5113)	]<0.001)))
A20032004	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(5114:5478)	]<0.001)))
A20042005	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(5479:5844)	]<0.001)))
A20052006	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(5845:6209)	]<0.001)))
A20062007	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(6210:6574)	]<0.001)))
A20072008	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(6575:6939)	]<0.001)))
A20082009	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(6940:7305)	]<0.001)))
A20092010	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(7306:7670)	]<0.001)))
A20102011	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(7671:8035)	]<0.001)))
A20112012	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(8036:8400)	]<0.001)))
A20122013	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(8401:8766)	]<0.001)))
A20132014	<-	as.vector(rowSums((	Day_2to1_sa2[,c	(8767:9131)	]<0.001)))

R1_19892014_sa<-data.frame(A19891990,A19901991, A19911992, A19921993, A19931994 ,A19941995 ,A19951996, A19961997 ,A19971998, A19981999, A19992000,A20002001,
A20012002, A20022003, A20032004, A20042005, A20052006, A20062007, A20072008, A20082009, A20092010, A20102011, A20112012, A20122013,A20132014,xy_sa)

x240_2014<-as.matrix((R1_19892014_sa)[,c(1:25)])

#step 2#
####################moving_window: 10 years#######################
######################dynamic component############

wind10_var<-function(x,xy) 
	{
	wind10_var=rollapply(t(x), FUN=var,by.column=T,width=10,na.rm = TRUE) ##the variance of RL1 for a period of 10 years
	wd10=c(1:dim(wind10_var)[1])#number of moving windows
	slope_wind10_var=lm((wind10_var)~wd10)$coef[2,]#slope of the decadal variance layers
	return (data.frame(slope_wind10_var,xy))
	}

slope_wind10_var_sa_2014<-wind10_var(x240_2014,xy_sa)

###Cd###
#######################################################	
Cd_dynamic<-function(x)
	{
	x=as.vector(x)
	replace(x, x>abs(min(x)), 0)
	x=(abs(min(x))-x)/(2*abs(min(x)))
	Cd_dynamic=x
	return(Cd_dynamic)
	}

Cd_sa_2014<-Cd_dynamic(slope_wind10_var_sa_2014[,1])

#######################static component##############
######the average value of RL1 for each pixel########
RL1_mean_sa_2014<-rollapply(t(x240_2014), FUN=mean,by.column=T,width=25,na.rm = TRUE) 

#step 3#
###Cs###

Cs_static2<-function(x)
		{
		Cs_static2=(x-min(x))/(max(x)-min(x))
		return(as.vector(Cs_static2))
		}
################
Cs_sa2_2014<-Cs_static2(RL1_mean_sa_2014)

##################################export data ######################
CS_df2<-matrix(Cs_sa2_2014,nrow =13,ncol =20)
CD_df2<-matrix(Cd_sa_2014,nrow =13,ncol =20)

write.table(CS_df2,paste(path=INDIR,'CS001.txt',sep = ""), sep = " ",row.names=F,col.names=F)
write.table(CD_df2,paste(path=INDIR,'CD002.txt',sep = ""), sep = " ",row.names=F,col.names=F)

EOF

### ASCII to geoMS

head OUT002.asc > $OUTDIR/OUTCD001002.asc
head OUT002.asc > $OUTDIR/OUTCS001001.asc

cat INPUTCS001.txt >> $OUTDIR/OUTCS001001.asc
cat INPUTCD002.txt >> $OUTDIR/OUTCD001002.asc


