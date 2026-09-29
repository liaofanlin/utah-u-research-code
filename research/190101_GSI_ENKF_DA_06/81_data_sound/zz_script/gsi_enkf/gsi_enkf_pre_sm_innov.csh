#!/bin/csh -x
#

set DA_START_TIME 	= $1
set GSI_ENKF_NANALS 	= $2

###############################################################
cd ./gsi_enkf/${DA_START_TIME}/03_pre_process

# ===============================================
# Preprocessing
# ===============================================
# GSI Analysis Time Details
set yyyy1 = `echo $DA_START_TIME | cut -c1-4`
set   mm1 = `echo $DA_START_TIME | cut -c5-6`
set   dd1 = `echo $DA_START_TIME | cut -c7-8`
set   hh1 = `echo $DA_START_TIME | cut -c9-10`

# Copy the python script here
cp ../../../zz_script/gsi_enkf/python_scripts/runme_create_sm_innov.py .

# ===============================================
# Create a file for python parameters
# ===============================================
cat >! func_parameters.py << EOF
def parameters():
    YEAR    = '${yyyy1}'
    MONTH   = '${mm1}'
    DAY     = '${dd1}'
    HOUR    = '${hh1}'
    
    return YEAR, MONTH, DAY, HOUR
EOF

# ===============================================
# Link first guess here
# ===============================================
ln -sf ../02_arw_${DA_START_TIME}/bk/wrfarw.ensmean firstguess.ensmean.nc

set ENS_MEM_ITER = 1

while ( ${ENS_MEM_ITER} <= ${GSI_ENKF_NANALS})

	# Set up member id string (only for member number < 100)
	if ($ENS_MEM_ITER<10) then
		set ENS_MEM_STR = 00${ENS_MEM_ITER}
	else
		set ENS_MEM_STR = 0${ENS_MEM_ITER}
	endif

	# Link files
	ln -sf ../02_arw_${DA_START_TIME}/bk/wrfarw.mem${ENS_MEM_STR} firstguess.mem${ENS_MEM_STR}.nc
	
	# For next member
	set ENS_MEM_ITER = `expr ${ENS_MEM_ITER} + 1`

end

# ===============================================
# Running python
# ===============================================
python runme_create_sm_innov.py


cd ../../../

