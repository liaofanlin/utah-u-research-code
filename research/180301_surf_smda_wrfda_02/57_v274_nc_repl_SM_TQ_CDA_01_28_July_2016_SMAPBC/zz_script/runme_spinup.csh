#!/bin/csh
#
set echo

echo "-------------------------------------------------------------------------"
echo "--- Beginning of runme_spinup.csh -------------------------------------"
echo "-------------------------------------------------------------------------"

# (2018.02.06)
#	- The main difference between runme_openloop.csh and runme_spinup.csh is 
#		* section 1.99.  There is no Section 1.99 in runme_openloop.csh.
#		* Variables RUN_DIR and JOBNAME

# (2018.02.06) 
# 	- To make this script very similar to runme_spinup.csh, I set the following variable
	set RUN_DIR								= spinup	# openloop or spinup
	set JOBNAME 							= SPINUP	# WRF_OPL or SPINUP

# (2017.08.24) Make the arguments same as those in 
#		-runme_openloop_cycling.csh
#		-runme_openloop.csh
	set WPS_START_DATE					= $1
	set WPS_END_DATE 						= $2
	set NPROC      		   			= $3		# number of processors
	set PROGRAM_DIR						= $4
	
	set PBS_QUEUE							= $5
	set FORECAST_HOURS	    			= $6
	set PBS_MEM 							= $7
	set PBS_PPN								= $8
	
	set PBS_WALLTIME 						= $9
	set CASENUM 							= $10
	set FORECAST_INI_FREQ 				= $11
	set PBS_NODES							= $12

	set WRF_EXE_VERSION					= $13
	set WRF_3DVAR_EXE_VERSION			= $14
	set MODULE_FILE						= $15
	set DA_SPECIAL_MODE01				= $16

	set SMDA_NX								= $17
	set SMDA_NY								= $18
	set SMDA_NZ								= $19
	set NC_REPL_PATH						= $20

	set QUEUE_TYPE							= $21
	set SBATCH_CHPC_TIME					= $22
	set SBATCH_CHPC_NODES				= $23
	set SBATCH_CHPC_NTASKS				= $24

	set SBATCH_CHPC_ACCOUNT				= $25
	set SBATCH_CHPC_PARTITION			= $26
	set SBATCH_CHPC_NPROC				= $27
	set SBATCH_CHPC_TIME_SHORT			= $28

	set SBATCH_CHPC_NODES_SHORT		= $29
	set SBATCH_CHPC_NTASKS_SHORT		= $30

	set SBATCH_CHPC_ACCOUNT_SHORT		= $31
	set SBATCH_CHPC_PARTITION_SHORT	= $32
	set SBATCH_CHPC_NPROC_SHORT		= $33
	set WRFDA_SPINUP_SWITCH				= $34		# It is used in runme_openloop.csh or runme_openloop_cycling.csh 
	
	set ADV_TIME_EXE 						= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe
	set WORKPATH               		= `pwd`

	

####################################################################################################

# ========================================================================
# 1. Create $DATE folder and link files for WRF runs
# ========================================================================
	# ========= Note (2018.03.27) ============
	# 	- Instead of launching real.exe every given ${FORECAST_INI_FREQ}, I set a fixed 
	#	  launching frequency at 6 hours.  So far, this is true for the following script:
	#		* runme_real.csh
	#		* runme_spinup.csh
	set FORECAST_INI_FREQ_6H	= 6
	# ========================================

	set DA_START_DATE 		= ${WPS_START_DATE}
	set DA_END_DATE   		= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ_6H}`
	set FORECAST_END_TIME	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_HOURS}`

	while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		rm -rf ./${RUN_DIR}/${DA_START_DATE}
		mkdir  ./${RUN_DIR}/${DA_START_DATE}

		cd 	 ./${RUN_DIR}/${DA_START_DATE}

		# 1.1. Link Table and Data files
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/*.TBL .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_SW_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_LW_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTM_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ETAMPNEW_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_AEROPT_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_ABS_DATA .
	
		# 1.2. Link ozone data for RRTMG radiation
		#	- See rn170324
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ozone* .
		
		# 1.3. Link data for the CLM Land surface model
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CLM_* .
	
		# 1.4. Link .exe, wrfinput, wrfbdy, and name list
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/main/wrf.exe .
		ln -sf ../../real/${DA_START_DATE}/wrfbdy_d01 .
		ln -sf ../../real/${DA_START_DATE}/namelist.input .
		ln -sf ../../real/${DA_START_DATE}/wrfinput_* .

		# 1.99. Special process of the namelist for spinup runs
		if (${WRFDA_SPINUP_SWITCH} == true) then
			# Process in the namelist file
			rm namelist.input
			ln -sf ../../real/${DA_START_DATE}/namelist.input_spinup namelist.input
		
		endif 

		cd ../..

		# Set the iteration variables
		set DA_START_DATE 		= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ_6H}`
		set DA_END_DATE 			= `${ADV_TIME_EXE} ${DA_END_DATE} 	${FORECAST_INI_FREQ_6H}`
		set FORECAST_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_HOURS}`

	end
	
# ========================================================================
# 3. Generate the PBS or SBATCH script
# ========================================================================

	set DA_START_DATE 		= ${WPS_START_DATE}
	set DA_END_DATE   		= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ_6H}`
	set FORECAST_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_HOURS}`

	cd ${RUN_DIR}

	while ( ${DA_END_DATE} <= ${WPS_END_DATE} )


		cd ${DA_START_DATE}
		set WORKSPACE		= `pwd`

# 3.1. Create a pbs script
# ----------------------------------------------------------------------------------------
if (${QUEUE_TYPE} == 'PBS') then
cat >! zz_runpbs.pbs << EOF
### file:  
#PBS -N ${JOBNAME}_${CASENUM}
#PBS -l nodes=${PBS_NODES}:ppn=${PBS_PPN}
#PBS -l mem=${PBS_MEM}gb
#PBS -l walltime=${PBS_WALLTIME}:00:00
#PBS -q ${PBS_QUEUE}

source ~/${MODULE_FILE}

cd ${WORKSPACE}
mpirun -n ${NPROC} -f \$PBS_NODEFILE ./wrf.exe

EOF

qsub zz_runpbs.pbs | sed 's/.repace.pace.gatech.edu//g' >& temp.txt	# This is used for GT
endif
## ----------------------------------------------------------------------------------------
## 3.2. Create a sbatch script
if (${QUEUE_TYPE} == 'SBATCH_CHPC') then
cat >! zz_runsbatch.slurm <<EOF
#!/bin/csh
#SBATCH --time=${SBATCH_CHPC_TIME}:00:00
#SBATCH --nodes=${SBATCH_CHPC_NODES}
#SBATCH --ntasks=${SBATCH_CHPC_NTASKS}
#SBATCH --account=${SBATCH_CHPC_ACCOUNT}
#SBATCH --partition=${SBATCH_CHPC_PARTITION}
#SBATCH -o slurm-%j.out-%N
#SBATCH -e slurm-%j.err-%N
#SBATCH -J ${JOBNAME}

source ~/${MODULE_FILE}

cd ${WORKSPACE}
mpirun -np \$SLURM_NTASKS ./wrf.exe

exit 0
EOF

sbatch zz_runsbatch.slurm | sed 's/Submitted batch job //g' >& temp.txt # This is used for UofU

endif
## ---------------------------------------------------------------------------------------
# 3.3. To Create a file that informs the job ID --------
set JOB_ID = `cat temp.txt`

cat >! zz_jobID.txt << EOF
${JOBNAME}.o${JOB_ID}
EOF

rm temp.txt
## ------------------------------------------------

		cd ..

		set DA_START_DATE 		= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ_6H}`
		set DA_END_DATE 			= `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ_6H}`
		set FORECAST_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_HOURS}`
	
	end


echo "------------------------------------------------------------------"
echo "--- End of runme_spinup.csh ------------------------------------"
echo "------------------------------------------------------------------"


