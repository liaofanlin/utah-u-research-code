#!/bin/csh

# Note (2019.04.03): This is added.  So that I can start the cycling run
# from a middle time.  If $CYCLE_COUNT=0, it means that the run starts
# at the earliest time.  If $CYCLE_COUNT=1, it means the run starts at 
# a middle time.
set CYCLE_COUNT = 0



### Only used for a slurm script
### #SBATCH --time=32:00:00
### #SBATCH --nodes=4
### #SBATCH --ntasks=128
### #SBATCH --account=zpu
### #SBATCH --partition=zpu-np
### #SBATCH -o slurm-%j.out-%N
### #SBATCH -e slurm-%j.err-%N
### #SBATCH -J ENKF
### #SBATCH -C c32

source ~/zpu-group10/installation/module_11_20170816.txt

cd /uufs/chpc.utah.edu/common/home/zpu-group14/lin/research/2019/190101_GSI_ENKF_DA_06/41_v307_Cycle_July2018_Mem_40_GSI_prog_16_Assim_conv

# Only remove the entire directory if $CYCLE_COUNT == 0
if ( ${CYCLE_COUNT} == 0 ) then
	rm -rf gsi_enkf
	mkdir gsi_enkf
endif

	csh ./zz_script/gsi_enkf/runme_gsi_enkf_cycling.csh \
		/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/11_install						WRFDA3.9_3dvar_dm		2018070100				2018072900 \
		true	120					150				40 \
		WRF3.9_dm_prog02_20181004				10		true	48 \
		2				64			zpu-np		zpu-np \
		zpu-group10/installation/module_11_20170816.txt						40				${CYCLE_COUNT}

exit 0
