#!/bin/csh
#
set echo
echo "-------------------------------------------------------------------------"
echo "--- Beginning of runme_darun_3dvar.csh --> darun_3dvar.csh --------------"
echo "-------------------------------------------------------------------------"

set WRF_SF_SURFACE_PHYSICS	= $1
set WRF_NUM_SOIL_LAYERS 	= $2
set WRF_MP_PHYSICS			= $3
set GEN_BE_NL_CV_OPTIONS	= $4

set GEN_BE_BIN_TYPE			= $5
set WRFDA_CHECK_MAX_IV		= $6
set DXDY_D01					= $7
set WRF_TIMESTEP				= $8

set WRFDA_USE_AMSUBOBS 		= $9
set WRFDA_USE_RAINOBS		= $10
set WRFDA_THIN_MESH_CONV	= "$11"
set E_VERT						= $12

set WRF_RA_SW_PHYSICS		= $13
set E_WE_D01					= $14
set E_SN_D01					= $15
set DA_START_TIME				= $16

set DA_END_TIME				= $17
set PROGRAM_DIR				= $18
set WRFDA_ST4_DIR				= $19
set WRFDA_RAIN_DIR_DA		= $20

set WRFDA_TIME_STEP			= $21
set WRFDA_LEN_SCALING		= $22
set WRFDA_CODE					= $23
set WRFDA_MAX_ERROR_RAIN	= $24

set WRFDA_RAIN_DA_TYPE 		= $25
set WRFDA_LEN04_SCALING		= $26
set CYCLING_MODE				= $27
set WPS_START_DATE			= $28

set WRF_4DVAR_EXE_VERSION	= $29
set WRFPLUS_EXE_VERSION		= $30
set WRFDA_I_PARENT_START	= $31
set WRFDA_J_PARENT_START	= $32

set DA_SPECIAL_MODE01		= $33
set SMDA_NX						= $34
set SMDA_NY						= $35
set SMDA_NZ						= $36

set WRF_RA_LW_PHYSICS		= $37
set WRF_BL_PBL_PHYSICS		= $38
set WRF_CU_PHYSICS_D01		= $39
set NC_REPL_PATH				= $40

set QUEUE_TYPE					= $41
set WRF_3DVAR_EXE_VERSION	= $42
set NPROC        				= $43		# number of processors
set GEN_BE_CYCLE_SWITCH		= $44

set GEN_BE_UNIVERSE_SWITCH	= $45
set WRFDA_CLOUD_CV_OPTIONS	= $46
set WRF_SF_SFCLAY_PHYSICS	= $47
set WRFDA_OB_FORMAT			= $48

set OBSPROC_WINDOW_HOUR		= $49
set WRFDA_THIN_CONV_ASCII	= $50
set WRFDA_USE_SYNOPOBS		= $51
set WRFDA_USE_SHIPSOBS		= $52

set WRFDA_USE_METAROBS		= $53
set WRFDA_USE_SOUNDOBS		= $54
set WRFDA_USE_PILOTOBS		= $55
set WRFDA_USE_AIREPOBS		= $56

set WRFDA_USE_GEOAMVOBS		= $57
set WRFDA_USE_POLARAMVOBS	= $58
set WRFDA_USE_BOGUSOBS		= $59
set WRFDA_USE_BUOYOBS		= $60

set WRFDA_USE_PROFILEROBS	= $61
set WRFDA_USE_SATEMOBS		= $62
set WRFDA_USE_GPSPWOBS		= $63	
set WRFDA_USE_GPSZTDOBS		= $64

set WRFDA_USE_GPSREFOBS		= $65
set WRFDA_USE_QSCATOBS		= $66
set WRFDA_DOMAIN				= $67
set E_WE_D02					= $68

set E_SN_D02					= $69
set DXDY_D02					= $70
set WRFDA_SFC_ASSI_OPTIONS	= $71


set WORKPATH             	= `pwd`
set ADV_TIME_EXE 				= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

# ------------------------------------------------------------------------------------------------------


cd 3dvar_${WRFDA_DOMAIN}

# =====================
# 1. Process of date
# =====================
	# Analysis time
	set yyyy1 = `echo $DA_START_TIME | cut -c1-4`
	set   mm1 = `echo $DA_START_TIME | cut -c5-6`
	set   dd1 = `echo $DA_START_TIME | cut -c7-8`
	set   hh1 = `echo $DA_START_TIME | cut -c9-10`
	
	# Initialization time for the previous 6-h forecast
	set PREVIOUS_6H_TIME   = `${ADV_TIME_EXE} ${DA_START_TIME} -6`
	
	# The beginning of the time window
	set WINDOW_START_TIME   = `${ADV_TIME_EXE} ${DA_START_TIME} -${OBSPROC_WINDOW_HOUR}`
	set yyyy0 = `echo $WINDOW_START_TIME | cut -c1-4`
	set   mm0 = `echo $WINDOW_START_TIME | cut -c5-6`
	set   dd0 = `echo $WINDOW_START_TIME | cut -c7-8`
	set   hh0 = `echo $WINDOW_START_TIME | cut -c9-10`

	# The end of the time window
	set WINDOW_END_TIME   = `${ADV_TIME_EXE} ${DA_START_TIME} ${OBSPROC_WINDOW_HOUR}`
	set yyyy2 = `echo $WINDOW_END_TIME | cut -c1-4`
	set   mm2 = `echo $WINDOW_END_TIME | cut -c5-6`
	set   dd2 = `echo $WINDOW_END_TIME | cut -c7-8`
	set   hh2 = `echo $WINDOW_END_TIME | cut -c9-10`


# =====================
# 2. Link files for 3D-Var
# =====================
	# 2.1. Link first guess 
	# ---------------------------
		ln -sf ../../../spinup/${PREVIOUS_6H_TIME}/wrfvar_input_${WRFDA_DOMAIN}_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 wrfinput_${WRFDA_DOMAIN}
		cp wrfinput_${WRFDA_DOMAIN} fg
		
	# 2.2. Link of wrfbdy
	# --------------------
		ln -sf ../../../real/${DA_START_TIME}/wrfbdy_d01 .

	# 2.3. Link ATM BEC (Link to be.dat in each cycle)
	# --------------------------------------------
		if (${GEN_BE_CYCLE_SWITCH} == true ) then
			if 	  ( ${GEN_BE_NL_CV_OPTIONS} == '3' ) then
				ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/run/be.dat.cv3 be.dat
			else if ( ${GEN_BE_NL_CV_OPTIONS} == '5' ) then
				ln -sf ../../../gen_be_cycle/${DA_START_TIME}/gen_be${GEN_BE_BIN_TYPE}_cv${GEN_BE_NL_CV_OPTIONS}/be.dat .
			else if ( ${GEN_BE_NL_CV_OPTIONS} == '6' ) then
				ln -sf ../../../gen_be_cycle/${DA_START_TIME}/gen_be${GEN_BE_BIN_TYPE}_cv${GEN_BE_NL_CV_OPTIONS}/be.dat .
			else 
			  	echo "Error!"
			endif
		endif
		
	# 2.4. Link ATM BEC (Link to a single be.dat)
	# ---------------------------------------
		if (${GEN_BE_UNIVERSE_SWITCH} == true ) then
			if 	  ( ${GEN_BE_NL_CV_OPTIONS} == '3' ) then
				ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/run/be.dat.cv3 be.dat
			else if ( ${GEN_BE_NL_CV_OPTIONS} == '5' ) then
				ln -sf ../../../gen_be_universe/gen_be${GEN_BE_BIN_TYPE}_cv${GEN_BE_NL_CV_OPTIONS}/be.dat .
			else if ( ${GEN_BE_NL_CV_OPTIONS} == '6' ) then
				ln -sf ../../../gen_be_universe/gen_be${GEN_BE_BIN_TYPE}_cv${GEN_BE_NL_CV_OPTIONS}/be.dat .
			else 
			  	echo "Error!"
			endif
		endif
		
	# 2.5. Link of CV3 be.dat file here
	# -------------------------------
		# Note (2018.01.10) 
		#	- Items 2 and 3 is not properly written for CV3.  When using CV3, 
		#	  I actually set "GEN_BE_CYCLE_SWITCH=false" & "GEN_BE_UNIVERSE_SWITCH=false".
		#	  Therefore, no be.dat file will be linked to the working folder. 
		if (-f be.dat) then
		
		else
			ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/run/be.dat.cv3 be.dat
		endif
	
	# 2.6. Link of observations
	# -----------------------
		ln -sf ../../../obsproc/${DA_START_TIME}/obs_gts_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00.3DVAR ob.ascii
		
	# 2.7. Link look-up tables
	# -------------------
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/run/VEGPARM.TBL .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/run/SOILPARM.TBL .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/run/LANDUSE.TBL .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/run/GENPARM.TBL .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/run/RRTM_DATA_DBL RRTM_DATA
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/run/crtm_coeffs .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/run/radiance_info .

	# 2.8. Link da_wrfvar.exe
	# -------------------
		# Real one!!!
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_wrfvar.exe .
		
		# For a testing purpose!!!
		# ln -sf ../../../${WRF_3DVAR_EXE_VERSION}/var/build/da_wrfvar.exe .

	# Other Setup
	# -----------

# =========================================
# Setup of the namelist for different domain
# =========================================
	# 1. Domain size and resolution
	# -----------------------------
		if (${WRFDA_DOMAIN} == 'd01') then
			set WEST_EAST_GRID_NUMBER 		= ${E_WE_D01}
			set SOUTH_NORTH_GRID_NUMBER 	= ${E_SN_D01}
			set GRID_DISTANCE					= ${DXDY_D01}
		else if (${WRFDA_DOMAIN} == 'd02') then
			set WEST_EAST_GRID_NUMBER 		= ${E_WE_D02}
			set SOUTH_NORTH_GRID_NUMBER 	= ${E_SN_D02}
			set GRID_DISTANCE					= ${DXDY_D02}			
		endif


# Creating namelist
# -----------------
cat >! namelist.input << EOF
 &wrfvar1
 var4d=false,
 var4d_lbc=false,
 var4d_bin=3600,
 var4d_bin_rain=21600,
 print_detail_outerloop=false,
 print_detail_grad=true,
 /
 &wrfvar2
 /
 &wrfvar3
 ob_format=${WRFDA_OB_FORMAT},
 /
 &wrfvar4
 thin_conv=true,
 thin_conv_ascii=${WRFDA_THIN_CONV_ASCII},
 thin_mesh_conv=${WRFDA_THIN_MESH_CONV},
 use_synopobs=${WRFDA_USE_SYNOPOBS},
 use_shipsobs=${WRFDA_USE_SHIPSOBS},
 use_metarobs=${WRFDA_USE_METAROBS},
 use_soundobs=${WRFDA_USE_SOUNDOBS},
 use_pilotobs=${WRFDA_USE_PILOTOBS},
 use_airepobs=${WRFDA_USE_AIREPOBS},
 use_geoamvobs=${WRFDA_USE_GEOAMVOBS},
 use_polaramvobs=${WRFDA_USE_POLARAMVOBS},
 use_bogusobs=${WRFDA_USE_BOGUSOBS},
 use_buoyobs=${WRFDA_USE_BUOYOBS},
 use_profilerobs=${WRFDA_USE_PROFILEROBS},
 use_satemobs=${WRFDA_USE_SATEMOBS},
 use_gpspwobs=${WRFDA_USE_GPSPWOBS},
 use_gpsztdobs=${WRFDA_USE_GPSZTDOBS},
 use_gpsrefobs=${WRFDA_USE_GPSREFOBS},
 use_qscatobs=${WRFDA_USE_QSCATOBS},
 use_amsubobs=${WRFDA_USE_AMSUBOBS},
 use_rainobs=${WRFDA_USE_RAINOBS},
 thin_rainobs=true,
 /
 &wrfvar5
 check_max_iv=${WRFDA_CHECK_MAX_IV},
 max_error_rain=${WRFDA_MAX_ERROR_RAIN},
 /
 &wrfvar6
 max_ext_its=1,
 ntmax=50,
 orthonorm_gradient=true,
 /
 &wrfvar7
 cv_options=${GEN_BE_NL_CV_OPTIONS},
 len_scaling1=${WRFDA_LEN_SCALING},
 len_scaling2=${WRFDA_LEN_SCALING},
 len_scaling3=${WRFDA_LEN_SCALING},
 len_scaling4=${WRFDA_LEN04_SCALING},
 len_scaling5=${WRFDA_LEN_SCALING},
 cloud_cv_options=${WRFDA_CLOUD_CV_OPTIONS},
 /
 &wrfvar8
 /
 &wrfvar9
 /
 &wrfvar10
 test_transforms=false,
 test_gradient=false,
 /
 &wrfvar11
 cv_options_hum=1,
 check_rh=0,
 sfc_assi_options=${WRFDA_SFC_ASSI_OPTIONS},
 calculate_cg_cost_fn=true,
 write_detail_grad_fn=.true.,
 /
 &wrfvar12
 /
 &wrfvar13
 /
 &wrfvar14
 rtminit_nsensor=3,
 rtminit_platform=1,1,1,
 rtminit_satid=15,16,17,
 rtminit_sensor=4,4,4,
 thinning_mesh=1.0,1.0,1.0,
 thinning=false,
 qc_rad=true,
 write_iv_rad_ascii=true,
 write_oa_rad_ascii=true,
 rtm_option=2,
 only_sea_rad=false,
 use_varbc=.true.
 use_crtm_kmatrix=.true.
 /
 &wrfvar15
 num_pseudo=0,
 pseudo_x=6.0,
 pseudo_y=5.0,
 pseudo_z=1.0,
 pseudo_err=1.0,
 pseudo_val=1.0,
 /
 &wrfvar16
 /
 &wrfvar17
 /
 &wrfvar18
 analysis_date="${yyyy1}-${mm1}-${dd1}_${hh1}:00:00.0000",
 /
 &wrfvar19
 pseudo_var='q',
 /
 &wrfvar20
 /
 &wrfvar21
 time_window_min="${yyyy0}-${mm0}-${dd0}_${hh0}:00:00.0000",
 /
 &wrfvar22
 time_window_max="${yyyy2}-${mm2}-${dd2}_${hh2}:00:00.0000",
 /
 &wrfvar23
 /
 &time_control
 start_year				= ${yyyy1},
 start_month			= ${mm1},
 start_day				= ${dd1},
 start_hour				= ${hh1},
 start_minute			= 00,
 start_second			= 00,
 end_year				= ${yyyy1},
 end_month				= ${mm1},
 end_day					= ${dd1},
 end_hour				= ${hh1},
 end_minute				= 00,
 end_second				= 00,
 /
 &domains
 time_step				= ${WRFDA_TIME_STEP},
 e_we						= ${WEST_EAST_GRID_NUMBER},
 e_sn						= ${SOUTH_NORTH_GRID_NUMBER},
 e_vert					= ${E_VERT},
 p_top_requested		= 5000,
 dx						= ${GRID_DISTANCE},
 dy						= ${GRID_DISTANCE},
 i_parent_start		= ${WRFDA_I_PARENT_START},
 j_parent_start		= ${WRFDA_J_PARENT_START},
 smooth_option			= 0,
 nproc_x					= 0,
 /
 &fdda
 /
 &dfi_control
 /
 &tc
 /
 &physics
 mp_physics				= ${WRF_MP_PHYSICS},
 ra_lw_physics			= ${WRF_RA_LW_PHYSICS},
 ra_sw_physics			= ${WRF_RA_SW_PHYSICS},
 radt						= 10,
 sf_sfclay_physics	= ${WRF_SF_SFCLAY_PHYSICS},
 sf_surface_physics	= ${WRF_SF_SURFACE_PHYSICS},
 bl_pbl_physics		= ${WRF_BL_PBL_PHYSICS},
 cu_physics				= ${WRF_CU_PHYSICS_D01},
 cudt						= 5,
 num_soil_layers		= ${WRF_NUM_SOIL_LAYERS},
 mp_zero_out         = 0,
 maxiens             = 1,
 maxens              = 3,
 maxens2             = 3,
 maxens3             = 16,
 ensdim              = 144,
 /
 &scm
 /
 &dynamics
 w_damping           = 0,
 diff_opt            = 1,
 km_opt              = 4,
 diff_6th_opt        = 0,
 diff_6th_factor     = 0.12,
 damp_opt            = 0,
 base_temp           = 290.,
 iso_temp            = 200.,
 zdamp               = 5000.,  5000.,
 dampcoef            = 0.01,   0.01,
 khdif               = 0,      0,
 kvdif               = 0,      0,
 /
 &bdy_control
 spec_bdy_width      = 5,
 spec_zone           = 1,
 relax_zone          = 4,
 specified           = .true., .false.,.false.,
 nested              = .false., .true., .true.,
 /
 &grib2
 /
 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups 			= 1,
 /
 &perturbation
 /
EOF

# Run WRF 3D-Var
# --------------
	# sbatch
	if (${QUEUE_TYPE} == 'SBATCH_CHPC') then
		mpirun -np $SLURM_NTASKS ./da_wrfvar.exe
	endif

	# pbs
	if (${QUEUE_TYPE} == 'PBS') then
		mpirun -n ${NPROC} -f $PBS_NODEFILE ./da_wrfvar.exe
	endif

cd ..

echo "---------------------------------------------------------------"
echo "--- End of runme_darun_3dvar.csh --> darun_3dvar.csh ----------"
echo "---------------------------------------------------------------"












