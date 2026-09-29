	rm -rf real_pert
	mkdir real_pert
	
	csh ./zz_script/pert_wrfda/runme_pert_wrfda.csh \
		121			151			41				9000 \
		2018070100	2018072900	WRF3.9_dm_prog02_20181004
