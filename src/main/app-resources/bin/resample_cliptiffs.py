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

def __OpenArray__( array, prototype_ds = None, xoff=0, yoff=0 ):
    ds = gdal.Open( gdalnumeric.GetArrayFilename(array) )

    if ds is not None and prototype_ds is not None:
        if type(prototype_ds).__name__ == 'str':
            prototype_ds = gdal.Open( prototype_ds )
        if prototype_ds is not None:
            gdalnumeric.CopyDatasetInfo( prototype_ds, ds, xoff=xoff, yoff=yoff )
    return ds

def __world2Pixel__(geoMatrix, x, y):
  """
  Uses a gdal geomatrix (gdal.GetGeoTransform()) to calculate
  the pixel location of a geospatial coordinate
  """
  ulX = geoMatrix[0]
  ulY = geoMatrix[3]
  xDist = geoMatrix[1]
  yDist = geoMatrix[5]
  rtnX = geoMatrix[2]
  rtnY = geoMatrix[4]
  pixel = int((x - ulX) / xDist)
  line = int((ulY - y) / xDist)
  return (pixel, line)

def open_tif2raster(path):
    return gdal.Open(path)
    
def open_tif2array(path):
    return gdalnumeric.LoadFile(path)
    
def open_tif_tuple(path):
    return open_tif2raster(path),open_tif2array(path)
    
def clip_tif_tuple(tif_tuple,ulx,uly,lrx,lry):
    geoTrans = tif_tuple[0].GetGeoTransform()
    ulX, ulY = __world2Pixel__(geoTrans, ulx, uly)
    lrX, lrY = __world2Pixel__(geoTrans, lrx, lry)
    if len(tif_tuple[1].shape)>2:
        clip = tif_tuple[1][:, ulY:lrY, ulX:lrX]
    else:
        clip = tif_tuple[1][ulY:lrY, ulX:lrX]
    return tif_tuple[0],clip,ulX,ulY
    
def save_tif_tuple2gtiff(opath,tif_tuple,raster_src):
    xoffset = tif_tuple[2]
    yoffset = tif_tuple[3]
    gtiffDriver = gdal.GetDriverByName( 'GTiff' )
    gtiffDriver.CreateCopy( opath+'.tif',__OpenArray__(tif_tuple[1], prototype_ds=raster_src, xoff=xoffset, yoff=yoffset))

def country_clip_loop(idir,odir,clip_tuple=(29.2226, 38.0303,31.9912, 35.8880)):
    onlyfiles = [ f for f in listdir(idir) if isfile(join(idir,f)) ]
    for f in onlyfiles:
        if f !='Thumbs.db':
            tup = open_tif_tuple(idir+'\\'+f)
            clip = clip_tif_tuple(tup,clip_tuple[0], clip_tuple[1],clip_tuple[2], clip_tuple[3])
            save_tif_tuple2gtiff(odir+'\\'+f[:-4]+'_sample',clip,idir+'\\'+f)
            get_raster_metadata(odir+'\\'+f[:-4]+'_sample.tif',odir+'\\'+f[:-4]+'_sample')
            print odir+'\\'+f[:-4]+'_sample.tif'
            
def get_raster_metadata(path,opath):
    print path
    datafile = gdal.Open(path)
    #print datafile.GetMetadata()
    
    fid = open(opath+'.txt','w')
    fid.write('### METADATA ###\n')
    
    width = datafile.RasterXSize
    height = datafile.RasterYSize
    
    cols = datafile.RasterXSize
    rows = datafile.RasterYSize
    bands = datafile.RasterCount
    
    """Print the information to the screen. Converting the numbers returned to strings using str()"""
    
    fid.write("Number of columns: " + str(cols)+'\n')
    fid.write("Number of rows: " + str(rows)+'\n')
    fid.write("Number of bands: " + str(bands)+'\n')
    fid.write('\n')
    
    """First we call the GetGeoTransform method of our datafile object"""

    gt = geoinformation = datafile.GetGeoTransform()
    #datafile.SetGeoTransform(gt)
    
    """The top left X and Y coordinates are at list positions 0 and 3 respectively"""
    
    topLeftX = geoinformation[0]
    topLeftY = geoinformation[3]
    #print geoinformation
    minx = gt[0]
    miny = gt[3] + width*gt[4] + height*gt[5] 
    maxx = gt[0] + width*gt[1] + height*gt[2]
    maxy = gt[3] 
    #print minx,miny,maxx,maxy
    """Print this information to screen"""
    
    fid.write('### OLD ORIGIN ###\n')
    fid.write("Top left X: " + str(topLeftX)+'\n')
    fid.write("Top left Y: " + str(topLeftY)+'\n')
    #fid.write('### NEW ORIGIN ###\n')
    #fid.write("Top left X: " + str(origin[0])+'\n')
    #fid.write("Top left Y: " + str(origin[1])+'\n')
    #fid.write('\n')
    
    """first we access the projection information within our datafile using the GetProjection() method. This returns a string in WKT format"""

    projInfo = datafile.GetProjection()
    #print projInfo
    """Then we use the osr module that comes with GDAL to create a spatial reference object"""
    
    spatialRef = osr.SpatialReference()
    
    """We import our WKT string into spatialRef"""
    
    spatialRef.ImportFromWkt(projInfo)
    
    """We use the ExportToProj4() method to return a proj4 style spatial reference string."""
    
    spatialRefProj = spatialRef.ExportToProj4()
    
    """We can then print them out"""
    
    fid.write('### SISTEMA DE COORDENADAS ###\n')
    fid.write("WKT format: " + str(spatialRef)+'\n')
    fid.write("Proj4 format: " + str(spatialRefProj)+'\n')

# O código abaixo é para clipar tifs.
#country_clip_loop('turquia','turquia\\output',clip_tuple=(29.2226, 38.0303,31.9912, 35.8880))
#country_clip_loop('africa' ,'africa\\output' ,clip_tuple=(29.2226, 38.0303,31.9912, 35.8880))
country_clip_loop('pt','pt\\output',clip_tuple=(-9.49861110927, 42.1458333333,-6.1819444426, 36.9791666666))

#get_raster_metadata('testep.tif')

