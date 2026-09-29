#!/bin/csh -x
#
set echo
echo "--------------------------------------------------------------------------------------------------------"
echo "--- Beginning of runme_uou_cda_cycling.csh --> zz_runme_uou_cda_cycling.csh --> uou_cda_fg_repl.csh ----"
echo "--------------------------------------------------------------------------------------------------------"

	set UOU_CDA_START_TIME		= $1
	set CYCLING_START_TIME		= $2
	set UOU_CDA_NX					= $3
	set UOU_CDA_NY					= $4
	
	set UOU_CDA_NZ					= $5
	set UOU_CDA_NZ_SOIL			= $6
	set PROGRAM_DIR				= $7
	set WRF_3DVAR_EXE_VERSION	= $8
	
	set UOU_CDA_FG_REPL_OPTION	= $9
	
	
	set ADV_TIME_EXE 				= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

################################################
# 0. Go into the working folder
cd ${CYCLING_START_TIME}/01_fg_repl

# 1. Decide to use uou_nc_repl_SM.exe or uou_nc_repl_SM_TQ.exe
# ------------------------------------------------------------
	# Replaceing only soil moisture
	if (${UOU_CDA_FG_REPL_OPTION} == "SM_ONLY" ) then
		set UOU_NC_REPL_EXE_PATH	= ~/zpu-group10/coding/fortran/2018/180401_uou_cda_nc_repl_development/v03
		set UOU_NC_REPL_EXE			= uou_nc_repl_SM.exe
	endif

	# Replaceing SM, T, and Q
	if (${UOU_CDA_FG_REPL_OPTION} == "SM_TQ" ) then
		set UOU_NC_REPL_EXE_PATH	= ~/zpu-group10/coding/fortran/2018/180421_uou_cda_nc_repl_SM_TQ_development/v01
		set UOU_NC_REPL_EXE			= uou_nc_repl_SM_TQ.exe
	endif

# 2. Time string preparation 
# ----------------------------
	# (for the current time)
	set yyyy1 = `echo $CYCLING_START_TIME | cut -c1-4`
	set   mm1 = `echo $CYCLING_START_TIME | cut -c5-6`
	set   dd1 = `echo $CYCLING_START_TIME | cut -c7-8`
	set   hh1 = `echo $CYCLING_START_TIME | cut -c9-10`	
	
	# For the previous six hours
	set DA_PREVIOUS_6H_TIME = `${ADV_TIME_EXE} ${CYCLING_START_TIME} -6`

	# For the previous 12 hours
	set DA_PREVIOUS_12H_TIME = `${ADV_TIME_EXE} ${CYCLING_START_TIME} -12`
	
# 3. Link and process of the first guess file 
# -------------------------------------------
	if (${CYCLING_START_TIME} == ${UOU_CDA_START_TIME}) then
		# For a cold start
		ln -sf ../../../../spinup/${DA_PREVIOUS_6H_TIME}/wrfvar_input_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 wrfout_prev_fcst
	else
		# For a warm start
		ln -sf ../../${DA_PREVIOUS_12H_TIME}/03_wrf/wrfvar_input_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 wrfout_prev_fcst
	endif
	
# 4. Linking files
# ---------------------
	# Link the uou_nc_repl.exe
	ln -sf ${UOU_NC_REPL_EXE_PATH}/${UOU_NC_REPL_EXE} .
	
	# Link of the WRF 6-h forecast from spinup runs
	ln -sf ../../../../spinup/${DA_PREVIOUS_6H_TIME}/wrfvar_input_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 wrfout_from_spinup
	cp wrfout_from_spinup wrfinput_d01_nc_repl
	
# 5. Create a name list for uou_nc_repl.exe
# ----------------------------------------	
cat >! namelist.nc_repl << EOF
&nc_repl
 NX=${UOU_CDA_NX},
 NY=${UOU_CDA_NY},
 NZ=${UOU_CDA_NZ},
 NZ_SOIL=${UOU_CDA_NZ_SOIL},
 NC_REPL_WRF_REPL_FILENAME='wrfinput_d01_nc_repl',
 NC_REPL_PRE_FCST_FILENAME='wrfout_prev_fcst',
 /
EOF
	
# 6. Run uou_nc_repl.exe
# ------------------------
	# run uou_nc_repl.exe
	./${UOU_NC_REPL_EXE}
			
	# Produce a difference file for checking the results
	ncdiff -v XLONG,XLAT,SMOIS,T,QVAPOR wrfout_from_spinup wrfinput_d01_nc_repl wrfinput_d01_diff
			
	# Go back to the original folder		
	cd ../..		
		
echo "--------------------------------------------------------------------------------------------------------"
echo "--- End of runme_uou_cda_cycling.csh --> zz_runme_uou_cda_cycling.csh --> uou_cda_fg_repl.csh ----------"
echo "--------------------------------------------------------------------------------------------------------"












