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

#python 2.7.6

import os

y1=int(os.getenv('y1'))
y2=int(os.getenv('y2'))

ulx=float(os.getenv('ulx'))
uly=float(os.getenv('uly'))
lrx=float(os.getenv('lrx'))
lry=float(os.getenv('lry'))

date= "%d-10-01/to/%d-09-30" % (y1,y2)
area="%.3f/%.3f/%.3f/%.3f" % (uly,ulx,lry,lrx)
target= "ecmwf_pt.grib"

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

gdalinfo $INDIR/ecmwf_pt.grib > $OUTDIR001/README_ECMWF_001.txt

echo "DONE"