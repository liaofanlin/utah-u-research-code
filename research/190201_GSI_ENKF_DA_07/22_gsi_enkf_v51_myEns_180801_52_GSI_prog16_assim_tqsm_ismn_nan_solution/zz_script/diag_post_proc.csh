#!/bin/csh -x
#

set DIAG_READ_PROCESS 	= $1
set DIAG_READ_EXE_FILE 	= read_diag_conv.exe
set DIAG_SM_STATION_NUM = 77





# =============================================
# Process of diag files
# =============================================
cd gsi/diag_post_proc


# Compile the read_diag_conv.exe
#	- 2018.09.03: The script is based on the following path:
#	  ~/zpu-group10/coding/fortran/2018/180901_read_diag_conv_gsi_3_6_coding/v01_case01
cp ../../zz_script/read_diag_conv/* .
make

# Link the diag files
ln -sf ../gsidiag_arw/diag_conv_ges.ensmean .
ln -sf ../gsidiag_arw/diag_conv_ges.mem0*   .

if (${DIAG_READ_PROCESS} == 'true')  then

	foreach CaseName(ensmean mem001 mem002 mem003 mem004 mem005 \
						          mem006 mem007 mem008 mem009 mem010)
	
# Create a file for running read_diag_conv.exe
# 	see rn190228
cat >! namelist.conv << EOF
&iosetup
 infilename='diag_conv_ges.${CaseName}',
 outfilename='diag_conv_ges.${CaseName}.txt',
 casename=${CaseName},
 smstationnum=${DIAG_SM_STATION_NUM},
/
EOF

	# Run the read_diag_exe file
	./read_diag_conv.exe

	end
		
else

endif 

cd ../..



#  =============================================
# Link files for enkf
#  =============================================
cd gsi/enkf_arw

if (${DIAG_READ_PROCESS} == 'true')  then
	foreach FileName(ensmean mem001 mem002 mem003 mem004 mem005 \
						          mem006 mem007 mem008 mem009 mem010)
		ln -sf ../diag_post_proc/diag_conv_ges.${FileName}_liaofan.bin diag_conv_ges.${FileName}
	end									 
	
else
	foreach FileName(ensmean mem001 mem002 mem003 mem004 mem005 \
						          mem006 mem007 mem008 mem009 mem010)
		ln -sf ../gsidiag_arw/diag_conv_ges.${FileName} diag_conv_ges.${FileName}
	end	
endif 

cd ../..