#!/bin/csh
#

set echo
echo "-------------------------------------------------------------------------"
echo "--- Beginning of runme_darun_3dvar.csh ----------------------------------"
echo "-------------------------------------------------------------------------"

	# 2017.08.24: The arguments have to be the same as those files of
	#	- runme_darun_3dvar.csh
	#	- runme_darun_4dvar.csh
	#	- runme_darun_4dvar_cycling.csh
	set PROGRAM_DIR						= $1
	set CASENUM								= $2
	set WPS_LON								= $3
	set WPS_LAT								= $4
	
	set WPS_START_DATE					= $5
	set WPS_END_DATE						= $6
	set WPS_GEN_END_DATE					= $7 	# Not used (2013.09.03)
	set WPS_FNL_DIR						= $8
		
	set WRF_SF_SURFACE_PHYSICS			= $9
	set WRF_NUM_SOIL_LAYERS				= $10
	set WRF_MP_PHYSICS					= $11
	set WRF_RA_SW_PHYSICS				= $12
	
	set GEN_BE_NL_CV_OPTIONS			= $13
	set GEN_BE_BIN_TYPE					= $14
	set WRFDA_CHECK_MAX_IV				= $15
	set WRFDA_USE_AMSUBOBS				= $16
	
	set WRFDA_USE_RAINOBS				= $17	
	set WRFDA_THIN_MESH_CONV			= "$18"
	set WRFDA_ST4_DIR						= $19
	set WRFDA_RAIN_DIR_DA				= $20
	
	set DXDY_D01							= $21
	set WRF_TIMESTEP						= $22
	set E_VERT								= $23
	set E_WE_D01							= $24
	
	set E_SN_D01							= $25
	set MAX_DOM								= $26
	set E_WE_D02							= $27
	set E_SN_D02							= $28
	
	set DXDY_D02							= $29
	set I_PARENT_START_D02				= $30
	set J_PARENT_START_D02				= $31
	set WRFDA_TIME_STEP					= $32
	
	set WRFDA_LEN_SCALING				= $33
	set E_WE_D03							= $34
	set E_SN_D03							= $35
	set DXDY_D03							= $36
	
	set I_PARENT_START_D03				= $37
	set J_PARENT_START_D03				= $38
	set PBS_QUEUE							= $39
	set WRFDA_CODE							= $40	# Not used (2017.08.25)
		
	set PBS_MEM 							= $41
	set PBS_PPN								= $42
	set PBS_WALLTIME						= $43
	set WRFDA_MAX_ERROR_RAIN			= $44
		
	set WRFDA_RAIN_DA_TYPE 				= $45
	set WRF_4DVAR_SWITCH					= $46
	set SMDA_SWITCH						= $47
	set WRFDA_LEN04_SCALING				= $48

	set SMDA_EXE_PATH 					= $49
	set SMDA_NX								= $50
	set SMDA_NY								= $51
	set SMDA_NZ								= $52

	set SMDA_WRFINPUT_FILE				= $53
	set SMDA_BEC_PATH						= $54
	set SMDA_BEC_FILENAME				= $55
	set SMDA_OBS_FILENAME				= $56
	
	set SMDA_OBS_FILEPATH				= $57
	set CYCLING_MODE						= $58
	set FORECAST_INI_FREQ				= $59
	set SMDA_DA_STRATEGY					= $60
	
	set PBS_NODES							= $61
	set WRF_EXE_VERSION					= $62
	set WRF_3DVAR_EXE_VERSION			= $63
	set WRF_4DVAR_EXE_VERSION			= $64
	
	set WRFPLUS_EXE_VERSION				= $65
	set MODULE_FILE						= $66
	set WRFDA_I_PARENT_START			= $67
	set WRFDA_J_PARENT_START			= $68
	
	set DA_SPECIAL_MODE01				= $69
	set WRF_RA_LW_PHYSICS				= $70
	set WRF_BL_PBL_PHYSICS				= $71
	set WRF_CU_PHYSICS_D01				= $72
	
	set NC_REPL_PATH						= $73
	set QUEUE_TYPE							= $74
	set WRF_3DVAR_SWITCH					= $75
	set WRFDA_PSOT_SWITCH				= $76
	
	set SBATCH_CHPC_TIME					= $77
	set SBATCH_CHPC_NODES				= $78
	set SBATCH_CHPC_NTASKS				= $79
	set SBATCH_CHPC_ACCOUNT				= $80
	
	set SBATCH_CHPC_PARTITION			= $81
	set SBATCH_CHPC_NPROC				= $82
	set SBATCH_CHPC_TIME_SHORT			= $83
	set SBATCH_CHPC_NODES_SHORT		= $84

	set SBATCH_CHPC_NTASKS_SHORT		= $85
	set SBATCH_CHPC_ACCOUNT_SHORT		= $86
	set SBATCH_CHPC_PARTITION_SHORT	= $87
	set SBATCH_CHPC_NPROC_SHORT		= $88
	
	set NPROC								= $89
	set GEN_BE_CYCLE_SWITCH				= $90
	set GEN_BE_UNIVERSE_SWITCH			= $91
	set WRFDA_CLOUD_CV_OPTIONS			= $92
	
	set WRF_SF_SFCLAY_PHYSICS			= $93

	set ADV_TIME_EXE 						= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

# =======================================================================================================

set DA_START_DATE = ${WPS_START_DATE}
set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_START_DATE} 6`

while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

	rm -rf ./3dvar/${DA_START_DATE}
	mkdir  ./3dvar/${DA_START_DATE}
	mkdir  ./3dvar/${DA_START_DATE}/3dvar
	mkdir  ./3dvar/${DA_START_DATE}/psot

	mkdir ./3dvar/${DA_START_DATE}/zz_script
	cp zz_script/darun_3dvar.csh 	./3dvar/${DA_START_DATE}/zz_script/
	cp zz_script/darun_psot.csh 	./3dvar/${DA_START_DATE}/zz_script/


	cd ./3dvar/${DA_START_DATE}


# -------------------------------------------------------------------------------------------------
# ---------------Under DA_START_DATE --------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
cat >! zz_runme_darun_3dvar.csh << EOF
#!/bin/csh
#

	set echo
	echo "-------------------------------------------------------------------------"
	echo "--- Running the runme_darun_3dvar.csh------------------------------------"
	echo "-------------------------------------------------------------------------"

	# 2017.08.25: Make the arguments the same as above
	set PROGRAM_DIR						= $1
	set CASENUM								= $2
	set WPS_LON								= $3
	set WPS_LAT								= $4
	
	set WPS_START_DATE					= $5
	set WPS_END_DATE						= $6
	set WPS_GEN_END_DATE					= $7 	# Not used (2013.09.03)
	set WPS_FNL_DIR						= $8
		
	set WRF_SF_SURFACE_PHYSICS			= $9
	set WRF_NUM_SOIL_LAYERS				= $10
	set WRF_MP_PHYSICS					= $11
	set WRF_RA_SW_PHYSICS				= $12
	
	set GEN_BE_NL_CV_OPTIONS			= $13
	set GEN_BE_BIN_TYPE					= $14
	set WRFDA_CHECK_MAX_IV				= $15
	set WRFDA_USE_AMSUBOBS				= $16
	
	set WRFDA_USE_RAINOBS				= $17	
	set WRFDA_THIN_MESH_CONV			= "$18"
	set WRFDA_ST4_DIR						= $19
	set WRFDA_RAIN_DIR_DA				= $20
	
	set DXDY_D01							= $21
	set WRF_TIMESTEP						= $22
	set E_VERT								= $23
	set E_WE_D01							= $24
	
	set E_SN_D01							= $25
	set MAX_DOM								= $26
	set E_WE_D02							= $27
	set E_SN_D02							= $28
	
	set DXDY_D02							= $29
	set I_PARENT_START_D02				= $30
	set J_PARENT_START_D02				= $31
	set WRFDA_TIME_STEP					= $32
	
	set WRFDA_LEN_SCALING				= $33
	set E_WE_D03							= $34
	set E_SN_D03							= $35
	set DXDY_D03							= $36
	
	set I_PARENT_START_D03				= $37
	set J_PARENT_START_D03				= $38
	set PBS_QUEUE							= $39
	set WRFDA_CODE							= $40	# Not used (2017.08.25)
		
	set PBS_MEM 							= $41
	set PBS_PPN								= $42
	set PBS_WALLTIME						= $43
	set WRFDA_MAX_ERROR_RAIN			= $44
		
	set WRFDA_RAIN_DA_TYPE 				= $45
	set WRF_4DVAR_SWITCH					= $46
	set SMDA_SWITCH						= $47
	set WRFDA_LEN04_SCALING				= $48

	set SMDA_EXE_PATH 					= $49
	set SMDA_NX								= $50
	set SMDA_NY								= $51
	set SMDA_NZ								= $52

	set SMDA_WRFINPUT_FILE				= $53
	set SMDA_BEC_PATH						= $54
	set SMDA_BEC_FILENAME				= $55
	set SMDA_OBS_FILENAME				= $56
	
	set SMDA_OBS_FILEPATH				= $57
	set CYCLING_MODE						= $58
	set FORECAST_INI_FREQ				= $59
	set SMDA_DA_STRATEGY					= $60
	
	set PBS_NODES							= $61
	set WRF_EXE_VERSION					= $62
	set WRF_3DVAR_EXE_VERSION			= $63
	set WRF_4DVAR_EXE_VERSION			= $64
	
	set WRFPLUS_EXE_VERSION				= $65
	set MODULE_FILE						= $66
	set WRFDA_I_PARENT_START			= $67
	set WRFDA_J_PARENT_START			= $68
	
	set DA_SPECIAL_MODE01				= $69
	set WRF_RA_LW_PHYSICS				= $70
	set WRF_BL_PBL_PHYSICS				= $71
	set WRF_CU_PHYSICS_D01				= $72
	
	set NC_REPL_PATH						= $73
	set QUEUE_TYPE							= $74
	set WRF_3DVAR_SWITCH					= $75
	set WRFDA_PSOT_SWITCH				= $76
	
	set SBATCH_CHPC_TIME					= $77
	set SBATCH_CHPC_NODES				= $78
	set SBATCH_CHPC_NTASKS				= $79
	set SBATCH_CHPC_ACCOUNT				= $80
	
	set SBATCH_CHPC_PARTITION			= $81
	set SBATCH_CHPC_NPROC				= $82
	set SBATCH_CHPC_TIME_SHORT			= $83
	set SBATCH_CHPC_NODES_SHORT		= $84

	set SBATCH_CHPC_NTASKS_SHORT		= $85
	set SBATCH_CHPC_ACCOUNT_SHORT		= $86
	set SBATCH_CHPC_PARTITION_SHORT	= $87
	set SBATCH_CHPC_NPROC_SHORT		= $88
	
	set NPROC								= $89
	set GEN_BE_CYCLE_SWITCH				= $90
	set GEN_BE_UNIVERSE_SWITCH			= $91
	set WRFDA_CLOUD_CV_OPTIONS			= $92
	
	set WRF_SF_SFCLAY_PHYSICS			= $93

	set ADV_TIME_EXE 						= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

	# Other Setup
	set DA_START_DATE 	= ${DA_START_DATE}
	set DA_END_DATE 		= ${DA_END_DATE}
# --------------------------------------------------------------------------------------------------------------



	echo "Current DA_START_DATE = " ${DA_START_DATE}
	echo "Current path is at:" `pwd`


	# WRF 3DVAR
	# ---------
		if (\${WRF_3DVAR_SWITCH} == 'true') then
			time csh ./zz_script/darun_3dvar.csh \
			\${WRF_SF_SURFACE} 			\${WRF_NUM_SOIL_LAYERS} 	\${WRF_PHY_MP} 				\${GEN_BE_NL_CV_OPTIONS} \
			\${GEN_BE_BIN_TYPE}				\${WRFDA_CHECK_MAX_IV}		\${DXDY_D01}					\${WRF_TIMESTEP} \
			\${WRFDA_USE_AMSUBOBS}	 		\${WRFDA_USE_RAINOBS}		"\${WRFDA_THIN_MESH_CONV}" \${E_VERT} \
			\${WRF_RA_SW_PHYSICS} 			\${E_WE_D01}					\${E_SN_D01}					\${DA_START_DATE} \
			\${DA_END_DATE} 					\${PROGRAM_DIR} 				\${WRFDA_ST4_DIR} 			\${WRFDA_RAIN_DIR_DA} \
			\${WRFDA_TIME_STEP}				\${WRFDA_LEN_SCALING}		\${WRFDA_CODE}					\${WRFDA_MAX_ERROR_RAIN} \
			\${WRFDA_RAIN_DA_TYPE}			\${WRFDA_LEN04_SCALING}		\${CYCLING_MODE}				\${WPS_START_DATE} \
			\${WRF_4DVAR_EXE_VERSION}		\${WRFPLUS_EXE_VERSION}		\${WRFDA_I_PARENT_START}	\${WRFDA_J_PARENT_START} \
			\${DA_SPECIAL_MODE01}			\${SMDA_NX}						\${SMDA_NY}						\${SMDA_NZ} \
			\${WRF_RA_LW_PHYSICS}			\${WRF_BL_PBL_PHYSICS}		\${WRF_CU_PHYSICS_D01}		\${NC_REPL_PATH} \
			\${QUEUE_TYPE}						\${WRF_3DVAR_EXE_VERSION}	\${NPROC}						\${GEN_BE_CYCLE_SWITCH} \
			\${GEN_BE_UNIVERSE_SWITCH}		\${WRFDA_CLOUD_CV_OPTIONS}	\${WRF_SF_SFCLAY_PHYSICS}
		endif

	# PSOT
	# ----
		if (\${WRFDA_PSOT_SWITCH} == 'true') then
			csh ./zz_script/darun_psot.csh

		endif


EOF


set WORKSPACE		= `pwd`
set JOBNAME 		= WRF_3DVAR

## 4. Loading module and submitting pbs
## ---------------------------------

# 4.1. Create a pbs script
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
time csh zz_runme_darun_3dvar.csh

EOF

qsub zz_runpbs.pbs | sed 's/.repace.pace.gatech.edu//g' >& temp.txt	# This is used for GT
endif
## ----------------------------------------------------------------------------------------
## 4.2. Create a sbatch script
if (${QUEUE_TYPE} == 'SBATCH_CHPC') then
cat >! zz_runsbatch.slurm <<EOF
#!/bin/csh
#SBATCH --time=${SBATCH_CHPC_TIME}:00:00
#SBATCH --nodes=${SBATCH_CHPC_NODES}
#SBATCH --ntasks=${SBATCH_CHPC_NTASKS}
#SBATCH --account=${SBATCH_CHPC_ACCOUNT}
#SBATCH --partition=${SBATCH_CHPC_PARTITION}
#SBATCH -o slurm-%j.out-%N
#SBATCH -J ${JOBNAME}

source ~/${MODULE_FILE}

cd ${WORKSPACE}
time csh zz_runme_darun_3dvar.csh

exit 0
EOF

sbatch zz_runsbatch.slurm | sed 's/Submitted batch job //g' >& temp.txt # This is used for UofU

endif
## ---------------------------------------------------------------------------------------
# To Create a file that informs the job ID --------
set JOB_ID = `cat temp.txt`

cat >! zz_jobID.txt << EOF
${JOBNAME}.o${JOB_ID}
EOF

rm temp.txt
## ------------------------------------------------


	cd ../..

# --------------------------------------------------------------------------------
	
	set DA_START_DATE 	= `${ADV_TIME_EXE} ${DA_START_DATE} 6`
	set DA_END_DATE 	= `${ADV_TIME_EXE} ${DA_END_DATE} 6`
	
end


echo "------------------------------------------------------------------"
echo "--- End of runme_darun_3dvar.csh ---------------------------------"
echo "------------------------------------------------------------------"



