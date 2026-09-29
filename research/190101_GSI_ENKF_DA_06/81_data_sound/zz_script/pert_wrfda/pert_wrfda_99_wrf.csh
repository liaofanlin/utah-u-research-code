#!/bin/csh -x
#
# NOTE (2018.11.01): Since this day, this script is not used.

# set echo
echo "-------------------------------------------------------------------------"
echo "--- Beginning of pert_wrfda_01_wrf.csh ----------------------------------"
echo "-------------------------------------------------------------------------"

set PROGRAM_DIR					= $1
set WRF_EXE_VERSION				= $2
set PERT_WRFDA_WRF_CORE			= $3
set PROC_TIME						= $4

set ENS_MEM_STR					= $5
set WRF_NAMELIST					= $6
set PERT_WRFDA_MODULE_WRF		= $7

# =======================================================================================================
# Pre-steps

cd real_pert/wrfinput_${PROC_TIME}/mem${ENS_MEM_STR}/wrf

# Linking necessary files
# =======================
	# wrfinput
	ln -sf ../wrfda/wrfvar_output wrfinput_d01
	
	# wrfbdy
	ln -sf ../../../../real/${PROC_TIME}/wrfbdy_d01 .
	
	# Name list
	ln -sf ../../../../real/${PROC_TIME}/${WRF_NAMELIST} namelist.input

	# Link Table and Data files
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/*.TBL .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_SW_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_LW_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTM_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ETAMPNEW_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_AEROPT_DATA .
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_ABS_DATA .

	# Link ozone data for RRTMG radiation
	#	- See rn170324
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ozone* .
	
	# WRF Executable
	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/main/wrf.exe .

# Run wrf.exe
# ====================
source ${PERT_WRFDA_MODULE_WRF}
mpirun -np $SLURM_NTASKS ./wrf.exe


cd ../../../..



echo "------------------------------------------------------------------"
echo "--- End of pert_wrfda_01_perturbing_wrfinput.csh -----------------"
echo "------------------------------------------------------------------"


