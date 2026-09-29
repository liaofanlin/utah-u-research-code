#!/bin/csh -x
#

set WPS_LON						= $1
set WPS_LAT						= $2
set WPS_START_DATE			= $3 
set WPS_END_DATE				= $4

set PROGRAM_DIR 				= $5
set MAX_DOM						= $6
set DXDY_D01					= $7
set DXDY_D02					= $8

set E_WE_D01					= $9
set E_SN_D01					= $10
set E_WE_D02					= $11
set E_SN_D02					= $12

set I_PARENT_START_D02		= $13
set J_PARENT_START_D02		= $14
set WPS_TRUELAT1				= $15
set WPS_TRUELAT2				= $16

set WRF_3DVAR_EXE_VERSION	= $17
set OBSPROC_WINDOW_HOUR		= $18
set FORECAST_INI_FREQ		= $19
set PREPBUFR2LITTLER_DIR	= $20

set WRFDA_USE_SYNOPOBS		= $21
set WRFDA_USE_SHIPSOBS		= $22
set WRFDA_USE_METAROBS		= $23
set WRFDA_USE_SOUNDOBS		= $24

set WRFDA_USE_PILOTOBS		= $25
set WRFDA_USE_AIREPOBS		= $26
set WRFDA_USE_GEOAMVOBS		= $27
set WRFDA_USE_POLARAMVOBS	= $28

set WRFDA_USE_BOGUSOBS		= $29
set WRFDA_USE_BUOYOBS		= $30
set WRFDA_USE_PROFILEROBS	= $31
set WRFDA_USE_SATEMOBS		= $32

set WRFDA_USE_GPSPWOBS		= $33
set WRFDA_USE_GPSZTDOBS		= $34
set WRFDA_USE_GPSREFOBS		= $35
set WRFDA_USE_QSCATOBS		= $36

set ADV_TIME_EXE 				= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe


# =================================================


set DA_START_DATE 		= ${WPS_START_DATE}
set DA_END_DATE   		= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

	rm -rf ./obsproc/${DA_START_DATE}
	mkdir ./obsproc/${DA_START_DATE}

	cd ./obsproc/${DA_START_DATE}

	set OBSPROC_START_TIME   	= `${ADV_TIME_EXE} ${DA_START_DATE} -${OBSPROC_WINDOW_HOUR}`
	set OBSPROC_END_TIME   		= `${ADV_TIME_EXE} ${DA_START_DATE} ${OBSPROC_WINDOW_HOUR}`
	
	
	# Process of date
	# ---------------
		set yyyy1 = `echo $DA_START_DATE | cut -c1-4`
		set   mm1 = `echo $DA_START_DATE | cut -c5-6`
		set   dd1 = `echo $DA_START_DATE | cut -c7-8`
		set   hh1 = `echo $DA_START_DATE | cut -c9-10`

		set yyyy0 = `echo $OBSPROC_START_TIME | cut -c1-4`
		set   mm0 = `echo $OBSPROC_START_TIME | cut -c5-6`
		set   dd0 = `echo $OBSPROC_START_TIME | cut -c7-8`
		set   hh0 = `echo $OBSPROC_START_TIME | cut -c9-10`
	
		set yyyy2 = `echo $OBSPROC_END_TIME | cut -c1-4`
		set   mm2 = `echo $OBSPROC_END_TIME | cut -c5-6`
		set   dd2 = `echo $OBSPROC_END_TIME | cut -c7-8`
		set   hh2 = `echo $OBSPROC_END_TIME | cut -c9-10`
		
	# Links of files
	# --------------
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/obsproc/obsproc.exe .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/obsproc/obserr.txt .
		ln -sf ${PREPBUFR2LITTLER_DIR}/${yyyy1}_littleR/${mm1}/${dd1}/${hh1}/prepbufr2littleR.txt obs.${yyyy1}${mm1}${dd1}${hh1}
		
	
	# Creation of the namelist
	# ------------------------			
cat >! namelist.obsproc << EOF
&record1
 obs_gts_filename = 'obs.${yyyy1}${mm1}${dd1}${hh1}',
 obs_err_filename = 'obserr.txt',
 gts_from_mmm_archive = .false.,
/

&record2
 time_window_min  = '${yyyy0}-${mm0}-${dd0}_${hh0}:00:00',
 time_analysis    = '${yyyy1}-${mm1}-${dd1}_${hh1}:00:00',
 time_window_max  = '${yyyy2}-${mm2}-${dd2}_${hh2}:00:00',
/

&record3
 max_number_of_obs        = 400000,
 fatal_if_exceed_max_obs  = .TRUE.,
/

&record4
 qc_test_vert_consistency = .TRUE.,
 qc_test_convective_adj   = .TRUE.,
 qc_test_above_lid        = .TRUE.,
 remove_above_lid         = .false.,
 domain_check_h           = .true.,
 Thining_SATOB            = .false.,
 Thining_SSMI             = .false.,
 Thining_QSCAT            = .false.,
 calc_psfc_from_qnh       = .false.,
/

&record5
 print_gts_read           = .TRUE.,
 print_gpspw_read         = .TRUE.,
 print_recoverp           = .TRUE.,
 print_duplicate_loc      = .TRUE.,
 print_duplicate_time     = .TRUE.,
 print_recoverh           = .TRUE.,
 print_qc_vert            = .TRUE.,
 print_qc_conv            = .TRUE.,
 print_qc_lid             = .TRUE.,
 print_uncomplete         = .TRUE.,
/

&record6
 ptop            = 1000.0,
 base_pres       = 100000.0,
 base_temp       = 290.0,
 base_lapse      = 50.0,
 base_strat_temp = 215.0,
 base_tropo_pres = 20000.0,
/

&record7
 IPROJ = 1,
 PHIC  = ${WPS_LAT},
 XLONC = ${WPS_LON},
 TRUELAT1= ${WPS_TRUELAT1},
 TRUELAT2= ${WPS_TRUELAT2},
 MOAD_CEN_LAT = ${WPS_LAT},
 STANDARD_LON = ${WPS_LON},
/

&record8
 IDD    =   1,
 MAXNES =   1,
 NESTIX =  ${E_SN_D01},  ${E_SN_D02},  136,  181,  211,
 NESTJX =  ${E_WE_D01},  ${E_WE_D02},  181,  196,  211,
 DIS    =  9,  3,  3.3,  1.1,  1.1,
 NUMC   =    1,    1,   2,     3,    4,
 NESTI  =    1,   ${J_PARENT_START_D02},  28,    35,   45,
 NESTJ  =    1,   ${I_PARENT_START_D02},  25,    65,   55,
 / 

&record9
 PREPBUFR_OUTPUT_FILENAME = 'prepbufr_output_filename',
 PREPBUFR_TABLE_FILENAME = 'prepbufr_table_filename',
 OUTPUT_OB_FORMAT = 2
 use_for          = '3DVAR',
 num_slots_past   = 3,
 num_slots_ahead  = 3,
 write_synop = .${WRFDA_USE_SYNOPOBS}., 
 write_ship  = .${WRFDA_USE_SHIPSOBS}.,
 write_metar = .${WRFDA_USE_METAROBS}.,
 write_buoy  = .${WRFDA_USE_BUOYOBS}., 
 write_pilot = .${WRFDA_USE_PILOTOBS}.,
 write_sound = .${WRFDA_USE_SOUNDOBS}.,
 write_amdar = .false.,
 write_satem = .${WRFDA_USE_SATEMOBS}.,
 write_satob = .false.,
 write_airep = .${WRFDA_USE_AIREPOBS}.,
 write_gpspw = .${WRFDA_USE_GPSPWOBS}.,
 write_gpsztd= .${WRFDA_USE_GPSZTDOBS}.,
 write_gpsref= .${WRFDA_USE_GPSREFOBS}.,
 write_gpseph= .false.,
 write_ssmt1 = .false.,
 write_ssmt2 = .false.,
 write_ssmi  = .false.,
 write_tovs  = .false.,
 write_qscat = .${WRFDA_USE_QSCATOBS}.,
 write_profl = .${WRFDA_USE_PROFILEROBS}.,
 write_bogus = .${WRFDA_USE_BOGUSOBS}.,
 write_airs  = .false.,
 /

EOF


	# Running obsproc.exe
	./obsproc.exe
	
	# Leaving the working path
	cd ../..
	
	# Setting up the date information for the next cycle
	set DA_START_DATE 		= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
	set DA_END_DATE 			= `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`
	
end

