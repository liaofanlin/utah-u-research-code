#!/bin/csh -x

# Document: rn180819
#	- Understanding diag_conv_ges Files Based on readconvobs.f90 and read_diag_conv.f90
# Document: rn180903
# 	- Experiment Coding AND Adding My Own diag_conv_ges Files (CHPC 180701 Case 61)


set DIAG_FILE_PATH = ~/zpu-group10/research/2018/180701_GSI_ENKF_DA_02/61_gsi_enkf_v26_myEns_180701_41_GSI_prog06_assim_t_only_edit_diag_files/gsi/gsidiag_arw
#set DIAG_FILE_NAME = diag_conv_ges.ensmean

#set DIAG_FILE_NAME = liaofan_diag_conv_out_binary.bin


# Clean the files
rm namelist.conv
rm read_diag_conv.exe
#rm ${DIAG_FILE_NAME}

# Compile read_diag_conv.f90
# 	- This script is based on the make file at 
#	  ~/zpu-group10/installation/11_install/gsi/comGSIv3.6_EnKFv1.2_prog04_for_understanding_codes/util/Analysis_Utilities/read_diag
make



foreach fileName (diag_conv_ges.ensmean diag_conv_ges.mem001 diag_conv_ges.mem002 diag_conv_ges.mem003 \
						diag_conv_ges.mem004  diag_conv_ges.mem005 diag_conv_ges.mem006 diag_conv_ges.mem007 \
						diag_conv_ges.mem008  diag_conv_ges.mem009 diag_conv_ges.mem010)

	# Link a diagnostic file here
	ln -sf ${DIAG_FILE_PATH}/${fileName} .

# Create a file for running read_diag_conv.exe
cat >! namelist.conv << EOF
&iosetup
 infilename='${fileName}',
 outfilename='${fileName}.txt',
/
EOF

	# Running the read_diag_conv.exe
	./read_diag_conv.exe

end






