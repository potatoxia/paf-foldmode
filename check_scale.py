#!/usr/bin/env python

import os
import numpy as np
import matplotlib.pyplot as plt
import glob
import subprocess
import sys
import numpy.fft as fft

#repeat     = 1
#nsamp      = 1024
#nchan      = 256
#npol       = 2
#ndim       = 2
#ndata      = nsamp * nchan * npol * ndim
#hdrsize    = 4096
#dsize = 1
#fdir  = "/beegfs/DENG/"
#fname = '2018-03-29-12:37:55.212043_0000000000000000.000000.dada'
##fname = '2018-03-29-12:37:55.212043_0000032768000000.000000.dada'
#
#blksize  = ndata * dsize
#fname = os.path.join(fdir, fname)
#f = open(fname, "r")
#f.seek(hdrsize + repeat * blksize)
#sample = np.array(np.fromstring(f.read(blksize), dtype='int8'))
##sample = np.reshape(sample, (nsamp, nchan, npol * ndim))
#
#plt.figure()
#plt.plot(sample)
#plt.show()

#fdir  = "/beegfs/DENG/J0218+4232"
#fname = "2018-04-18-12:54:12.567416_scale.txt"

def five_average(data, naverage):
    len_data = len(data)
    average_data = []

    for idata in range(len_data - naverage):
        average_data.append(np.mean(data[idata:idata+5]))
        print data[idata:idata+5]
        
    return np.array(average_data)

fdir  = "/beegfs/DENG/J0332+5434"
fname = "2018-04-17-18:16:25.50499_scale.txt"

d = np.loadtxt("{:s}/{:s}".format(fdir, fname))
#print five_average(d)
#five_average(d)
#print d[-1:3]

plt.figure()
plt.plot(d[0:100,0])
plt.plot(d[0:100,1])
plt.show()
