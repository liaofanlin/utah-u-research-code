#!/bin/csh -x

# Document: rn180819
#	- Understanding diag_conv_ges Files Based on readconvobs.f90 and read_diag_conv.f90
# Document: rn180903
# 	- Experiment Coding AND Adding My Own diag_conv_ges Files (CHPC 180701 Case 61)


set DIAG_FILE_PATH = ~/zpu-group10/research/2018/180701_GSI_ENKF_DA_02/45_gsi_enkf_v20_myEns_180701_41_GSI_prog04_Exploring_sub_get_num_convobs/gsi/gsidiag_arw
set DIAG_FILE_NAME = diag_conv_ges.ensmean

#set DIAG_FILE_NAME = liaofan_diag_conv_out_binary.bin


# Clean the files
rm namelist.conv
rm read_diag_conv.exe
rm ${DIAG_FILE_NAME}

# Compile read_diag_conv.f90
# 	- This script is based on the make file at 
#	  ~/zpu-group10/installation/11_install/gsi/comGSIv3.6_EnKFv1.2_prog04_for_understanding_codes/util/Analysis_Utilities/read_diag
make

# Link a diagnostic file here
ln -sf ${DIAG_FILE_PATH}/${DIAG_FILE_NAME} .

# Create a file for running read_diag_conv.exe
cat >! namelist.conv << EOF
&iosetup
 infilename='${DIAG_FILE_NAME}',
 outfilename='${DIAG_FILE_NAME}.txt',
/
EOF

# Running the read_diag_conv.exe
./read_diag_conv.exe







