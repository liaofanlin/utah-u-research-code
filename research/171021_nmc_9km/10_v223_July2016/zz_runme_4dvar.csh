#!/bin/csh -x
	rm -rf 4dvar
	mkdir 4dvar
	
	time csh ./zz_script/runme_darun_4dvar.csh \
	/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/12_install 					171021_10 							-97.0 								38.5 \
	2016070100 				2016072900 					2016073100 					/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/fnl_0p25_ncar \
	2 		4 			8						4 \
	5 		5				true 				false \
	true				"28*10." 		/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/st4 						/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/trmm/forWRFDA_v1 \
	9000 						45 					41 								603 \
	393 						1 							141 							161 \
	9000 						53 			20				150 \
	1 			301							241 							4000	\
	51			24 			apurimacforce-6							WRFDA3.4_4dvar_dm \
	64							32							120						3 \
	TRMM			false				false							1 \
	/uufs/chpc.utah.edu/common/home/u6013926/data2/coding/fortran/2017/170301_smda_v09_data2_module_04					602							392								4 \
	wrfinput_d01			/nv/hp19/llin35/data2/research/2015/151001_SMDA_exp/99_bec_nc/02_BaBEC					BaBEC.nc					smos_obs.nc \
	/uufs/chpc.utah.edu/common/home/u6013926/data2/data/smos/ori_cp34-bec/smos_for_DA_v05_20170517				false					6					01 \
	1						WRF3.9.1_dm				WRFDA3.9.1_3dvar_dm_prog02_gen_be_diags			WRFDA3.9_4dvar_dm \
	WRFPLUS3.9_dm			zpu-group10/installation/module_12_20170818.txt						0				0 \
	false				4				2				6 \
	/uufs/chpc.utah.edu/common/home/u6013926/data2/coding/fortran/2017/170401_nc_repl_v02_data2_module_04					SBATCH_CHPC						false					true \
	48				1				12				zpu \
	ember		12				12			1 \
	12	zpu	ember	12 \
	12								false			false			0 \
	2
	
	# List of the items
	# -----------------	
	#	time csh ./zz_script/runme_darun_4dvar.csh \
	#	${PROGRAM_DIR} 					${CASENUM} 						${WPS_LON} 							${WPS_LAT} \	
	#	${WPS_START_DATE} 				${WPS_END_DATE} 					${WPS_GEN_END_DATE} 				${WPS_FNL_DIR} \
	#	${WRF_SF_SURFACE_PHYSICS}		${WRF_NUM_SOIL_LAYERS} 		${WRF_MP_PHYSICS} 					${WRF_RA_SW_PHYSICS} \
	#	${GEN_BE_NL_CV_OPTIONS} 		${GEN_BE_BIN_TYPE}				${WRFDA_CHECK_MAX_IV} 				${WRFDA_USE_AMSUBOBS} \
	#	${WRFDA_USE_RAINOBS}			"${WRFDA_THIN_MESH_CONV}" 	${WRFDA_ST4_DIR} 					${WRFDA_RAIN_DIR_DA} \			# Argument 20
	#	${DXDY_D01} 						${WRF_TIMESTEP} 					${E_VERT} 								${E_WE_D01} \
	#	${E_SN_D01} 						${MAX_DOM} 						${E_WE_D02} 							${E_SN_D02} \
	#	${DXDY_D02} 						${I_PARENT_START_D02} 			${J_PARENT_START_D02}				${WRFDA_TIME_STEP} \
	#	${WRFDA_LEN_SCALING} 			${E_WE_D03}						${E_SN_D03} 							${DXDY_D03}	\
	#	${I_PARENT_START_D03}			${J_PARENT_START_D03} 			${PBS_QUEUE}							${WRFDA_CODE} \					# Argument 40
	#	${PBS_MEM}							${PBS_PPN}							${PBS_WALLTIME}						${WRFDA_MAX_ERROR_RAIN} \
	#	${WRFDA_RAIN_DA_TYPE}			${WRF_4DVAR_SWITCH}				${SMDA_SWITCH}						${WRFDA_LEN04_SCALING} \
	#  ${SMDA_EXE_PATH}					${SMDA_NX}							${SMDA_DY}								${SMDA_NZ} \
	#  ${SMDA_WRFINPUT_FILE}			${SMDA_BEC_PATH}					${SMDA_BEC_FILENAME}				${SMDA_OBS_FILENAME} \
	#	${SMDA_OBS_FILEPATH}			${CYCLING_MODE}					${FORECAST_INI_FREQ}				${SMDA_DA_STRATEGY} \			# Argument 60
	#  ${PBS_NODES}						${WRF_EXE_VERSION}				${WRF_3DVAR_EXE_VERSION}			${WRF_4DVAR_EXE_VERSION} \
	#	${WRFPLUS_EXE_VERSION}			${MODULE_FILE}					${WRFDA_I_PARENT_START}			${WRFDA_J_PARENT_START} \
	#	${DA_SPECIAL_MODE01}			${WRF_RA_LW_PHYSICS}			${WRF_BL_PBL_PHYSICS}				${WRF_CU_PHYSICS_D01} \
	#	${NC_REPL_PATH}					${QUEUE_TYPE}						${WRF_3DVAR_SWITCH}					${WRFDA_PSOT_SWITCH} \
	#	${SBATCH_CHPC_TIME}				${SBATCH_CHPC_NODES}			${SBATCH_CHPC_NTASKS}				${SBATCH_CHPC_ACCOUNT} \		# Argument 80
	#	${SBATCH_CHPC_PARTITION}		${SBATCH_CHPC_NPROC}			${SBATCH_CHPC_TIME_SHORT}			${SBATCH_CHPC_NODES_SHORT} \
	#	${SBATCH_CHPC_NTASKS_SHORT}	${SBATCH_CHPC_ACCOUNT_SHORT}	${SBATCH_CHPC_PARTITION_SHORT}	${SBATCH_CHPC_NPROC_SHORT} \
	#	${NPROC}							${GEN_BE_CYCLE_SWITCH}			${GEN_BE_UNIVERSE_SWITCH}			${WRFDA_CLOUD_CV_OPTIONS} \
	#	${WRF_SF_SFCLAY_PHYSICS}
