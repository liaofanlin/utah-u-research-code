#!/bin/csh -x
#

set GSI_GSI_ROOT = $1


cd gsi/pre_proc

	# Process of convinfo
	cp ${GSI_GSI_ROOT}/fix/global_convinfo.txt convinfo

	# Revise the convinfor for my experiment purpose
	# ----------------------------------------------
	# NOTE (2018.09.26): Please see rn180925 for the information of observation
	#	types (e.g., 120, 180, 181, 187, etc.). 
	
	# Convert use_flag=1 to -1 for ps data
	sed -i -- 's/ps       120    0    1/ps       120    0   -1/g' convinfo
	sed -i -- 's/ps       180    0    1/ps       180    0   -1/g' convinfo
	sed -i -- 's/ps       180    01   1/ps       180    01  -1/g' convinfo
	sed -i -- 's/ps       181    0    1/ps       181    0   -1/g' convinfo
	sed -i -- 's/ps       187    0    1/ps       187    0   -1/g' convinfo

	# Convert use_flag=1 to -1 for q data
	#sed -i -- 's/q        120    0    1/q        120    0   -1/g' convinfo
	#sed -i -- 's/q        180    0    1/q        180    0   -1/g' convinfo
	#sed -i -- 's/q        180    01   1/q        180    01  -1/g' convinfo
	sed -i -- 's/q        187    0   -1/q        187    0    1/g' convinfo
	
	# Convert use_flag=1 to -1 for t data
	#sed -i -- 's/t        120    0    1/t        120    0   -1/g' convinfo
	#sed -i -- 's/t        130    0    1/t        130    0   -1/g' convinfo
	#sed -i -- 's/t        180    0    1/t        180    0   -1/g' convinfo
	#sed -i -- 's/t        180    01   1/t        180    01  -1/g' convinfo
	sed -i -- 's/t        187    0   -1/t        187    0    1/g' convinfo

	# Convert use_flag=1 to -1 for uv data
	sed -i -- 's/uv       220    0    1/uv       220    0   -1/g' convinfo
	sed -i -- 's/uv       223    0    1/uv       223    0   -1/g' convinfo		
	sed -i -- 's/uv       224    0    1/uv       224    0   -1/g' convinfo
	sed -i -- 's/uv       230    0    1/uv       230    0   -1/g' convinfo
	sed -i -- 's/uv       280    0    1/uv       280    0   -1/g' convinfo
	sed -i -- 's/uv       280    01   1/uv       280    01  -1/g' convinfo	

cd ../..

# Link convinfo for gsi and enkf
cd gsi/gsidiag_arw
	ln -sf ../pre_proc/convinfo .
cd ../..
	
cd gsi/enkf_arw
	ln -sf ../pre_proc/convinfo .
cd ../..

