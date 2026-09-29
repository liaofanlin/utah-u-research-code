#!/bin/csh
#
set echo
echo "-------------------------------------------------------------------------"
echo "--- Here is the gen_be_real.csh -----------------------------------------"
echo "-------------------------------------------------------------------------"

set WRF_SF_SURFACE_PHYSICS	= $1
set WRF_NUM_SOIL_LAYERS 	= $2
set WRF_MP_PHYSICS			= $3
set START_DATE					= $4

set END_DATE					= $5
set DXDY_D01					= $6
set WRF_TIMESTEP				= $7
set E_VERT						= $8

set WRF_RA_SW_PHYSICS		= $9
set E_WE_D01					= $10
set E_SN_D01					= $11
set PROGRAM_DIR				= $12

set WRF_EXE_VERSION			= $13
set WRF_FEEDBACK				= $14
set WRF_RA_LW_PHYSICS		= $15
set WRF_BL_PBL_PHYSICS		= $16

set WRF_CU_PHYSICS_D01		= $17
set WPS_DATA_TYPE				= $18
set GEN_BE_CYCLE_SWITCH		= $19
set GEN_BE_UNIVERSE_SWITCH	= $20

set WRF_SF_SFCLAY_PHYSICS	= $21

cd real/${START_DATE}

# Process of date
# ---------------
	set yyyy1 = `echo $START_DATE | cut -c1-4`
	set   mm1 = `echo $START_DATE | cut -c5-6`
	set   dd1 = `echo $START_DATE | cut -c7-8`
	set   hh1 = `echo $START_DATE | cut -c9-10`
	
	set yyyy2 = `echo $END_DATE | cut -c1-4`
	set   mm2 = `echo $END_DATE | cut -c5-6`
	set   dd2 = `echo $END_DATE | cut -c7-8`
	set   hh2 = `echo $END_DATE | cut -c9-10`

# Set up vertical levels of FNL data (2017.02.17)
#	- It is known that on and after 2016.05.11 12UTC, the vertical levels change 
#	- from 27 to 32 in the 0.25 degree FNL dataset.  1 degree FNL dataset is not
#	- yet tested in 2016. 
	if (${START_DATE} >= 2016051112) then 
		set WRF_NUM_METGRID_LEVELS = 32
	else 
		set WRF_NUM_METGRID_LEVELS = 27
	endif
		
# Link real.exe		
ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/main/real.exe .

# Link to met_em files
# --------------------
	# GEN_BE for each cycle
	if (${GEN_BE_CYCLE_SWITCH} == 'true') then
		ln -sf ../../../../wps/met_em.* .
	endif

	# GEN_BE	for all the cycles
	if (${GEN_BE_UNIVERSE_SWITCH} == 'true') then
		ln -sf ../../../wps/met_em.* .
	endif
	
	
	
cat >! namelist.input << EOF
 &time_control
 start_year                          = ${yyyy1},	${yyyy1}, 
 start_month                         = ${mm1},  	${mm1}, 
 start_day                           = ${dd1},		${dd1},   
 start_hour                          = ${hh1},		${hh1},    
 start_minute                        = 00,			00,  
 start_second                        = 00,			00,  
 end_year                            = ${yyyy2},	${yyyy2},	 
 end_month                           = ${mm2},		${mm2},  
 end_day                             = ${dd2},		${dd2},   
 end_hour                            = ${hh2},		${hh2},  
 end_minute                          = 00,   		00,
 end_second                          = 00,   		00,
 interval_seconds                    = 21600
 input_from_file                     = .true.,.false.,
 fine_input_stream                   = 0, 0,
 history_interval                    = 720,  720,
 frames_per_outfile                  = 1, 1,
 restart                             = .false.,
 restart_interval                    = 100000,
 io_form_history                     = 2
 io_form_restart                     = 2
 io_form_input                       = 2
 io_form_boundary                    = 2
 debug_level                         = 0
 write_input                         = .true.,
 inputout_interval                   = 360, 360,
 inputout_begin_h                    =   6, 6,
 inputout_end_h                      =   6, 6,
 input_outname="wrfvar_input_d<domain>_<date>",
 /
 &dfi_control
 /
 &domains
 time_step                           = ${WRF_TIMESTEP},
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = 1,
 s_we                                = 1,     1,
 e_we                                = ${E_WE_D01},   
 s_sn                                = 1,     1,
 e_sn                                = ${E_SN_D01},   
 s_vert                              = 1,     1,
 e_vert                              = ${E_VERT},   
 num_metgrid_levels                  = ${WRF_NUM_METGRID_LEVELS},
 dx                                  = ${DXDY_D01}, 
 dy                                  = ${DXDY_D01},
 grid_id                             = 1,     2,
 parent_id                           = 0,     1,
 i_parent_start                      = 0,    
 j_parent_start                      = 0,     
 parent_grid_ratio                   = 1,     4,
 parent_time_step_ratio              = 1,     4,
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
 mp_physics                          = ${WRF_MP_PHYSICS},			${WRF_MP_PHYSICS},
 ra_lw_physics                       = ${WRF_RA_LW_PHYSICS},		${WRF_RA_LW_PHYSICS},
 ra_sw_physics                       = ${WRF_RA_SW_PHYSICS},		${WRF_RA_SW_PHYSICS},
 radt                                = 10,    							10,
 sf_sfclay_physics                   = ${WRF_SF_SFCLAY_PHYSICS},	${WRF_SF_SFCLAY_PHYSICS},
 sf_surface_physics                  = ${WRF_SF_SURFACE_PHYSICS},	${WRF_SF_SURFACE_PHYSICS},
 bl_pbl_physics                      = ${WRF_BL_PBL_PHYSICS},		${WRF_BL_PBL_PHYSICS},
 bldt                                = 0,     							0,
 cu_physics                          = ${WRF_CU_PHYSICS_D01},		1,
 cudt                                = 5,     							5,
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
 zdamp                               = 5000.,  5000.,
 dampcoef                            = 0.01,   0.01,
 khdif                               = 0,      0,
 kvdif                               = 0,      0,
 /
 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,
 relax_zone                          = 4,
 specified                           = .true., .false.,.false.,
 nested                              = .false., .true., .true.,
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

echo "--------------------------------"
echo "---   Done gen_be_real.csh   ---"
echo "--------------------------------"
