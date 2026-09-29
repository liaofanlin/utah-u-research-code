#!/bin/csh -x
#
# Note (2018.11.11): For more information, please visit:
#	- NCL book at 2017.06.28
#	- rn170701
#	- /Volumes/G-RAID/archive/MATLAB/2017/170811_PrSMDA_R01_v06/fig_06_T_Q_analysis_increment

set WPS_START_DATE		= $1
set WPS_END_DATE			= $2
set ADV_TIME_EXE			= $3
set WORKPATH				= $4


set WRF_OUT_TIME_FREQ	= $5
set FORECAST_LEAD_TIME	= $6
set ENS_MEMBER_NUM		= $7

set FORECAST_INI_FREQ	= 24
#######################################################################################
echo "Processing WRF Out Files in 72h forecasts INTRP3D: "

rm -rf matlab_sp/72h_forecast_intrp3d
mkdir  matlab_sp/72h_forecast_intrp3d

cd matlab_sp/72h_forecast_intrp3d

set DA_START_DATE    = ${WPS_START_DATE}
set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`


# ---------------------------------------------------------------------	
# 1. Loop for all the cycles
# ---------------------------------------------------------------------	
while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

	# Folder processing
	mkdir ${DA_START_DATE}
	cd    ${DA_START_DATE}

	echo " "
	echo "============== Processing "${DA_START_DATE}" ================="
		
				

	# ---------------------------------------------------------------------	
	# 2. Loop for each ensemble member
	# ---------------------------------------------------------------------	
	set COUNT = 1
	
	while ( ${COUNT} <= ${ENS_MEMBER_NUM} )
	
		# Set up member string (only for member size <100)
		if (${COUNT}<10) then
			set mem_str = "mem00"${COUNT}
		else
			set mem_str = "mem0"${COUNT}
		endif
		
		# Make a folder
		mkdir ${mem_str}
		
		cd ${mem_str}
		
		# ---------------------------------------------------------------------	
		# 3. Loop for forecast
		# ---------------------------------------------------------------------	
		# Set up the time for the forecast
		set WRF_OUT_TIME 			= ${DA_START_DATE}
		set WRF_OUT_FINAL_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_LEAD_TIME}`
								
		while (${WRF_OUT_TIME} <= ${WRF_OUT_FINAL_TIME})
	
			# Process of date
			# ---------------
			set yyyy1 = `echo $WRF_OUT_TIME | cut -c1-4`
			set   mm1 = `echo $WRF_OUT_TIME | cut -c5-6`
			set   dd1 = `echo $WRF_OUT_TIME | cut -c7-8`
			set   hh1 = `echo $WRF_OUT_TIME | cut -c9-10`			
	
			# Copy the NCL script here
			cp ${WORKPATH}/zz_script/producing_files_for_matlab/16_modified_wrf_PressureLevel1.ncl .	
					
			# Compute Tc, Td, and RH at the pressure levels for the forecasts
			ln -sf ${WORKPATH}/gsi_enkf/${DA_START_DATE}/08_wrf_72h_fcst/${mem_str}/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 input.nc
			ncl 16_modified_wrf_PressureLevel1.ncl
			mv output.nc wrf_init_at_${DA_START_DATE}_valid_at_${WRF_OUT_TIME}.nc
			mv plt_PressureLevel1.pdf forecast_valid_at_${WRF_OUT_TIME}_PressureLevel1.pdf
			rm input.nc
		
			# For next step
			set WRF_OUT_TIME = `${ADV_TIME_EXE} ${WRF_OUT_TIME} ${WRF_OUT_TIME_FREQ}`
			
		end
		# ---------------------------------------------------------------------		
		# Leaving the ensemble member folder
		cd ..			
						
		# Count 
		set COUNT = `expr ${COUNT} + 1`

	end		
	# ---------------------------------------------------------------------	
	# Leaving the initial time folder
	cd ..	
		
	# For next step
	set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
	set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

cd ../..
