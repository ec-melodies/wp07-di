# -*- coding: utf-8 -*-
"""
@author: cerena
"""

from __future__ import division
import numpy as np

from osgeo import gdal, ogr, gdalnumeric,osr
from osgeo._gdalconst import *

from os import listdir
from os.path import isfile, join


"""
[190, 1]
[14, 15, 16, 20, 21 22 = 2 
[11 12 13 = 3
[32 40 41 42 50 60 70 90 91 92 100 101 102 = 4
[30 31 110 130 131 132 133 134 135 136 = 5
[120 140 141 142 143 144 145 = 6
[150 151 152 153 = 7
230 = 8
#200 201 202 203 = 9
#160 161 162 170 180 181 182 183 184 185 186 187 188 = 10
#210 = 11
#*	= NULL
"""

def __OpenArray__( array, prototype_ds = None, xoff=0, yoff=0 ):
    ds = gdal.Open( gdalnumeric.GetArrayFilename(array) )

    if ds is not None and prototype_ds is not None:
        if type(prototype_ds).__name__ == 'str':
            prototype_ds = gdal.Open( prototype_ds )
        if prototype_ds is not None:
            gdalnumeric.CopyDatasetInfo( prototype_ds, ds, xoff=xoff, yoff=yoff )
    return ds

def open_tif2raster(path):
    return gdal.Open(path)
    
def open_tif2array(path):
    return gdalnumeric.LoadFile(path)
    
def open_tif_tuple(path):
    return open_tif2raster(path),open_tif2array(path)
    
def save_tif_tuple2gtiff(opath,tif_tuple,raster_src):
    xoffset = tif_tuple[2]
    yoffset = tif_tuple[3]
    gtiffDriver = gdal.GetDriverByName( 'GTiff' )
    gtiffDriver.CreateCopy( opath+'.tif',__OpenArray__(tif_tuple[1], prototype_ds=raster_src, xoff=xoffset, yoff=yoffset))

def change_to(value):
    if value in [190]:
        return 1
    elif value in [14,15,16,20,21,22]:
        return 2
    elif value in [11,12,13]:
        return 3
    elif value in [32,40,41,42,50,60,70,90,91,92,100,101,102]:
        return 4
    elif value in [30,31,110,130,131,132,133,134,135,136]:
        return 5
    elif value in [120,140,141,142,143,144,145]:
        return 6
    elif value in [150,151,152,153]:
        return 7
    elif value in [230]:
        return 8
    elif value in [200,201,202,203]:
        return 9
    elif value in [160,161,162,170,180,181,182,183,184,185,186,187,188]:
        return 10
    elif value in [210]:
        return 11
    else:
        return -9999
        
def reclass_tif(tup):
    new = tup[1].copy()
    print new.shape
    for i in xrange(tup[1].shape[0]):
        print i,tup[1].shape[0]
        for j in xrange(tup[1].shape[1]):
            new[i,j] = change_to(tup[1][i,j])
    return (tup[0],new,0,0)
    
def reclassify_tif(ipath):
    tup = open_tif_tuple(ipath+'.tif')
    newtup = reclass_tif(tup)
    save_tif_tuple2gtiff(ipath[:-4]+'_reclassify',newtup,ipath+'.tif')
    
reclassify_tif('GLOBCOVER_Moz.tif')

