
	rm -rf openloop
	mkdir  openloop

	csh ./zz_script/runme_openloop_cycling.csh \
	2016063018 			2016073100  					48 							/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/12_install	\
	apurimacforce-6					72					64							32 \
	120				180301_51							12				1 \
	WRF3.9.1_dm			WRFDA3.9.1_3dvar_dm_prog02_gen_be_diags		zpu-group10/installation/module_12_20170818.txt						false \
	602						392							4							/uufs/chpc.utah.edu/common/home/u6013926/data2/coding/fortran/2017/170401_nc_repl_v02_data2_module_04 \
	SBATCH_CHPC					48				2				48 \
	owner-guest		kingspeak-guest		48				12 \
	1	12	zpu	ember \
	12	true
