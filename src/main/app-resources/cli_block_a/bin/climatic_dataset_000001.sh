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
#source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# Set environment variable 
#-------------------------------------------------------------------------------------# 
#bash /application/bin/ISD5_Nx/ini.sh
export -p DIR=/data/auxdata/ISD/
export PATH=/opt/anaconda/bin/:$PATH
export -p INDIR=/data/INPUT/
export -p OUTDIR=$DIR/ISD000/
export -p CMDIR=$OUTDIR/CM001

export y1=$1
export y2=$2
export uly=$3
export ulx=$4
export lry=$5
export lrx=$6
export deg=$7
#-------------------------------------------------------------------------------------#
cat <<EOF | /opt/anaconda/bin/python - 
#cat <<EOF | python - 
#Python 2.7.10 :: Continuum Analytics, Inc.
import os
import sys
from sys import argv
import cioppy
#ciop = cioppy.Cioppy()
#-------------------------------------------------------------------------------------# 
#import the ciop functions (e.g. copy, log)
sys.path.append('/opt/anaconda/bin/')
# ciop = cioppy.Cioppy()
# the parameters value from workflow

y1=int(os.environ["y1"])
y2=int(os.environ["y2"])
ulx=float(os.environ["ulx"])
uly=float(os.environ["uly"])
lrx=float(os.environ["lrx"])
lry=float(os.environ["lry"])
deg=float(os.environ["deg"])

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
tdir=os.path.join('/data/auxdata/ISD/ISD000/CM001/')
#rtdir=os.environ['tdir']
target001=os.path.join(tdir,'ecmwf.grib') 
os.chdir(tdir)
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
EOF
#-------------------------------------------------------------------------------------#
mv $CMDIR/ecmwf.grib $CMDIR/ecmwf_$y2.grib
#rm -f $CMDIR/ecmwf.grib
echo "DONE"

#exit 0