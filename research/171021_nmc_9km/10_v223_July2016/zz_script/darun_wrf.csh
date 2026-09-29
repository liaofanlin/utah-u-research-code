#!/bin/csh
#
echo "-------------------------------------------------------------------------------------------------"
echo "--- Beginning of the following two paths : "
echo "---    runme_darun_4dvar.csh         --> zz_runme_darun_4dvar.csh         --> darun_wrf.csh -----"
echo "---    runme_darun_4dvar_cycling.csh --> zz_runme_darun_4dvar_cycling.csh --> darun_wrf.csh -----"
echo "-------------------------------------------------------------------------------------------------"

set NPROC      		   	= $1		# number of processors
set PROGRAM_DIR			= $2
set DA_START_DATE		= $3
set SMDA_SWITCH			= $4
set WRF_EXE_VERSION		= $5
set QUEUE_TYPE			= $6

cd wrf

ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/*.TBL .
ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_SW_DATA .
ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_LW_DATA .
ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTM_DATA .
ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ETAMPNEW_DATA .
ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_AEROPT_DATA .
ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_ABS_DATA .
ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/main/wrf.exe .


if (${SMDA_SWITCH} == 'false')  then
	ln -sf ../update_bdy/wrfbdy_d01 .
	ln -sf ../update_bdy/wrfvar_output wrfinput_d01
endif

if (${SMDA_SWITCH} == 'true') then
	ln -sf ../smda/wrfbdy_d01 .
	ln -sf ../smda/wrfinput_d01 .
endif

ln -sf ../../../real/${DA_START_DATE}/namelist.input .

# Run WRF 
# --------
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
echo "---    runme_darun_4dvar.csh         --> zz_runme_darun_4dvar.csh         --> darun_wrf.csh -----"
echo "---    runme_darun_4dvar_cycling.csh --> zz_runme_darun_4dvar_cycling.csh --> darun_wrf.csh -----"
echo "-------------------------------------------------------------------------------------------------"
