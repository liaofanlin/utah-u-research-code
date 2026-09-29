#!/bin/csh -x
#

# Note (2018.09.28): This has not been updated for a while

set WPS_START_DATE		= $1
set WPS_END_DATE			= $2
set ADV_TIME_EXE			= $3
set WORKPATH				= $4

set FORECAST_INI_FREQ	= $5
set WRF_OUT_TIME_FREQ	= $6
set FORECAST_LEAD_TIME	= $7
#######################################################################################

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
	ncks -v XLAT,XLONG,T,QVAPOR,SMOIS,P,PB \
		${WORKPATH}/real/${DA_START_DATE}/wrfinput_d01 \
		wrfinput_d01_${DA_START_DATE}_sp.nc

	# For next step
	set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
	set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`
	
	
	cd ..

end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

cd ../..
