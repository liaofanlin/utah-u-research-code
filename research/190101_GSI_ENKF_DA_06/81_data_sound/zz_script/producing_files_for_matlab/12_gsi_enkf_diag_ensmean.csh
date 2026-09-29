#!/bin/csh -x
#

# Note (2018.09.28): This has not been updated for a while
set echo

set WPS_START_DATE		= $1
set WPS_END_DATE			= $2
set ADV_TIME_EXE			= $3
set WORKPATH				= $4

set FORECAST_INI_FREQ	= $5
set WRF_OUT_TIME_FREQ	= $6
set FORECAST_LEAD_TIME	= $7
#######################################################################################

echo "Linking OBSPROC GSI-EnKF Diag Ensmean Data:"

rm -rf matlab_sp/gsi_enkf_diag_ensmean
mkdir  matlab_sp/gsi_enkf_diag_ensmean

cd 	 matlab_sp/gsi_enkf_diag_ensmean

set DA_START_DATE    = ${WPS_START_DATE}
set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

	echo "  - Processing ",${DA_START_DATE}

	# Process of Extrating WRF Output
	# -------------------------------
		mkdir ${DA_START_DATE}

		cd ${DA_START_DATE}

		cp ${WORKPATH}/gsi_enkf/${DA_START_DATE}/06_enkf/liaofan_READCONVOBS_diag_ensmean_detail_01.txt .
		cp ${WORKPATH}/gsi_enkf/${DA_START_DATE}/06_enkf/liaofan_READCONVOBS_diag_ensmean_detail_02.txt .

		cd ..

	# For next step
	set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
	set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

cd ../..

