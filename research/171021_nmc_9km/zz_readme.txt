==========================================
CASE DOCUMENT (2019.02.13)
==========================================

CASE	| Research Note	| Title
------------------------------------------------------
10,11	| 190212				| Preliminary Results for the Manuscript
15
------------------------------------------------------


==========
OTHER NOTE
==========

2018.02.19
The summary of the NMC_SMATM experiments can be found at 
	- rn171106: Summary of the Technical Process for NMC_SMATM 

2018.09.17
Total Space = 7.5T

2018.09.17

EXP	| Period		| FNL Data	| FREQ	| SIZE	|  Status						| Document	
------------------------------------------------------------------------------------	
10		| 07/2016	| 0.25		| 06h		| 2.900T	| OPL DONE/MATLAB DONE		| rn171111-171116
11		| 07/2017	| 0.25		| 06h		| 0.971T	| OPL DONE/MATLAB DONE		| rn171111-171116
12		| 07/2013	| 1			| 06h		| 0.805T	| OPL DONE/MATLAB DONE		| 
13		| 08/2016	| 0.25		| 06h		| 0.970T	| OPL DONE/MATLAB RUNNING	|

15		| 07/2015	| 1			| 06h 	| 0.829T	| OPL DONE/MATLAB DONE		| rn171111-171116
16		| 08/2015	| 1			| 06h		| 0.829T	| OPL DONE/MATLAB DONE		| rn171110 


31		| 01/2017	| 0.25		| 12h		| 0.529T	| OPL DONE/MATLAB RUNNING
32		| 02/2017	| 0.25		| 12h		| 0.506T	| OPL DONE/MATLAB RUNNING			
33		| 03/2017	| 0.25		| 12h		| 0.536T	| OPL DONE/MATLAB RUNNING
34		| 04/2017	| 0.25		| 12h		| 0.529T	| OPL DONE/MATLAB RUNNING
35		| 05/2017	| 0.25		| 12h		| 0.536T	| OPL DONE/MATLAB RUNNING
36		| 06/2017	| 0.25		| 12h		| 0.529T	| OPL DONE/MATLAB RUNNING
37		| 07/2017	| 0.25		| 12h		| 0.536T	| OPL DONE/MATLAB RUNNING
38		| 08/2017	| 0.25		| 12h		| 0.537T	| OPL DONE/MATLAB RUNNING
39		| 09/2017	| 0.25		| 06h		| 0.682T	| OPL DONE/MATLAB RUNNING	|
40		| 10/2017	| 0.25		| 12h		| 0.535T	| OPL DONE/MATLAB RUNNING
41		| 11/2017	| 0.25		| 12h		| 0.529T	| (51/58) zpu-kp
42		| 12/2017	| 0.25		| 12h		| 0.531T	| (53/58) zpu-kp

51		| 01/2016	| 0.25		| 12h		| 0.563T	| OPL DONE/MATLAB RUNNING	|
52		| 02/2016	| 0.25		| 12h		| 0.485T	| OPL DONE/MATLAB RUNNING	|
53		| 03/2016	| 0.25		| 12h		| 0.509T	| OPL DONE/MATLAB RUNNING	|
54		| 04/2016	| 0.25		| 12h		| 0.502T	| OPL DONE/MATLAB RUNNING	|
55		| 05/2016	| 0.25		| 12h		| 0.622T	| OPL DONE/MATLAB RUNNING	| nt20171109
56		| 06/2016	| 0.25		| 12h		| 0.529T	| OPL DONE/MATLAB RUNNING	|
59		| 09/2016	| 0.25		| 12h		| 0.525T	| OPL DONE/MATLAB RUNNING	| nt20171108	
60		| 10/2016	| 0.25		| 12h		| 0.536T	| OPL DONE/MATLAB RUNNING	|
61		| 11/2016	| 0.25		| 12h		| 0.529T	| OPL DONE/MATLAB RUNNING	|
62		| 12/2016	| 0.25		| 12h		| 0.614T	| OPL DONE/MATLAB RUNNING	|


71		| 01/2015	| 1			| 12h		| 0.363T	| OPL DONE/MATLAB DONE
72		| 02/2015	| 1 			| 12h		| 0.344T	| OPL DONE/MATLAB DONE
73		| 03/2015	| 1 			| 12h 	| 0.363T	| OPL DONE/MATLAB DONE
74		| 04/2015	| 1			| 12h		| 0.361T	| OPL DONE/MATLAB DONE
75		| 05/2015	| 1 			| 12h		| 0.363T	| OPL DONE/MATLAB DONE
76		| 06/2015	| 1			| 12h		| 0.361T	| OPL DONE/MATLAB DONE
78		| 08/2015	| 0.25		| 12h		| 0.502T	| OPL DONE/MATLAB DONE
79		| 09/2015	| 0.25		| 12h		| 0.502T	| OPL DONE/MATLAB DONE
80		| 10/2015	| 0.25		| 12h		| 0.509T	| OPL DONE/MATLAB DONE
81		| 11/2015	| 0.25		| 12h		| 0.502T	| OPL DONE/MATLAB DONE
82		| 12/2015	| 0.25 		| 12h		| 0.502T	| OPL DONE/MATLAB DONE



91		| 08/2015	| 0.25		| 06h		| 0.972T	| OPL DONE/MATLAB DONE		| rn171110
	

NOTE:
==========
nt20171108
	- The FNL 0.25 degree data has issues on 09/27 18 UTC, 09/28 06&12UTC, 2016.  
	- In WPS, I reproduce the required data using FNL 1-dgree data
	- Then, in REAL, I re-run real.exe for dates
		* 2017092700, 2017092712
		* 2017092800, 2017092812
		* 2017092900, 2017092912 

nt20171109
	- The FNL data (for both 1- and 0.25-degree) change the vertical levels from 27 to 32 on 2016.05.11 12UTC.
	- Thus, forecasts initilized at 2017051012 and 2017051100 are affected, leading to missing forecasts.



