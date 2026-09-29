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

set FORECAST_INI_FREQ	= $5
set WRF_OUT_TIME_FREQ	= $6
set FORECAST_LEAD_TIME	= $7
set ENS_MEMBER_NUM		= $8
#######################################################################################
echo "Processing WRF Out Files in 3DVAR FGES & ANAL INTRP3D: "

rm -rf matlab_sp/fges_anal_intrp3d
mkdir  matlab_sp/fges_anal_intrp3d

cd matlab_sp/fges_anal_intrp3d

set DA_START_DATE    = ${WPS_START_DATE}
set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

	# Folder processing
	mkdir ${DA_START_DATE}
	cd    ${DA_START_DATE}

	echo " "
	echo "===== Processing "${DA_START_DATE}" ====="
		
	# Copy the NCL script here
	cp ../../../zz_script/producing_files_for_matlab/16_modified_wrf_PressureLevel1.ncl .	
		
	# ---------------------------------------------------------------------	
	# Obtain the number of ensemble member
	# ---------------------------------------------------------------------	
	set COUNT = 1
	
	while ( ${COUNT} <= ${ENS_MEMBER_NUM} )
	
		# Set up member string (only for member size <100)
		if (${COUNT}<10) then
			set mem_str = "mem00"${COUNT}
		else
			set mem_str = "mem0"${COUNT}
		endif
		
		# Compute Tc, Td, and RH at the pressure levels for the first guess
		ln -sf ../../../gsi_enkf/${DA_START_DATE}/06_enkf/firstguess.${mem_str} input.nc
		ncl 16_modified_wrf_PressureLevel1.ncl
		mv output.nc fges_${DA_START_DATE}_${mem_str}.nc
		mv plt_PressureLevel1.pdf fges_${mem_str}_PressureLevel1.pdf
		rm input.nc
		
		# Compute Tc, Td, and RH at the pressure levels for the analysis
		ln -sf ../../../gsi_enkf/${DA_START_DATE}/06_enkf/analysis.${mem_str} input.nc
		ncl 16_modified_wrf_PressureLevel1.ncl
		mv output.nc anal_${DA_START_DATE}_${mem_str}.nc
		mv plt_PressureLevel1.pdf anal_${mem_str}_PressureLevel1.pdf
		rm input.nc
		
		# Count 
		set COUNT = `expr ${COUNT} + 1`

	end		
				
	# Go back 
	cd ..	
		
	# For next step
	set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
	set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

cd ../..
