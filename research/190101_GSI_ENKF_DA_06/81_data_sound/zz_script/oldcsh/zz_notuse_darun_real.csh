#!/bin/csh
#

set echo
echo "-------------------------------------------------------------------------"  
echo "--- Running the darun_real.csh (sub of runme_da.csh) --------------------"
echo "-------------------------------------------------------------------------"

set WRF_PHY_SF_SURFACE  = $1
set WRF_NUM_SOIL_LAYERS = $2
set WRF_PHY_MP				= $3
set DXDY						= $4
set TIMESTEP				= $5
set E_VERT					= $6
set WRF_RA_SW_PHYSICS	= $7
set E_WE						= $8 
set E_SN						= $9
set DA_START_DATE			= $10

set DA_END_DATE			= $11
set MAX_DOM					= $12
set E_WE_D02				= $13
set E_SN_D02				= $14
set DXDY_D02				= $15
set I_PARENT_START_D02	= $16
set J_PARENT_START_D02	= $17
set PROGRAM_DIR			= $18
set E_WE_D03				= $19
set E_SN_D03				= $20

set DXDY_D03				= $21
set I_PARENT_START_D03	= $22
set J_PARENT_START_D03	= $23



cd ./darun/${DA_START_DATE}/real

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

ln -sf /nv/hp19/llin35/data/apurimac/wrf/WRFV3.4_dm/main/real.exe .
ln -sf ../../../wps/met_em.* .

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
 input_from_file                     = .true.,		.false.,		.false.,
 fine_input_stream                   = 0, 			0,				0,
 history_interval                    = 60,  			60,			60,
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
 time_step                           = ${TIMESTEP},
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = ${MAX_DOM},
 s_we                                = 1,     		1,								1,
 e_we                                = ${E_WE},   	${E_WE_D02},				${E_WE_D03},
 s_sn                                = 1,     		1,								1,
 e_sn                                = ${E_SN},   	${E_SN_D02},				${E_SN_D03},
 s_vert                              = 1,     		1,								1,
 e_vert                              = ${E_VERT},  ${E_VERT},					${E_VERT},
 num_metgrid_levels                  = 27,
 dx                                  = ${DXDY}, 	${DXDY_D02},				${DXDY_D03},
 dy                                  = ${DXDY}, 	${DXDY_D02},				${DXDY_D03},
 grid_id                             = 1,     		2,								3,
 parent_id                           = 0,     		1,								2,
 i_parent_start                      = 0,     		${I_PARENT_START_D02},	${I_PARENT_START_D03},
 j_parent_start                      = 0,     		${J_PARENT_START_D02},	${J_PARENT_START_D03},
 parent_grid_ratio                   = 1,     		3,								3,
 parent_time_step_ratio              = 1,     		3,								3,
 feedback                            = 0,
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
 mp_physics                          = ${WRF_PHY_MP},				${WRF_PHY_MP}, 			${WRF_PHY_MP},    
 ra_lw_physics                       = 1,     						1,								1,
 ra_sw_physics                       = ${WRF_RA_SW_PHYSICS},	${WRF_RA_SW_PHYSICS},	${WRF_RA_SW_PHYSICS},
 radt                                = 10,    						10,							10,
 sf_sfclay_physics                   = 1,     						1,								1,
 sf_surface_physics                  = ${WRF_PHY_SF_SURFACE},	${WRF_PHY_SF_SURFACE},	${WRF_PHY_SF_SURFACE},     
 bl_pbl_physics                      = 1,     						1,								1,
 bldt                                = 0,     						0,								0,
 cu_physics                          = 1,     						1,								0,
 cudt                                = 5,     						5,								5,
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

cd ../../..

echo "-------------------------------------------------------------------------"  
echo "--- Finishing the darun_real.csh (sub of runme_da.csh) ------------------"
echo "-------------------------------------------------------------------------"


