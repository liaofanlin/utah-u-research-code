#!/bin/csh
#

set START_DATE				= $1


	cp wrf/${START_DATE}/wrfout* fc/${START_DATE}/
	
echo "---------------------------"
echo "---   Done run_fc.csh   ---"
echo "---------------------------"
