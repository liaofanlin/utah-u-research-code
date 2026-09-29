#!/bin/csh
#

set NPROC_FAST   				= $1		# number of processors
set START_DATE					= $2
set PROGRAM_DIR				= $3
set WRF_EXE_VERSION			= $4

set QUEUE_TYPE					= $5
set GEN_BE_CYCLE_SWITCH		= $6
set GEN_BE_UNIVERSE_SWITCH	= $7

# =========================================================

cd wrf/${START_DATE}

# Links of running files
# ----------------------
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/*.TBL .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_SW_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_LW_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTM_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ETAMPNEW_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_AEROPT_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_ABS_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/main/wrf.exe .
		
# Link ozone data for RRTMG radiation
# -----------------------------------
#	- See rn170324
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ozone* .

	
# Link wrfbdy, wrfinput, and name list
# -----------------------------------
	ln -sf ../../real/${START_DATE}/wrfbdy_d01 .
	ln -sf ../../real/${START_DATE}/wrfinput_d01 .	
	ln -sf ../../real/${START_DATE}/namelist.input .

# MPIRUN
# -------
	# sbatch
	if (${QUEUE_TYPE} == 'SBATCH_CHPC') then
		mpirun -np $SLURM_NTASKS ./wrf.exe
	endif

	# pbs
	if (${QUEUE_TYPE} == 'PBS') then
		mpirun -n ${NPROC_FAST} -f $PBS_NODEFILE ./wrf.exe
	endif

cd ../..

echo "-----------------------------------------------------"
echo "--- End of runme_gen_be.csh -- > gen_be_wrf.csh   ---"
echo "-----------------------------------------------------"

