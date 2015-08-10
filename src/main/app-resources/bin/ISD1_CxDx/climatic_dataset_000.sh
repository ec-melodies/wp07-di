#!/bin/sh
############################################################################
#	
# PURPOSE: Accessing ECMWF data servers in batch
#
#############################################################################

# Requires:
# gdalinfo
#!/bin/bash

# source the ciop functions (e.g. ciop-log, ciop-getparam)
source ${ciop_job_include}

###Setting enviroments 
# quadricula 
ulx="-9.5110"
uly="38.9876"
lrx="-7.0172"
lry="38.1229"

export ulx
export uly
export lrx
export lry

#ano hidrologico
y1="1989"
y2="2014"

export y1
export y2

cat <<EOF | python - 

##!/usr/bin/python 2.7.6
##
import os

y1=int(os.getenv('y1'))
y2=int(os.getenv('y2'))

ulx=float(os.getenv('ulx'))
uly=float(os.getenv('uly'))
lrx=float(os.getenv('lrx'))
lry=float(os.getenv('lry'))

date= "%d-10-01/to/%d-09-30" % (y1,y2)
area="%.3f/%.3f/%.3f/%.3f" % (uly,ulx,lry,lrx)
target= "ecmwf_tp.grib"

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
    "grid": "0.25/0.25",
    "stream": "oper",
    "target": target,
    "time": "00/12",
    "type": "fc",
})

EOF

gdalinfo $INDIR/ecmwf_tp.grib > $INDIR/README_ecmwf_tp.txt