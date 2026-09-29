#!/bin/csh -x
#

# set echo
echo "-------------------------------------------------------------------------"
echo "--- Beginning of pert_wrfda_01_da_update_bc.csh -------------------------"
echo "-------------------------------------------------------------------------"

set PROC_TIME						= $1
set ENS_MEM_STR 					= $2
set PERT_WRFDA_PROGRAM_DIR		= $3	
set PERT_WRFDA_3DVAR_VERSION	= $4

set PERT_WRFDA_MODULE_WRFDA 	= $5
set WORKING_DIR					= $6
set WORKING_STR 					= $7

# =======================================================================================================
# Pre-steps
# =======================
echo "   --> Processing Member ${ENS_MEM_STR} of ${PROC_TIME} (${WORKING_STR})"

cd ${WORKING_DIR}

# Linking necessary files
# =======================
	# Original wrfbdy
	ln -sf ../../../../../real/${PROC_TIME}/wrfbdy_d01 wrfbdy_ori
	
	# wrfbdy to be updated
	cp wrfbdy_ori wrfbdy_d01
	
	# First guess (original wrfinput)
	ln -sf ../da_wrfvar/fg wrfinput_d01

	# wrfvar_out (perturbed wrfinput)
	ln -sf ../da_wrfvar/wrfvar_output
	
	# da_update_bc.exe
	ln -sf ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/var/build/da_update_bc.exe .
		
# Creating name list
# ====================
cat >! parame.in << EOF
 &control_param
 da_file            = './wrfvar_output'
 wrf_bdy_file       = './wrfbdy_d01'
 domain_id          = 1
 debug   			  = .true.
 update_lateral_bdy = .true.
 update_low_bdy 	  = .false.            
 update_lsm         = .false. 
 iswater            = 16
 var4d_lbc          = .false.
/
EOF

# Run da_update_bc.exe
# ====================
source ${PERT_WRFDA_MODULE_WRFDA}
./da_update_bc.exe


cd ../../../../..



echo "------------------------------------------------------------------"
echo "--- End of pert_wrfda_01_da_update_bc.csh ------------------------"
echo "------------------------------------------------------------------"


