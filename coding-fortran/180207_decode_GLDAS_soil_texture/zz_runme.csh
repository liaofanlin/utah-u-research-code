#!/bin/csh -x

# Note:
#	- All the data are from https://ldas.gsfc.nasa.gov/gldas/GLDASsoils.php

# Clean this directory
# --------------------
	rm tex_statsfao_mod44w_025.1gd4r
	rm read_soils.f90
	rm *.jpg

# Get the data
# ------------
	# GLDAS 1/4 degree soil texture binary data
	wget https://ldas.gsfc.nasa.gov/gldas/data/0.25deg/tex_statsfao_mod44w_025.1gd4r
	
	# Fortran code to read the big_endian soil texture data
	wget https://ldas.gsfc.nasa.gov/gldas/data/0.25deg/read_soils.f90
	
	cp read_soils.f90 read_soils.f90_ori
	
# Edit the gfortran file
# ----------------------
	# The original length is too short
	sed -i -- 's,len=20,len=30,g' read_soils.f90		
	
	# The file name of the texture data is different
	sed -i -- "s,! fname = 'tex_statsfao_mod44w_0.25_gldas2p4.bin', fname = 'tex_statsfao_mod44w_025.1gd4r',g" read_soils.f90	 
	
	# Comment out the file that is not read
	sed -i -- "s, fname = 'sandfao.1gd4r.bin',! fname = 'sandfao.1gd4r.bin',g" read_soils.f90
	
	# The original data is in big_endian, while the CHPC is in little endian.  I need to convert it.
	sed -i -- "s/ny\*4/ny\*4,CONVERT='BIG_ENDIAN'/g" read_soils.f90
	
	# Add a few lines to write data into a text file
	sed -i 's:read(98,rec=1) soils:read(98,rec=1) soils\n open(100,file="tex_statsfao.txt")\n write(100,*) soils\n close(100):g' read_soils.f90

# Compile the script and execute it
	gfortran -o read_soils.exe read_soils.f90
	./read_soils.exe
	
# Run MATLAB to plot the data on the MAC Desktop!