#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Accessing ECMWF data servers in batch (ecmwfapi)
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# python
# ciop
#-------------------------------------------------------------------------------------# 
##source the ciop functions
##source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# Set environment variable 
#-------------------------------------------------------------------------------------# 
bash /application/bin/ISD5_node/ini.sh
export -p DIR=~/data/ISD/
export PATH=/opt/anaconda/bin/:$PATH
export -p INDIR=~/data/INPUT/
export -p OUTDIR=$DIR/ISD000/
export -p CMDIR=$OUTDIR/CM001
#-------------------------------------------------------------------------------------#
cat <<EOF | /opt/anaconda/bin/python - 
#cat <<EOF | python - 
#Python 2.7.10 :: Continuum Analytics, Inc.
import os
import sys
#import cioppy
#-------------------------------------------------------------------------------------# 
#import the ciop functions (e.g. copy, log)
sys.path.append('/opt/anaconda/bin/')
#ciop = cioppy.Cioppy()
# the parameters value from workflow
#y1=ciop.getparam(int('y1'))
#y2=ciop.getparam(int('y2'))
#ulx=ciop.getparam(float('ulx'))
#uly=ciop.getparam(float('uly'))
#lrx=ciop.getparam(float('lrx'))
#lry=ciop.getparam(float('lry'))
#deg=ciop.getparam(float('deg'))

y1=1989
y2=2014
uly=44.25
ulx=-9.75
lry=36.75
lrx=3.00
deg=0.75

#-------------------------------------------------------------------------------------#
tdir=os.path.join('/data/ISD/ISD000/CM001/')
rtdir=os.environ['HOME']+tdir
target001=os.path.join(rtdir,'ecmwf.grib') 
os.chdir(rtdir)
date= "%d-10-01/to/%d-09-30" % (y1,y2)
area="%.3f/%.3f/%.3f/%.3f" % (uly,ulx,lry,lrx)
grid="%.2f/%.2f" % (deg,deg)
#-------------------------------------------------------------------------------------#
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
    "grid": grid,
    "stream": "oper",
    "target": target001,
    "time": "00/12",
    "type": "fc",
})
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
# ciop.publish(target001, metalink = True)
EOF
#-------------------------------------------------------------------------------------#
#cp $INDIR/ecmwf.grib $OUTDIR/ecmwf.grib 
gdalinfo $CMDIR/ecmwf.grib > $CMDIR/README_ECMWF.txt
echo "DONE"
exit 0
#-------------------------------------------------------------------------------------#