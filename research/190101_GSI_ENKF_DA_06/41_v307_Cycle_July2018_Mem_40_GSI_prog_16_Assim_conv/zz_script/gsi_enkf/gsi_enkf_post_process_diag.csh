#!/bin/csh -x
#

set GSI_ENKF_DIAG_READ_PROCESS 	= $1
set DA_START_TIME						= $2
set GSI_ENKF_NANALS 					= $3

set DIAG_SM_STATION_NUM 			= 36	# Station numbers of ISMN
set DIAG_READ_EXE_FILE 				= read_diag_conv.exe

# =============================================
# Process of diag files
# =============================================
	cd gsi_enkf/${DA_START_TIME}/05_post_process_diag

	# Compile the read_diag_conv.exe
	#	- 2018.09.03: The script is based on the following path:
	#	  ~/zpu-group10/coding/fortran/2018/180901_read_diag_conv_gsi_3_6_coding/v01_case01
	cp ../../../zz_script/gsi_enkf/read_diag_conv/* .
	make

	# Link the diag files
	ln -sf ../04_gsidiag/diag_conv_ges.ensmean .
	ln -sf ../04_gsidiag/diag_conv_ges.mem* .
	
	# Link the SM innovation files here
	ln -sf ../03_pre_process/sm_innov_* .

	# Start to re-process diag files
	if (${GSI_ENKF_DIAG_READ_PROCESS} == 'true') then


		# -----------------------------------------------------	
		# Process for diag ensmean file
		
# Create a file for running read_diag_conv.exe
cat >! namelist.conv << EOF
&iosetup
 infilename='diag_conv_ges.ensmean',
 outfilename='diag_conv_ges.ensmean.txt',
 casename='ensmean',
 smstationnum=${DIAG_SM_STATION_NUM}, 
/
EOF
		# Run the read_diag_exe file
		./${DIAG_READ_EXE_FILE}		
		
		
		# -----------------------------------------------------	
		# Process for diag ensemble files
		set ENS_MEM_ITER = 1
	
		while ( ${ENS_MEM_ITER} <= ${GSI_ENKF_NANALS})
		
			# Set up member id string (only for member number < 100)
			if ($ENS_MEM_ITER<10) then
				set ENS_MEM_STR = 00${ENS_MEM_ITER}
			else
				set ENS_MEM_STR = 0${ENS_MEM_ITER}
			endif
		
# Create a file for running read_diag_conv.exe
cat >! namelist.conv << EOF
&iosetup
 infilename='diag_conv_ges.mem${ENS_MEM_STR}',
 outfilename='diag_conv_ges.mem${ENS_MEM_STR}.txt',
 casename='mem${ENS_MEM_STR}',
 smstationnum=${DIAG_SM_STATION_NUM}, 
/
EOF
		
			# Run the read_diag_exe file
			./${DIAG_READ_EXE_FILE}
		
			# Repeat for the next ensemble member
			set ENS_MEM_ITER = `expr ${ENS_MEM_ITER} + 1`
	
		end	
		# -----------------------------------------------------
	else
			
	endif

		
	cd ../../..
	
	
	
#  =============================================
# Link files for enkf
#  =============================================
	cd gsi_enkf/${DA_START_TIME}/06_enkf

	if (${GSI_ENKF_DIAG_READ_PROCESS} == 'true')  then
		
		# Link diag ensmean file
		ln -sf ../05_post_process_diag/diag_conv_ges.ensmean_liaofan.bin diag_conv_ges.ensmean
		
		# -----------------------------------------------------	
		# Link diag ensemble files
		set ENS_MEM_ITER = 1
	
		while ( ${ENS_MEM_ITER} <= ${GSI_ENKF_NANALS})
		
			# Set up member id string (only for member number < 100)
			if ($ENS_MEM_ITER<10) then
				set ENS_MEM_STR = 00${ENS_MEM_ITER}
			else
				set ENS_MEM_STR = 0${ENS_MEM_ITER}
			endif
		
			# Run the read_diag_exe file
			ln -sf ../05_post_process_diag/diag_conv_ges.mem${ENS_MEM_STR}_liaofan.bin diag_conv_ges.mem${ENS_MEM_STR}
		
			# Repeat for the next ensemble member
			set ENS_MEM_ITER = `expr ${ENS_MEM_ITER} + 1`
	
		end	
		# -----------------------------------------------------														 

	else
		
		ln -sf ../04_gsidiag/diag_conv_ges.* .
	endif 
	
	
	cd ../../..
	