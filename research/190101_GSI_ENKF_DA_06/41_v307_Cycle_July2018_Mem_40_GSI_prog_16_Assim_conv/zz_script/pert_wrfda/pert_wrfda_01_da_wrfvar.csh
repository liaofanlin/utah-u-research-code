#!/bin/csh -x
#

# set echo
echo "-------------------------------------------------------------------------"
echo "--- Beginning of pert_wrfda_01_da_wrfvar.csh ----------------------------"
echo "-------------------------------------------------------------------------"

set PROC_TIME						= $1
set ENS_MEM_STR					= $2
set E_WE_D01						= $3
set E_SN_D01						= $4

set E_VERT							= $5
set DXDY_D01						= $6
set PERT_WRFDA_PROGRAM_DIR		= $7	
set PERT_WRFDA_3DVAR_VERSION	= $8

set PERT_WRFDA_MODULE_WRFDA 	= $9
set WORKING_DIR					= $10
set WORKING_STR 					= $11


set PERT_WRFDA_3DVAR_EXE		= ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/var/build/da_wrfvar.exe
set ADV_TIME_EXE					= ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/var/build/da_advance_time.exe


# =======================================================================================================
# Pre-steps
echo "   --> Processing Member ${ENS_MEM_STR} of ${PROC_TIME} (${WORKING_STR})"

cd ${WORKING_DIR}

# Analysis Time Details
# =========================
set yyyy1 = `echo $PROC_TIME | cut -c1-4`
set   mm1 = `echo $PROC_TIME | cut -c5-6`
set   dd1 = `echo $PROC_TIME | cut -c7-8`
set   hh1 = `echo $PROC_TIME | cut -c9-10`

# Linking necessary files
# =======================
	# First guess
	ln -sf ../../../../../real/${PROC_TIME}/wrfinput_d01 fg
	
	# be.dat
	ln -sf ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/var/run/be.dat.cv3 be.dat

	# Look-up tables for WRFDA
	ln -sf ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/run/VEGPARM.TBL .
	ln -sf ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/run/SOILPARM.TBL .
	ln -sf ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/run/LANDUSE.TBL .
	ln -sf ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/run/GENPARM.TBL .
	ln -sf ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/run/RRTM_DATA_DBL RRTM_DATA
	ln -sf ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/var/run/crtm_coeffs .
	ln -sf ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/var/run/radiance_info .
	
	# WRFDA Executable
	ln -sf ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/var/build/da_wrfvar.exe .

# Define the variance of RANDOMCV
# ===============================	
if (${WORKING_STR} == 'wrfinput') then
	set PERT_WRFDA_RANDOMCV_AS = 0.25
else if (${WORKING_STR} == 'wrfbdy') then
	set PERT_WRFDA_RANDOMCV_AS = 0.25
else
	echo 'Error'
endif

# Creating name list
# ====================
cat >! namelist.input << EOF
&wrfvar1
print_detail_outerloop=false,
print_detail_grad=true,
/
&wrfvar2
/
&wrfvar3
ob_format=2,
/
&wrfvar4
/
&wrfvar5
/
&wrfvar6
/
&wrfvar7
cv_options = 3,
as1        = ${PERT_WRFDA_RANDOMCV_AS}, 1.0, 1.5,
as2        = ${PERT_WRFDA_RANDOMCV_AS}, 1.0, 1.5,
as3        = ${PERT_WRFDA_RANDOMCV_AS}, 1.0, 1.5,
as4        = ${PERT_WRFDA_RANDOMCV_AS}, 1.0, 1.5,
as5        = ${PERT_WRFDA_RANDOMCV_AS}, 1.0, 1.5,
/
&wrfvar8
/
&wrfvar9
/
&wrfvar10
/
&wrfvar11
/
&wrfvar12
/
&wrfvar13
/
&wrfvar14
/
&wrfvar15
/
&wrfvar16
/
&wrfvar17
analysis_type = "RANDOMCV",
/
&wrfvar18
analysis_date="${yyyy1}-${mm1}-${dd1}_${hh1}:00:00.0000",
/
&wrfvar19
/
&wrfvar20
/
&wrfvar21
/
&wrfvar22
/
&wrfvar23
/
&time_control
start_year				= ${yyyy1},
start_month				= ${mm1},
start_day				= ${dd1},
start_hour				= ${hh1},
start_minute			= 00,
start_second			= 00,
end_year					= ${yyyy1},
end_month				= ${mm1},
end_day					= ${dd1},
end_hour					= ${hh1},
end_minute				= 00,
end_second				= 00,
/
&domains
time_step				= 200,
e_we						= ${E_WE_D01},
e_sn						= ${E_SN_D01},
e_vert					= ${E_VERT},
p_top_requested		= 5000,
dx							= ${DXDY_D01},
dy							= ${DXDY_D01},
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
mp_physics				= 3,
ra_lw_physics			= 1,
ra_sw_physics			= 1,
radt						= 10,
sf_sfclay_physics		= 1,
sf_surface_physics	= 2,
bl_pbl_physics			= 1,
cu_physics				= 1,
cudt						= 5,
num_soil_layers		= 4,
mp_zero_out         	= 0,
maxiens             	= 1,
maxens              	= 3,
maxens2             	= 3,
maxens3             	= 16,
ensdim              	= 144,
/
&scm
/
&dynamics
/
&bdy_control
/
&grib2
/
&namelist_quilt
/
&perturbation
/
EOF

# Run da_wrfvar.exe
# ====================
source ${PERT_WRFDA_MODULE_WRFDA}
./da_wrfvar.exe


cd ../../../../..



echo "------------------------------------------------------------------"
echo "--- End of pert_wrfda_01_da_wrfvar.csh ---------------------------"
echo "------------------------------------------------------------------"


