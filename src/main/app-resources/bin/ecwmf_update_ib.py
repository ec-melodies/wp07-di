#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer
server = ECMWFDataServer()
server.retrieve({
    "class": "ei",
    "dataset": "interim",
    "date": "1989-10-01/to/2014-09-30",
    "expver": "1",
    "levtype": "sfc",
    "param": "228.128",
    "step": "12",
    "area": "44.0/-10.0/35.5/3.5",
    "grid": "0.75/0.75",
    "stream": "oper",
    "target": "Iberian8914.grib",
    "time": "00/12",
    "type": "fc",
})



