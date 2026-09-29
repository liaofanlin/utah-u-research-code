#!/bin/csh
#

set echo
echo "-------------------------------------------------------------------------"
echo "--- Running the runme_real.csh ------------------------------------------"
echo "-------------------------------------------------------------------------"


	set WRF_MP_PHYSICS				= $1
	set WRF_RA_LW_PHYSICS			= $2
	set WRF_RA_SW_PHYSICS			= $3
	set WRF_BL_PBL_PHYSICS			= $4
	
	set WRF_SF_SFCLAY_PHYSICS		= $5
	set WRF_SF_SURFACE_PHYSICS		= $6
	set WRF_NUM_SOIL_LAYERS			= $7
	set WRF_CU_PHYSICS_D01			= $8
	
	set WRF_CU_PHYSICS_D02			= $9
	set WRF_CU_PHYSICS_D03			= $10
	set WRF_TIMESTEP					= $11
	set WRF_FEEDBACK					= $12
	
	set WRF_HISTORY_INTERVAL_D01	= $13
	set WRF_HISTORY_INTERVAL_D02	= $14
	set WRF_HISTORY_INTERVAL_D03	= $15
	set WRF_EXE_VERSION				= $16
	
	set WRF_INPUT_FROM_FILE_D01	= $17
	set WRF_INPUT_FROM_FILE_D02	= $18
	set WRF_INPUT_FROM_FILE_D03	= $19
	set WRF_3DVAR_EXE_VERSION		= $20
	
	set MAX_DOM							= $21
	set E_VERT							= $22
	set FORECAST_HOURS				= $23
	set PROGRAM_DIR					= $24
	
	set E_WE_D01						= $25
	set E_SN_D01						= $26
	set DXDY_D01						= $27
	set FORECAST_INI_FREQ			= $28
	
	set E_WE_D02						= $29
	set E_SN_D02						= $30
	set DXDY_D02						= $31
	set WPS_DATA_TYPE					= $32
	
	set E_WE_D03						= $33
	set E_SN_D03						= $34
	set DXDY_D03						= $35
	set WRF_NUM_LAND_CAT				= $36
	
	set I_PARENT_START_D02			= $37
	set J_PARENT_START_D02			= $38
	set PARENT_GRID_RATIO_D02		= $39
	set I_PARENT_START_D03			= $40
	
	set J_PARENT_START_D03			= $41
	set PARENT_GRID_RATIO_D03		= $42
	set WPS_START_DATE				= $43
	set WPS_END_DATE					= $44
	
	set ADV_TIME_EXE 					= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

# -------------------------------------------------------------------------------------------------------


set DA_START_DATE 		= ${WPS_START_DATE}
set DA_END_DATE   		= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
set FORECAST_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_HOURS}`

# while ( ${DA_END_DATE} <= ${WPS_END_DATE} ) # used when doing WRFDA

while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

	# Set up vertical levels of FNL data (2017.02.17)
	#	- It is known that on and after 2016.05.11 12UTC, the vertical levels change from 27 to 32
	#	- in the 0.25 degree FNL dataset.  It seems the case for 1-degree FNL Data
		if (${DA_START_DATE} >= 2016051112) then 
			set WRF_NUM_METGRID_LEVELS = 32
		else 
			set WRF_NUM_METGRID_LEVELS = 27
		endif
			
			
	
	rm -rf ./real/${DA_START_DATE}
	mkdir ./real/${DA_START_DATE}

	cd ./real/${DA_START_DATE}

	# Process of date
	# ---------------
		set yyyy1 = `echo $DA_START_DATE | cut -c1-4`
		set   mm1 = `echo $DA_START_DATE | cut -c5-6`
		set   dd1 = `echo $DA_START_DATE | cut -c7-8`
		set   hh1 = `echo $DA_START_DATE | cut -c9-10`
	
		set yyyy2 = `echo $FORECAST_END_TIME | cut -c1-4`
		set   mm2 = `echo $FORECAST_END_TIME | cut -c5-6`
		set   dd2 = `echo $FORECAST_END_TIME | cut -c7-8`
		set   hh2 = `echo $FORECAST_END_TIME | cut -c9-10`
	
	# for wrfda
	# ---------
	#	set yyyy2 = `echo $DA_END_DATE | cut -c1-4`
	#	set   mm2 = `echo $DA_END_DATE | cut -c5-6`
	#	set   dd2 = `echo $DA_END_DATE | cut -c7-8`
	#	set   hh2 = `echo $DA_END_DATE | cut -c9-10`

	# ----------------------------------------------------

	ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/main/real.exe .
	ln -sf ../../wps/met_em.* .

cat >! namelist.input << EOF
 &time_control
 start_year                          = ${yyyy1},	${yyyy1},	${yyyy1}, 
 start_month                         = ${mm1},		${mm1},		${mm1},	   
 start_day                           = ${dd1},		${dd1},		${dd1},   
 start_hour                          = ${hh1},		${hh1},		${hh1},   
 start_minute                        = 00,			00,  			00,
 start_second                        = 00,			00,  			00,
 end_year                            = ${yyyy2},	${yyyy2},	${yyyy2}, 
 end_month                           = ${mm2},		${mm2},		${mm2},  
 end_day                             = ${dd2},		${dd2},		${dd2},   
 end_hour                            = ${hh2},		${hh2},		${hh2},  
 end_minute                          = 00,   		00,			00,
 end_second                          = 00,   		00,			00,
 interval_seconds                    = 21600
 input_from_file                     = .${WRF_INPUT_FROM_FILE_D01}.,		.${WRF_INPUT_FROM_FILE_D02}.,		.${WRF_INPUT_FROM_FILE_D03}.,
 fine_input_stream                   = 0, 			0,				0,
 history_interval                    = ${WRF_HISTORY_INTERVAL_D01},  	${WRF_HISTORY_INTERVAL_D02},		${WRF_HISTORY_INTERVAL_D03},
 frames_per_outfile                  = 1, 			1,				1,
 restart                             = .false.,
 restart_interval                    = 100000,
 io_form_history                     = 2
 io_form_restart                     = 2
 io_form_input                       = 2
 io_form_boundary                    = 2
 debug_level                         = 0
 write_input                         = .true.,
 inputout_interval                   = 360, 			360,			360,
 inputout_begin_h                    = 6, 			6,				6,
 inputout_end_h                      = 6, 			6,				6,
 input_outname 							 = "wrfvar_input_d<domain>_<date>",
 /
 &dfi_control
 /
 &domains
 time_step                           = ${WRF_TIMESTEP},
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = ${MAX_DOM},
 s_we                                = 1,     			1,									1,
 e_we                                = ${E_WE_D01},   ${E_WE_D02},					${E_WE_D03},
 s_sn                                = 1,     			1,									1,
 e_sn                                = ${E_SN_D01},   ${E_SN_D02},					${E_SN_D03},
 s_vert                              = 1,     			1,									1,
 e_vert                              = ${E_VERT}, 	 	${E_VERT},						${E_VERT},
 num_metgrid_levels                  = ${WRF_NUM_METGRID_LEVELS},
 dx                                  = ${DXDY_D01}, 	${DXDY_D02},					${DXDY_D03},
 dy                                  = ${DXDY_D01}, 	${DXDY_D02},					${DXDY_D03},
 grid_id                             = 1,     			2,									3,
 parent_id                           = 0,     			1,									2,
 i_parent_start                      = 0,     			${I_PARENT_START_D02},		${I_PARENT_START_D03},
 j_parent_start                      = 0,     			${J_PARENT_START_D02},		${J_PARENT_START_D03},
 parent_grid_ratio                   = 1,     			${PARENT_GRID_RATIO_D02},	${PARENT_GRID_RATIO_D03},
 parent_time_step_ratio              = 1,     			${PARENT_GRID_RATIO_D02},	${PARENT_GRID_RATIO_D03},
 feedback                            = ${WRF_FEEDBACK},
 smooth_option                       = 0,
 p_top_requested                     = 5000, 
 interp_type                         = 1
 lowest_lev_from_sfc                 = .false.
 lagrange_order                      = 1
 force_sfc_in_vinterp                = 1
 zap_close_levels                    = 500
 sfcp_to_sfcp                        = .false.
 adjust_heights                      = .false.
 /
 &physics
 mp_physics                          = ${WRF_MP_PHYSICS},			${WRF_MP_PHYSICS},			${WRF_MP_PHYSICS},
 ra_lw_physics                       = ${WRF_RA_LW_PHYSICS},		${WRF_RA_LW_PHYSICS},		${WRF_RA_LW_PHYSICS},
 ra_sw_physics                       = ${WRF_RA_SW_PHYSICS},		${WRF_RA_SW_PHYSICS},		${WRF_RA_SW_PHYSICS},
 radt                                = 10,    							10,								10,
 sf_sfclay_physics                   = ${WRF_SF_SFCLAY_PHYSICS},  ${WRF_SF_SFCLAY_PHYSICS},	${WRF_SF_SFCLAY_PHYSICS},
 sf_surface_physics                  = ${WRF_SF_SURFACE_PHYSICS},	${WRF_SF_SURFACE_PHYSICS},	${WRF_SF_SURFACE_PHYSICS},     
 bl_pbl_physics                      = ${WRF_BL_PBL_PHYSICS},		${WRF_BL_PBL_PHYSICS},		${WRF_BL_PBL_PHYSICS},
 bldt                                = 0,     							0,									0,
 cu_physics                          = ${WRF_CU_PHYSICS_D01},		${WRF_CU_PHYSICS_D02},		${WRF_CU_PHYSICS_D03},
 cudt                                = 5,     							5,									5,
 isfflx                              = 1,
 ifsnow                              = 0,
 icloud                              = 1,
 surface_input_source                = 1,
 num_soil_layers                     = ${WRF_NUM_SOIL_LAYERS},
 mp_zero_out                         = 0,
 maxiens                             = 1,
 maxens                              = 3,
 maxens2                             = 3,
 maxens3                             = 16,
 ensdim                              = 144,
 num_land_cat                        = ${WRF_NUM_LAND_CAT},
 /
 &fdda
 /
 &dynamics
 w_damping                           = 0,
 diff_opt                            = 1,
 km_opt                              = 4,
 diff_6th_opt                        = 0,
 diff_6th_factor                     = 0.12,
 damp_opt                            = 0,
 base_temp                           = 290.,
 iso_temp                            = 200.,
 zdamp                               = 5000.,  5000.,	5000.,
 dampcoef                            = 0.01,   0.01,	0.01,
 khdif                               = 0,      0,		0,
 kvdif                               = 0,      0,		0,
 /
 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,
 relax_zone                          = 4,
 specified                           = .true., 	.false.,	.false.,
 nested                              = .false., .true., 	.true.,
 /
 &grib2
 /
 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /
EOF

	./real.exe
	cd ../..

	set DA_START_DATE 		= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
	set DA_END_DATE 		= `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`
	set FORECAST_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_HOURS}`
	
end


echo "-------------------------------------------------------------------------"
echo "--- Finishing the runme_real.csh ----------------------------------------"
echo "-------------------------------------------------------------------------"

