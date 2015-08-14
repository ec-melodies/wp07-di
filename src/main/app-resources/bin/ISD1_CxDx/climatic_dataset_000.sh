#!/bin/bash
############################################################################
#	
# PURPOSE: Accessing ECMWF data servers in batch
#
#############################################################################
# Requires:
# gdalinfo
# python

bash /application/bin/ISD5_node/ini.sh

export PATH=/opt/anaconda/bin/:$PATH

cat <<EOF | /opt/anaconda/bin/python - 

#Python 2.7.10 :: Continuum Analytics, Inc.

import os
inport sys
import cioppy

# import the ciop functions (e.g. copy, log)

tdir=os.path.join('/data/INPUT/')
rtdir=os.environ['HOME']+tdir

y1=ciop.getparam(int('y1'))
y2=ciop.getparam(int('y2'))

ulx=ciop.getparam(float('ulx'))
uly=ciop.getparam(float('uly'))
lrx=ciop.getparam(float('lrx'))
lry=ciop.getparam(float('lry'))
target001=os.path.join(rtdir,'ecmwf.grib')
    
date= "%d-10-01/to/%d-09-30" % (y1,y2)
area="%.3f/%.3f/%.3f/%.3f" % (uly,ulx,lry,lrx)
target002= ciop.publish('target001', metalink = True)

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
    "target": target001,
    "time": "00/12",
    "type": "fc",
})


EOF

gdalinfo $INDIR/ecmwf_pt.grib > $OUTDIR001/README_ECMWF_001.txt

echo "DONE"