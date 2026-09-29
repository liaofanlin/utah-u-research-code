#!/bin/csh -x

# ============================================
# CODE DESCRIPTION
# ============================================
# Note (2018.08.07):
# 	- This code is slightly documented at rn180807
#
# Note (2018.04.04):
#	- The code is modified based on 
#		/zpu-group10/pu02/server_gt_pace/data02/coding/fortran/2017/170401_nc_repl_v02_data2_module_04
#
# Note (2017.02.03):
#	- The original code is obtained from 
#		/nv/hp19/llin35/data2/coding/fortran/2015/150401_nc_repl/01_nc_repl_module_04


# ============================================
# DEFINING VARIABLES
# ============================================
	set MODULE_FILE 					= ~/zpu-group10/installation/module_12_20170818.txt
	set COMPILER_FORTRAN				= gfortran
	set CDA_CODE_VERSION				= 01
	set NC_REPL_SM_TQ_EXE			= uou_nc_repl_SM_TQ.exe
	
	set E_WE_D01						= 603
	set E_SN_D01						= 393
	set WRF_NUM_SOIL_LAYERS 		= 4
	
	set UOU_NC_REPL_WRF_REAL_PATH	= ~/zpu-group10/research/2018/180301_surf_smda_wrfda_02/31_v270_SDA_01_28_July_2016/real/2016070100
	set UOU_NC_REPL_WRFOUT_PATH	= ~/zpu-group10/research/2018/180301_surf_smda_wrfda_02/31_v270_SDA_01_28_July_2016/spinup/2016063018
	
	set NX 								= `expr ${E_WE_D01} - 1`
	set NY 								= `expr ${E_SN_D01} - 1`
	set NZ								= 40
	set NZ_SOIL							= ${WRF_NUM_SOIL_LAYERS}	

# ============================================
# CREATING A NAME LIST FOR uou_nc_repl.exe
# ============================================
# Remove the name list
rm namelist.nc_repl_SM_TQ
	
# Create the name list
cat >! namelist.nc_repl << EOF
&nc_repl
 NX=${NX},
 NY=${NY},
 NZ=${NZ},
 NZ_SOIL=${NZ_SOIL},
 NC_REPL_WRF_REPL_FILENAME='wrfinput_d01_nc_repl',
 NC_REPL_PRE_FCST_FILENAME='wrfout_prev_fcst',
 /
EOF
	
# ============================================
# COMPILING uou_nc_repl.exe
# ============================================	
	# Loading the module
	source ${MODULE_FILE}
	
	# Remove the history
	rm *.exe
	
	# Compile the script
	#	- This part is different from compiling at GT.  For more details, please see 
	#    ~/zpu-group10/installation/12_install/zz_note.txt
	${COMPILER_FORTRAN} -o ${NC_REPL_SM_TQ_EXE} uou_nc_repl_SM_TQ_v${CDA_CODE_VERSION}.f90 \
		-I${NETCDF}/include \
		-L${NETCDFC}/lib -lnetcdf -lm \
		-L${NETCDFF}/lib -lnetcdff -lm	
	
# ============================================
# TESTING uou_nc_repl.exe
# ============================================	
	# Remove the old files
	rm wrfinput_d01_nc_repl
	rm wrfinput_d01_from_real
	rm wrfout_prev_fcst
	
	# Link files
	ln -sf ${UOU_NC_REPL_WRFOUT_PATH}/wrfvar_input_d01_2016-07-01_00:00:00 wrfout_prev_fcst
	ln -sf ${UOU_NC_REPL_WRF_REAL_PATH}/wrfinput_d01 wrfinput_d01_from_real
	cp wrfinput_d01_from_real wrfinput_d01_nc_repl
	
	# Running the uou_nc_repl_SM_TQ.exe
	./${NC_REPL_SM_TQ_EXE}
	
