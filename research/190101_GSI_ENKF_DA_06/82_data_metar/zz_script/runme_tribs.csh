#!/bin/csh -x
#

set echo

set TRIBS_EXE_VERSION		= $1
set TRIBS_EXE_PATH			= $2
set TRIBS_STATIC_FILE_PATH	= $3
set HYDRO_KHOUR				= $4
set WPS_START_DATE			= $5 

set WORKPATH               = `pwd`


# =================================================================
# MISC process
# ============
	rm -rf hydro/04_tribs
	mkdir hydro/04_tribs
	mkdir hydro/04_tribs/PointFiles
	mkdir hydro/04_tribs/Soil
	mkdir hydro/04_tribs/Landuse
	mkdir hydro/04_tribs/InputFiles
	mkdir hydro/04_tribs/Weather
	mkdir hydro/04_tribs/Rain
	mkdir hydro/04_tribs/Output
	mkdir hydro/04_tribs/Output/hyd
	mkdir hydro/04_tribs/Output/voronoi
	

	# Process of date
		set yyyy1 = `echo $WPS_START_DATE | cut -c1-4`
		set   mm1 = `echo $WPS_START_DATE | cut -c5-6`
		set   dd1 = `echo $WPS_START_DATE | cut -c7-8`
		set   hh1 = `echo $WPS_START_DATE | cut -c9-10`

# =================================================================
# Links for tRIBS
# ===============	
	cd hydro/04_tribs
	
	ln -sf ${TRIBS_STATIC_FILE_PATH}/PointFiles/turkey.points 							./PointFiles/
	ln -sf ${TRIBS_STATIC_FILE_PATH}/Soil/turkey_soil.sdtt 								./Soil/
	ln -sf ${TRIBS_STATIC_FILE_PATH}/Soil/turkey_soil.soi 								./Soil/
	ln -sf ${TRIBS_STATIC_FILE_PATH}/Landuse/turkey_LandUse.ldtt						./Landuse/
	ln -sf ${TRIBS_STATIC_FILE_PATH}/Landuse/turkey_LandUse.lan							./Landuse/
	ln -sf ${TRIBS_STATIC_FILE_PATH}/InputFiles/turkey_GW.iwt							./InputFiles/
	ln -sf ${TRIBS_STATIC_FILE_PATH}/InputFiles/turkey_VegRough.vgr					./InputFiles/
	ln -sf ${TRIBS_STATIC_FILE_PATH}/InputFiles/turkey_SoilRough.slr					./InputFiles/
	
	ln -sf ${TRIBS_STATIC_FILE_PATH}/Weather/Weather.mdf									./Weather/
	ln -sf ${TRIBS_STATIC_FILE_PATH}/Weather/Weather.sdf									./Weather/
	
#	ln -sf ${TRIBS_STATIC_FILE_PATH}/Rain/Rainsingle.sdf									./Rain/
	ln -sf ${TRIBS_STATIC_FILE_PATH}/Rain/Rain1.mdf											./Rain/
	ln -sf ${WORKPATH}/matlab_post/process/tribs/text_tribs_input/Rain_turkey.mdf	./Rain/
	
	ln -sf ${TRIBS_EXE_PATH}/${TRIBS_EXE_VERSION} .

# =================================================================	
# Creation of Rain/Rainsingle.sdf file
# ====================================	
	# RefLat=4756000 & RefLon=600663 is approximately the center of the Turkey basin
	# I used the website http://home.hiwaay.net/~taylorc/toolbox/geography/geoutm.html
	# and provide lon=-91.766, lat=42.95, and zone 15N and then get the RefLat and RefLon.

# ID, File Path , RefLat, RefLon, Simulation legth, No. of columns in the *.mdf file
cat >! Rainsingle.sdf << EOF
1	6				
1	Rain/Rain_turkey.mdf	4756000	600663	${HYDRO_KHOUR}	5
EOF
	
# =================================================================
# Creation of *.in file
# =====================
cat >! turkey.in << EOF

##############################################################################
##
##
##                    tRIBS Distributed Hydrologic Model
##              TIN-based Real-time Integrated Basin Simulator
##                       Ralph M. Parsons Laboratory
##                  Massachusetts Institute of Technology
##  
##
##	              Input File for tRIBS simulations
##
##############################################################################


##=========================================================================
##
##
##			Section 1: Model Run Parameters
##
##
##=========================================================================

## Time Variables 
## --------------

STARTINGDATETIME: Starting time 			 (#MM/DD/YYYY/HH#)
${mm1}/${dd1}/${yyyy1}/00

RUNTIME:     	Run duration 				 (#hours#)
${HYDRO_KHOUR}

TIMESTEP:    	Unsaturated zone computational time step (#mins#)
3.75

GWSTEP:      	Saturated zone computational time step 	 (#mins#)
30.0

METSTEP:     	Meteorological data time step 		 (#mins#)
60

RAININTRVL:  	Time interval in rainfall input 	 (#hours#)
1

OPINTRVL:    	Output interval 			 (#hours#)
1.0

SPOPINTRVL:   	Spatial output interval 		 (#hours#)
1

INTSTORMMAX: 	Interstorm interval 			 (#hours#)
100


## Routing Variables
## -----------------

BASEFLOW:    	Pre-storm baseflow to initialize veloc.  (#m3/s#)  
0.01

VELOCITYCOEF: 	Discharge-velocity coefficient 		 (#m/s#)
1.2

VELOCITYRATIO: 	Stream to hillslope velocity coefficient (#D/L#)
60

KINEMVELCOEF:   Coefficient in power law for non-linear routing
3

FLOWEXP: 	Nonlinear discharge coefficient		 (#D/L#)
0.3

CHANNELROUGHNESS: Uniform channel roughness value        (#D/L#)
0.15

CHANNELWIDTH:     Uniform channel width                  (# m #)
12

CHANNELWIDTHCOEFF:	Coefficient in width-area relationship 
2.33

CHANNELWIDTHEXPNT:	Exponent in width-area relationship 
0.5422

CHANNELWIDTHFILE:	Filename that contains channel widths


##=========================================================================
##
##
##			Section 2: Model Run Options
##
##
##  OPTREADINPUT:	1  tMesh data		5  Arc/Info *.net
##			2  Point file		6  Arc/Info *.lin,*.pnt
##			3  ArcGrid (random)	7  Scratch
##			4  ArcGrid (hex)	8  Point file using Tipper
##
##  RAINSOURCE:		1  Stage III radar
##			2  WSI radar
##                      3  Rain gauges
##
##  OPTEVAPOTRANS:	0  Inactive evapotranspiration
##			1  Penman-Monteith method
##                      2  Deardorff method
##  			3  Priestley-Taylor method
##                      4  Pan evaporation measurements
##
##  OPTINTERCEPT:	0  Inactive interception 
## 			1  Canopy storage method
##			2  Canopy water balance method
##  
##  GFLUXOPTION:	0  No ground heat flux computation
##			1  Temperature gradient method
##			2  Force restore method
##
##  OPTRUNON:		0  No runon is simulated
##			1  Simplified runon scheme is used
##
##  METDATAOPTION:	0  Inactive meteorological data
##			1  Weather station point data
##			2  Gridded meteorological data
##
##  CONVERTDATA:	0  Inactive met data preprocessing
##			1  Active met data preprocessing
##
##  OPTGWFILE:          0  Grid of water table depth is assumed as input
##	                1  File with water table depths for Voronoi cells
##
##  OPTVEGROUGH:        0  Grid of vegetation roughness is assumed as input
##	                1  File with veget. rough. table for Voronoi cells
##  
##  OPTSOILROUGH:       0  Grid of soil roughness is assumed as input
##	                1  File with soil rough. table for Voronoi cells
##
##
##  OPTBEDROCK:         0  A uniform value used (DEPTHTOBEDROCK)
##	                1  Input grid file of bedrock depth is expected 
##
##  WIDTHINTERPOLATION: 0  Interpolate between measured and observed
##	                1  Interpolate only between measured
##
##  OPTEROSION:         0  No Erosion
##	                1  Splash EROSION
##			2  Diffusive EROSION
##
##=========================================================================

OPTMESHINPUT:   Mesh input data option
8

INPUTTIME:      Time slice which is searched by tListInputData
0

RAINSOURCE: Rainfall data source option
3

OPTEVAPOTRANS: 	Option for evapoTranspiration scheme
4

OPTINTERCEPT: 	Option for interception scheme
2

GFLUXOPTION: 	Option for ground heat flux
2

OPTRUNON:	Option of runon mechanism
0  

METDATAOPTION:  Option for meteorological data
1

CONVERTDATA:   	Option to convert met data format
0

OPTGWFILE:	Option for groundwater initialization
0

OPTVEGROUGH:    Option to read vegetation roughness
0

OPTSOILROUGH:	Option to read soil roughness
0

OPTBEDROCK:     Option to read bedrock depth
0

WIDTHINTERPOLATION:  Option for interpolating width values
0

OPTEROSION:  Option for erosion
0
##=========================================================================
##
##
##			Section 3: Model Input Files and Pathnames
##
##
##=========================================================================

## Mesh Generation
## -----------------

INPUTDATAFILE:    tMesh input file base name *.nodes, *.edges, *.tri: Opt 1
Input/Pointfiles/

POINTFILENAME:    tMesh input file base name *.points: Opt 2, 8 turnetx.points
PointFiles/turkey.points

ARCINFOFILENAME:  tMesh input file base name *.net, *.lin, *.pnt: Opt 5, 6
Input/PointFiles/tur5net

## Soil Variables
## -----------------

DEPTHTOBEDROCK:   Uniform depth to bedrock 		 (#m#)
15

## Resampling Grids
## -----------------

BEDROCKFILE
Input_turkey/

SOILTABLENAME:    Soil parameter reference table (*.sdtt)
Soil/turkey_soil.sdtt

SOILMAPNAME:      Soil texture ASCII grid (*.soi)
Soil/turkey_soil.soi

ERODIBILITY:      Soil texture ASCII grid (*.soi)
Input_mameyes/Soil/mam_Soil_erod.soi

SHEARSTRESS:      Soil texture ASCII grid (*.soi)
Input_mameyes/Soil/mam_Soil_shear.soi

FACTOR:  reduces teh shear stress when FS<1 
1.0

LANDTABLENAME:    Land use parameter reference table (*.ldtt)
Landuse/turkey_LandUse.ldtt

LANDMAPNAME:  	  Land use ASCII grid (*.lan)
Landuse/turkey_LandUse.lan

VEGTABLENAME:     File containing vegetation parameter info


VEGINITFILENAME:  File containing vegetation parameter info


GWATERFILE:       Ground water ASCII grid (*.iwt) 
InputFiles/turkey_GW.iwt

VEGROUGHFILE
InputFiles/turkey_VegRough.vgr

SOILROUGHFILE
InputFiles/turkey_SoilRough.slr

RAINFILE:         Base name of the radar ASCII grid
./Rain/Fall1996/p

RAINEXTENSION:    Extension for the radar ASCII grid 
txt


## Meteorological Data
## ------------------

HYDROMETSTATIONS:  Hydrometeorological station file (*.sdf)
Weather/Weather.sdf

HYDROMETGRID:  	   Hydrometeorological ASCII grid (*.gdf)
Weather/

HYDROMETCONVERT:   Hydrometeorological data input file (*.mdi)
Weather/

HYDROMETBASENAME:  Hydrometeorological data file (*.mdf)
Weather/Weather.mdf

GAUGESTATIONS: 	   Rain Gauge station file (*.sdf)
Rain/Rainsingle.sdf

TLINKE:		   Linke turbidity factor (par-r of shortwave radiation model)
2.5

## Output Data
## -----------

OUTFILENAME:	   Base name of the tMesh and dynamic variable output
Output/voronoi/synth

OUTHYDROFILENAME:  Base name for hydrograph output
Output/hyd/synth

OUTHYDROEXTENSION: Extension for hydrograph output
mrf

RIBSHYDOUTPUT:
0

NODEOUTPUTLIST
Input/Nodes/pNodes.dat

HYDRONODELIST
Input/Nodes/hNodes.dat

OUTLETNODELIST
Input/Nodes/oNodes.dat

##=========================================================================
##
##
##			Section 4: Model Climate Forcing Modes 
##
##
##  STOCHASTICMODE:	0  No Stochastic Mode	 4  Mean+Sine Forcing
##                      1  Mean Forcing     	 5  Random+Sine Forcing
##                      2  Random Forcing        6  Random Seasonal Forcing
##                      3  Sinusoidal Forcing
##                      
##=========================================================================

## Stochastic Climate Forcing
## --------------------------

STOCHASTICMODE:	   Stochastic Climate Mode Option
0

PMEAN:		   Mean rainfall intensity (mm/hr)	
0.0

STDUR:		   Mean storm duration (hours)
5.285446

ISTDUR:		   Mean time interval between storms (hours) 
93.334584

SEED:		   Random seed
11

PERIOD:		   Period of variation (hours) 
0

MAXPMEAN:	   Maximum value of mean rainfall intensity (mm/hr) 
0

MAXSTDURMN:        Maximum value of mean storm duration (hours) 
0

MAXISTDURMN: 	   Maximum value of mean interstorm period (hours) 
0

WEATHERTABLENAME:  File with input parameters for weather generator
Input/

##=========================================================================
##
##
##			Section 5: Model Rainfall Modes
##
##
##  FORECASTMODE:	0  No Forecasting		
##			1  Single or Updating QPF Forecast
##			2  Persistence Forecast
## 	                3  Climatological Forecast
##
##
##  RAINDISTRIBUTION:	0  Spatially-distributed Radar
##			1  Mean Areal Precipitation Radar
##
##=========================================================================

## Rainfall Forecasting
## --------------------

FORECASTMODE:	  Rainfall Forecasting Mode Option
0

FORECASTTIME:	  Single Forecast Time (hours from start)
0

FORECASTLEADTIME:  Forecast Lead Time (hour interval) 
0

FORECASTLENGTH:	   Forecast Window Length (hours)
0

FORECASTFILE:	   Base name of the radar QPF grids
Rain/

CLIMATOLOGY:	   Rainfall climatology (mm/hr)
0

RAINDISTRIBUTION:  Distributed or MAP radar rainfall	
0

##=========================================================================
##
##
##			Section 6: Parallel Computing 
##
##
##  PARALLELMODE:	0  Run in serial mode
##			1  Run in parallel mode
##
##
##  GRAPHFILEOPTION:	0  Default partitioning of the graph
##			1  Reach-based
##			2  Inlet/outlet-based
##
##  GRAPHFILE:		Reach connectivity file (parallel only)
##
##=========================================================================

## Parallel Processing
##--------------------

PARALLELMODE:
0

GRAPHFILEOPTION:
0

GRAPHFILE:        Reach connectivity file (parallel ONLY)
Input/

## Viewers
## -----------

TRIBS_DISP_HYDRO:  Hydrograph run-time viewer (disabled)

##=========================================================================
##
##
##			End of Template.in
##
##
##=========================================================================

EOF
	
	
	
	
cd ../..
	
	
	
	
	

