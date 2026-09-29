#!/bin/csh -x
#

set echo
# Note (2017.08.20):
# ------------------
# 	- Please see the removed scripts appeared in GT clusters in 
#
# Note (2015.03.18):
# ------------------
# 	- In order to switch between old and new versions of compilation, I need to vary:
# 		* PROGRAM_DIR, MODULE_FILE, WPS_EXE_VERSION, WPS_GEOG_PATH, WRFDA_EXE_VERSION, and WRF_EXE_VERSION
#		* WRFDA_THIN_MESH_CONV, WRFDA_I_PARENT_START, WRFDA_J_PARENT_START
#
# Note (2014.09.21):
# ------------------
# 	- This script has the following function
# 		1. zz_runme_darun.csh, 
#		2. zz_runme_matlab.csh (make sure to manually change queue to iw-shared-6) 
#		3. zz_runme_linkingmatlab.csh  
#		4. zz_script/runme_job_del.csh (I may need to manually change a little bit of the script)
# 		5. zz_checking.csh
#
# Note (2014.06.27):
# ------------------
# 	- Please check each variable one by one and see if it necessary to change it
#
# Note (2014.05.23):
# ------------------
#	- Frequent variable needed change:
# 	  CASENUM, all switches, WPS_START_DATE, WPS_END_DATE, WPS_GEN_END_DATE, WRFDA_THIN_MESH_CONV, WRFDA_RAIN_DIR_DA, WRFDA_RAIN_DA_TYPE
	
# ======================	
# Top setting	
# ======================
	set CASENUM						= 180301_51				# Study date and then case number
	set QUEUE_TYPE					= SBATCH_CHPC			# Either "SBATCH_CHPC" (used in UofU) or "PBS" (used in GT)
	
	# Storage 10 (ZPU)
	# ----------------
	#                      | 12_install                                    
	# -----------------------------------------------------------------
	# MODULE_FILE          | zpu-group10/installation/module_12_20170818.txt 
	# PROGRAM_DIR          | ~/zpu-group10/installation/12_install           
	# WPS_EXE_VERSION      | WPS3.9.1                                    
	# WPS_GEOG_PATH        | ${PROGRAM_DIR}/wps/geog                   
	# WRFDA_EXE_VERSION    | WRFDA3.9.1_3dvar_dm                         
	# WRFPLUS_EXE_VERSION  | WRFPLUS3.4_dm                             
	# WRFDA_THIN_MESH_CONV | "28*10."                                 
	# WRFDA_I_PARENT_START | 0                                       
	# WRFDA_J_PARENT_START | 0 								         
	# WRF_EXE_VERSION      | WRF3.9.1_dm                               	
    


	# The reason for the following setup can be found at 
	# https://liaofanprogress01.files.wordpress.com/2014/12/150206_rn_compilation-and-runtime-issue-of-wrf-and-wrfda-3-6-1.pdf
		# WRFDA_THIN_MESH_CONV
		# WRFDA_I_PARENT_START
		# WRFDA_J_PARENT_START
					
		set MODULE_FILE = zpu-group10/installation/module_12_20170818.txt

	
		# For 12_install (zpu-group10)
		if (${MODULE_FILE} == 'zpu-group10/installation/module_12_20170818.txt') then	
			set PROGRAM_DIR				= ~/zpu-group10/installation/12_install
			set WPS_EXE_VERSION			= WPS3.9.1
			set WPS_GEOG_PATH				= ${PROGRAM_DIR}/wps/geog
			set WRF_4DVAR_EXE_VERSION	= WRFDA3.9_4dvar_dm
			set WRF_3DVAR_EXE_VERSION 	= WRFDA3.9.1_3dvar_dm_prog02_gen_be_diags
			set WRFPLUS_EXE_VERSION		= WRFPLUS3.9_dm
			set WRFDA_I_PARENT_START	= 0
			set WRFDA_J_PARENT_START	= 0	
			set WRF_EXE_VERSION			= WRF3.9.1_dm		
			set SMDA_EXE_PATH				= ~/data2/coding/fortran/2017/170301_smda_v09_data2_module_04
			set NC_REPL_PATH				= ~/data2/coding/fortran/2017/170401_nc_repl_v02_data2_module_04
		endif



	# SBATCH USED AT U OF U
	# ---------------------
      # Regular setting for 3D-Var, 4D-Var, OPL, and GEN_BE
      #  - Choices for the combination of SBATCH_CHPC_ACCOUNT & SBATCH_CHPC_PARTITION
		#		* ACCOUNT		| PARTITION
		#		* -------------------------
		#		* zpu				| kingspeak
		#		* zpu				| ember
		#		* zpu				| lonepeak
		#		* zpu				| notchpeak
		#		* zpu-kp			| zpu-kp
		#		* zpu-em			| zpu-em
		#		* zpu-np			| zpu-np
		#		* owner-guest	| notchpeak-guest
		#		* owner-guest	| kingspeak-guest
		#		* owner-guest	| ember-guest

		set SBATCH_CHPC_TIME					= 48						# Number of hours
		set SBATCH_CHPC_NODES				= 2
		set SBATCH_CHPC_NTASKS				= 48					# Total CPUs
		set SBATCH_CHPC_ACCOUNT				= owner-guest			# See above
		set SBATCH_CHPC_PARTITION			= kingspeak-guest		# See above
		set SBATCH_CHPC_NPROC				= 48

		# Setting for short jobs (e.g., MATLAB)
		set SBATCH_CHPC_TIME_SHORT			= 12
		set SBATCH_CHPC_NODES_SHORT		= 1
		set SBATCH_CHPC_NTASKS_SHORT		= 12
		set SBATCH_CHPC_ACCOUNT_SHORT		= zpu				# zpu, zpu-kp, zpu-em
		set SBATCH_CHPC_PARTITION_SHORT	= ember			# kingspeak, ember, zpu-kp, zpu-em, lonepeak
		set SBATCH_CHPC_NPROC_SHORT		= 12

	# PBS USED AT GEORGIA TECH
	# -------------------------
		# Regular setting for DA and Openloop runs
		set PBS_QUEUE					= apurimacforce-6
		set PBS_MEM 					= 64
		set PBS_PPN 					= 32
		set PBS_WALLTIME 				= 120
		set PBS_NODES					= 1
		set NPROC						= ${SBATCH_CHPC_NPROC}		# Set it equal to SBATCH_NPROC. Need to change it when using PBS
	
		# Fast setting for gen_be and real
		set PBS_QUEUE_FAST			= iw-shared-6	
		set PBS_MEM_FAST				= 8
		set PBS_PPN_FAST				= 2
		set PBS_WALLTIME_FAST		= 12
		set NPROC_FAST					= ${SBATCH_CHPC_NPROC}		# Set it equal to SBATCH_NPROC. Need to change it when using PBS
	
		# Short setting for MATLAB
		set PBS_QUEUE_MATLAB			= apurimacforce-6
		set PBS_MEM_MATLAB			= 8
		set PBS_PPN_MATLAB			= 2
		set PBS_WALLTIME_MATLAB		= 120

	# Experiment Setup
	set FORECAST_HOURS 					= 72					# used by real.exe; use 6 for wrfda; use 24 for SM BEC study
	set FORECAST_INI_FREQ 				= 12 					# The frequency of folder creation; use 6 for wrfda; use 12 for SM BEC study
	set FORECAST_HOURS_CDA_CYCLING 	= 672 

# ======================
# Switch
# ======================
	set WRF_4DVAR_SWITCH							= false
	set WRF_3DVAR_SWITCH							= false
	set SMDA_SWITCH								= false
	set OPL_SWITCH									= true
	set CYCLING_MODE								= true
	set WRF_HYDRO_SWITCH							= false
	set TRIBS_SWITCH								= false
	
	# Option for GEN_BE (only one can be true)
	set GEN_BE_CYCLE_SWITCH						= false
	set GEN_BE_UNIVERSE_SWITCH					= false
	
	# Options for WRFDA Convenstional Data Assimilation
	set WRFDA_OBSPROC_SWITCH					= true
	set WRFDA_PSOT_SWITCH						= true
	set WRFDA_NCL_PLOTS_SWITCH					= true
	set WRFDA_3DVAR_D01_SWITCH					= true
	set WRFDA_3DVAR_D02_SWITCH					= false
	
	# Option for UOU CDA
	set UOU_CDA_SWITCH 						 	= true
	
		# Now the default spin up time is 6 hours.  
		# It will requires the spin-up run finished, and then one can start WRF 3DVAR.
		set WRFDA_SPINUP_SWITCH					= true
	
	
	# DA_SPECIAL_MODE01: this mode can be used only when CYCLING_MODE = true (in this mode, only soil moisture is recycled)
	set DA_SPECIAL_MODE01						= false	
	
	set MATLAB_SPECIAL_WRFOUT_EXTRACTION	= true	
	
	# Only one following MATLAB scenario can be true 
	set MATLAB_SCENARIO_01						= false		# An old one that I rarely use
	set MATLAB_SCENARIO_02						= false		# 6h rainfall interpolation
	set MATLAB_SCENARIO_03						= true		# 1h rainfall interpolation
	
	set MATLAB_SCENARIO_05						= false		# 1h rainfall interpolation for WRF-Hydro simulations
	set MATLAB_SCENARIO_06						= false		# Process ST4 rainfall for tRIBS (Turkey basin)

# ======================
# WPS setup
# ======================
	# Time and coordinate setup
	# -------------------------
		set WPS_LON						= -97.0			# for 27km & 9km, use -94.0; 
		set WPS_LAT						= 38.5			# for 27km, use 36.0; for 9km, use 39.0
		set WPS_MAP_PROJ				= lambert
		set WPS_TRUELAT1				= 45				# use 45 for lambert over the US.  Use WPS_LON for mercator.
		set WPS_TRUELAT2				= 30				# Use 30 for lambert over the US.   It is useless for mercator.
		set WPS_STAND_LON				= -97				# Use WPS_LON for lambert over the US.  It is useless for mercator.
		
		set WPS_START_DATE			= 2016063018	# for the gen_be_wps.csh and run_wps.csh
		set WPS_END_DATE				= 2016073100	# For SM BEC study, the hour must be either '00' or '12'
		# for the gen_be_wps.csh 
		# 	2014.05.22: this WPS_GEN_END_DATE must be at leat one to three days larger than WPS_END_DATE
		set WPS_GEN_END_DATE			= 2016080300
		
	# Landuse setup
	# -------------
		# 2017.08.21: Since WRF 3.9, the default land use become MODIS
		# 2017.08.24: Since WRF 3.8, the default "num_land_cat=21".  This includes lake category with MODIS.  
		#		 	  Prior WRF 3.8, the MODIS landuse uses "num_land_cat=20"
		set WPS_LAND_USE_TYPE		= MODIS			# Now, options are "MODIS" or "USGS"
		
		if (${WPS_LAND_USE_TYPE} == 'MODIS') then
			set WPS_GEOG_DATA_RES	= default
			set WPS_NUM_LAND_CAT		= 21
		endif
		
		if (${WPS_LAND_USE_TYPE} == 'USGS') then
			set WPS_GEOG_DATA_RES	= usgs_30s+default
			set WPS_NUM_LAND_CAT		= 24
		endif
	
	# FNL Datasets
	# ------------
		#                         | Paths                                                  						| Data Type
		# -------------------------------------------------------------------------------------------------------------------
		# FNL 1-by-1 degree       | /uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/fnl_1degree_ncar	| NCEP_FNL_1_degree
		# --------------------------------------------------------------------------------------------------------------------
		# FNL 0.25-by-0.25 degree | /uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/fnl_0p25_ncar		| NCEP_FNL_0p25_degree
		set WPS_FNL_DIR				= /uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/fnl_0p25_ncar
		set WPS_DATA_TYPE				= NCEP_FNL_0p25_degree

	# WPS Domain setup
	# ----------------
		set MAX_DOM						= 1 		# 3 for RA
		set E_VERT						= 41				

		set E_WE_D01					= 603		# 150	for RA;
		set E_SN_D01					= 393		# 80 for RA;
		set DXDY_D01					= 9000		# 36000 for RA

		set E_WE_D02					= 1363		# 211 for RA
		set E_SN_D02					= 811		# 151 for RA
		set DXDY_D02					= 3000		# 12000 for RA
		set I_PARENT_START_D02		= 76		# 39 for RA
		set J_PARENT_START_D02		= 61		# 15 for RA
		set PARENT_GRID_RATIO_D02	= 3			# 3 for RA

		set E_WE_D03					= 301		# 301 for RA
		set E_SN_D03					= 241		# 241 for RA
		set DXDY_D03					= 4000		# 4000 for RA
		set I_PARENT_START_D03		= 51		# 51 for RA
		set J_PARENT_START_D03		= 24		# 24 for RA
		set PARENT_GRID_RATIO_D03  = 3			# 3 for RA

# ======================
# WRFDA setup
# ======================
	# Varied by options
	# -----------------
		#                        WRFDA_RAIN_DIR_DA                                  			|  WRFDA_RAIN_DA_TYPE
		# ----------------------------------------------------------------------------------------------------
		# ST4 DA   | 																 	    						|  ST4
		# TRMM DA  | /uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/trmm/forWRFDA_v1 |  TRMM
		#
		# It can be either ST4, TRMM, or any other created by me in the future
		# Please go to darun_da.csh to edit more if loop statement if there is any change	
			set WRFDA_RAIN_DIR_DA		= /uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/trmm/forWRFDA_v1
			set WRFDA_RAIN_DA_TYPE 		= TRMM   
			

		# The following variables are varied in DIR 140502 (sensitivity test)
			set WRFDA_MAX_ERROR_RAIN 	= 3
			set WRFDA_LEN_SCALING 		= 1
			set WRFDA_LEN04_SCALING 	= 1

		# WRFDA 4D-Var time step	
			set WRFDA_TIME_STEP			= 150		# 150 for 4D-Var

		# Setup for GEN_BE
		set GEN_BE_NL_CV_OPTIONS		= 3
		set GEN_BE_BIN_TYPE				= 5
		set GEN_BE_WRAPPER_INTERVAL	= 12
			
	# Other Setup
	# -------------
		set WRFDA_CHECK_MAX_IV		= false
		set WRFDA_CODE					= WRFDA3.4_4dvar_dm	# Now, WRFDA_CODE is not used anywhere.
		set WRFDA_CLOUD_CV_OPTIONS	= 0
		set WRFDA_OB_FORMAT			= 2			# 2 for obsproc-processed data
		set WRFDA_SFC_ASSI_OPTIONS	= 2
		
		
	# Stage 4 Data set
		# set WRFDA_ST4_DIR				= /nv/hp19/llin35/data/archive_data/st4/data	# GT Apurimac
		set WRFDA_ST4_DIR				= /uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/st4
		
	# Namelist wrfvar4 setup
		set WRFDA_THIN_CONV_ASCII	= false		# Default: false
		set WRFDA_THIN_MESH_CONV	= "28*10."
		set WRFDA_USE_SYNOPOBS		= false		# Default: true
		set WRFDA_USE_SHIPSOBS		= false		# Default: true
		set WRFDA_USE_METAROBS		= true		# Default: true
		set WRFDA_USE_SOUNDOBS		= false		# Default: true
		set WRFDA_USE_PILOTOBS		= false		# Default: true
		set WRFDA_USE_AIREPOBS		= false		# Default: true
		set WRFDA_USE_GEOAMVOBS		= false		# Default: true
		set WRFDA_USE_POLARAMVOBS	= false		# Default: true
		set WRFDA_USE_BOGUSOBS		= false		# Default: true
		set WRFDA_USE_BUOYOBS		= false		# Default: true
		set WRFDA_USE_PROFILEROBS	= false		# Default: true
		set WRFDA_USE_SATEMOBS		= false		# Default: true
		set WRFDA_USE_GPSPWOBS		= false		# Default: true
		set WRFDA_USE_GPSZTDOBS		= false		# Default: false
		set WRFDA_USE_GPSREFOBS		= false		# Default: true
		set WRFDA_USE_QSCATOBS		= false		# Default: true
		set WRFDA_USE_AMSUBOBS		= false		# Default: false
		set WRFDA_USE_RAINOBS		= false		# Default: false
		
	
# ======================
# OBSPROC
# ======================
	set OBSPROC_WINDOW_HOUR 	= 1		# One hour before/after the analysis time
	set PREPBUFR2LITTLER_DIR	= ~/zpu-group10/data/ncar_ds337_conventional_dataset
	
# ======================
# WRF SETUP
# ======================
	set WRF_TIMESTEP					= 30					# 6 times of the resolution
	set WRF_FEEDBACK					= 0
	
	# Physics Schemes
	set WRF_MP_PHYSICS				= 8
	set WRF_RA_LW_PHYSICS			= 4
	set WRF_RA_SW_PHYSICS			= 4
	set WRF_BL_PBL_PHYSICS			= 2
	set WRF_SF_SFCLAY_PHYSICS		= 2
	set WRF_SF_SURFACE_PHYSICS		= 2
	set WRF_NUM_SOIL_LAYERS			= 4
	
	set WRF_CU_PHYSICS_D01			= 6	
	set WRF_CU_PHYSICS_D02			= 0
	set WRF_CU_PHYSICS_D03			= 0
	
	# Some Other Physics Options
	set WRF_USEMONALB 				= false	# default=false; 	true for RUC LSM
	set WRF_RDLAI2D					= false	# default=false; 	true for RUC LSM
	set WRF_MOSAIC_LU					= 0		# default=0; 		1 for RUC_LSM
	set WRF_MOSAIC_SOIL				= 0		# default=0; 		1 for RUC_LSM
	
	set WRF_HISTORY_INTERVAL_D01 	= 360		# 60 means 1 hour; 720 means 12 hours
	set WRF_HISTORY_INTERVAL_D02 	= 360
	set WRF_HISTORY_INTERVAL_D03 	= 360
	
	set WRF_INPUT_FROM_FILE_D01	= true
	set WRF_INPUT_FROM_FILE_D02	= true
	set WRF_INPUT_FROM_FILE_D03	= false

# ======================
# UOU CDA Setup
# ======================	
	# Used by both CDA and CDA2
	set UOU_CDA_NX 				= `expr ${E_WE_D01} - 1`
	set UOU_CDA_NY 				= `expr ${E_SN_D01} - 1`
	set UOU_CDA_NZ					= `expr ${E_VERT} - 1`
	set UOU_CDA_NZ_SOIL			= ${WRF_NUM_SOIL_LAYERS}
	set UOU_CDA_SMOBS_ERROR		= 0.04
	set UOU_CDA_CYCLING_OPTION	= CDA			# Current options: SDA, OPL, CDA
	set UOU_CDA_FG_REPL_OPTION = SM_TQ		# CUurrent options: SM_ONLY, SM_TQ
	
	# Observation Path
		# SMAP SM witout BC
		# set UOU_CDA_SMOBS_PATH 		= ~/zpu-group10/coding/matlab/2018/180121_MATLAB_SURF_SMDA_WRFDA_01/180201_Creating_SMAP_E_L2_SM_for_SMDA_QC_2016/output_ncfile 

		# SMAP SM with BC
		set UOU_CDA_SMOBS_PATH 		= ~/zpu-group10/coding/matlab/2018/180501_SURF_SMDA_WRFDA_05/180521_Creating_SMAP_E_L2_SM_for_SMDA_QC_BC_2016/output_ncfile

	# Used by only CDA (updating SM only)
	set UOU_CDA_BEC_PATH 		= ~/zpu-group10/coding/matlab/2018/180221_NMC_SMATM_Manuscript_v04/nc_data_3y_avg

	# Used by only CDA2 (updating SM, T, and Q)
	set UOU_CDA_KG_PATH			= ~/zpu-group10/coding/matlab/2018/180221_NMC_SMATM_Manuscript_v04/nc_data_3y_avg_kalman_gain
	
# ======================
# SMDA setup
# ======================
	set SMDA_NX 					= `expr ${E_WE_D01} - 1`
	set SMDA_NY 					= `expr ${E_SN_D01} - 1`
	set SMDA_NZ 					= ${WRF_NUM_SOIL_LAYERS}
	set SMDA_WRFINPUT_FILE 		= wrfinput_d01
	set SMDA_OBS_TYPE				= SMOS				# Now, options are "SMAP" or "SMOS"
	
	if (${SMDA_OBS_TYPE} == 'SMOS') then
		set SMDA_OBS_FILENAME	= smos_obs.nc
		set SMDA_OBS_FILEPATH	= ~/data2/data/smos/ori_cp34-bec/smos_for_DA_v05_20170517
		set SMDA_DA_STRATEGY		= 01				# Please go to darun_smda.csh for more detail
	endif
	
	if (${SMDA_OBS_TYPE} == 'SMAP') then
		set SMDA_OBS_FILENAME	= sm_obs.nc
		set SMDA_OBS_FILEPATH	= ~/data2/data/smap/SPL2SMP.004/interp_sm_for_DA_v04_20170508
		set SMDA_DA_STRATEGY		= 02				# Please go to darun_smda.csh for more detail
	endif	
	
	# The following two must be change accordingly (2014.08.09)
		# BbBEC: /nv/hp19/llin35/data/research/2014/140221_SM_BEC_final_products/01_ncfile_BbBEC/BbBEC.nc
		# BaBEC: /nv/hp19/llin35/data/research/2014/140221_SM_BEC_final_products/03_ncfile_BaBEC/BaBEC.nc
	set SMDA_BEC_PATH				= /nv/hp19/llin35/data2/research/2015/151001_SMDA_exp/99_bec_nc/02_BaBEC
	set SMDA_BEC_FILENAME		= BaBEC.nc		# Either BbBEC.nc or BaBEC.nc
	
# ======================	
# WRF-Hydro Setup
# ======================
	# WRF-Hydro Versions
	#                           | available versions
	# -----------------------------------------------
	# apurimac_02 (old storage) | WRF_Hydro_v01
	#                           | WRF_Hydro_v02.1
	#                           | WRF_Hydro_v03.0
	#                           | WRF_Hydro_v03.0_noahMP
	#                           | WRF_Hydro_v03.0_noah_web
	# 04_install (new storage)  | WRF_HYDRO3.0_noah
	#                           | WRF_HYDRO3.0_noahMP	
	set HYDRO_EXE_VERSION		= WRF_HYDRO3.0_noah	
	set HYDRO_DOMAIN				= 3
	set HYDRO_AGGFACTRT			= 40		# integer multiple between the land model grid and the terrain routing grid
	set HYDRO_DTRT					= 6
	set HYDRO_FORC_TYP			= 3		# Specification of forcing data:  1=HRLDAS-hr format, 3=WRF
	set HYDRO_KHOUR				= 1680	# hours of hydro simulation	
	
	# Physics related
	set HYDRO_SUBRTSWCRT			= 1		# switch control of subsurface routing: 1=yes
	set HYDRO_OVRTSWCRT			= 1		# switch control of overland routing: 1=yes
	set HYDRO_CHANRTSWCRT		= 1		# switch control of channel routing: 1=yes
	set HYDRO_GWBASESWCRT		= 0		# switch control of baseflow bucket model: 0=no
	set HYDRO_RT_OPTION			= 1		# routing option: 1=steepest descent
	set HYDRO_CHANNEL_OPTION	= 3		# channel routing option: 3=Diff.Wave-gridded
	set HYDRO_BASN_MSK_FILE		= gw_basns_geogrid.txt
	
	# My switch for hydro
	set HYDRO_SW_FORCING_HERE	= 1	# 1=wrfout with ST4 rainfall; 

# ======================
# tRIBS Setup
# ======================
	set TRIBS_EXE_VERSION			= tribs
	set TRIBS_EXE_PATH				= ${PROGRAM_DIR}/tribs/tRIBSErosionCode_20150909
	set TRIBS_STATIC_FILE_PATH		= /nv/hp19/llin35/data/research/2015/150901_tribs_turkey/32_Turkey02_test

# MATLAB Setup
# ------------
	set MATLAB_SCENARIO_LOC_STR	= IA	# KS: Kansas; IA: Iowa

# Others
# ------
	set ADV_TIME_EXE 				= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe
	set TIME01 						= ${WPS_START_DATE}
	set TIME02 						= `${ADV_TIME_EXE} ${WPS_START_DATE} 12`
	set TIME03 						= `${ADV_TIME_EXE} ${WPS_START_DATE} 24`

##########################################################################################################
### (note 2017.09.11) An old part that is no longer used
	if (${MODULE_FILE} == 'module_default') then
		echo "Module is set to be default"
	else
		source ~/${MODULE_FILE}
		echo "Load ${MODULE_FILE}"
	endif
###
# ============================
# 0. NOTE for Below
# ============================
# (2018.02.08) 
#	- Section 1 denotes the components that start when after running zz_runme.csh
# 	- Section 2 denotes the components that need to be started via zz_runme_XXX.csh
# 	- After 2.3. (WRF 4DVAR), it is not maintained.  

# ============================
# 1.1. WPS
# ============================
	rm -rf wps
	mkdir wps
	
	csh ./zz_script/runme_wps.csh \
	${WPS_LON}  					${WPS_LAT}  					${WPS_START_DATE} 			${WPS_END_DATE} \
	${PROGRAM_DIR} 				${WPS_FNL_DIR} 				${MAX_DOM} 						${DXDY_D01} \
	${E_WE_D01} 					${E_SN_D01} 					${E_WE_D02} 					${E_SN_D02} \
	${DXDY_D02} 					${I_PARENT_START_D02} 		${J_PARENT_START_D02} 		${PARENT_GRID_RATIO_D02} \
	${E_WE_D03} 					${E_SN_D03} 					${DXDY_D03} 					${I_PARENT_START_D03} \
	${J_PARENT_START_D03} 		${PARENT_GRID_RATIO_D03}	${WPS_GEN_END_DATE}			${WPS_EXE_VERSION} \
	${WPS_GEOG_PATH}				${WRF_4DVAR_EXE_VERSION}	${WRF_3DVAR_EXE_VERSION}	${WPS_DATA_TYPE} \
	${WPS_GEOG_DATA_RES}			${WPS_MAP_PROJ}				${WPS_TRUELAT1}				${WPS_TRUELAT2} \
	${WPS_STAND_LON}

# ============================
# 1.2. GEN_BE
# ============================
	# (note 2017.09.11) Make the argument the same for 
	#	- runme_gen_be_cycle.csh
	#	- runme_gen_be_universe.csh
	
	# GEN_BE for each cycle
	# ----------------------
	if (${GEN_BE_CYCLE_SWITCH} == 'true') then
		rm -rf gen_be_cycle
		mkdir gen_be_cycle

		time csh ./zz_script/runme_gen_be_cycle.csh \
		${PROGRAM_DIR} 					${WPS_LON} 							${WPS_LAT} 								${WPS_START_DATE} \
		${WPS_END_DATE} 					${WPS_GEN_END_DATE} 				${WPS_FNL_DIR} 						${WRF_SF_SURFACE_PHYSICS} \
		${WRF_NUM_SOIL_LAYERS} 			${WRF_MP_PHYSICS} 				${WRF_RA_SW_PHYSICS} 				${WRF_SF_SFCLAY_PHYSICS}\
		${DXDY_D01}		 					${WRF_TIMESTEP} 					${E_VERT} 								${E_WE_D01} \
		${E_SN_D01} 						${CASENUM}							${PBS_PPN_FAST}						${PBS_MEM_FAST} \
		${PBS_WALLTIME_FAST}				${PBS_QUEUE_FAST}					${WRF_EXE_VERSION}					${WRF_4DVAR_EXE_VERSION} \
		${WRF_3DVAR_EXE_VERSION} 		${MODULE_FILE}						${WRF_FEEDBACK}						${WRF_RA_LW_PHYSICS} \
		${WRF_BL_PBL_PHYSICS}			${WRF_CU_PHYSICS_D01}			${WPS_DATA_TYPE}						${QUEUE_TYPE} \
		${SBATCH_CHPC_TIME}				${SBATCH_CHPC_NODES}				${SBATCH_CHPC_NTASKS}				${SBATCH_CHPC_ACCOUNT} \
		${SBATCH_CHPC_PARTITION}		${SBATCH_CHPC_NPROC}				${SBATCH_CHPC_TIME_SHORT}			${SBATCH_CHPC_NODES_SHORT} \
		${SBATCH_CHPC_NTASKS_SHORT}	${SBATCH_CHPC_ACCOUNT_SHORT}	${SBATCH_CHPC_PARTITION_SHORT}	${SBATCH_CHPC_NPROC_SHORT} \
		${GEN_BE_NL_CV_OPTIONS}			${GEN_BE_BIN_TYPE}				${GEN_BE_CYCLE_SWITCH}				${GEN_BE_UNIVERSE_SWITCH} \
		${GEN_BE_WRAPPER_INTERVAL}		${NPROC_FAST} 
	endif

	# GEN_BE, a single be.dat file for all cycles
	# ------------------------------------------
	if (${GEN_BE_UNIVERSE_SWITCH} == 'true') then
		rm -rf gen_be_universe
		mkdir gen_be_universe

		time csh ./zz_script/runme_gen_be_universe.csh \
		${PROGRAM_DIR} 					${WPS_LON} 							${WPS_LAT} 								${WPS_START_DATE} \
		${WPS_END_DATE} 					${WPS_GEN_END_DATE} 				${WPS_FNL_DIR} 						${WRF_SF_SURFACE_PHYSICS} \
		${WRF_NUM_SOIL_LAYERS} 			${WRF_MP_PHYSICS} 				${WRF_RA_SW_PHYSICS} 				${WRF_SF_SFCLAY_PHYSICS}\
		${DXDY_D01}		 					${WRF_TIMESTEP} 					${E_VERT} 								${E_WE_D01} \
		${E_SN_D01} 						${CASENUM}							${PBS_PPN_FAST}						${PBS_MEM_FAST} \
		${PBS_WALLTIME_FAST}				${PBS_QUEUE_FAST}					${WRF_EXE_VERSION}					${WRF_4DVAR_EXE_VERSION} \
		${WRF_3DVAR_EXE_VERSION} 		${MODULE_FILE}						${WRF_FEEDBACK}						${WRF_RA_LW_PHYSICS} \
		${WRF_BL_PBL_PHYSICS}			${WRF_CU_PHYSICS_D01}			${WPS_DATA_TYPE}						${QUEUE_TYPE} \
		${SBATCH_CHPC_TIME}				${SBATCH_CHPC_NODES}				${SBATCH_CHPC_NTASKS}				${SBATCH_CHPC_ACCOUNT} \
		${SBATCH_CHPC_PARTITION}		${SBATCH_CHPC_NPROC}				${SBATCH_CHPC_TIME_SHORT}			${SBATCH_CHPC_NODES_SHORT} \
		${SBATCH_CHPC_NTASKS_SHORT}	${SBATCH_CHPC_ACCOUNT_SHORT}	${SBATCH_CHPC_PARTITION_SHORT}	${SBATCH_CHPC_NPROC_SHORT} \
		${GEN_BE_NL_CV_OPTIONS}			${GEN_BE_BIN_TYPE}				${GEN_BE_CYCLE_SWITCH}				${GEN_BE_UNIVERSE_SWITCH} \
		${GEN_BE_WRAPPER_INTERVAL}		${NPROC_FAST} 
	endif

# ============================
# 1.3. WRFDA OBSPROC
# ============================
	if (${WRFDA_OBSPROC_SWITCH} == 'true') then
		rm -rf obsproc
		mkdir obsproc
		
		csh ./zz_script/runme_obsproc.csh \
		${WPS_LON}						${WPS_LAT}					${WPS_START_DATE}				${WPS_END_DATE} \
		${PROGRAM_DIR}					${MAX_DOM}					${DXDY_D01}						${DXDY_D02} \
		${E_WE_D01}						${E_SN_D01}					${E_WE_D02}						${E_SN_D02} \
		${I_PARENT_START_D02}		${J_PARENT_START_D02}	${WPS_TRUELAT1}				${WPS_TRUELAT2} \
		${WRF_3DVAR_EXE_VERSION}	${OBSPROC_WINDOW_HOUR}	${FORECAST_INI_FREQ}			${PREPBUFR2LITTLER_DIR} \
		${WRFDA_USE_SYNOPOBS}		${WRFDA_USE_SHIPSOBS}	${WRFDA_USE_METAROBS}		${WRFDA_USE_SOUNDOBS} \
		${WRFDA_USE_PILOTOBS}		${WRFDA_USE_AIREPOBS}	${WRFDA_USE_GEOAMVOBS}		${WRFDA_USE_POLARAMVOBS} \
		${WRFDA_USE_BOGUSOBS}		${WRFDA_USE_BUOYOBS}		${WRFDA_USE_PROFILEROBS}	${WRFDA_USE_SATEMOBS} \
		${WRFDA_USE_GPSPWOBS}		${WRFDA_USE_GPSZTDOBS}	${WRFDA_USE_GPSREFOBS}		${WRFDA_USE_QSCATOBS}
	endif
		
# ============================	
# 1.4. Create a csh script for check file number
# ============================
	rm zz_checking.csh	
	
	csh ./zz_script/runme_create_checking.csh \
	${WPS_START_DATE} 				${WPS_END_DATE}				${FORECAST_INI_FREQ}		${ADV_TIME_EXE} \
	${GEN_BE_NL_CV_OPTIONS}			${GEN_BE_BIN_TYPE}			${FORECAST_HOURS}

# ============================
# 1.5. REAL
# ============================
	rm -rf real
	mkdir real
	
	csh ./zz_script/runme_real.csh \
	${WRF_MP_PHYSICS}					${WRF_RA_LW_PHYSICS}				${WRF_RA_SW_PHYSICS}				${WRF_BL_PBL_PHYSICS} \
	${WRF_SF_SFCLAY_PHYSICS}		${WRF_SF_SURFACE_PHYSICS}		${WRF_NUM_SOIL_LAYERS}			${WRF_CU_PHYSICS_D01} \
	${WRF_CU_PHYSICS_D02}			${WRF_CU_PHYSICS_D03}			${WRF_TIMESTEP}					${WRF_FEEDBACK} \
	${WRF_HISTORY_INTERVAL_D01}	${WRF_HISTORY_INTERVAL_D02}	${WRF_HISTORY_INTERVAL_D03}	${WRF_EXE_VERSION} \
	${WRF_INPUT_FROM_FILE_D01}		${WRF_INPUT_FROM_FILE_D02}		${WRF_INPUT_FROM_FILE_D03}		${WRF_3DVAR_EXE_VERSION} \
	${MAX_DOM}							${E_VERT}							${FORECAST_HOURS} 				${PROGRAM_DIR} \
	${E_WE_D01}							${E_SN_D01}							${DXDY_D01} 						${FORECAST_INI_FREQ} \
	${E_WE_D02}							${E_SN_D02}							${DXDY_D02}							${WPS_DATA_TYPE} \
	${E_WE_D03}							${E_SN_D03}							${DXDY_D03}							${WPS_NUM_LAND_CAT} \
	${I_PARENT_START_D02}			${J_PARENT_START_D02} 			${PARENT_GRID_RATIO_D02}		${I_PARENT_START_D03} \
	${J_PARENT_START_D03} 			${PARENT_GRID_RATIO_D03}		${WPS_START_DATE}					${WPS_END_DATE} \
	${WRF_USEMONALB}					${WRF_RDLAI2D}						${WRF_MOSAIC_LU}					${WRF_MOSAIC_SOIL}

# ============================
# 1.6. SPINUP
# ============================
	# (2018.02.08) NOTE THAT ALL THE INPUT ARGUMENTS ARE THE SAME FOR THE FOLLOWS:
	#	- runme_openloop.csh
	#	- runme_openloop_cycling.csh
	#	- runme_spinup.csh

	if (${WRFDA_SPINUP_SWITCH} == 'true') then
		rm -rf spinup
		mkdir  spinup
		
		csh ./zz_script/runme_spinup.csh \
		${WPS_START_DATE} 			${WPS_END_DATE}  					${NPROC} 							${PROGRAM_DIR}	\
		${PBS_QUEUE}					${FORECAST_HOURS}					${PBS_MEM}							${PBS_PPN} \
		${PBS_WALLTIME}				${CASENUM}							${FORECAST_INI_FREQ}				${PBS_NODES} \
		${WRF_EXE_VERSION}			${WRF_3DVAR_EXE_VERSION}		${MODULE_FILE}						${DA_SPECIAL_MODE01} \
		${SMDA_NX}						${SMDA_NY}							${SMDA_NZ}							${NC_REPL_PATH} \
		${QUEUE_TYPE}					${SBATCH_CHPC_TIME}				${SBATCH_CHPC_NODES}				${SBATCH_CHPC_NTASKS} \
		${SBATCH_CHPC_ACCOUNT}		${SBATCH_CHPC_PARTITION}		${SBATCH_CHPC_NPROC}				${SBATCH_CHPC_TIME_SHORT} \
		${SBATCH_CHPC_NODES_SHORT}	${SBATCH_CHPC_NTASKS_SHORT}	${SBATCH_CHPC_ACCOUNT_SHORT}	${SBATCH_CHPC_PARTITION_SHORT} \
		${SBATCH_CHPC_NPROC_SHORT}	${WRFDA_SPINUP_SWITCH}
	endif

###########################################################################################
# A logic judgement for cycling or not (for WRFDA)
# -----------------------------------------------
	if (${CYCLING_MODE} == 'false') then
		set DARUN_FILE_STR = ''
	else if (${CYCLING_MODE} == 'true') then
		set DARUN_FILE_STR = '_cycling'
	else
		
	endif

# ============================
# 2.1. OPL
# ============================
# (2018.02.08) NOTE THAT ALL THE INPUT ARGUMENTS ARE THE SAME FOR THE FOLLOWS:
#	- runme_openloop.csh
#	- runme_openloop_cycling.csh
#	- runme_spinup.csh

rm zz_runme_opl.csh

if (${OPL_SWITCH} == 'true') then
cat >! zz_runme_opl.csh << EOF

	rm -rf openloop
	mkdir  openloop

	csh ./zz_script/runme_openloop${DARUN_FILE_STR}.csh \
	${WPS_START_DATE} 			${WPS_END_DATE}  					${NPROC} 							${PROGRAM_DIR}	\
	${PBS_QUEUE}					${FORECAST_HOURS}					${PBS_MEM}							${PBS_PPN} \
	${PBS_WALLTIME}				${CASENUM}							${FORECAST_INI_FREQ}				${PBS_NODES} \
	${WRF_EXE_VERSION}			${WRF_3DVAR_EXE_VERSION}		${MODULE_FILE}						${DA_SPECIAL_MODE01} \
	${SMDA_NX}						${SMDA_NY}							${SMDA_NZ}							${NC_REPL_PATH} \
	${QUEUE_TYPE}					${SBATCH_CHPC_TIME}				${SBATCH_CHPC_NODES}				${SBATCH_CHPC_NTASKS} \
	${SBATCH_CHPC_ACCOUNT}		${SBATCH_CHPC_PARTITION}		${SBATCH_CHPC_NPROC}				${SBATCH_CHPC_TIME_SHORT} \
	${SBATCH_CHPC_NODES_SHORT}	${SBATCH_CHPC_NTASKS_SHORT}	${SBATCH_CHPC_ACCOUNT_SHORT}	${SBATCH_CHPC_PARTITION_SHORT} \
	${SBATCH_CHPC_NPROC_SHORT}	${WRFDA_SPINUP_SWITCH}
EOF
endif

# ============================
# 2.2. WRF 3DVAR
# ============================
	rm zz_runme_3dvar.csh

cat >! zz_runme_3dvar.csh << EOF
#!/bin/csh -x
	rm -rf 3dvar
	mkdir 3dvar

	time csh ./zz_script/runme_darun_3dvar${DARUN_FILE_STR}.csh \
	${PROGRAM_DIR} 					${CASENUM} 							${WPS_LON} 								${WPS_LAT} \
	${WPS_START_DATE} 				${WPS_END_DATE} 					${WPS_GEN_END_DATE} 					${WPS_FNL_DIR} \
	${WRF_SF_SURFACE_PHYSICS} 		${WRF_NUM_SOIL_LAYERS} 			${WRF_MP_PHYSICS}						${WRF_RA_SW_PHYSICS} \
	${GEN_BE_NL_CV_OPTIONS} 		${GEN_BE_BIN_TYPE}				${WRFDA_CHECK_MAX_IV} 				${WRFDA_USE_AMSUBOBS} \
	${WRFDA_USE_RAINOBS}				"${WRFDA_THIN_MESH_CONV}" 		${WRFDA_ST4_DIR} 						${WRFDA_RAIN_DIR_DA} \
	${DXDY_D01} 						${WRF_TIMESTEP} 					${E_VERT} 								${E_WE_D01} \
	${E_SN_D01} 						${MAX_DOM} 							${E_WE_D02} 							${E_SN_D02} \
	${DXDY_D02} 						${I_PARENT_START_D02} 			${J_PARENT_START_D02}				${WRFDA_TIME_STEP} \
	${WRFDA_LEN_SCALING} 			${E_WE_D03}							${E_SN_D03} 							${DXDY_D03}	\
	${I_PARENT_START_D03}			${J_PARENT_START_D03} 			${PBS_QUEUE}							${WRFDA_CODE} \
	${PBS_MEM}							${PBS_PPN}							${PBS_WALLTIME}						${WRFDA_MAX_ERROR_RAIN} \
	${WRFDA_RAIN_DA_TYPE}			${WRF_4DVAR_SWITCH}				${SMDA_SWITCH}							${WRFDA_LEN04_SCALING} \
	${SMDA_EXE_PATH}					${SMDA_NX}							${SMDA_NY}								${SMDA_NZ} \
	${SMDA_WRFINPUT_FILE}			${SMDA_BEC_PATH}					${SMDA_BEC_FILENAME}					${SMDA_OBS_FILENAME} \
	${SMDA_OBS_FILEPATH}				${CYCLING_MODE}					${FORECAST_INI_FREQ}					${SMDA_DA_STRATEGY} \
	${PBS_NODES}						${WRF_EXE_VERSION}				${WRF_3DVAR_EXE_VERSION}			${WRF_4DVAR_EXE_VERSION} \
	${WRFPLUS_EXE_VERSION}			${MODULE_FILE}						${WRFDA_I_PARENT_START}				${WRFDA_J_PARENT_START} \
	${DA_SPECIAL_MODE01}				${WRF_RA_LW_PHYSICS}				${WRF_BL_PBL_PHYSICS}				${WRF_CU_PHYSICS_D01} \
	${NC_REPL_PATH}					${QUEUE_TYPE}						${WRF_3DVAR_SWITCH}					${WRFDA_PSOT_SWITCH} \
	${SBATCH_CHPC_TIME}				${SBATCH_CHPC_NODES}				${SBATCH_CHPC_NTASKS}				${SBATCH_CHPC_ACCOUNT} \
	${SBATCH_CHPC_PARTITION}		${SBATCH_CHPC_NPROC}				${SBATCH_CHPC_TIME_SHORT}			${SBATCH_CHPC_NODES_SHORT} \
	${SBATCH_CHPC_NTASKS_SHORT}	${SBATCH_CHPC_ACCOUNT_SHORT}	${SBATCH_CHPC_PARTITION_SHORT}	${SBATCH_CHPC_NPROC_SHORT} \
	${NPROC}								${GEN_BE_CYCLE_SWITCH}			${GEN_BE_UNIVERSE_SWITCH}			${WRFDA_CLOUD_CV_OPTIONS} \
	${WRF_SF_SFCLAY_PHYSICS}		${WRFDA_OB_FORMAT}				${WRFDA_NCL_PLOTS_SWITCH}			${OBSPROC_WINDOW_HOUR} \
	${WRFDA_THIN_CONV_ASCII}		${WRFDA_USE_SYNOPOBS}			${WRFDA_USE_SHIPSOBS}				${WRFDA_USE_METAROBS} \
	${WRFDA_USE_SOUNDOBS}			${WRFDA_USE_PILOTOBS}			${WRFDA_USE_AIREPOBS}				${WRFDA_USE_GEOAMVOBS} \
	${WRFDA_USE_POLARAMVOBS}		${WRFDA_USE_BOGUSOBS}			${WRFDA_USE_BUOYOBS}					${WRFDA_USE_PROFILEROBS} \
	${WRFDA_USE_SATEMOBS}			${WRFDA_USE_GPSPWOBS}			${WRFDA_USE_GPSZTDOBS}				${WRFDA_USE_GPSREFOBS} \
	${WRFDA_USE_QSCATOBS} 			${WRFDA_3DVAR_D01_SWITCH}		${WRFDA_3DVAR_D02_SWITCH}			${WRFDA_SFC_ASSI_OPTIONS}

EOF

# ==================================
# 2.3. UOU CDA & UOU CDA CYCLING
# ==================================
rm zz_runme_uou_cda.csh

if (${UOU_CDA_SWITCH} == 'true') then
cat >! zz_runme_uou_cda.csh << EOF

	rm -rf uou_cda${DARUN_FILE_STR}
	mkdir  uou_cda${DARUN_FILE_STR}

	csh ./zz_script/runme_uou_cda${DARUN_FILE_STR}.csh \
	${WPS_START_DATE} 					${WPS_END_DATE}  					${NPROC} 							${PROGRAM_DIR}	\
	${PBS_QUEUE}							${FORECAST_HOURS}					${PBS_MEM}							${PBS_PPN} \
	${PBS_WALLTIME}						${CASENUM}							${FORECAST_INI_FREQ}				${PBS_NODES} \
	${WRF_EXE_VERSION}					${WRF_3DVAR_EXE_VERSION}		${MODULE_FILE}						${DA_SPECIAL_MODE01} \
	${NC_REPL_PATH} 						${QUEUE_TYPE}						${SBATCH_CHPC_TIME}				${SBATCH_CHPC_NODES}	\
	${SBATCH_CHPC_NTASKS} 				${SBATCH_CHPC_ACCOUNT}			${SBATCH_CHPC_PARTITION}		${SBATCH_CHPC_NPROC}	\
	${SBATCH_CHPC_TIME_SHORT} 			${SBATCH_CHPC_NODES_SHORT}		${SBATCH_CHPC_NTASKS_SHORT}	${SBATCH_CHPC_ACCOUNT_SHORT} \
	${SBATCH_CHPC_PARTITION_SHORT} 	${SBATCH_CHPC_NPROC_SHORT}		${WRFDA_SPINUP_SWITCH}			${UOU_CDA_SMOBS_ERROR} \
	${UOU_CDA_SMOBS_PATH} 				${UOU_CDA_BEC_PATH}				${FORECAST_HOURS_CDA_CYCLING}	${UOU_CDA_CYCLING_OPTION} \
	${UOU_CDA_FG_REPL_OPTION} 			${UOU_CDA_NX}						${UOU_CDA_NY}						${UOU_CDA_NZ} \
	${UOU_CDA_NZ_SOIL}					${UOU_CDA_KG_PATH}
EOF
endif	

# ============================
# 2.5. WRF 4DVAR
# ============================
if (${WRF_4DVAR_SWITCH} == 'true') then
	rm zz_runme_4dvar.csh

cat >! zz_runme_4dvar.csh << EOF
#!/bin/csh -x
	rm -rf 4dvar
	mkdir 4dvar
	
	time csh ./zz_script/runme_darun_4dvar${DARUN_FILE_STR}.csh \
	${PROGRAM_DIR} 					${CASENUM} 							${WPS_LON} 								${WPS_LAT} \
	${WPS_START_DATE} 				${WPS_END_DATE} 					${WPS_GEN_END_DATE} 					${WPS_FNL_DIR} \
	${WRF_SF_SURFACE_PHYSICS} 		${WRF_NUM_SOIL_LAYERS} 			${WRF_MP_PHYSICS}						${WRF_RA_SW_PHYSICS} \
	${GEN_BE_NL_CV_OPTIONS} 		${GEN_BE_BIN_TYPE}				${WRFDA_CHECK_MAX_IV} 				${WRFDA_USE_AMSUBOBS} \
	${WRFDA_USE_RAINOBS}				"${WRFDA_THIN_MESH_CONV}" 		${WRFDA_ST4_DIR} 						${WRFDA_RAIN_DIR_DA} \
	${DXDY_D01} 						${WRF_TIMESTEP} 					${E_VERT} 								${E_WE_D01} \
	${E_SN_D01} 						${MAX_DOM} 							${E_WE_D02} 							${E_SN_D02} \
	${DXDY_D02} 						${I_PARENT_START_D02} 			${J_PARENT_START_D02}				${WRFDA_TIME_STEP} \
	${WRFDA_LEN_SCALING} 			${E_WE_D03}							${E_SN_D03} 							${DXDY_D03}	\
	${I_PARENT_START_D03}			${J_PARENT_START_D03} 			${PBS_QUEUE}							${WRFDA_CODE} \
	${PBS_MEM}							${PBS_PPN}							${PBS_WALLTIME}						${WRFDA_MAX_ERROR_RAIN} \
	${WRFDA_RAIN_DA_TYPE}			${WRF_4DVAR_SWITCH}				${SMDA_SWITCH}							${WRFDA_LEN04_SCALING} \
	${SMDA_EXE_PATH}					${SMDA_NX}							${SMDA_NY}								${SMDA_NZ} \
	${SMDA_WRFINPUT_FILE}			${SMDA_BEC_PATH}					${SMDA_BEC_FILENAME}					${SMDA_OBS_FILENAME} \
	${SMDA_OBS_FILEPATH}				${CYCLING_MODE}					${FORECAST_INI_FREQ}					${SMDA_DA_STRATEGY} \
	${PBS_NODES}						${WRF_EXE_VERSION}				${WRF_3DVAR_EXE_VERSION}			${WRF_4DVAR_EXE_VERSION} \
	${WRFPLUS_EXE_VERSION}			${MODULE_FILE}						${WRFDA_I_PARENT_START}				${WRFDA_J_PARENT_START} \
	${DA_SPECIAL_MODE01}				${WRF_RA_LW_PHYSICS}				${WRF_BL_PBL_PHYSICS}				${WRF_CU_PHYSICS_D01} \
	${NC_REPL_PATH}					${QUEUE_TYPE}						${WRF_3DVAR_SWITCH}					${WRFDA_PSOT_SWITCH} \
	${SBATCH_CHPC_TIME}				${SBATCH_CHPC_NODES}				${SBATCH_CHPC_NTASKS}				${SBATCH_CHPC_ACCOUNT} \
	${SBATCH_CHPC_PARTITION}		${SBATCH_CHPC_NPROC}				${SBATCH_CHPC_TIME_SHORT}			${SBATCH_CHPC_NODES_SHORT} \
	${SBATCH_CHPC_NTASKS_SHORT}	${SBATCH_CHPC_ACCOUNT_SHORT}	${SBATCH_CHPC_PARTITION_SHORT}	${SBATCH_CHPC_NPROC_SHORT} \
	${NPROC}								${GEN_BE_CYCLE_SWITCH}			${GEN_BE_UNIVERSE_SWITCH}			${WRFDA_CLOUD_CV_OPTIONS} \
	${WRF_SF_SFCLAY_PHYSICS}
	
	# List of the items
	# -----------------	
	#	time csh ./zz_script/runme_darun_4dvar${DARUN_FILE_STR}.csh \
	#	\${PROGRAM_DIR} 					\${CASENUM} 						\${WPS_LON} 							\${WPS_LAT} \	
	#	\${WPS_START_DATE} 				\${WPS_END_DATE} 					\${WPS_GEN_END_DATE} 				\${WPS_FNL_DIR} \
	#	\${WRF_SF_SURFACE_PHYSICS}		\${WRF_NUM_SOIL_LAYERS} 		\${WRF_MP_PHYSICS} 					\${WRF_RA_SW_PHYSICS} \
	#	\${GEN_BE_NL_CV_OPTIONS} 		\${GEN_BE_BIN_TYPE}				\${WRFDA_CHECK_MAX_IV} 				\${WRFDA_USE_AMSUBOBS} \
	#	\${WRFDA_USE_RAINOBS}			"\${WRFDA_THIN_MESH_CONV}" 	\${WRFDA_ST4_DIR} 					\${WRFDA_RAIN_DIR_DA} \			# Argument 20
	#	\${DXDY_D01} 						\${WRF_TIMESTEP} 					\${E_VERT} 								\${E_WE_D01} \
	#	\${E_SN_D01} 						\${MAX_DOM} 						\${E_WE_D02} 							\${E_SN_D02} \
	#	\${DXDY_D02} 						\${I_PARENT_START_D02} 			\${J_PARENT_START_D02}				\${WRFDA_TIME_STEP} \
	#	\${WRFDA_LEN_SCALING} 			\${E_WE_D03}						\${E_SN_D03} 							\${DXDY_D03}	\
	#	\${I_PARENT_START_D03}			\${J_PARENT_START_D03} 			\${PBS_QUEUE}							\${WRFDA_CODE} \					# Argument 40
	#	\${PBS_MEM}							\${PBS_PPN}							\${PBS_WALLTIME}						\${WRFDA_MAX_ERROR_RAIN} \
	#	\${WRFDA_RAIN_DA_TYPE}			\${WRF_4DVAR_SWITCH}				\${SMDA_SWITCH}						\${WRFDA_LEN04_SCALING} \
	#  \${SMDA_EXE_PATH}					\${SMDA_NX}							\${SMDA_DY}								\${SMDA_NZ} \
	#  \${SMDA_WRFINPUT_FILE}			\${SMDA_BEC_PATH}					\${SMDA_BEC_FILENAME}				\${SMDA_OBS_FILENAME} \
	#	\${SMDA_OBS_FILEPATH}			\${CYCLING_MODE}					\${FORECAST_INI_FREQ}				\${SMDA_DA_STRATEGY} \			# Argument 60
	#  \${PBS_NODES}						\${WRF_EXE_VERSION}				\${WRF_3DVAR_EXE_VERSION}			\${WRF_4DVAR_EXE_VERSION} \
	#	\${WRFPLUS_EXE_VERSION}			\${MODULE_FILE}					\${WRFDA_I_PARENT_START}			\${WRFDA_J_PARENT_START} \
	#	\${DA_SPECIAL_MODE01}			\${WRF_RA_LW_PHYSICS}			\${WRF_BL_PBL_PHYSICS}				\${WRF_CU_PHYSICS_D01} \
	#	\${NC_REPL_PATH}					\${QUEUE_TYPE}						\${WRF_3DVAR_SWITCH}					\${WRFDA_PSOT_SWITCH} \
	#	\${SBATCH_CHPC_TIME}				\${SBATCH_CHPC_NODES}			\${SBATCH_CHPC_NTASKS}				\${SBATCH_CHPC_ACCOUNT} \		# Argument 80
	#	\${SBATCH_CHPC_PARTITION}		\${SBATCH_CHPC_NPROC}			\${SBATCH_CHPC_TIME_SHORT}			\${SBATCH_CHPC_NODES_SHORT} \
	#	\${SBATCH_CHPC_NTASKS_SHORT}	\${SBATCH_CHPC_ACCOUNT_SHORT}	\${SBATCH_CHPC_PARTITION_SHORT}	\${SBATCH_CHPC_NPROC_SHORT} \
	#	\${NPROC}							\${GEN_BE_CYCLE_SWITCH}			\${GEN_BE_UNIVERSE_SWITCH}			\${WRFDA_CLOUD_CV_OPTIONS} \
	#	\${WRF_SF_SFCLAY_PHYSICS}
EOF
endif


# Major process of Matlab
# -----------------------
	rm zz_runme_matlab.csh

cat >! zz_runme_matlab.csh << EOF
#!/bin/csh -x

	rm -rf matlab_post
	mkdir matlab_post/
	
	csh zz_script/runme_matlab.csh \
	${WPS_START_DATE} 				${WPS_END_DATE}						${PROGRAM_DIR} \
	${CASENUM} 							${FORECAST_HOURS}						${FORECAST_INI_FREQ} \
	${MAX_DOM}							${PBS_PPN_MATLAB} 					${PBS_MEM_MATLAB} \
	${PBS_WALLTIME_MATLAB}			${PBS_QUEUE_MATLAB}					${WRFDA_ST4_DIR} \
	${WRFDA_RAIN_DIR_DA}				${WRFDA_RAIN_DA_TYPE}				${MATLAB_SCENARIO_01} \
	${MATLAB_SCENARIO_02}	 		${WPS_GEN_END_DATE}					${MATLAB_SPECIAL_WRFOUT_EXTRACTION} \
	${SMDA_OBS_FILEPATH}				${WRF_HISTORY_INTERVAL_D01}		${WRF_3DVAR_EXE_VERSION} \
	${MODULE_FILE}						${MATLAB_SCENARIO_03}				${MATLAB_SCENARIO_05} \
	${MATLAB_SCENARIO_LOC_STR}		${MATLAB_SCENARIO_06}				${HYDRO_AGGFACTRT} \
	${QUEUE_TYPE}						${SBATCH_CHPC_TIME_SHORT}			${SBATCH_CHPC_NODES_SHORT} \
	${SBATCH_CHPC_NTASKS_SHORT}	${SBATCH_CHPC_ACCOUNT_SHORT}		${SBATCH_CHPC_PARTITION_SHORT} \
	${SBATCH_CHPC_NPROC_SHORT}
EOF

# Create csh file for WRF-HYDRO
# -----------------------------
if (${WRF_HYDRO_SWITCH} == 'true') then
	rm zz_runme_hydro.csh

cat >! zz_runme_hydro.csh << EOF
#!/bin/csh -x

	csh zz_script/runme_hydro.csh \
	${PROGRAM_DIR}			${MODULE_FILE}				${HYDRO_EXE_VERSION}	${WRF_3DVAR_EXE_VERSION} \
	${WPS_START_DATE}		${HYDRO_DOMAIN}				${HYDRO_AGGFACTRT}		${HYDRO_DTRT} \
	${HYDRO_FORC_TYP}		${HYDRO_KHOUR}				${HYDRO_SUBRTSWCRT}		${HYDRO_OVRTSWCRT} \
	${HYDRO_CHANRTSWCRT}	${HYDRO_GWBASESWCRT}		${HYDRO_RT_OPTION}		${HYDRO_CHANNEL_OPTION} \
	${HYDRO_BASN_MSK_FILE}	${HYDRO_SW_FORCING_HERE} 
EOF
endif

# Create csh file for tRIBS
# -------------------------
if (${TRIBS_SWITCH} == 'true') then
	rm zz_runme_tribs.csh

cat >! zz_runme_tribs.csh << EOF
#!/bin/csh -x

	csh zz_script/runme_hydro.csh \
	${TRIBS_EXE_VERSION}		${TRIBS_EXE_PATH}			${TRIBS_STATIC_FILE_PATH} \
	${HYDRO_KHOUR}				${WPS_START_DATE}
EOF
endif


# Linking to Desktop Matlab
# -----------------------
rm zz_runme_linkingmatlab.csh

cat >! zz_runme_linkingmatlab.csh << EOF
#!/bin/csh -x

	csh zz_script/runme_linkingmatlab.csh \
	${PROGRAM_DIR}			${WPS_START_DATE} 		${WPS_END_DATE}		${WRF_3DVAR_EXE_VERSION}
EOF
	
# Final message:
# -------------
echo "Current path is at:"
echo `pwd`

exit 0
