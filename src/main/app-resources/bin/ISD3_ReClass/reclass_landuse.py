# -*- coding: utf-8 -*-
"""
@author: cerena
"""

from __future__ import division
import numpy as np
from scipy.misc import imresize

from osgeo import gdal, ogr, gdalnumeric,osr
from osgeo._gdalconst import *

from os import listdir
from os.path import isfile, join

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
    np.save(opath+'.npy',tif_tuple[4])
    save_ascii(tif_tuple[4],opath)

def save_ascii(new,opath):
    fid = open(opath+'.txt','w')
    fid.write(str(new.shape[0])+'_'+str(new.shape[1])+'\n1\nvar\n')
    for y in xrange(new.shape[1]):
        for x in range(new.shape[0]):
            fid.write('%10.3f\n'%new[x,y])
    fid.close()

def landuse_mean1(tup,target):
    unique = np.unique(tup[1])
    new = tup[1].copy()
    new2 = np.zeros(new.shape,dtype='float32') #new.copy().astype('float32')
    target = (target[0],imresize(target[1],size=tup[1].shape,interp='nearest'))
    print unique
    print target[1].shape
    print tup[1].shape
    for i in unique:
        ind = np.where(tup[1]==i)
        m = target[1][ind].mean()
        new[ind] = m
        new2[ind] = (1/250)*m-0.08
        print i,m
    return tup[0],new,0,0,new2
    
def landuse_mean2(tup,target):
    unique = np.unique(tup[1])
    new = tup[1].copy()
    new2 = np.zeros(new.shape,dtype='float32') #new.copy().astype('float32')
    target = (target[0],imresize(target[1],size=tup[1].shape,interp='nearest'))
    print unique
    print target[1].shape
    print tup[1].shape
    for i in unique:
        ind = np.where(tup[1]==i)
        m = target[1][ind].mean()
        new[ind] = m
        new2[ind] = 0.0005*m
        print i,m
    return tup[0],new,0,0,new2

def landuse_mean_from_tif(ipath,tpath,factor=1):
    tup = open_tif_tuple(ipath)
    target = open_tif_tuple(tpath)
    if factor==1:
        obj = landuse_mean1(tup,target)
    if factor==2:
        obj = landuse_mean2(tup,target)
    save_tif_tuple2gtiff(tpath+'_land',obj,ipath)
    
landuse_mean_from_tif('glob_pt1_reclassify.tif.tif','pt\\output\\PROBAV_S10_TOC_20140901_333M_V001_NDVI.tif',factor=1)