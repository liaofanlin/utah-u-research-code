#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 15 13:43:14 2019


"""

#%% Basic package loading
#import matplotlib
#matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import sys
import os
import matplotlib as mpl
from netCDF4 import Dataset
#from mpl_toolkits.basemap import Basemap
import pickle


from datetime import datetime
from datetime import timedelta

#%% Basic information

print("Python: Creating SM Innovation Files")

# Time
from func_parameters import parameters

# Load the time information 
YEAR, MONTH, DAY, HOUR = parameters()

# Get the time string
YEAR_START    = YEAR
MONTH_START   = MONTH
DAY_START     = DAY
HOUR_START    = HOUR


#
# Default is the data set in 2018
DATA_PATH_ISMN = "/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/coding/" + \
                 "python/2019/000000_data/ISMN_data/" + \
                 "Data_seperate_files_20180501_20180930_4697_H08t_20190127"
ISMN_NETWORK = ['SCAN','USCRN']

# NC File
DATA_PATH = "."

# Ensemble size
ENS_SIZE = 40
#%% Read WRF NC File and ISMN Station text file
# Open the NetCDF file  
ncfile = Dataset(DATA_PATH + "/" + "firstguess.mem001.nc") 

# Loading WRF variables.  
#   - the loading dim for lon/lat is 1 x X x Y and smois is 1 x 4 x X x Y.  Thus, 
#     I use np.squeeze to remove the single dimension.
lon_wrf = np.squeeze( ncfile.variables['XLONG'][:])
lat_wrf = np.squeeze(ncfile.variables['XLAT'][:])


# Computing the mean
lon_0 = lon_wrf.mean()
lat_0 = lat_wrf.mean()

ncfile.close()

# Open the station list file
DATA_PATH_STATION_TXT = "/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/" + \
                        "coding/python/2019/190201_GSI_ENKF_DA_01/" + \
                        "190520_ISMN_stations_within_WRF_domain_chpc_190101_case_61"
f = open(DATA_PATH_STATION_TXT + '/station_info.txt','r')
data_txt = f.readlines()
f.close()

#%% Create the headers for the ensemble SM data file
for ii in range(0,ENS_SIZE+1):
    
    # String of the member
    if ii == 0:
        memStr = "ensmean"
    elif ii<10:
        memStr = "mem00" +  str(ii)
    else:
        memStr = "mem0" + str(ii)
        
    f_out = open('sm_innov_' + YEAR_START + MONTH_START + DAY_START + HOUR_START + \
                 '_' + memStr + '.txt','w')
    
    f_out.write("# rdiagbuf(12),  rdiagbuf(3),  rdiagbuf(4),  rdiagbuf(6), rdiagbuf(16), rdiagbuf(17), rdiagbuf(18),\n")
    f_out.close()

#%% 
for ss in range(0,len(data_txt)-1):
    
    # =========================================================================
    # Steps to get (1) lon, lat, station name, network of each station and (2) 
    # soil moisture at the time of interest (analysis time)
    # =========================================================================
    # Read each line from the station text file
    data_txt_line = data_txt[ss+1]
    C = data_txt_line.split()
    
    # Get lon, lat, name, and network
    lon_ismn = float(C[2])
    lat_ismn = float(C[3])
    nam_ismn = C[1].replace("_","")
    net_ismn = C[0]
    
    # Obtain the data file name within each station
    file_path = DATA_PATH_ISMN + '/' + net_ismn + '/' + nam_ismn
    
    file_list = os.listdir(file_path)
    
    if net_ismn == 'SCAN': # SCAN
        file_ind = [file_list.index(i) for i in file_list if "sm_0.050800_0.050800" in i]
    elif net_ismn == 'USCRN': # USCRN
        file_ind = [file_list.index(i) for i in file_list if "sm_0.050000_0.050000" in i]
    
    if len(file_ind) == 0:
        file_name = 'FileNotExist'
    else:
        file_name = file_path + '/' + file_list[ file_ind[0] ]    

    # Read the file
    f = open(file_name,'r')
    data = f.readlines()
    
    # Find the data of the time of the interest
    time_str = YEAR_START + '/' + MONTH_START + '/' + DAY_START + ' ' + HOUR_START + ':00'
    data_ind = [data.index(i) for i in data if time_str in i]
    
    # Get the SM data at the time of interest
    C02 = data[data_ind[0]].split()
    slm_ismn = float(C02[12])
    
    # Flag control
    flg_ismn = C02[13]
    
    if flg_ismn == 'G':
        qc = 1
    else:
        qc = -1

    # =========================================================================
    # Steps to get (1) lon, lat, station name, network of each station and (2) 
    # soil moisture at the time of interest (analysis time)
    # =========================================================================
    # Find the WRF grid nearest to the ISMN station
    dist = np.sqrt( (lon_ismn-lon_wrf)**2 + (lat_ismn-lat_wrf)**2 )
    dist_min_ind = np.where( dist == dist.min())
    dist_min = dist.min()

    # A loop for all the ensemble members
    for ii in range(0,ENS_SIZE+1): 
        
        # String of the member
        if ii == 0:
            memStr = "ensmean"
        elif ii<10:
            memStr = "mem00" +  str(ii)
        else:
            memStr = "mem0" + str(ii)

        # Read SMOIS and PSFC
        ncfile = Dataset(DATA_PATH + "/" + "firstguess." + memStr + ".nc")  
        smois_wrf = np.squeeze(ncfile.variables['SMOIS'][:])
        psfc = np.squeeze(ncfile.variables['PSFC'][:])
        ncfile.close()
        slm_wrf = smois_wrf[0,:,:]
        
        # Get the SM and Pressure at the Grid nearest to the ISMN Station
        slm_innv = slm_ismn - slm_wrf[dist_min_ind[0][0],dist_min_ind[1][0]]
        psfc_ismn = psfc[dist_min_ind[0][0],dist_min_ind[1][0]]
        
        # Write Results into each ensemble member text file        
        f_out = open('sm_innov_' + YEAR_START + MONTH_START + DAY_START + HOUR_START + \
                     '_' + memStr + '.txt','a')
        f_out.write('%14d, %12.3f, %12.3f, %12.3f, %12.3f, %12.4f, %12.7f,\n' % \
                    (qc, lat_ismn, lon_ismn+360, psfc_ismn/100, 25, slm_ismn, slm_innv) );   
        f_out.close()         
        

