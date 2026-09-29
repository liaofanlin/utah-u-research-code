#!/bin/csh
#
echo "-------------------------------------------------------------------------------------------------"
echo "--- Beginning of the following two paths : "
echo "---    runme_darun_3dvar.csh   --> zz_runme_darun_3dvar.csh  --> darun_3dvar_wrf.csh -----"
echo "-------------------------------------------------------------------------------------------------"

set NPROC      		= $1		# number of processors
set PROGRAM_DIR		= $2
set DA_START_DATE		= $3
set SMDA_SWITCH		= $4		# This one is not used
set WRF_EXE_VERSION	= $5
set QUEUE_TYPE			= $6

##################################################################

# 1. Create a working directory
# ========================
	rm -rf wrf
	mkdir wrf

	cd wrf

# 2. Link files
# ======================
	# 2.1. data, tables, and wrf.exe
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/*.TBL .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_SW_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_LW_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTM_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ETAMPNEW_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_AEROPT_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_ABS_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/main/wrf.exe .

	# 2.2. Link ozone data for RRTMG radiation
	#	- See rn170324
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ozone* .
	
	# 2.3. Link data for the CLM Land surface model
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CLM_* .	

	# 2.4. Link wrf input and bdy files
	ln -sf ../3dvar_d01/wrfbdy_d01 .
	ln -sf ../3dvar_d01/wrfvar_output wrfinput_d01

	# 2.5. Link name list
	ln -sf ../../../real/${DA_START_DATE}/namelist.input .

# 3. Run WRF 
# ========================
	# sbatch
	if (${QUEUE_TYPE} == 'SBATCH_CHPC') then
		mpirun -np $SLURM_NTASKS ./wrf.exe
	endif

	# pbs
	if (${QUEUE_TYPE} == 'PBS') then
		mpirun -n ${NPROC} -f $PBS_NODEFILE ./wrf.exe
	endif

cd ..

echo "-------------------------------------------------------------------------------------------------"
echo "--- End of the following two paths : "
echo "---    runme_darun_3dvar.csh   --> zz_runme_darun_3dvar.csh  --> darun_3dvar_wrf.csh -----"
echo "-------------------------------------------------------------------------------------------------"
