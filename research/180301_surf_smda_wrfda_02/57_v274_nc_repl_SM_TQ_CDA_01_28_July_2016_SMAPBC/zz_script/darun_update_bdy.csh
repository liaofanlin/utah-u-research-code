#!/bin/csh
#

echo "-------------------------------------------------------------------------"
echo "--- Running the darun_update_bdy.csh (sub of runme_darun.csh) -----------"
echo "-------------------------------------------------------------------------"



set PROGRAM_DIR				= $1
set DA_START_DATE			= $2
set WRF_3DVAR_EXE_VERSION	= $3

cd update_bdy

ln -sf ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_update_bc.exe .
ln -sf ../prda/wrfvar_output .
ln -sf ../../../real/${DA_START_DATE}/wrfinput_d01 .
ln -sf ../../../real/${DA_START_DATE}/wrfbdy_d01 wrfbdy_ori
cp wrfbdy_ori wrfbdy_d01

cat >! parame.in << EOF
 &control_param
 wrfvar_output_file = './wrfvar_output'
 wrf_bdy_file       = './wrfbdy_d01'
 wrf_input          = './wrfinput_d01'
 domain_id          = 1
 debug   			= .true.
 update_lateral_bdy = .true.
 update_low_bdy 	= .false.            
 update_lsm         = .false. 
 iswater            = 16
/
EOF

./da_update_bc.exe

cd ..

echo "-------------------------------------------------------------------------"
echo "--- Finishing the darun_update_bdy.csh (sub of runme_darun.csh) ---------"
echo "-------------------------------------------------------------------------"
