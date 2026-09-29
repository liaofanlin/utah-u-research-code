#!/bin/csh -x
#

# =============================================
# NOTE 
# =============================================
# 	- Note (2018.09.28): This script requires me manually change the parameters

# 	- Example of Usage
# 		csh ./zz_script/runme_producing_files_for_matlab.csh

# =============================================
# PARAMENTERS
# =============================================
# set echo 

# Time and lead time relevant
	set WPS_START_DATE			= 2016070100
	set WPS_END_DATE				= 2016072900

	set FORECAST_INI_FREQ		= 12	# Unit in hours
	set WRF_OUT_TIME_FREQ		= 6
	set FORECAST_LEAD_TIME		= 72
	set ENS_MEMBER_NUM			= 40

# Clear the entir matlab_sp folder?
	set SWITCH_CLEAR_MATLAB_SP = true

# Link or prepare files for the folloing cases
	# Conventional Observations
	set SWITCH_01_OBSPROC_3DVAR				= false
	
	# Cases for non-cycling runs
	set SWITCH_02_UOU_CDA_CDA					= false
	set SWITCH_03_UOU_CDA_WRF 					= false
	set SWITCH_04_OPL								= false
	set SWITCH_05_3DVAR_WRF 					= false
	set SWITCH_06_3DVAR_TEXT_OUT				= false
	set SWITCH_07_3DVAR_FGES_ANAL_INTRP3D	= false
	
	# Data for real
	set SWITCH_08_REAL							= false
	
	# Data for GSI-EnKF
	set SWITCH_11_GSI_ENKF_FIRSTGUESS		= false
	set SWITCH_12_GSI_ENKF_DIAG_ENSMEAN		= false
	set SWITCH_13_GSI_ENKF_ANALYSIS			= false
	
	# Cases for cycling runs
	set SWITCH_21_UOU_CDA_CYCLING 						= false
	set SWITCH_22_UOU_CDA_CYCLING_FORECAST_INTRP3D	= true

# Parameters that do not change much
	set PROGRAM_DIR				= /uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/12_install
	set WRF_3DVAR_EXE_VERSION	= WRFDA3.9.1_3dvar_dm
	set ADV_TIME_EXE				= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

# Working and Targeting paths
	set WORKPATH					= `pwd`
	set TARGETPATH					= `pwd`
	#set TARGETPATH					= `pwd`
#######################################################################################

cd ${TARGETPATH}

# Clean the matlab_sp or not
if (${SWITCH_CLEAR_MATLAB_SP} == true ) then
	rm -rf matlab_sp03
	mkdir  matlab_sp03
endif 

# ==================================================
# 1. Linking for 3dvar data in OBSPROC
# ==================================================
	if (${SWITCH_01_OBSPROC_3DVAR} == true) then
		csh ./zz_script/producing_files_for_matlab/01_obsproc_3dvar.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}
	endif		
# ==================================================
# 2. Data Processing for DA in CDA
# ==================================================
	if (${SWITCH_02_UOU_CDA_CDA} == true) then
		csh ./zz_script/producing_files_for_matlab/02_uou_cda_cda.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}
	endif
	
# ==================================================
# 3. Data Processing for WRF in CDA
# ==================================================
	if (${SWITCH_03_UOU_CDA_WRF} == true) then
		csh ./zz_script/producing_files_for_matlab/03_uou_cda_wrf.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}
	endif	

# ==================================================
# 4. Data Processing for OPL
# ==================================================
	if (${SWITCH_04_OPL} == true) then
		csh ./zz_script/producing_files_for_matlab/04_opl.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}
	endif	

# ==================================================
# 5. Data Processing for WRF in 3DVAR
# ==================================================
	if (${SWITCH_05_3DVAR_WRF} == true) then
		csh ./zz_script/producing_files_for_matlab/05_3dvar_wrf.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}
	endif	

# ==================================================
# 6. Data Processing for text outputs in 3DVAR
# ==================================================
	if (${SWITCH_06_3DVAR_TEXT_OUT} == true) then
		csh ./zz_script/producing_files_for_matlab/06_3dvar_text_out.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}
	endif	

# ==============================================================
# 7. Data interpolation of Td, Tc, RH of FGES & ANAL from 3DVAR
# ==============================================================
	if (${SWITCH_07_3DVAR_FGES_ANAL_INTRP3D} == true) then
		csh ./zz_script/producing_files_for_matlab/07_3dvar_fges_anal_intrp3d.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}
	endif	

	
# ==================================================
# 8. Data Processing for real
# ==================================================
	if (${SWITCH_08_REAL} == true) then
		csh ./zz_script/producing_files_for_matlab/08_real.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}
	endif		

# ==================================================
# 11. Data Processing for GSI-EnKF first guess
# ==================================================
	if (${SWITCH_11_GSI_ENKF_FIRSTGUESS} == true) then
		csh ./zz_script/producing_files_for_matlab/11_gsi_enkf_firstguess.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}
	endif				
	
# ==================================================
# 12. Data Processing for GSI-EnKF Diag Ensmean
# ==================================================
	if (${SWITCH_12_GSI_ENKF_DIAG_ENSMEAN} == true) then
		csh ./zz_script/producing_files_for_matlab/12_gsi_enkf_diag_ensmean.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}
	endif		
		
# ==================================================
# 13. Data Processing for GSI-EnKF Diag Ensmean
# ==================================================
	if (${SWITCH_12_GSI_ENKF_DIAG_ENSMEAN} == true) then
		csh ./zz_script/producing_files_for_matlab/13_gsi_enkf_analysis.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}	${ENS_MEMBER_NUM}
	endif				
	
	
	
# ==================================================
# 21. Data Processing for Full WRF Runs in UOU CYCLING
# ==================================================
	if (${SWITCH_21_UOU_CDA_CYCLING} == true) then
		csh ./zz_script/producing_files_for_matlab/21_uou_cda_cycling.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}
	endif	
		
# ====================================================================
# 22. Data interpolation of Td, Tc, RH of Forecasts from UOU CYCLING
# ====================================================================
	if (${SWITCH_22_UOU_CDA_CYCLING_FORECAST_INTRP3D} == true) then
		csh ./zz_script/producing_files_for_matlab/22_uou_cda_cycling_forecast_intrp3d.csh \
			${WPS_START_DATE}			${WPS_END_DATE}			${ADV_TIME_EXE}			${WORKPATH} \
			${FORECAST_INI_FREQ}		${WRF_OUT_TIME_FREQ}		${FORECAST_LEAD_TIME}
	endif			
			
# ===================================
# Return to where I run this script
cd ${WORKPATH}

