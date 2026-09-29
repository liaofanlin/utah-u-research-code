#!/bin/csh -x

# Note:
#	- All the data are from https://ldas.gsfc.nasa.gov/gldas/GLDASsoils.php

# Clean this directory
# --------------------
	rm porfaot.1gd4r
	rm read_porosity.f90
	rm *.jpg
	rm *.txt

# Get the data
# ------------
	# GLDAS 1/4 degree soil porosity binary data
	wget https://ldas.gsfc.nasa.gov/gldas/data/0.25deg/oldstandard/porfaot.1gd4r
	
	# Fortran code to read the big_endian soil porosity data
	wget https://ldas.gsfc.nasa.gov/gldas/data/0.25deg/oldstandard/read_porosity.f90
	
	cp read_porosity.f90 read_porosity.f90_ori
	
# Edit the gfortran file
# ----------------------
	# The original length is too short
	sed -i -- 's,len=20,len=30,g' read_porosity.f90		

	# Uncomment the file to be read
	sed -i -- "s,! fname = 'porfaot.1gd4r', fname = 'porfaot.1gd4r',g" read_porosity.f90

	# Comment out the file that is not read
	sed -i -- "s, fname = 'porfaob.1gd4r',! fname = 'porfaob.1gd4r',g" read_porosity.f90
		
	# The original data is in big_endian, while the CHPC is in little endian.  I need to convert it.
	sed -i -- "s/ny\*4/ny\*4,CONVERT='BIG_ENDIAN'/g" read_porosity.f90
	
	# Add a few lines to write data into a text file
	sed -i 's:read(98,rec=1) por:read(98,rec=1) por\n open(100,file="porfaot.txt")\n write(100,*) por\n close(100):g' read_porosity.f90

# Compile the script and execute it
	gfortran -o read_porosity.exe read_porosity.f90
	./read_porosity.exe
	
# Run MATLAB to plot the data on the MAC Desktop!