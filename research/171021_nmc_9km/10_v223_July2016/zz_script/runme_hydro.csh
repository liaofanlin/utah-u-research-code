#!/bin/csh -x
#

set echo

set PROGRAM_DIR					= $1
set MODULE_FILE					= $2
set HYDRO_EXE_VERSION			= $3
set WRF_3DVAR_EXE_VERSION		= $4

set WPS_START_DATE				= $5
set HYDRO_DOMAIN				= $6
set HYDRO_AGGFACTRT				= $7
set HYDRO_DTRT					= $8

set HYDRO_FORC_TYP				= $9
set HYDRO_KHOUR					= $10
set HYDRO_SUBRTSWCRT			= $11
set HYDRO_OVRTSWCRT				= $12

set HYDRO_CHANRTSWCRT			= $13
set HYDRO_GWBASESWCRT			= $14
set HYDRO_RT_OPTION				= $15
set HYDRO_CHANNEL_OPTION		= $16

set HYDRO_BASN_MSK_FILE			= $17
set HYDRO_SW_FORCING_SOURCE		= $18

set ADV_TIME_EXE 					= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

# ===========================================================================================
# MISC process
# ============
	# Load modules
		source ~/${MODULE_FILE}

	# Process of date
		set yyyy1 = `echo $WPS_START_DATE | cut -c1-4`
		set   mm1 = `echo $WPS_START_DATE | cut -c5-6`
		set   dd1 = `echo $WPS_START_DATE | cut -c7-8`
		set   hh1 = `echo $WPS_START_DATE | cut -c9-10`

# ===========================================================================================
# Links for Hydro
# ===============
	rm -rf hydro/03_wrfhydro
	mkdir hydro/03_wrfhydro
	mkdir hydro/03_wrfhydro/domain
	mkdir hydro/03_wrfhydro/forcing
	mkdir hydro/03_wrfhydro/z_wrfhydro_output
	
	
	cd hydro/03_wrfhydro
	
	# Note: I have to manually handle the files in 01_terrestrial_dir first
	cd domain
		ln -sf ../../01_terrestrial_dir/Fulldom_hires_netcdf_file.nc .
		ln -sf -sf ../../01_terrestrial_dir/gw_basns_geogrid.txt .
	cd ..
	
	# Link the files of geo_em and wrfinput	
		cd domain
			ln -sf ../../../wps/geo_em.d0${HYDRO_DOMAIN}.nc .
			ln -sf ../../../real/${WPS_START_DATE}/wrfinput_d0${HYDRO_DOMAIN} .
		cd ..
		
	# Link forcing data
	if ( ${HYDRO_SW_FORCING_SOURCE} == 1 ) then
		# Link wrfout but the rainfall is replaced with NCEP Stage IV precipitation
		cd forcing
			ln -sf ../../../matlab_post/${WPS_START_DATE}/process/wrfout/d03/wrfout_d0* .
		cd ..
	else if ( ${HYDRO_SW_FORCING_SOURCE} == 2 ) then
	
	else
		echo Error
	endif
		
	# Links for executable!
	ln -sf ${PROGRAM_DIR}/wrf_hydro/${HYDRO_EXE_VERSION}/Run/wrf_hydro.exe .

# ===========================================================================================
# Links and Creation of TBL files
# ===============================	
	# Link TBL for GENPARM, LANDUSE, MPTABLE, SOILPARM, URBPARM, URBPARM_UZE, VEGPARM
	ln -sf ${PROGRAM_DIR}/wrf/WRF3.6.1_dm/run/*.TBL .
	
	# Link TBL for CHANPARM, DISTR_HYDRO_CAL, HYDRO, LAKEPARM
	# 	- I do not use LAKEPARM
#	ln -sf ${PROGRAM_DIR}/wrf_hydro/WRF_Hydro_v01/Run/CHANPARM.TBL .
#	ln -sf ${PROGRAM_DIR}/wrf_hydro/WRF_Hydro_v01/Run/DISTR_HYDRO_CAL_PARMS.TBL .
	ln -sf ${PROGRAM_DIR}/wrf_hydro/${HYDRO_EXE_VERSION}/Run/HYDRO.TBL .
	ln -sf /nv/hp19/llin35/data/apurimac_02/wrf_hydro/WRF_Hydro_v01/Run/LAKEPARM.TBL .

	# Create GWBUCKPARM.TBL (I may not use it)
	# ---------------------
cat >! GWBUCKPARM.TBL << EOF
Basin,Coeff.,Expon.,Zmax,Zinit
  1,0.0400, 2.000, 0.125, 0.0765
  2,0.0400, 2.000, 0.125, 0.0765
  3,0.0400, 2.000, 0.125, 0.0765
  4,0.0400, 2.000, 0.125, 0.0765
  5,0.0400, 2.000, 0.125, 0.0765

EOF

	# Creation of CHANPARM.TBL
	# ---------------------------
cat >! CHANPARM.TBL << EOF
Channel Parameters
StreamOrder
10,1,  'Bw     HLINK   ChSSlp   MannN'
1,     1.5,    0.02,    3.0,      0.55
2,     3.0,    0.02,    1.0,      0.35
3,     5.0,    0.02,    0.5,      0.15
4,     10.,    0.03,   0.18,      0.10
5,     20.,    0.03,   0.05,      0.07
6,     40.,    0.03,   0.05,      0.05
7,     60.,    0.03,   0.05,      0.04
8,     70.,    0.10,   0.05,      0.03
9,     80.,    0.30,   0.05,      0.02
10,    100.,    0.30,   0.05,      0.01
EOF

# ===========================================================================================
# Creation of hydro.namelist
# ==========================	
cat >! hydro.namelist << EOF
&HYDRO_nlist

!!!! SYSTEM COUPLING !!!!
!Specify what is being coupled:  1=HRLDAS (offline Noah-LSM), 2=WRF, 3=NASA/LIS, 4=CLM
 sys_cpl = 1

!!!! MODEL INPUT DATA FILES !!!
!Specify land surface model gridded input data file...(e.g.: "geo_em.d03.nc")
 GEO_STATIC_FLNM = "domain/geo_em.d0${HYDRO_DOMAIN}.nc"

!Specify the high-resolution routing terrain input data file...(e.g.: "Fulldom_hires_hydrofile.nc"
 GEO_FINEGRID_FLNM = "domain/Fulldom_hires_netcdf_file.nc"

!Specify the name of the restart file if starting from restart...comment out with '!' if not...
! RESTART_FILE  = 'HYDRO_RST.2013-09-11_06:00_DOMAIN3'

!!!! MODEL SETUP AND I/O CONTROL !!!!
!Specify the domain or nest number identifier...(integer)
 IGRID = ${HYDRO_DOMAIN}

!Specify the restart file write frequency...(minutes)
 !rst_dt = 360   
 rst_dt = 60   

!Specify the output file write frequency...(minutes)
 out_dt = 60 ! minutes

!Specify the number of output times to be contained within each output history file...(integer)
!   SET = 1 WHEN RUNNING CHANNEL ROUTING ONLY/CALIBRATION SIMS!!!
!   SET = 1 WHEN RUNNING COUPLED TO WRF!!!
 SPLIT_OUTPUT_COUNT = 1

! rst_typ = 1 : overwrite the soil variables from routing restart file.
 rst_typ = 0

!Restart switch to set restart accumulation variables = 0 (0-no reset, 1-yes reset to 0.0)
 RSTRT_SWC = 0

!Specify the minimum stream order to output to netcdf point file...(integer)
!Note: lower value of stream order produces more output.
 order_to_write = 1

!Switches to specify if routing restart files are to be read in/output in a flat binary format
!(=0 no, 1-yes read/write in binary format)
 rst_bi_in = 0 ! read restart in binary format
 rst_bi_out = 0 ! output restart in binary format

!Routing output netcdf file control...(=0 no files written, =1 files are written)
 CHRTOUT_DOMAIN = 1 ! Netcdf point timeseries output at all channel points
 CHRTOUT_GRID = 1 ! Netcdf grid of channel streamflow values
 LSMOUT_DOMAN = 1 ! Netcdf grid of variables passed between LSM and routing components
 RTOUT_DOMAIN = 1 ! Netcdf grid of terrain routing variables on routing grid
 output_gw = 1 ! Netcdf grid of groundwater-baseflow bucket information
 outlake = 0 ! Netcdf point timeseries output of lake information



!!!!!!! THE FOLLOWING DO NOT EXIST IN WRF-HYDRO V.3.0 !!!!!!
!Specify if output history files are to be written...(.TRUE. or .FALSE.)
! HISTORY_OUTPUT = .TRUE.
!
!Output high-resolution routing files...0=none, 1=total chan_inflow ASCII time-series, 2=hires grid and chan_inflow...
! HIRES_OUT = 2
!
!Specify the number of soil layers (integer) and the depth of the bottom of each layer (meters)...
! Notes: In Version 1 of WRF-Hydro these must be the same as in the namelist.input file
!       Future versions will permit this to be different.
! NSOIL=4
! ZSOIL8(1) = -0.10
! ZSOIL8(2) = -0.40
! ZSOIL8(3) = -1.0 
! ZSOIL8(4) = -2.0 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


!!!! PHYSICS OPTIONS AND RELATED SETTINGS !!!!
!Switch for terrain adjustment of incoming solar radiation: 0=no, 1=yes
!Note: This option is not yet active in Verion 1.0...
!      WRF has this capability so be careful not to double apply the correction!!!
 TERADJ_SOLAR = 0


!Specify the grid spacing of the terrain routing grid...(meters)
 DXRT = 100

!Specify the integer multiple between the land model grid and the terrain routing grid...(integer)
 AGGFACTRT = ${HYDRO_AGGFACTRT}

!Specify the routing model timestep...(seconds)
 DTRT = ${HYDRO_DTRT}

!Switch activate subsurface routing...(0=no, 1=yes)
 SUBRTSWCRT = ${HYDRO_SUBRTSWCRT}

!Switch activate surface overland flow routing...(0=no, 1=yes)
 OVRTSWCRT = ${HYDRO_OVRTSWCRT}

!Switch to activate channel routing Routing Option: 1=Seepest Descent (D8) 2=CASC2D
 rt_option    = ${HYDRO_RT_OPTION}
 
!Switch to activate channel routing option...((0=no, 1=yes)
 CHANRTSWCRT = ${HYDRO_CHANRTSWCRT}

!Specify channel routing option: 1=Muskingam-reach, 2=Musk.-Cunge-reach, 3=Diff.Wave-gridded
 channel_option =${HYDRO_CHANNEL_OPTION}

!Specify the reach file for reach-based routing options...
 route_link_f = ""

!Switch to activate baseflow bucket model...(0=none, 1=exp. bucket, 2=pass-through)
 GWBASESWCRT = ${HYDRO_GWBASESWCRT}

!Specify baseflow/bucket model initialization...(0=cold start from table, 1=restart file)
 GW_RESTART = 0

!Groundwater/baseflow mask specified on land surface model grid...
!Note: Only required if baseflow bucket model is active
 gwbasmskfil = "domain/${HYDRO_BASN_MSK_FILE}"

/
EOF

# ===========================================================================================
# Creation of namelist.hrldas
# ===========================
cat >! namelist.hrldas << EOF
&NOAHLSM_OFFLINE

 HRLDAS_CONSTANTS_FILE = "domain/wrfinput_d0${HYDRO_DOMAIN}"
 INDIR  = './forcing'

! OUTDIR = "./hrldas_output/"

 START_YEAR  = ${yyyy1}
 START_MONTH  = ${mm1}
 START_DAY  = ${dd1}
 START_HOUR  = ${hh1}
 START_MIN   = 00

! RESTART_FILENAME_REQUESTED  = 'RESTART.2013091206_DOMAIN3'

! KDAY = 720
! KDAY = 1440
  KHOUR = ${HYDRO_KHOUR}

 FORCING_TIMESTEP =  3600
 NOAH_TIMESTEP    =    60
 OUTPUT_TIMESTEP  =  3600

! RESTART_FREQUENCY_HOURS = 0 ! 480
! RESTART_FREQUENCY_HOURS = 99999 ! 480
 RESTART_FREQUENCY_HOURS = 1 ! 480

! Split output after split_output_count output times.
! SPLIT_OUTPUT_COUNT = 240
 SPLIT_OUTPUT_COUNT = 1

! SUBWINDOW_XSTART = 32
! SUBWINDOW_XEND = 32
! SUBWINDOW_YSTART = 60
! SUBWINDOW_YEND = 60

 NSOIL=4
 ZSOIL(1) = -0.10
 ZSOIL(2) = -0.40
 ZSOIL(3) = -1.00
 ZSOIL(4) = -2.00

 ZLVL = 2.0
 ZLVL_WIND = 10.0

 IZ0TLND = 0
 SFCDIF_OPTION = 0
 UPDATE_SNOW_FROM_FORCING = .TRUE.

!Specification of forcing data:  1=HRLDAS-hr format, 2=HRLDAS-min format, 3=WRF, 4=Idealized, 5=Ideal w/ Spec.Precip., 6=HRLDAS-hrly format w/ Spec. Precip
 FORC_TYP = ${HYDRO_FORC_TYP}

!Switch for snow data assimilation: 0=no, 1=yes
SNOW_ASSIM = 0

! for extract greenfrac
GEO_STATIC_FLNM = "domain/geo_em.d0${HYDRO_DOMAIN}.nc"

!HRLDAS_ini_typ 1: initial and parameters from frocing; 0: from wrfinput.
HRLDAS_ini_typ = 0

/

&URBAN_OFFLINE
 SF_URBAN_PHYSICS = 0
 ZLVL_URBAN = 15.0
/
EOF
