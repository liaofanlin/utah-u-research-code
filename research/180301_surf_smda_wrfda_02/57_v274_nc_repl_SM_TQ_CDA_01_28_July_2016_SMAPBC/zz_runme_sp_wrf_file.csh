#!/bin/csh -x
#


# Time and lead time relevant
set WPS_START_DATE			= 2016070100
set WPS_END_DATE				= 2016072900

set FORECAST_INI_FREQ		= 12	# Unit in hours

# Parameters that do not change much
set PROGRAM_DIR				= /uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/12_install
set WRF_3DVAR_EXE_VERSION	= WRFDA3.9.1_3dvar_dm
set ADV_TIME_EXE				= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

#########################################################

rm -rf matlab_sp02
mkdir matlab_sp02

cd matlab_sp02

# Main loop to copy wrfinput file and analysis increment!
# -----------------------------------------------------
	set DA_START_DATE    = ${WPS_START_DATE}
	set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

	while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		echo "  - Processing ",${DA_START_DATE}

		mkdir ${DA_START_DATE}	
		cd    ${DA_START_DATE}
		
		cp ../../uou_cda_cycling/${WPS_START_DATE}/${DA_START_DATE}/02_cda/wrfinput_cda .
		cp ../../uou_cda_cycling/${WPS_START_DATE}/${DA_START_DATE}/02_cda/wrfinput_diff .
	
		# For next step
		set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
		set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

		cd ..

	end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )


cd ..



