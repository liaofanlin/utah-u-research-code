#!/bin/csh -x

	rm -rf matlab_post
	mkdir matlab_post/
	
	csh zz_script/runme_matlab.csh \
	2016063018 				2016073100						/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/12_install \
	180301_51 							72						12 \
	1							2 					8 \
	120			apurimacforce-6					/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/st4 \
	/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/trmm/forWRFDA_v1				TRMM				false \
	false	 		2016080300					true \
	/uufs/chpc.utah.edu/common/home/u6013926/data2/data/smos/ori_cp34-bec/smos_for_DA_v05_20170517				360		WRFDA3.9.1_3dvar_dm_prog02_gen_be_diags \
	zpu-group10/installation/module_12_20170818.txt						true				false \
	IA		false				40 \
	SBATCH_CHPC						12			1 \
	12	zpu		ember \
	12
