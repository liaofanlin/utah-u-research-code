#!/bin/csh -x
#

# Example of Usage
# 	- One-line version
# 		csh ./zz_script/runme_producing_files_for_desktop.csh

# 	Multiple-line version
#  ------------------------
#	csh ./zz_script/runme_producing_files_for_desktop.csh \
#		2016070100 2016070600 \
#		/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/12_install WRFDA3.9.1_3dvar_dm \
#		6 true \ 		# FORECAST_INI_FREQ & SWITCH_CLEAR_MATLAB_SP
#		false false \	# SWITCH_OBSPROC_3DVAR & SWITCH_UOU_CDA_CDA
#		true false \	# SWITCH_UOU_CDA_WRF & SWITCH_OPL
#		6 48 \			# WRF_OUT_TIME_FREQ & FORECAST_LEAD_TIME
#		true true		# SWITCH_3DVAR_WRF & SWITCH_3DVAR_TEXT_OUT

# set echo 

# Time and lead time relevant
set WPS_START_DATE			= 2016070100
set WPS_END_DATE				= 2016072900

set FORECAST_INI_FREQ		= 12	# Unit in hours
set WRF_OUT_TIME_FREQ		= 6
set FORECAST_LEAD_TIME		= 72

# Clear the entir matlab_sp folder?
set SWITCH_CLEAR_MATLAB_SP = true

# Link or prepare files for the folloing cases
	# Conventional Observations
	set SWITCH_01_OBSPROC_3DVAR	= false
	
	# Cases for non-cycling runs
	set SWITCH_02_UOU_CDA_CDA		= false
	set SWITCH_03_UOU_CDA_WRF 		= false
	set SWITCH_04_OPL					= false
	set SWITCH_05_3DVAR_WRF 		= false
	set SWITCH_06_3DVAR_TEXT_OUT	= false
		
	# Cases for cycling runs
	set SWITCH_07_UOU_CDA_CYCLING = true
	
	# Data for real
	set SWITCH_08_REAL				= false

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
	rm -rf matlab_sp
	mkdir matlab_sp
endif 

# ==================================================
# 1. Linking for 3dvar data in OBSPROC
# ==================================================
	if (${SWITCH_01_OBSPROC_3DVAR} == true) then
	
		echo "Linking OBSPROC 3DVAR Data: "
	
		rm -rf matlab_sp/obsproc
		mkdir  matlab_sp/obsproc
	
		cd matlab_sp/obsproc
	
		set DA_START_DATE    = ${WPS_START_DATE}
		set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
	
		while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

			echo "  - Processing ",${DA_START_DATE}

			# Process of Extrating WRF Output
			# -------------------------------
				mkdir ${DA_START_DATE}
	
				cd ${DA_START_DATE}
	
				# Process of date
				# ---------------
					set yyyy1 = `echo $DA_START_DATE | cut -c1-4`
					set   mm1 = `echo $DA_START_DATE | cut -c5-6`
					set   dd1 = `echo $DA_START_DATE | cut -c7-8`
					set   hh1 = `echo $DA_START_DATE | cut -c9-10`
	
					cp ${WORKPATH}/obsproc/${DA_START_DATE}/obs_gts_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00.3DVAR .
	
				cd ..

			# For next step
			set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
			set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

		end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		cd ../..
	
	endif		
	
	
# ==================================================
# 2. Data Processing for DA in CDA
# ==================================================
	if (${SWITCH_02_UOU_CDA_CDA} == true) then
		
		echo "Processing DA Data in UOU CDA: "
		
		rm -rf matlab_sp/cda
		mkdir matlab_sp/cda
		
		cd matlab_sp/cda
	
   	set DA_START_DATE    = ${WPS_START_DATE}
   	set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
	
		while ( ${DA_END_DATE} <= ${WPS_END_DATE} )
	
			echo "  - Processing ",${DA_START_DATE}

			# Process of Extrating WRF Output
			# -------------------------------
				mkdir ${DA_START_DATE}
		
				cd ${DA_START_DATE}
		
					ln -sf ${WORKPATH}/uou_cda/${DA_START_DATE}/cda/wrfinput_ori .
					ln -sf ${WORKPATH}/uou_cda/${DA_START_DATE}/cda/wrfinput_cda .
					cp     ${WORKPATH}/uou_cda/${DA_START_DATE}/cda/satellite_obs_sm.nc .
		
					ncks -v SMOIS,XLAT,XLONG \
								wrfinput_ori \
								wrfinput_ori_sp.nc
					ncks -v SMOIS,XLAT,XLONG \
								wrfinput_cda \
								wrfinput_cda_sp.nc

					rm wrfinput_ori wrfinput_cda
	
				cd ..

			# For next step
			set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
			set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`
   
		end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		cd ../..
		
	endif
	
# ==================================================
# 3. Data Processing for WRF in CDA
# ==================================================
	if (${SWITCH_03_UOU_CDA_WRF} == true) then
	
		echo "Processing WRF Out Files in UOU CDA: "
	
		rm -rf matlab_sp/cda_wrf
		mkdir matlab_sp/cda_wrf
	
		cd matlab_sp/cda_wrf

   	set DA_START_DATE    = ${WPS_START_DATE}
   	set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

		while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

			echo "  - Processing ",${DA_START_DATE}

			mkdir ${DA_START_DATE}	
			cd    ${DA_START_DATE}

			set WRF_OUT_TIME 			= ${DA_START_DATE}
			set WRF_OUT_FINAL_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_LEAD_TIME}`
				
				
			while (${WRF_OUT_TIME} <= ${WRF_OUT_FINAL_TIME})
			
				# Process of date
				# ---------------
					set yyyy1 = `echo $WRF_OUT_TIME | cut -c1-4`
					set   mm1 = `echo $WRF_OUT_TIME | cut -c5-6`
					set   dd1 = `echo $WRF_OUT_TIME | cut -c7-8`
					set   hh1 = `echo $WRF_OUT_TIME | cut -c9-10`			
				
				# Extract wrfout variables	
				ncks -v SMOIS,XLAT,XLONG,T2,Q2,HFX,LH \
					${WORKPATH}/uou_cda/${DA_START_DATE}/wrf/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 \
					wrfout_d01_${yyyy1}_${mm1}_${dd1}_${hh1}_sp.nc
				
				# For next step
				set WRF_OUT_TIME = `${ADV_TIME_EXE} ${WRF_OUT_TIME} ${WRF_OUT_TIME_FREQ}`
				

			end
			
			cd ..
			
			# For next step
			set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
			set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

		end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		cd ../..
	
	endif	

# ==================================================
# 4. Data Processing for OPL
# ==================================================
	if (${SWITCH_04_OPL} == true) then
	
		echo "Processing WRF Out Files in OPL: "
	
		rm -rf matlab_sp/opl
		mkdir matlab_sp/opl
	
		cd matlab_sp/opl

   	set DA_START_DATE    = ${WPS_START_DATE}
   	set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

		while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

			echo "  - Processing ",${DA_START_DATE}

			mkdir ${DA_START_DATE}	
			cd    ${DA_START_DATE}

			set WRF_OUT_TIME 			= ${DA_START_DATE}
			set WRF_OUT_FINAL_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_LEAD_TIME}`
				
				
			while (${WRF_OUT_TIME} <= ${WRF_OUT_FINAL_TIME})
			
				# Process of date
				# ---------------
					set yyyy1 = `echo $WRF_OUT_TIME | cut -c1-4`
					set   mm1 = `echo $WRF_OUT_TIME | cut -c5-6`
					set   dd1 = `echo $WRF_OUT_TIME | cut -c7-8`
					set   hh1 = `echo $WRF_OUT_TIME | cut -c9-10`			
				
				# Extract wrfout variables	
				ncks -v SMOIS,XLAT,XLONG,T2,Q2,HFX,LH \
					${WORKPATH}/openloop/${DA_START_DATE}/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 \
					wrfout_d01_${yyyy1}_${mm1}_${dd1}_${hh1}_sp.nc
				
				# For next step
				set WRF_OUT_TIME = `${ADV_TIME_EXE} ${WRF_OUT_TIME} ${WRF_OUT_TIME_FREQ}`
				

			end
			
			cd ..
			
			# For next step
			set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
			set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

		end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		cd ../..
	
	endif	


# ==================================================
# 5. Data Processing for WRF in 3DVAR
# ==================================================
	if (${SWITCH_05_3DVAR_WRF} == true) then
	
		echo "Processing WRF Out Files in 3DVAR: "
	
		rm -rf matlab_sp/3dvar_wrf
		mkdir matlab_sp/3dvar_wrf
	
		cd matlab_sp/3dvar_wrf

   	set DA_START_DATE    = ${WPS_START_DATE}
   	set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

		while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

			echo "  - Processing ",${DA_START_DATE}

			mkdir ${DA_START_DATE}	
			cd    ${DA_START_DATE}

			set WRF_OUT_TIME 			= ${DA_START_DATE}
			set WRF_OUT_FINAL_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_LEAD_TIME}`
				
				
			while (${WRF_OUT_TIME} <= ${WRF_OUT_FINAL_TIME})
			
				# Process of date
				# ---------------
					set yyyy1 = `echo $WRF_OUT_TIME | cut -c1-4`
					set   mm1 = `echo $WRF_OUT_TIME | cut -c5-6`
					set   dd1 = `echo $WRF_OUT_TIME | cut -c7-8`
					set   hh1 = `echo $WRF_OUT_TIME | cut -c9-10`			
				
				# Extract wrfout variables	
				ncks -v SMOIS,XLAT,XLONG,T2,Q2,HFX,LH \
					${WORKPATH}/3dvar/${DA_START_DATE}/wrf/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 \
					wrfout_d01_${yyyy1}_${mm1}_${dd1}_${hh1}_sp.nc
				
				# For next step
				set WRF_OUT_TIME = `${ADV_TIME_EXE} ${WRF_OUT_TIME} ${WRF_OUT_TIME_FREQ}`
				

			end
			
			cd ..
			
			# For next step
			set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
			set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

		end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		cd ../..
	
	endif	


# ==================================================
# 6. Data Processing for text outputs in 3DVAR
# ==================================================
	if (${SWITCH_06_3DVAR_TEXT_OUT} == true) then

		echo "Processing Text Output Files in 3DVAR: "

		rm -rf matlab_sp/3dvar_text_out
		mkdir matlab_sp/3dvar_text_out

		cd matlab_sp/3dvar_text_out

   	set DA_START_DATE    = ${WPS_START_DATE}
   	set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

		while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

			echo "  - Processing ",${DA_START_DATE}

			mkdir ${DA_START_DATE}	
			cd    ${DA_START_DATE}
	
			# Copy the text files of interest
			cp ${WORKPATH}/3dvar/${DA_START_DATE}/3dvar_d01/statistics .			
						
			cd ..
		
			# For next step
			set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
			set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

		end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		cd ../..

	endif	




# ==================================================
# 7. Data Processing for Full WRF Runs in UOU CYCLING
# ==================================================
	if (${SWITCH_07_UOU_CDA_CYCLING} == true) then

		echo "Processing WRF Out Files in UOU CDA CYCLING: "

		# Folder Processing
		rm -rf matlab_sp/uou_cycling_wrf
		mkdir	 matlab_sp/uou_cycling_wrf
		cd     matlab_sp/uou_cycling_wrf

		
   	set DA_START_DATE    = ${WPS_START_DATE}
   	set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

		while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

			echo "  - Processing ",${DA_START_DATE}

			mkdir ${DA_START_DATE}	
			cd    ${DA_START_DATE}

			set WRF_OUT_TIME 			= ${DA_START_DATE}
			set WRF_OUT_FINAL_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_LEAD_TIME}`
			
			while (${WRF_OUT_TIME} <= ${WRF_OUT_FINAL_TIME})
		
				# Process of date
				# ---------------
					set yyyy1 = `echo $WRF_OUT_TIME | cut -c1-4`
					set   mm1 = `echo $WRF_OUT_TIME | cut -c5-6`
					set   dd1 = `echo $WRF_OUT_TIME | cut -c7-8`
					set   hh1 = `echo $WRF_OUT_TIME | cut -c9-10`			
			
				# Extract wrfout variables	
				ncks -v SMOIS,XLAT,XLONG,T2,Q2,HFX,LH,ISLTYP,T,QVAPOR,P,PB,PBLH,RAINC,RAINNC \
					${WORKPATH}/uou_cda_cycling/${WPS_START_DATE}/${DA_START_DATE}/04_wrf_full/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 \
					wrfout_d01_${yyyy1}_${mm1}_${dd1}_${hh1}_sp.nc
			
				# For next step
				set WRF_OUT_TIME = `${ADV_TIME_EXE} ${WRF_OUT_TIME} ${WRF_OUT_TIME_FREQ}`
			

			end
		
			cd ..
		
			# For next step
			set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
			set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

		end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		cd ../..

	endif	
	
# ==================================================
# 8. Data Processing for real
# ==================================================
	if (${SWITCH_08_REAL} == true) then

		echo "Processing REAL Data: "

		# Folder Processing
		rm -rf matlab_sp/real
		mkdir	 matlab_sp/real
		cd     matlab_sp/real

   	set DA_START_DATE    = ${WPS_START_DATE}
   	set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

		while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

			echo "  - Processing ",${DA_START_DATE}

			mkdir ${DA_START_DATE}	
			cd    ${DA_START_DATE}
				
			# Copy real files
			ncks -v XLAT,XLONG,T,QVAPOR \
				${WORKPATH}/real/${DA_START_DATE}/wrfinput_d01 \
				wrfinput_d01_${DA_START_DATE}_sp.nc
	
			# For next step
			set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
			set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`
			
			
			cd ..

		end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		cd ../..

	endif		
		
# ===================================
# Return to where I run this script
cd ${WORKPATH}

