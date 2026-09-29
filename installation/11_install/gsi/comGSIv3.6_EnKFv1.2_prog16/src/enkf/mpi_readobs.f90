module mpi_readobs
!$$$  module documentation block
!
! module: mpi_readobs                  read obs, ob priors and associated
!                                      metadata if called from root task, 
!                                      otherwise receive data from root task.
!
! prgmmr: whitaker         org: esrl/psd               date: 2009-02-23
!
! abstract:
!
! Public Subroutines:
!  mpi_readobs: called by subroutine readobs in module enkf_obsmod. 
!   Read obs, ob priors and metadata from diag* files
!   created by GSI forward operator code and broadcast to all tasks.
!   
! Public Variables: None
!
! Modules Used:
!  readsatobs: to read satellite radiance diag* files.
!  readconvobs: to read diag_conv* files (obs from prepbufr file).
!  readozobs: to read diag_sbuv* ozone files.
!  mpisetup
!
! program history log:
!   2009-02-23  Initial version.
!
! attributes:
!   language: f95
!
!$$$
  
use kinds, only: r_kind, r_single, i_kind
use radinfo, only: npred
use readconvobs
use readsatobs
use readozobs
use mpisetup

implicit none

private
public :: mpi_getobs

contains

subroutine mpi_getobs(obspath, datestring, nobs_conv, nobs_oz, nobs_sat, nobs_tot, &
                      sprd_ob, ensmean_ob, ensmean_obbc, ob, &
                      oberr, oblon, oblat, obpress, &
                      obtime, oberrorig, obcode, obtype, &
                      biaspreds, anal_ob, indxsat, nanals)
							 
	character*500, intent(in) :: obspath
	character*10, intent(in) :: datestring
	character(len=10) :: id,id2
	real(r_single), allocatable, dimension(:) :: ensmean_ob,ob,oberr,oblon,oblat,obpress,obtime,oberrorig,ensmean_obbc,sprd_ob
	integer(i_kind), allocatable, dimension(:) :: obcode,indxsat
	real(r_single), allocatable, dimension(:,:) :: biaspreds
	real(r_single), allocatable, dimension(:,:) :: anal_ob,anal_obtmp
	real(r_single), allocatable, dimension(:) :: h_xnobc
	real(r_single) :: analsi,analsim1
	real(r_double) t1,t2
	character(len=20), allocatable,  dimension(:) ::  obtype
	integer(i_kind) nob, ierr, iozproc, isatproc, &
	      nobs_conv, nobs_oz, nobs_sat, nobs_tot, nanal
	integer(i_kind), intent(in) :: nanals
	integer	:: ii		! liaofan 2018.08.22 
	character (len=6) :: filename	! liaofan 2018.08.22
	
	iozproc=max(0,min(1,numproc-1))
	isatproc=max(0,min(2,numproc-2))
	 
	! ===== This is the beginning of Reading observation numbers ========================
	if (nproc == 0) then 
		write(*,*) ' '
		write(*,*) "   ============================================================================"
		write(*,*) "   (mpi_readobs.f90) This is the beginning of reading observation numbers"
		write(*,*) "   (mpi_readobs.f90)    iozproc  = ",iozproc
		write(*,*) "   (mpi_readobs.f90)    isatproc = ",isatproc
		write(*,*) "   (mpi_readobs.f90)    	- Note (2018.08.17): iozproc=1; isatproc=2"
		write(*,*) "   (mpi_readobs.f90)    "
		write(*,*) "   (mpi_readobs.f90)    obspath = ",trim(obspath)
		write(*,*) "   (mpi_readobs.f90)    datestring = ",datestring
		write(*,*) "   (mpi_readobs.f90)    	- Note (2018.08.17): in subroutine get_num_convobs:"
		write(*,*) "   (mpi_readobs.f90)    		* obspath is intent(in)"
		write(*,*) "   (mpi_readobs.f90)    		* datestring is intent(in)"
		write(*,*) "   (mpi_readobs.f90)    		* nobs_conv is intent(out)"
		write(*,*) "   (mpi_readobs.f90)    		* id is intent(in)"
		write(*,*) '   ==================================== (added by liaofan) 2018.08.17 ========='
		write(*,*) ' '
	end if
	! ===================================================================================	 
	 
	! Get Total Number of Conventional and Sat Obs for ensmean.
	! ---------------------------------------------------------
	! See rn180819, rn180820
	id = 'ensmean'
	if(nproc == 0) call get_num_convobs(obspath,datestring,nobs_conv,id)
	if(nproc == iozproc) call get_num_ozobs(obspath,datestring,nobs_oz,id)
	if(nproc == isatproc) call get_num_satobs(obspath,datestring,nobs_sat,id)
		
	call mpi_bcast(nobs_conv,1,mpi_integer,0,mpi_comm_world,ierr)
	call mpi_bcast(nobs_oz,1,mpi_integer,iozproc,mpi_comm_world,ierr)
	call mpi_bcast(nobs_sat,1,mpi_integer,isatproc,mpi_comm_world,ierr)
	if(nproc == 0) print *,'nobs_conv, nobs_oz, nobs_sat = ',nobs_conv,nobs_oz,nobs_sat
	nobs_tot = nobs_conv + nobs_oz + nobs_sat
	
	! if nobs_tot != 0 (there were some obs to read)
	if (nobs_tot > 0) then
		if (nproc == 0) then
			! this array only needed on root.
			allocate(anal_ob(nanals,nobs_tot))
		end if
		! these arrays needed on all processors.
		allocate(h_xnobc(nobs_tot))
		allocate(sprd_ob(nobs_tot),ob(nobs_tot),oberr(nobs_tot),oblon(nobs_tot),&
		oblat(nobs_tot),obpress(nobs_tot),obtime(nobs_tot),oberrorig(nobs_tot),obcode(nobs_tot),&
		obtype(nobs_tot),ensmean_ob(nobs_tot),ensmean_obbc(nobs_tot),&
		biaspreds(npred+1, nobs_sat),indxsat(nobs_sat))
	else
		! stop if no obs found (must be an error somewhere).
		print *,'no obs found!'
		call stop2(11)
	end if

	! read ensemble mean and every ensemble member
	nanal = nproc+1
	id = 'ensmean'
	id2 = id
	if (nanal <= nanals) then
		write(id2,'(a3,(i3.3))') 'mem',nanal
	endif

	! ===== This is the beginning of Reading observations  ============================
	if (nproc == 0) then 
		write(*,*) ' '
		write(*,*) "   ============================================================================"
		write(*,*) "   (mpi_readobs.f90) (nproc=0) This is the beginning of reading observations"
		write(*,*) "   (mpi_readobs.f90)    nobs_conv = ",nobs_conv
		write(*,*) "   (mpi_readobs.f90)    nobs_oz   = ",nobs_oz
		write(*,*) "   (mpi_readobs.f90)    nobs_sat  = ",nobs_sat
		write(*,*) '   ==================================== (added by liaofan) 2018.08.17 ========='
		write(*,*) ' '
	end if
	! ===================================================================================
		write(*,*) ' '
		write(*,*) "   ============================================================================"
		write(*,*) "   (mpi_readobs.f90) This is the beginning of reading observations"
		write(*,*) "   (mpi_readobs.f90)    nproc = ",nproc
		write(*,*) "   (mpi_readobs.f90)    id2   = ",id2
		write(*,*) '   ==================================== (added by liaofan) 2018.08.20 ========='
		write(*,*) ' '
	! ===================================================================================


	
	! READ OBS.
	! -------------------------------------------------------
	! only thing that is different on each task is h_xnobc.  All other
	! fields are defined from ensemble mean.
	! individual members read on 1st nanals tasks, ens mean read on all tasks.
	if (nobs_conv > 0) then
		
		! first nobs_conv are conventional obs.
		call get_convobs_data(obspath, datestring, nobs_conv,               &
		  ensmean_obbc(1:nobs_conv), h_xnobc(1:nobs_conv), ob(1:nobs_conv), &
		  oberr(1:nobs_conv), oblon(1:nobs_conv), oblat(1:nobs_conv),       &
		  obpress(1:nobs_conv), obtime(1:nobs_conv), obcode(1:nobs_conv),   &
		  oberrorig(1:nobs_conv), obtype(1:nobs_conv), id,id2)
		  
		! ===== Added by Liaofan on 2018.08.22 ==============================================
		if (nproc<10) then
			write(filename,"(A,I1)") '0',nproc
		else
			write(filename,"(I2)") nproc
		end if  

		open(unit=31,file='liaofan_MPI_READOBS_variables_after_calling_get_convobs_data_'//trim(filename)//'.txt')
		write(31,"(A)") 'Note (2018.08.22) This script is outputed from mpi_readobs.f90'
		write(31,"(A)") 'obtype, ensmean_obbc,      h_xnobc,           ob'
		do ii=1,nobs_conv
			write(31,"(A,A3,A,F12.5,A,F12.5,A,F12.5)") '   ', obtype(ii), ', ', &
				ensmean_obbc(ii),', ',h_xnobc(ii),', ',ob(ii)
		enddo
		
		close(31)
	  	! ===================================================================================		  
		  
	end if
	
	if (nobs_oz > 0) then
		
		! second nobs_oz are conventional obs.
      call get_ozobs_data(obspath, datestring, nobs_oz,  &
        ensmean_obbc(nobs_conv+1:nobs_conv+nobs_oz),     &
        h_xnobc(nobs_conv+1:nobs_conv+nobs_oz),          &
        ob(nobs_conv+1:nobs_conv+nobs_oz),               &
        oberr(nobs_conv+1:nobs_conv+nobs_oz),            &
        oblon(nobs_conv+1:nobs_conv+nobs_oz),            &
        oblat(nobs_conv+1:nobs_conv+nobs_oz),            &
        obpress(nobs_conv+1:nobs_conv+nobs_oz),          &
        obtime(nobs_conv+1:nobs_conv+nobs_oz),           &
        obcode(nobs_conv+1:nobs_conv+nobs_oz),           &
        oberrorig(nobs_conv+1:nobs_conv+nobs_oz),        &
        obtype(nobs_conv+1:nobs_conv+nobs_oz), id,id2)
	end if
	
	if (nobs_sat > 0) then
		
      biaspreds = 0. ! initialize bias predictor array to zero.
		! last nobs_sat are satellite radiance obs.
      !print *,nproc,id,id2,'read sat obs'
      call get_satobs_data(obspath, datestring, nobs_sat, &
        ensmean_obbc(nobs_conv+nobs_oz+1:nobs_tot),       &
        h_xnobc(nobs_conv+nobs_oz+1:nobs_tot),            &
        ob(nobs_conv+nobs_oz+1:nobs_tot),                 &
        oberr(nobs_conv+nobs_oz+1:nobs_tot),              &
        oblon(nobs_conv+nobs_oz+1:nobs_tot),              &
        oblat(nobs_conv+nobs_oz+1:nobs_tot),              &
        obpress(nobs_conv+nobs_oz+1:nobs_tot),            &
        obtime(nobs_conv+nobs_oz+1:nobs_tot),             &
        obcode(nobs_conv+nobs_oz+1:nobs_tot),             &
        oberrorig(nobs_conv+nobs_oz+1:nobs_tot),          &
        obtype(nobs_conv+nobs_oz+1:nobs_tot), biaspreds,indxsat,id,id2)
		  
	end if ! read obs.

	call mpi_barrier(mpi_comm_world,ierr)  ! synch tasks.

	! use mpi_gather to gather ob prior ensemble on root.
	! requires allocation of nobs_tot x nanals temporory array.
	!    if (nproc == 0) then
	!       t1 = mpi_wtime()
	!       allocate(anal_obtmp(nobs_tot,nanals))
	!    endif
	!    if (nproc <= nanals-1) then
	!       call mpi_gather(h_xnobc,nobs_tot,mpi_real4,&
	!       anal_obtmp,nobs_tot,mpi_real4,0,mpi_comm_io,ierr)
	!       if (nproc .eq. 0) then
	!          anal_ob = transpose(anal_obtmp); deallocate(anal_obtmp)
	!          t2 = mpi_wtime()
	!          print *,'time to create ob prior ensemble on root = ',t2-t1
	!       endif
	!    endif

	! use mpi_send/mpi_recv to gather ob prior ensemble on root.
	! a bit slower, but does not require large temporary array like mpi_gather.
	if (nproc <= nanals-1) then
		if (nproc == 0) then
			t1 = mpi_wtime()
			anal_ob(1,:) = h_xnobc(:)
			do nanal=2,nanals
				call mpi_recv(h_xnobc,nobs_tot,mpi_real4,nanal-1, &
				             1,mpi_comm_io,mpi_status,ierr)
				anal_ob(nanal,:) = h_xnobc(:)
			enddo
			t2 = mpi_wtime()
			print *,'time to gather ob prior ensemble on root = ',t2-t1
		else ! nproc != 0
			
			! send to root.
			call mpi_send(h_xnobc,nobs_tot,mpi_real4,0,1,mpi_comm_io,ierr)
		end if 
	end if ! nanal <= nanals

	! ===================================================================================
		write(*,*) ' '
		write(*,*) "   ============================================================================"
		write(*,*) "   (mpi_readobs.f90) Before computing ensmean_ob, anal_ob, and sprd_ob"
		write(*,*) "   	nanals   = ",nanals
		write(*,*) "   	DIM full of anal_ob = ",size(anal_ob)
		write(*,*) "   	DIM 01 of anal_ob  = ",size(anal_ob,1)
		write(*,*) "   	DIM 02 of anal_ob  = ",size(anal_ob,2)
		write(*,*) "   	DIM 02 of anal_ob  = ",size(anal_ob,2)
		write(*,*) "   	- Note (2018.08.22) anal_ob is allocated only when nproc=0."
		write(*,*) "   	  The allocation is defined before, 'allocate(anal_ob(nanals,nobs_tot))'"
		write(*,*) "   	  In my study case, nanals=10 (members), and nobs_tot=774 (total obs)"
		write(*,*) '   ==================================== (added by liaofan) 2018.08.21 ========='
		write(*,*) ' '
	! ===================================================================================
	if (nproc == 0) then
		write(*,*) ' '
		write(*,*) "   ============================================================================"
		write(*,*) "   (mpi_readobs.f90) Before computing ensmean_ob, anal_ob, and sprd_ob"
		write(*,*) "   	1._r_single   = ",1._r_single
		write(*,*) "   	float(nanals) = ",float(nanals)
		write(*,*) '   ==================================== (added by liaofan) 2018.08.22 ========='
		write(*,*) ' '
	endif
	! ===== Added by Liaofan on 2018.08.22 ==============================================
	if (nproc == 0) then
		open(unit=21,file='liaofan_MPI_READOBS_anal_ob_without_bc.txt')
		write(21,"(A)") 'Note (2018.08.22) This script is outputed from mpi_readobs.f90'		
		
		open(unit=22,file='liaofan_MPI_READOBS_anal_ob_with_bc.txt')
		write(22,"(A)") 'Note (2018.08.22) This script is outputed from mpi_readobs.f90'		
		
		open(unit=23,file='liaofan_MPI_READOBS_sprd_ob.txt')
		write(23,"(A)") 'Note (2018.08.22) This script is outputed from mpi_readobs.f90'	
		
		write(*,*) 'anal_ob(1,1)=',anal_ob(1,1)
	endif
	! ===================================================================================	
	
	
	
			
	! make anal_ob contain ob prior ensemble *perturbations*
	if (nproc == 0) then
		analsi=1._r_single/float(nanals)
		analsim1=1._r_single/float(nanals-1)
		  
		!$omp parallel do private(nob,nanal)
		do nob=1,nobs_tot

			! ===== Added by Liaofan on 2018.08.22 ==============================================
			write(21,"(10(F10.4,A))") (anal_ob(ii,nob),', ',ii=1,nanals)	
			! ===================================================================================	
						
			! remove ensemble mean from each member.
			ensmean_ob(nob)  = sum(anal_ob(:,nob))*analsi
			
			! ensmean_ob is unbiascorrected ensemble mean (anal_ob
			anal_ob(:,nob) = anal_ob(:,nob)-ensmean_ob(nob)

			! ===== Added by Liaofan on 2018.08.22 ==============================================
			write(22,"(10(F10.4,A))") (anal_ob(ii,nob),', ',ii=1,nanals)	
			! ===================================================================================	
			
			! compute sprd
         sprd_ob(nob) = sum(anal_ob(:,nob)**2)*analsim1
			
			! ===== Added by Liaofan on 2018.08.22 ==============================================
			write(23,"(F10.4)") sprd_ob(nob)
			! ===================================================================================				
		enddo
		
		!$omp end parallel do
	endif

	! ===== Added by Liaofan on 2018.08.22 ==============================================
	close(21)	
	close(22)
	close(23)
	! ===================================================================================	

	! broadcast ob prior ensemble mean and spread to every task.
	if (nproc == 0) t1 = mpi_wtime()
	call mpi_bcast(ensmean_ob,nobs_tot,mpi_real4,0,mpi_comm_world,ierr)
	call mpi_bcast(sprd_ob,nobs_tot,mpi_real4,0,mpi_comm_world,ierr)
	
	if (nproc == 0) then
		t2 = mpi_wtime()
		print *,'time to broadcast ob prior ensemble mean and spread = ',t2-t1
	endif
	deallocate(h_xnobc)

end subroutine mpi_getobs

end module mpi_readobs
