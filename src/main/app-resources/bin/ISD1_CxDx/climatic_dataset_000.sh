#!/bin/bash
############################################################################
#	
# PURPOSE: Accessing ECMWF data servers in batch
#
#############################################################################
# Requires:
# gdalinfo
# python


cat <<EOF | python - 

#Python 2.7.10 :: Continuum Analytics, Inc.

import os
import cioppy 

y1=ciop.getparam(int('y1'))
y2=ciop.getparam(int('y2'))

ulx=ciop.getparam(float('ulx'))
uly=ciop.getparam(float('uly'))
lrx=ciop.getparam(float('lrx'))
lry=ciop.getparam(float('lry'))

date= "%d-10-01/to/%d-09-30" % (y1,y2)
area="%.3f/%.3f/%.3f/%.3f" % (uly,ulx,lry,lrx)
target= ciop.publish('/tmp/ecmwf_pt.grib', metalink = True)

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

#gdalinfo $INDIR/ecmwf_pt.grib > $OUTDIR001/README_ECMWF_001.txt

echo "DONE"