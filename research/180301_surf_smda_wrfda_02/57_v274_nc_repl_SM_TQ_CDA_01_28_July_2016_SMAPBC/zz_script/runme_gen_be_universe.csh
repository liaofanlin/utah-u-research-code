#!/bin/csh
#

set echo
echo "-------------------------------------------------------------------------"
echo "--- Beginning of runme_gen_be_universe.csh ------------------------------"
echo "-------------------------------------------------------------------------"

	# The following arguments have to be the same for 
	#	- runme_ge_be_cycle.csh
	#	- runme_ge_be_universe.csh
	set PROGRAM_DIR						= $1
	set WPS_LON								= $2
	set WPS_LAT								= $3 
	set WPS_START_DATE					= $4

	set WPS_END_DATE						= $5
	set WPS_GEN_END_DATE					= $6
	set WPS_FNL_DIR						= $7
	set WRF_SF_SURFACE_PHYSICS			= $8

	set WRF_NUM_SOIL_LAYERS				= $9
	set WRF_MP_PHYSICS					= $10
	set WRF_RA_SW_PHYSICS				= $11
	set WRF_SF_SFCLAY_PHYSICS			= $12

	set DXDY_D01							= $13
	set WRF_TIMESTEP						= $14
	set E_VERT								= $15
	set E_WE_D01							= $16

	set E_SN_D01							= $17
	set CASENUM 							= $18
	set PBS_PPN_FAST						= $19
	set PBS_MEM_FAST						= $20

	set PBS_WALLTIME_FAST				= $21
	set PBS_QUEUE_FAST					= $22
	set WRF_EXE_VERSION					= $23
	set WRF_4DVAR_EXE_VERSION			= $24

	set WRF_3DVAR_EXE_VERSION			= $25
	set MODULE_FILE						= $26
	set WRF_FEEDBACK						= $27
	set WRF_RA_LW_PHYSICS				= $28

	set WRF_BL_PBL_PHYSICS				= $29
	set WRF_CU_PHYSICS_D01				= $30
	set WPS_DATA_TYPE						= $31
	set QUEUE_TYPE							= $32

	set SBATCH_CHPC_TIME					= $33
	set SBATCH_CHPC_NODES				= $34
	set SBATCH_CHPC_NTASKS				= $35
	set SBATCH_CHPC_ACCOUNT				= $36

	set SBATCH_CHPC_PARTITION			= $37
	set SBATCH_CHPC_NPROC				= $38
	set SBATCH_CHPC_TIME_SHORT			= $39
	set SBATCH_CHPC_NODES_SHORT		= $40

	set SBATCH_CHPC_NTASKS_SHORT		= $41
	set SBATCH_CHPC_ACCOUNT_SHORT		= $42
	set SBATCH_CHPC_PARTITION_SHORT	= $43
	set SBATCH_CHPC_NPROC_SHORT		= $44

	set GEN_BE_NL_CV_OPTION				= $45
	set GEN_BE_BE_BIN_TYPE				= $46
	set GEN_BE_CYCLE_SWITCH				= $47
	set GEN_BE_UNIVERSE_SWITCH			= $48

	set GEN_BE_WRAPPER_INTERVAL		= $49
	set NPROC_FAST							= $50
	
	set ADV_TIME_EXE 						= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe


## =============================================================================
	pwd

	
	# Make folders and copy scripts
	# ------------------------------
		mkdir ./gen_be_universe/fc
		mkdir ./gen_be_universe/real
		mkdir ./gen_be_universe/wrf
		mkdir ./gen_be_universe/gen_be_anal

		mkdir ./gen_be_universe/zz_script
		cp zz_script/gen_be_fc.csh 				./gen_be_universe/zz_script/
		cp zz_script/gen_be_real.csh 				./gen_be_universe/zz_script/
		cp zz_script/gen_be_wrapper.ksh 			./gen_be_universe/zz_script/
		cp zz_script/gen_be_wrf.csh 				./gen_be_universe/zz_script/
		cp zz_script/gen_be_anal.csh				./gen_be_universe/zz_script/

		cp zz_script/gen_be_plot_wrapper.ksh 	./gen_be_universe/gen_be_anal	
	
	# Go to the gen_be folder
		cd ./gen_be_universe
	

	
# -------------------------------------------------------------------------------------------------
# ---------------Under GEN ----------------------------------------------------------
# -------------------------------------------------------------------------------------------------	
	
cat >! zz_runme_gen_be_universe.csh << EOF
#!/bin/csh
#	
	
	set echo
	echo "-------------------------------------------------------------------------------"
	echo "--- Beginning of runme_gen_be_universe.csh --> zz_runme_gen_be_universe.csh ---"
	echo "-------------------------------------------------------------------------------"
	
	# 2017.08.25: Keep the following arguments the same as above
	set PROGRAM_DIR						= $1
	set WPS_LON								= $2
	set WPS_LAT								= $3 
	set WPS_START_DATE					= $4

	set WPS_END_DATE						= $5
	set WPS_GEN_END_DATE					= $6
	set WPS_FNL_DIR						= $7
	set WRF_SF_SURFACE_PHYSICS			= $8

	set WRF_NUM_SOIL_LAYERS				= $9
	set WRF_MP_PHYSICS					= $10
	set WRF_RA_SW_PHYSICS				= $11
	set WRF_SF_SFCLAY_PHYSICS			= $12

	set DXDY_D01							= $13
	set WRF_TIMESTEP						= $14
	set E_VERT								= $15
	set E_WE_D01							= $16

	set E_SN_D01							= $17
	set CASENUM 							= $18
	set PBS_PPN_FAST						= $19
	set PBS_MEM_FAST						= $20

	set PBS_WALLTIME_FAST				= $21
	set PBS_QUEUE_FAST					= $22
	set WRF_EXE_VERSION					= $23
	set WRF_4DVAR_EXE_VERSION			= $24

	set WRF_3DVAR_EXE_VERSION			= $25
	set MODULE_FILE						= $26
	set WRF_FEEDBACK						= $27
	set WRF_RA_LW_PHYSICS				= $28

	set WRF_BL_PBL_PHYSICS				= $29
	set WRF_CU_PHYSICS_D01				= $30
	set WPS_DATA_TYPE						= $31
	set QUEUE_TYPE							= $32

	set SBATCH_CHPC_TIME					= $33
	set SBATCH_CHPC_NODES				= $34
	set SBATCH_CHPC_NTASKS				= $35
	set SBATCH_CHPC_ACCOUNT				= $36

	set SBATCH_CHPC_PARTITION			= $37
	set SBATCH_CHPC_NPROC				= $38
	set SBATCH_CHPC_TIME_SHORT			= $39
	set SBATCH_CHPC_NODES_SHORT		= $40

	set SBATCH_CHPC_NTASKS_SHORT		= $41
	set SBATCH_CHPC_ACCOUNT_SHORT		= $42
	set SBATCH_CHPC_PARTITION_SHORT	= $43
	set SBATCH_CHPC_NPROC_SHORT		= $44

	set GEN_BE_NL_CV_OPTION				= $45
	set GEN_BE_BE_BIN_TYPE				= $46
	set GEN_BE_CYCLE_SWITCH				= $47
	set GEN_BE_UNIVERSE_SWITCH			= $48

	set GEN_BE_WRAPPER_INTERVAL		= $49
	set NPROC_FAST							= $50
	
	set ADV_TIME_EXE 						= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe
	

# =========================================================	
	# Run WRF Forecasts
	# -----------------
		set GEN_BE_LOOP_START_DATE 	= \${WPS_START_DATE}
		set GEN_BE_LOOP_END_DATE		= `\${ADV_TIME_EXE} \${WPS_GEN_END_DATE} -24`

		while ( \${GEN_BE_LOOP_START_DATE} <= \${GEN_BE_LOOP_END_DATE} )

			set END_DATE = \`\${ADV_TIME_EXE} \${GEN_BE_LOOP_START_DATE} 24\`
			
			mkdir real/\${GEN_BE_LOOP_START_DATE}
			csh ./zz_script/gen_be_real.csh \
			\${WRF_SF_SURFACE_PHYSICS}	\${WRF_NUM_SOIL_LAYERS} 	\${WRF_MP_PHYSICS}			\${GEN_BE_LOOP_START_DATE} \
			\${END_DATE} 					\${DXDY_D01} 					\${WRF_TIMESTEP} 				\${E_VERT} \
			\${WRF_RA_SW_PHYSICS} 		\${E_WE_D01} 					\${E_SN_D01} 					\${PROGRAM_DIR} \
			\${WRF_EXE_VERSION}			\${WRF_FEEDBACK}				\${WRF_RA_LW_PHYSICS}		\${WRF_BL_PBL_PHYSICS} \
			\${WRF_CU_PHYSICS_D01}		\${WPS_DATA_TYPE}				\${GEN_BE_CYCLE_SWITCH}		\${GEN_BE_UNIVERSE_SWITCH} \
			\${WRF_SF_SFCLAY_PHYSICS}
			
			mkdir wrf/\${GEN_BE_LOOP_START_DATE}
			csh ./zz_script/gen_be_wrf.csh  \
			\${NPROC_FAST}  				\${GEN_BE_LOOP_START_DATE} \${PROGRAM_DIR}				\${WRF_EXE_VERSION} \
			\${QUEUE_TYPE}					\${GEN_BE_CYCLE_SWITCH}		\${GEN_BE_UNIVERSE_SWITCH}
			
			mkdir fc/\${GEN_BE_LOOP_START_DATE}
			csh ./zz_script/gen_be_fc.csh \
			\${GEN_BE_LOOP_START_DATE}
	
			set GEN_BE_LOOP_START_DATE = \`\${ADV_TIME_EXE} \${GEN_BE_LOOP_START_DATE} \${GEN_BE_WRAPPER_INTERVAL}\`
	
		end		
			
	# Run GEN_BE
	# ----------
		set WRAPPER_START_DATE 	= \`\${ADV_TIME_EXE} \${WPS_START_DATE} 24\`
		set WRAPPER_END_DATE 	= \`\${ADV_TIME_EXE} \${WPS_GEN_END_DATE} -24\`

		ksh ./zz_script/gen_be_wrapper.ksh \
		\${E_VERT}						\${WRAPPER_START_DATE}		\${WRAPPER_END_DATE}		\${PROGRAM_DIR} \
		\${WRF_3DVAR_EXE_VERSION}	\${GEN_BE_NL_CV_OPTION}		\${GEN_BE_BE_BIN_TYPE}	\${GEN_BE_WRAPPER_INTERVAL}

	# Post Processing
	# ---------------
		csh ./zz_script/gen_be_anal.csh \
		\${PROGRAM_DIR}	\${WRF_3DVAR_EXE_VERSION}	\${GEN_BE_NL_CV_OPTION}		\${GEN_BE_BE_BIN_TYPE}
		
EOF



# Process of submitting the job
# -----------------------------
set WORKSPACE	= `pwd`
set JOBNAME 	= GEN_BE

## 4. Loading module and submitting pbs
## ---------------------------------
# 4.1. Create a pbs script
# ------------------------
if (${QUEUE_TYPE} == 'PBS') then
cat >! zz_runpbs.pbs << EOF
### file:  
#PBS -N ${JOBNAME}_${CASENUM}_${DA_START_DATE}
#PBS -l nodes=1:ppn=${PBS_PPN_FAST}
#PBS -l mem=${PBS_MEM_FAST}gb
#PBS -l walltime=${PBS_WALLTIME_FAST}:00:00
#PBS -q ${PBS_QUEUE_FAST}

source ~/${MODULE_FILE}

cd ${WORKSPACE}
time csh zz_runme_gen_be_universe.csh

EOF

qsub zz_runpbs.pbs | sed 's/.repace.pace.gatech.edu//g' >& temp.txt	# This is used for GT
endif

# 4.2. Create a sbatch script
# ---------------------------
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
time csh zz_runme_gen_be_universe.csh

exit 0
EOF

sbatch zz_runsbatch.slurm | sed 's/Submitted batch job //g' >& temp.txt # This is used for UofU

endif
##


set JOB_ID = `cat temp.txt`

cat >! zz_jobID.txt << EOF
${JOBNAME}.o${JOB_ID}
EOF

rm temp.txt

cd ..

# --------------------------------------------------------------------------------

		
echo "-------------------------------------------------------------------"
echo "--- End of runme_gen_be_universe.csh ------------------------------"
echo "-------------------------------------------------------------------"
		
		
		
