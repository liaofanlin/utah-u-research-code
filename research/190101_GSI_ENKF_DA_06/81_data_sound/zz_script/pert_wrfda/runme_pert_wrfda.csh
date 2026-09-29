#!/bin/csh -x
#

# set echo
echo "-------------------------------------------------------------------------"
echo "--- Beginning of runme_perturbation_wrfda.csh ---------------------------"
echo "-------------------------------------------------------------------------"

set E_WE_D01						= $1
set E_SN_D01						= $2
set E_VERT							= $3
set DXDY_D01						= $4

set WPS_START_DATE 				= $5
set WPS_END_DATE					= $6
set WRF_EXE_VERSION				= $7




set PERT_WRFDA_MEMBER			= 40
set PERT_WRFDA_MODULE_WRFDA 	= ~/zpu-group10/installation/module_12_20170818.txt
# set PERT_WRFDA_MODULE_WRF		= ~/zpu-group10/installation/module_11_20170816.txt

set PERT_WRFDA_PROGRAM_DIR		= ~/zpu-group10/installation/12_install
set PERT_WRFDA_3DVAR_VERSION	= WRFDA3.9.1_3dvar_dm_prog05_da_random_seed
set PERT_WRFDA_3DVAR_EXE		= ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/var/build/da_wrfvar.exe
set ADV_TIME_EXE					= ${PERT_WRFDA_PROGRAM_DIR}/wrfda/${PERT_WRFDA_3DVAR_VERSION}/var/build/da_advance_time.exe

# =======================================================================================================


	mkdir real_pert/wrfinput
	mkdir real_pert/wrfinput/${WPS_START_DATE}
	mkdir real_pert/wrfbdy


# ============================================
# 1. Perturbing Initial Conditions (wrfinput)
# ============================================
	set MEMBER_COUNT = 1
	
	while ( ${MEMBER_COUNT} <= ${PERT_WRFDA_MEMBER} )	

		# Set up member id string (only for member number < 100)
		if ($MEMBER_COUNT<10) then
			set ENS_MEM_STR = 00${MEMBER_COUNT}
		else
			set ENS_MEM_STR = 0${MEMBER_COUNT}
		endif
						
		# Create folders		
		mkdir real_pert/wrfinput/${WPS_START_DATE}/mem${ENS_MEM_STR}
		mkdir real_pert/wrfinput/${WPS_START_DATE}/mem${ENS_MEM_STR}/da_wrfvar

		# Perform WRFDA Perturbation
		set CURRENT_PATH 	= `pwd`
		set WORKING_DIR 	= ${CURRENT_PATH}/real_pert/wrfinput/${WPS_START_DATE}/mem${ENS_MEM_STR}/da_wrfvar
		set WORKING_STR   = wrfinput
		
		csh zz_script/pert_wrfda/pert_wrfda_01_da_wrfvar.csh \
			${WPS_START_DATE} 			${ENS_MEM_STR}				${E_WE_D01}						${E_SN_D01} \
			${E_VERT}						${DXDY_D01}					${PERT_WRFDA_PROGRAM_DIR}	${PERT_WRFDA_3DVAR_VERSION} \
			${PERT_WRFDA_MODULE_WRFDA}	${WORKING_DIR}				${WORKING_STR}

		# For next iteration
		set MEMBER_COUNT = `expr ${MEMBER_COUNT} + 1`
	end
	
	
# ====================================================
# 2. Perturbing Lateral Boundary Condition (wrfbdy)
# ====================================================
	

	set DA_START_TIME = ${WPS_START_DATE}
	set DA_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_TIME} 6`

	while (${DA_END_TIME} <= ${WPS_END_DATE}) 
	
		# 2.1 Folder preparation
		mkdir real_pert/wrfbdy/${DA_START_TIME}
		
		# 2.2. Working on each member
		set MEMBER_COUNT = 1
	
		while ( ${MEMBER_COUNT} <= ${PERT_WRFDA_MEMBER} )	

			# 2.2.1. Set up member id string (only for member number < 100)
			if ($MEMBER_COUNT<10) then
				set ENS_MEM_STR = 00${MEMBER_COUNT}
			else
				set ENS_MEM_STR = 0${MEMBER_COUNT}
			endif		
	
			# 2.2.2. Create folder
			mkdir real_pert/wrfbdy/${DA_START_TIME}/mem${ENS_MEM_STR}
			mkdir real_pert/wrfbdy/${DA_START_TIME}/mem${ENS_MEM_STR}/da_wrfvar
			mkdir real_pert/wrfbdy/${DA_START_TIME}/mem${ENS_MEM_STR}/da_update_bc

			# 2.2.3. Perform WRFDA da_wrfvar.exe
			set CURRENT_PATH 	= `pwd`
			set WORKING_DIR 	= ${CURRENT_PATH}/real_pert/wrfbdy/${DA_START_TIME}/mem${ENS_MEM_STR}/da_wrfvar
			set WORKING_STR   = wrfbdy
			
			csh zz_script/pert_wrfda/pert_wrfda_01_da_wrfvar.csh \
				${DA_START_TIME} 				${ENS_MEM_STR}		${E_WE_D01}						${E_SN_D01} \
				${E_VERT}						${DXDY_D01}			${PERT_WRFDA_PROGRAM_DIR}	${PERT_WRFDA_3DVAR_VERSION} \
				${PERT_WRFDA_MODULE_WRFDA}	${WORKING_DIR}		${WORKING_STR}

			# 2.2.4. Perform WRFDA da_update_bc.exe
			set CURRENT_PATH 	= `pwd`
			set WORKING_DIR 	= ${CURRENT_PATH}/real_pert/wrfbdy/${DA_START_TIME}/mem${ENS_MEM_STR}/da_update_bc
			set WORKING_STR   = da_update_bc		

			csh zz_script/pert_wrfda/pert_wrfda_02_da_update_bc.csh \
				${DA_START_TIME}				${ENS_MEM_STR}		${PERT_WRFDA_PROGRAM_DIR}	${PERT_WRFDA_3DVAR_VERSION} \
				${PERT_WRFDA_MODULE_WRFDA}	${WORKING_DIR}		${WORKING_STR}

			# For next iteration
			set MEMBER_COUNT = `expr ${MEMBER_COUNT} + 1`
		end		
		
		# 2.3. Setting up the next time step 
		set DA_START_TIME 	= `${ADV_TIME_EXE} ${DA_START_TIME} 6`
		set DA_END_TIME 		= `${ADV_TIME_EXE} ${DA_END_TIME} 6`
		
		
	end	# End of "while (${DA_END_TIME} <= ${WPS_END_DATE})"
		
		
echo "------------------------------------------------------------------"
echo "--- End of runme_pert_wrfda.csh ----------------------------------"
echo "------------------------------------------------------------------"


