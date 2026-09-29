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
