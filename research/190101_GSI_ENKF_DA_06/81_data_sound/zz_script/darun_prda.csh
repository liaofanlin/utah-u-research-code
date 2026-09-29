#!/bin/csh
#
set echo
echo "-----------------------------------------------------------------------------------------------"
echo "--- Beginning of runme_darun_4dvar.csh --> zz_runme_darun_4dvar.csh -->  darun_prda.csh--------"
echo "-----------------------------------------------------------------------------------------------"


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
	set DA_START_DATE				= $16
	
	set DA_END_DATE				= $17
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
	set NPROC        				= $42		# number of processors
	set GEN_BE_CYCLE_SWITCH		= $43
	set GEN_BE_UNIVERSE_SWITCH	= $44	
	
	set WRFDA_CLOUD_CV_OPTIONS = $45
	set WRF_SF_SFCLAY_PHYSICS	= $46


	set WORKPATH             	= `pwd`
	set ADV_TIME_EXE 				= ${PROGRAM_DIR}/wrfda/${WRF_4DVAR_EXE_VERSION}/var/build/da_advance_time.exe

# ------------------------------------------------------------------------------------------------------

cd prda

# Process of date
# ---------------
	set yyyy1 = `echo $DA_START_DATE | cut -c1-4`
	set   mm1 = `echo $DA_START_DATE | cut -c5-6`
	set   dd1 = `echo $DA_START_DATE | cut -c7-8`
	set   hh1 = `echo $DA_START_DATE | cut -c9-10`
	
	set yyyy2 = `echo $DA_END_DATE | cut -c1-4`
	set   mm2 = `echo $DA_END_DATE | cut -c5-6`
	set   dd2 = `echo $DA_END_DATE | cut -c7-8`
	set   hh2 = `echo $DA_END_DATE | cut -c9-10`

# ----------------------------------------------------

# Link files for PrDA
# -------------------
	# Link first guess and wrfbdy
	# ---------------------------
		ln -sf ../../../real/${DA_START_DATE}/wrfinput_d01 .
		cp wrfinput_d01 fg
		ln -sf ../../../real/${DA_START_DATE}/wrfbdy_d01 .

	# Link ATM BEC (Link to be.dat in each cycle)
	# --------------------------------------------
		if (${GEN_BE_CYCLE_SWITCH} == true ) then
			if 	  ( ${GEN_BE_NL_CV_OPTIONS} == '3' ) then
				ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/run/be.dat.cv3 be.date
			else if ( ${GEN_BE_NL_CV_OPTIONS} == '5' ) then
				ln -sf ../../../gen_be_cycle/${DA_START_DATE}/gen_be${GEN_BE_BIN_TYPE}_cv${GEN_BE_NL_CV_OPTIONS}/be.dat .
			else if ( ${GEN_BE_NL_CV_OPTIONS} == '6' ) then
				ln -sf ../../../gen_be_cycle/${DA_START_DATE}/gen_be${GEN_BE_BIN_TYPE}_cv${GEN_BE_NL_CV_OPTIONS}/be.dat .
			else 
			  	echo "Error!"
			endif
		endif
		
	# Link ATM BEC (Link to a single be.dat)
	# ---------------------------------------
		if (${GEN_BE_UNIVERSE_SWITCH} == true ) then
			if 	  ( ${GEN_BE_NL_CV_OPTIONS} == '3' ) then
				ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/run/be.dat.cv3 be.date
			else if ( ${GEN_BE_NL_CV_OPTIONS} == '5' ) then
				ln -sf ../../../gen_be_universe/gen_be${GEN_BE_BIN_TYPE}_cv${GEN_BE_NL_CV_OPTIONS}/be.dat .
			else if ( ${GEN_BE_NL_CV_OPTIONS} == '6' ) then
				ln -sf ../../../gen_be_universe/gen_be${GEN_BE_BIN_TYPE}_cv${GEN_BE_NL_CV_OPTIONS}/be.dat .
			else 
			  	echo "Error!"
			endif
		endif	

	# Link look-up tables and exe
	# ---------------------------
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_4DVAR_EXE_VERSION}/run/VEGPARM.TBL .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_4DVAR_EXE_VERSION}/run/SOILPARM.TBL .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_4DVAR_EXE_VERSION}/run/LANDUSE.TBL .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_4DVAR_EXE_VERSION}/run/GENPARM.TBL .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_4DVAR_EXE_VERSION}/run/RRTM_DATA_DBL RRTM_DATA
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_4DVAR_EXE_VERSION}/var/build/da_wrfvar.exe .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_4DVAR_EXE_VERSION}/var/run/crtm_coeffs .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRF_4DVAR_EXE_VERSION}/var/run/radiance_info .
		ln -sf ${PROGRAM_DIR}/wrfda/${WRFPLUS_EXE_VERSION}/run/RRTMG_SW_DATA_DBL RRTMG_SW_DATA
		ln -sf ${PROGRAM_DIR}/wrfda/${WRFPLUS_EXE_VERSION}/run/RRTMG_LW_DATA_DBL RRTMG_LW_DATA

	# Link Pr observations
	# --------------------
		if ( ${WRFDA_USE_RAINOBS} == 'true' ) then

			# for ST4
			if ( ${WRFDA_RAIN_DA_TYPE} == 'ST4' ) then
				ln -sf ${WRFDA_RAIN_DIR_DA}/${yyyy1}/${mm1}/06h/ob.rain.${DA_END_DATE}.06h ob07.rain
			endif
	
			# for TRMM
			if ( ${WRFDA_RAIN_DA_TYPE} == 'TRMM' ) then
				ln -sf ${WRFDA_RAIN_DIR_DA}/${yyyy1}/${mm1}/ob07_${yyyy2}${mm2}${dd2}-${hh2}.rain ob07.rain
			endif

			set WRFDA_OB_FORMAT = 2
		endif

	# Link radiance observations
	# --------------------------
		if ( ${WRFDA_USE_AMSUBOBS} == 'true') then
			ln -sf ../../data/amsub/gdas1.t12z.1bamub.tm00.bufr_d.LINUX amsub01.bufr
			ln -sf ../../data/amsub/gdas1.t18z.1bamub.tm00.bufr_d.LINUX amsub02.bufr
			set WRFDA_OB_FORMAT = 1
		endif

# Creating namelist
# -----------------
cat >! namelist.input << EOF
 &wrfvar1
 var4d=true,
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
 use_amsubobs=${WRFDA_USE_AMSUBOBS},
 use_rainobs=${WRFDA_USE_RAINOBS},
 thin_rainobs=true,
 thin_mesh_conv=${WRFDA_THIN_MESH_CONV},
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
 sfc_assi_options=1,
 calculate_cg_cost_fn=true,
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
 /
 &wrfvar16
 /
 &wrfvar17
 /
 &wrfvar18
 analysis_date="${yyyy1}-${mm1}-${dd1}_${hh1}:00:00.0000",
 /
 &wrfvar19
 /
 &wrfvar20
 /
 &wrfvar21
 time_window_min="${yyyy1}-${mm1}-${dd1}_${hh1}:00:00.0000",
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
 end_year				= ${yyyy2},
 end_month				= ${mm2},
 end_day					= ${dd2},
 end_hour				= ${hh2},
 end_minute				= 00,
 end_second				= 00,
 interval_seconds		= 21600,
 /
 &domains
 time_step				= ${WRFDA_TIME_STEP},
 e_we						= ${E_WE_D01},
 e_sn						= ${E_SN_D01},
 e_vert					= ${E_VERT},
 p_top_requested		= 5000,
 dx						= ${DXDY_D01},
 dy						= ${DXDY_D01},
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

# Run WRF 4D-VAR Precipitation DA
# --------------------------------
	# sbatch
	if (${QUEUE_TYPE} == 'SBATCH_CHPC') then
		mpirun -np $SLURM_NTASKS ./da_wrfvar.exe
	endif

	# pbs
	if (${QUEUE_TYPE} == 'PBS') then
		mpirun -n ${NPROC} -f $PBS_NODEFILE ./da_wrfvar.exe
	endif

cd ..

echo "---------------------------------------------------------------------------------------"
echo "--- End of runme_darun_4dvar.csh --> zz_runme_darun_4dvar.csh --> darun_prda.csh ------"
echo "---------------------------------------------------------------------------------------"
