program uou_nc_repl_SM_TQ_v01

	use netcdf
	
	implicit none
	
! =====================================================================
! == SPECIFICATION ====================================================
! =====================================================================
	! Input argument
		character(len=25) :: NC_REPL_PRE_FCST_FILENAME
		character(len=25) :: NC_REPL_WRF_REPL_FILENAME
		character(len=20) :: NC_REPL_VARIABLE
		
	! Dimension variables
		integer :: NX, NY, NZ, NZ_SOIL
		
	! allocatable variables
		real, allocatable :: smois(:,:,:)
		real, allocatable :: t(:,:,:)
		real, allocatable :: q(:,:,:)
		
  	! This will be the netCDF ID for the file and data variable.
  		integer :: ncid_NC_INPUT_PR_FCST, varid_NC_INPUT_PR_FCST
  		integer :: ncid_NC_INPUT_NC_REPL, varid_NC_INPUT_NC_REPL
		
		
	! Name list
	namelist /nc_repl/ NX,NY,NZ,NZ_SOIL, &
		NC_REPL_WRF_REPL_FILENAME, &
		NC_REPL_PRE_FCST_FILENAME
		
		
! =====================================================================
! == EXECUTION ========================================================
! =====================================================================
	! ---------------------------
	! 1. READING DATA
	! ---------------------------
	
	! 1.1. Reading the variables in the name list.  
	! -------------------------------------------
		! 	- (2018.02.08) For more details, see section 20170927 at my fortran book
		open(unit=1,file='namelist.nc_repl',form='formatted', &
			status='old',action='read')
		read(unit=1,nml=nc_repl)
		write(*,nml=nc_repl)
		close(unit=1)	
		
		! Allocate variables
		allocate( smois(NX,NY,NZ_SOIL) )
		allocate( t(NX,NY,NZ) )
		allocate( q(NX,NY,NZ) )	
		
	! Process of wrfinput file
	! ------------------------
		print *," "
		print *,"Process of ", NC_REPL_PRE_FCST_FILENAME, '& ', NC_REPL_WRF_REPL_FILENAME
		print *,"---------------------------"	


		! Read INPUT from WRF PREV FORECAST
		! ---------------------------------
			call check( nf90_open( NC_REPL_PRE_FCST_FILENAME , nf90_noWrite , ncid_NC_INPUT_PR_FCST ) )	
			
			! Read SM			
			call check( nf90_inq_varid( ncid_NC_INPUT_PR_FCST , "SMOIS" , varid_NC_INPUT_PR_FCST) )	
			call check( nf90_get_var(ncid_NC_INPUT_PR_FCST, varid_NC_INPUT_PR_FCST, smois ) )
			
			! Read T
			call check( nf90_inq_varid( ncid_NC_INPUT_PR_FCST , "T" , varid_NC_INPUT_PR_FCST) )	
			call check( nf90_get_var(ncid_NC_INPUT_PR_FCST, varid_NC_INPUT_PR_FCST, t ) )
			
			! Read Q
			call check( nf90_inq_varid( ncid_NC_INPUT_PR_FCST , "QVAPOR" , varid_NC_INPUT_PR_FCST) )	
			call check( nf90_get_var(ncid_NC_INPUT_PR_FCST, varid_NC_INPUT_PR_FCST, q ) )
					
			
		! Read writable input for WRF input to be replaced	
		! ------------------------------------------------
			call check( nf90_open( NC_REPL_WRF_REPL_FILENAME , nf90_Write , ncid_NC_INPUT_NC_REPL ) )
							
			! Replacement of SMOIS	
			call check( nf90_inq_varid( ncid_NC_INPUT_NC_REPL, "SMOIS" , varid_NC_INPUT_NC_REPL) )
			call check( nf90_put_var(ncid_NC_INPUT_NC_REPL, varid_NC_INPUT_NC_REPL, smois ) )

			! Replacement of T
			call check( nf90_inq_varid( ncid_NC_INPUT_NC_REPL, "T" , varid_NC_INPUT_NC_REPL) )
			call check( nf90_put_var(ncid_NC_INPUT_NC_REPL, varid_NC_INPUT_NC_REPL, t ) )
			
			! Replacement of Q
			call check( nf90_inq_varid( ncid_NC_INPUT_NC_REPL, "QVAPOR" , varid_NC_INPUT_NC_REPL) )
			call check( nf90_put_var(ncid_NC_INPUT_NC_REPL, varid_NC_INPUT_NC_REPL, q ) )
		
		! CLOSE THE NC FILES
		call check( nf90_close(ncid_NC_INPUT_PR_FCST) )	
		call check( nf90_close(ncid_NC_INPUT_NC_REPL) )		
		
		
		print *,"uou_nc_repl_SM_TQ.exe is successfully executed!"
		
!
contains
  	subroutine check(status)
    	integer, intent ( in) :: status
    
    	if(status /= nf90_noerr) then 
      	print *, trim(nf90_strerror(status))
      	stop "Stopped"
    	end if
  	end subroutine check  
  	
		
		
end program uou_nc_repl_SM_TQ_v01
