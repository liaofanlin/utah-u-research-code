module enkf
!$$$  module documentation block
!
! module: enkf                         Update model state variables and
!                                      bias coefficients with the
!                                      serial EnKF.
!
! prgmmr: whitaker         org: esrl/psd               date: 2009-02-23
!
! abstract: Updates the model state using the serial EnKF.  If the namelist
!  parameter deterministic is .true., the serial ensemble square root
!  filter described by Whitaker and Hamill (2002, MWR, p. 1913-1924) is used.
!  If deterministic is .false., the serial EnKF with perturbed obs 
!  is used. If deterministic=.false, and sortinc=.true., the updated
!  observation variable ensemble members are paired with the prior members
!  so as to reduce the value of the update increments, following 
!  Anderson (2003, MWR, p. 634-642).  By "serial", we mean that observations
!  are processed individually, one at a time.  The order that observations
!  are assimilated can be controlled by the namelist parameter iassim_order.
!  iassim_order=0 means assimilate obs in the order they were read in, 
!  iassim_order=1 means shuffle the obs randomly before assimilating,
!  and iassim_order=2 means assimilate in order of predicted obervation variance
!  reduction. Note that the predicted variance reduction is based on the
!  original background observation variance, and does not include the effect
!  of the assimilation of other observations.
!
!  The EnKF update is done in parallel using the algorithm described
!  by Anderson and Collins (2007, J. of Atm. & Oceanic Tech., p. 1452-1463).
!  In this algorithm, both the model state variables and the observation priors
!  (the predicted observation variable ensemble members) are updated so as to
!  avoid recomputing the forward operator after each observation is assimilated.
!
!  After the observation variables are updated, the bias coefficients update is done
!  using update_biascorr from module radbias.  This update is done via a
!  matrix inversion using all the observations at once, and a static (diagonal)
!  background error covariance matrix.  If the namelist parameter numiter is >
!  1, this process is repeated numiter times, with each observation variable update using
!  the latest estimate of the bias correction coefficients and each bias
!  coefficient update using the latest estimate of the observation increment
!  (observation minus ensemble mean observation variable).  The model state
!  variables are only updated during the last iteration.  After the update is
!  complete, the variables anal_chunk and ensmean_chunk (from module statevec)
!  contain the updated model state ensemble perturbations and ensemble mean,
!  and predx (from module radinfo) contains the updated bias coefficients.
!  obfit_post and obsprd_post contain the observation increments and observation
!  variable variance.
!
!  Covariance localization is used in the state update to limit the impact 
!  of observations to a specified distance from the observation in the
!  horizontal and vertical.  These distances can be set separately in the
!  NH, tropics and SH, and in the horizontal, vertical and time dimensions,
!  using the namelist parameters  corrlengthnh, corrlengthtr, corrlengthsh,
!  lnsigcutoffnh, lnsigcutofftr, lnsigcutoffsh (lnsigcutoffsatnh,
!  lnsigcutoffsattr, lnsigcutoffsatsh for satellite obs, similar for ps obs)
!  obtimelnh, obtimeltr, obtimelsh. The length scales should be given in km for the
!  horizontal, hours for time, and 'scale heights' (units of -log(p/pref)) in the
!  vertical. The function used for localization (function taper)
!  is imported from module covlocal. Localization requires that
!  every observation have an associated horizontal, vertical and temporal location.
!  For satellite radiance observations the vertical location is given by
!  the maximum in the weighting function associated with that sensor/channel/
!  background state (this computation, along with the rest of the forward
!  operator calcuation, is performed by a separate program using the GSI
!  forward operator code).  Since all the observation variable ensemble
!  members often cannot fit in memory, they are saved in a temp file by 
!  module readobs, and only those needed on this task are read in by
!  subroutine enkf_update.
!
!  Adaptive observation thinning can be done via the parameter paoverpb_thresh.
!  If this parameter >= 1 (1 is the default) no thinning is done.  If < 1, an 
!  observation is not assimilated unless it will reduce the observation
!  variable ensemble variance by paoverpb_thresh (e.g. if paoverpb_thresh = 0.9,
!  only obs that will reduce the variance by 10% will be assimilated).
!
! Public Subroutines:
!  enkf_update: performs the EnKF update (calls update_biascorr to perform
!   the bias coefficient update.  The EnKF/bias coefficient update is 
!   iterated numiter times (parameter numiter from module params).
!
! Public Variables: None
!
! Modules Used: kinds, constants, params, covlocal, mpisetup, loadbal, statevec,
!               kdtree2_module, enkf_obsmod, radinfo, radbias, gridinfo
!
! program history log:
!   2009-02-23:  Initial version.
!   2016-02-01:  Ensure posterior perturbation mean remains zero.
!
! attributes:
!   language: f95
!
!$$$

use mpisetup
use covlocal, only:  taper
use kinds, only: r_double,i_kind,r_single,r_single
use kdtree2_module, only: kdtree2_r_nearest, kdtree2_result
use loadbal, only: numobsperproc, numptsperproc, indxproc_obs, iprocob, &
                   indxproc, lnp_chunk, kdtree_obs, kdtree_grid, &
                   ensmean_obchunk, indxob_chunk, oblnp_chunk, nobs_max, &
                   obtime_chunk, grdloc_chunk, obloc_chunk, &
                   npts_max, anal_obchunk_prior
use statevec, only: ensmean_chunk, anal_chunk, ensmean_chunk_prior
use enkf_obsmod, only: oberrvar, ob, ensmean_ob, obloc, oblnp, &
                  nobstot, nobs_conv, nobs_oz, nobs_sat,&
                  obfit_prior, obfit_post, obsprd_prior, obsprd_post, obtime,&
                  obtype, oberrvarmean, numobspersat, deltapredx, biaspreds,&
                  biasprednorm, oberrvar_orig, probgrosserr, prpgerr,&
                  corrlengthsq,lnsigl,obtimel,obloclat,obloclon,obpress,stattype
use constants, only: pi, one, zero
use params, only: sprd_tol, paoverpb_thresh, ndim, datapath, nanals,&
                  iassim_order,sortinc,deterministic,numiter,nlevs,nvars,&
                  zhuberleft,zhuberright,varqc,lupd_satbiasc,huber,univaroz,&
                  covl_minfact,covl_efold,nbackgrounds,nhr_anal,fhr_assim,&
                  iseed_perturbed_obs,lupd_obspace_serial
use radinfo, only: npred,nusis,nuchan,jpch_rad,predx
use radbias, only: apply_biascorr, update_biascorr
use gridinfo, only: nlevs_pres,index_pres,nvarozone
use sorting, only: quicksort, isort
!use innovstats, only: print_innovstats

implicit none

private
public :: enkf_update

contains

subroutine enkf_update()
use random_normal, only : rnorm, set_random_seed
! serial EnKF update.

! local variables.
integer(i_kind) nob,nob1,nob2,nob3,npob,nf,nf2,ii,nobx,nskip,&
                niter,i,nrej,npt,nuse,ncount,nb
integer(i_kind) indxens1(nanals),indxens2(nanals)
real(r_single) hxpost(nanals),hxprior(nanals),hxinc(nanals),&
             dist,lnsig,obt,&
             sqrtoberr,corrlengthinv,lnsiglinv,obtimelinv
real(r_single) corrsqr,covl_fact
real(r_double) :: t1,t2,t3,t4,t5,t6,tbegin,tend
real(r_single) kfgain,hpfht,hpfhtoberrinv,r_nanals,r_nanalsm1,hpfhtcon
real(r_single) anal_obtmp(nanals),obinc_tmp,obens(nanals),obganl(nanals)
real(r_single) normdepart, pnge, width
real(r_single) buffer(nanals+2)
real(r_single),allocatable, dimension(:,:) :: anal_obchunk
real(r_single),dimension(nobstot):: oberrvaruse
real(r_single) r,paoverpb
real(r_single) taper1,taper3
real(r_single),allocatable, dimension(:) :: rannum,corrlengthsq_orig,lnsigl_orig
integer(i_kind), allocatable, dimension(:) :: indxassim,iskip,indxassim2,indxassim3
real(r_single), allocatable, dimension(:) :: buffertmp,taper_disob,taper_disgrd
real(r_single), allocatable, dimension(:) :: paoverpb_save
real(r_single), allocatable, dimension(:) :: paoverpb_min, paoverpb_min1, paoverpb_chunk
integer(i_kind) ierr
! kd-tree search results
type(kdtree2_result),dimension(:),allocatable :: sresults1,sresults2 
integer(i_kind) nanal,nn,nnn,nobm,nsame,nn1,nn2
real(r_single),dimension(nlevs_pres):: taperv
logical lastiter, kdgrid, kdobs

character (len=6) :: filename		! liaofan 2018.09.12
character (len=6) :: filename02	! liaofan 2019.02.20
character (len=6) :: filename03	! liaofan 2019.02.20
integer	:: iiii		! liaofan 2018.09.12 

! allocate temporary arrays.
allocate(anal_obchunk(nanals,nobs_max))
allocate(sresults1(numptsperproc(nproc+1)),taper_disgrd(numptsperproc(nproc+1)))
allocate(sresults2(numobsperproc(nproc+1)),taper_disob(numobsperproc(nproc+1)))
allocate(buffertmp(nobstot))
! index array that controls assimilation order
allocate(indxassim(nobstot),iskip(nobstot))
allocate(paoverpb_save(nobstot))
allocate(corrlengthsq_orig(nobstot),lnsigl_orig(nobstot))

! define a few frequently used parameters
r_nanals=one/float(nanals)
r_nanalsm1=one/float(nanals-1)

! default is to assimilate in order they are read in.
do nob=1,nobstot
	indxassim(nob) = nob
end do

! set random seed if random number generator is to be used.
if (iassim_order == 1 .or. .not. deterministic) then
   if (deterministic .and. nproc == 0) then
      ! random numbers only generated on root task.
      call set_random_seed(iseed_perturbed_obs, nproc)
   else
      ! random numbers generated for perturbed obs
      ! on all tasks - set random seed identically
      ! on all tasks to get same random sequence.
      call set_random_seed(iseed_perturbed_obs, nproc)
   endif
endif

if (iassim_order == 1) then
	! create random index array so obs are assimilated in random order.
	if (nproc == 0) then
      print *,'assimilate obs in random order'
      allocate(rannum(nobstot))
      call random_number(rannum)
      call quicksort(nobstot,rannum,indxassim)
      deallocate(rannum)
	end if
	
	call mpi_bcast(indxassim,nobstot,mpi_integer,0, &
       mpi_comm_world,ierr)
else if (iassim_order .eq. 2) then
	if (nproc .eq. 0) print *,'assimilate obs in order of increasing HPaHT/HPbHT'
	
	allocate(paoverpb_chunk(numobsperproc(nproc+1)))
	allocate(indxassim2(nobstot),indxassim3(nobstot))
  	allocate(paoverpb_min(2),paoverpb_min1(2))
  	! don't try to get all the obs - stop when paoverpb
  	! very close to 1.0.  If paoverpb_thresh is set to 1.0,
  	! there are precision issues in the sorting, and duplicated
  	! are found (resulting in obs being assimlated more than once).
  	if (paoverpb_thresh .gt. 0.999) paoverpb_thresh = 0.999
  	! if obs to be assimilated in order of increasing HPaHT/HPbHT,
  	! paoverpb_chunk holds latest estimate of obsdprd_post on each task.
  	do nob=1,numobsperproc(nproc+1)
     	nob1 = indxproc_obs(nproc+1,nob)
     	paoverpb_chunk(nob) = oberrvar(nob1)/(oberrvar(nob1)+obsprd_prior(nob1))
	enddo

	do nob=1,nobstot
      indxassim2(nob) = nob
	enddo
  
  	indxassim = 0
else
	if (nproc .eq. 0) print *,'assimilate obs in order they were read in'
end if

! initialize some arrays with first-guess values.
obfit_post(1:nobstot) = obfit_prior(1:nobstot)
obsprd_post(1:nobstot) = obsprd_prior(1:nobstot)
anal_obchunk = anal_obchunk_prior
corrlengthsq_orig = corrlengthsq
lnsigl_orig = lnsigl

! Check to see if kdtree structures are associated
kdgrid=associated(kdtree_grid)
kdobs=associated(kdtree_obs)

if (nproc == 0) print *,'	======================================================================'
if (nproc == 0) print *,"	(enkf.f90) Before 'do niter=1,numiter'"
if (nproc == 0) print *,'		numiter	      = ',numiter
if (nproc == 0) print *,'		varqc	         = ',varqc
if (nproc == 0) print *,'		huber	         = ',huber
if (nproc == 0) print *,'		nobstot	      = ',nobstot
if (nproc == 0) print *,'		deterministic	= ',deterministic
if (nproc == 0) print *,'		nanals         = ',nanals
if (nproc == 0) print *,'		nobs_max       = ',nobs_max
if (nproc == 0) print *,'		r_nanalsm1     = ',r_nanalsm1
if (nproc == 0) print *,'	============================================ liaofan at 2018.08.28 ==='

do niter=1,numiter

	lastiter = niter == numiter
	
	! apply bias correction with latest estimate of bias coeffs.
	! (already done for first iteration)
	if (nobs_sat > 0 .and. niter > 1 ) call apply_biascorr()

	! reset first guess perturbations at start of each iteration.
	nrej=0
	nsame=0
	anal_obchunk = anal_obchunk_prior
	
	!! === Commented out on 2019.03.19 =========================================
	!! ==== Added by Liaofan on 2019.02.14 =====================================
	!!	rn190214
	!if (nproc == 0) print *,'	======================================================================'
	!if (nproc == 0) print *,"	(enkf.f90) Before 'do nob1=1,numobsperproc(nproc+1)'"
	!if (nproc == 0) print *,'		nproc	                  = ',nproc
	!if (nproc == 0) print *,'     Size of numobsperproc   = ',size(numobsperproc)
	!if (nproc == 0) print *,'     1st Dim of indxproc_obs = ',size(indxproc_obs,1)
	!if (nproc == 0) print *,'     2nd Dim of indxproc_obs = ',size(indxproc_obs,2)
	!if (nproc == 0) print *,'     Size of ensmean_ob      = ',size(ensmean_ob)
	!if (nproc == 0) print *,'	============================================ liaofan at 2019.02.14 ==='	
	!if (nproc == 0) print *,'  '
   !
	!do nob1=1,numobsperproc(nproc+1)
	!	
	!	nob2 = indxproc_obs(nproc+1,nob1)
	!	
	!	if (nproc == 0) print *,'  ======================================================================'
	!	if (nproc == 0) print *,"  (enkf.f90) In 'do nob1=1,numobsperproc(nproc+1)'"			
	!	if (nproc == 0) print *,'     numobsperproc(nproc+1)     = ',numobsperproc(nproc+1)		
	!	if (nproc == 0) print *,'     nproc 							= ',nproc
	!	if (nproc == 0) print *,'     nob1  						   = ',nob1
	!	if (nproc == 0) print *,'     indxproc_obs(nproc+1,nob1) = ',indxproc_obs(nproc+1,nob1)
	!	if (nproc == 0) print *,'     ensmean_ob(nob2) 				= ',ensmean_ob(nob2)
	!	if (nproc == 0) print *,'  ============================================ liaofan at 2019.02.14 ==='
	!	if (nproc == 0) print *,'  '
	!				
	!enddo	
	!! =========================================================================
			
	! ensmean_ob is updated with latest bias coefficient perturbations.
	! nob1 is the index of the obs to be processed on this rank
	! nob2 maps nob1 to 1:nobstot array (nob)		
	do nob1=1,numobsperproc(nproc+1)
		nob2 = indxproc_obs(nproc+1,nob1)
		ensmean_obchunk(nob1) = ensmean_ob(nob2)
	enddo


	!! === Commented out on 2019.03.19 ==========================================
	!! ==== Added by Liaofan on 2019.02.17 =====================================
	!!	rn190214
	!if (nproc == 0) print *,'  ======================================================================'
	!if (nproc == 0) print *,"  (enkf.f90) Before 'RESET OB ERROR TO ACCOUNT FOR GROSS ERRORS'"
	!if (nproc == 0) print *,'     huber    = ',huber
	!if (nproc == 0) print *,'     niter    = ',niter
	!if (nproc == 0) print *,'     varqc    = ',varqc
	!if (nproc == 0) print *,'     oberrvar = ',oberrvar
	!if (nproc == 0) print *,'     ------------------------'
	!if (nproc == 0) print *,'     Note (2019.02.17): In a test, due to niter=1 & varqc=F, the obs err'
	!if (nproc == 0) print *,"       is assigned as 'oberrvaruse(nob) = oberrvar(nob)'"
	!if (nproc == 0) print *,'  ============================================ liaofan at 2019.02.17 ==='	
	!if (nproc == 0) print *,'  '
	!! =========================================================================
			
	! ===========================================
	! RESET OB ERROR TO ACCOUNT FOR GROSS ERRORS
	! ===========================================
  	if (niter > 1 .and. varqc) then
    	if (huber) then ! "huber norm" QC
			
      	do nob=1,nobstot
				
      		normdepart = obfit_post(nob)/sqrt(oberrvar(nob))
        	 	! depends of 2 parameters: zhuberright, zhuberleft.
        	 	if (normdepart < -zhuberleft) then
           	 	pnge = zhuberleft/abs(normdepart)
        		else if (normdepart > zhuberright) then
           	 	pnge = zhuberright/abs(normdepart)
        	 	else
           	 	pnge = one
        	 	end if
				
        	 	! eqn 17 in Dharssi, Lorenc and Inglesby
        	 	! divide ob error by prob of gross error not occurring.
        	 	oberrvaruse(nob) = oberrvar(nob)/pnge
        	 	! pnge is the prob that the ob *does not* contain a gross error.
        	 	! assume rejected if prob of gross err > 50%.
        	 	probgrosserr(nob) = one-pnge
        	 	
				if (probgrosserr(nob) > 0.5_r_single) then 
           	 	nrej=nrej+1
        	 	endif
				
			end do
			
		else ! "flat-tail" QC.
				
			do nob=1,nobstot
				! original form, gross error cutoff a multiple of ob error st dev.
				! here gross err cutoff proportional to ensemble spread plus ob error
				! Dharssi, Lorenc and Inglesby eqn (1) a = grosserrw*sqrt(S+R) 
				width = sprd_tol*sqrt(obsprd_prior(nob)+oberrvar(nob))
				pnge = prpgerr(nob)*sqrt(2.*pi*oberrvar(nob))/((one-prpgerr(nob))*(2.*width))
				normdepart = obfit_post(nob)/sqrt(oberrvar(nob))
				pnge = one - (pnge/(pnge+exp(-normdepart**2/2._r_single)))
				! eqn 17 in Dharssi, Lorenc and Inglesby
				! divide ob error by prob of gross error not occurring.
				oberrvaruse(nob) = oberrvar(nob)/pnge
				! pnge is the prob that the ob *does not* contain a gross error.
				! assume rejected if prob of gross err > 50%.
				probgrosserr(nob) = one-pnge
				
				if (probgrosserr(nob) > 0.5_r_single) then 
					nrej=nrej+1
				endif
			end do
		endif
		
	else
		
		do nob=1,nobstot
			oberrvaruse(nob) = oberrvar(nob)
		end do
		
	end if
	
	


	if (niter == 1) iskip = 0
	
	nobm = 1
	ncount = 0
	t2 = zero
	t3 = zero
	t4 = zero
	t5 = zero
	t6 = zero
	nf    = 0
	nf2   = 0
	tbegin = mpi_wtime()
	
	! ================================
	! LOOP OVER 'GOOD' OBS.
	! ================================
	obsloop: do nobx=1,nobstot

	   t1 = mpi_wtime()

      ! which ob to assimilate next?
      if (iassim_order == 2) then
         if (niter == 1) then
            ! find ob with min HPaHT/HPbHT
            nob1 = minloc(paoverpb_chunk,1)
            paoverpb_min1(1) = paoverpb_chunk(nob1)
            paoverpb_min1(2) = indxproc_obs(nproc+1,nob1)
            call mpi_allreduce(paoverpb_min1,paoverpb_min,1,&
                               mpi_2real,mpi_minloc,mpi_comm_world,ierr)
            if (paoverpb_min(1) >= paoverpb_thresh) then
					if (nproc .eq. 0) &
					print *,'exiting obsloop after ',nobx,' obs processed' 
					nob1 = count(indxassim2 /= 0)
                
					if (nobx-1+nob1 /= nobstot) then
						if (nproc .eq. 0) then
							print *,'error: not all obs accounted for!'
							print *,'count indxassim2 nonzero',nob1
							print *,'nobx,nobstot,nobx+nobstot',nobx,nobstot,nobx-1+nob1
						endif
                    call stop2(91)
					endif
					
					! fill rest of indxassim array with un-assimilated obs
					indxassim(nobx:nobstot) = pack(indxassim2,indxassim2 /= 0)
					do nob=nobx,nobstot
						nob1 = indxassim(nob)
						paoverpb_save(nob1) = paoverpb_thresh + tiny(paoverpb_thresh)
						iskip(nob1) = 1
					enddo
					
					! check to see that all obs accounted for.
					if (nproc .eq. 0) then
						do nob=1,nobstot
							indxassim2(nob) = nob
						enddo
						
						indxassim3 = indxassim
						call isort(indxassim3, nobstot)
						
						! if indxassim2 != indxassim3 there are duplicates
						nob1 = count(indxassim2-indxassim3 /= 0)
						
						if (nob1 /= 0) then
							if (nproc .eq. 0) then
								print *,'error: not all obs accounted for!'
								print *,'count nonzero',nob1
							endif
							call stop2(92)
						endif
						
					endif
					
					exit obsloop
				endif 
				
            nob = paoverpb_min(2); indxassim(nobx) = nob
				
            if (indxassim2(nob) == 0) then
               if (nproc .eq. 0) then
                  print *,'error: this ob already assimilated!'
                  print *,'nobx,nob,paoverpb',nobx,nob,paoverpb_min(1),oberrvaruse(nob)
               endif
               call stop2(93)
            else
               indxassim2(nob) = 0
				endif
				
         else ! niter > 1
            nob = indxassim(nobx)
         endif
      else
         nob = indxassim(nobx)
      endif

      npob = iprocob(nob) ! what task is this ob on?
  
  	 	!! ==== Commented out on 2019.03.19 ========================================
		!! ==== Added by Liaofan on 2019.02.14 =====================================
		!!	See rn190214
		!if (nproc == 0) print *,'	======================================================================'
		!if (nproc == 0) print *,"	(enkf.f90) Before 'if (nproc == npob) then'"
		!if (nproc == 0) print *,'     nob 						 = ',nob
		!if (nproc == 0) print *,'		indxob_chunk(nob)     = ',indxob_chunk(nob)
		!if (nproc == 0) print *,'     size of anal_obchunk  = ',size(anal_obchunk)
		!if (nproc == 0) print *,'     anal_obchunk          = ',anal_obchunk
		!if (nproc == 0) print *,'     r_nanalsm1            = ',r_nanalsm1
		!if (nproc == 0) print *,'     ob(nob)               = ',ob(nob)
		!if (nproc == 0) print *,'     ensmean_obchunk       = ',ensmean_obchunk
		!if (nproc == 0) print *,'     size of buffer        = ',size(buffer)
		!if (nproc == 0) print *,'	============================================ liaofan at 2019.02.14 ==='	
		!if (nproc == 0) print *,'	'
		!! =========================================================================  
  
      ! get ob priors, ob increment from that processor,
      ! send to other processors.
      if (nproc == npob) then
          nob1 = indxob_chunk(nob); 
          hpfht = sum(anal_obchunk(:,nob1)**2)*r_nanalsm1
          buffer(1:nanals) = anal_obchunk(:,nob1)
          buffer(nanals+1) = ob(nob)-ensmean_obchunk(nob1)
          buffer(nanals+2) = hpfht
      end if
		
		!! ==== Commented out on 2019.03.19 ========================================
		!! ==== Added by Liaofan on 2019.02.14 =====================================
		!!	See rn190214
		!if (nproc == 0) print *,'	======================================================================'
		!if (nproc == 0) print *,"	(enkf.f90) After 'if (nproc == npob) then'"
		!if (nproc == 0) print *,'     buffer = ',buffer
		!if (nproc == 0) print *,'	============================================ liaofan at 2019.02.14 ==='
		!if (nproc == 0) print *,'	'
		!! =========================================================================  			
		
      call mpi_bcast(buffer,nanals+2,mpi_real4,npob,mpi_comm_world,ierr)

      t2 = t2 + mpi_wtime() - t1
      t1 = mpi_wtime()

      anal_obtmp = buffer(1:nanals)
      obinc_tmp = buffer(nanals+1)
      hpfht = buffer(nanals+2)

	
		
      hpfhtoberrinv = one/(hpfht+oberrvaruse(nob))
      paoverpb = oberrvar(nob)/(hpfht + oberrvar(nob))
			
		!! ==== Commented out on 2019.03.19 ========================================	
		!! ==== Added by Liaofan on 2019.02.17 =====================================
		!!	See rn190214
		!if (nproc == 0) print *,'  ======================================================================'
		!if (nproc == 0) print *,"  (enkf.f90) After computing hpfhtoberrinv & paoverpb"
		!if (nproc == 0) print *,'     oberrvaruse(nob) = ',oberrvaruse(nob)
		!if (nproc == 0) print *,'     oberrvar(nob)    = ',oberrvar(nob)
		!if (nproc == 0) print *,'     hpfhtoberrinv    = ',hpfhtoberrinv
		!if (nproc == 0) print *,'     paoverpb         = ',paoverpb
		!if (nproc == 0) print *,'  ============================================ liaofan at 2019.02.17 ==='
		!if (nproc == 0) print *,'  '
		!! =========================================================================  		
		
			
      if (niter == 1) paoverpb_save(nob) = paoverpb

      if (paoverpb_save(nob) >= paoverpb_thresh .or. &
          oberrvaruse(nob) > 1.e10_r_single) then
          iskip(nob) = 1
          if (iassim_order == 2) then
             if (nproc .eq. 0) &
             print *,'exiting obsloop after ',nobx,' obs processed' 
             exit obsloop
          else
             cycle obsloop ! skip to next ob
          endif
      else
          iskip(nob) = 0
      end if


		! ================================
		! Determine obganl
		! ================================
		!	- See page 74 of EnKF user guide v 1.2
      if (deterministic) then
         ! EnSRF.
         obganl = -anal_obtmp/(one+sqrt(oberrvaruse(nob)*hpfhtoberrinv))
      else
         ! perturbed obs EnKF.
         sqrtoberr=sqrt(oberrvaruse(nob))
         do nanal=1,nanals
             obens(nanal) = sqrtoberr*rnorm()
         enddo
			
         ! make sure mean is zero
         obens = obens - sum(obens)*r_nanals
			
         if (sortinc) then
				
				! To minimize regression errors, sort to minimize increments.
				! ref - Anderson (2003) "A Least-Squares Framework for Ensemble Filtering"
				! April issue, pages 634-642.
				kfgain = hpfht*hpfhtoberrinv
				hxprior = anal_obtmp
				hxpost = hxprior+kfgain*(obens-hxprior)
				call quicksort(nanals, hxprior, indxens1)
				call quicksort(nanals, hxpost, indxens2)
				do nanal=1,nanals
					hxinc(indxens1(nanal)) = hxpost(indxens2(nanal)) - hxprior(indxens1(nanal))
				end do
				
				! re-order ob perturbations to minimize increments.
				obens = hxinc/kfgain + hxprior
         end if
         obganl = obens - anal_obtmp
      end if

		!! ==== Commented out on 2019.03.19 ========================================
		!! ==== Added by Liaofan on 2019.02.18 =====================================
		!!	rn190218
		!if (nproc == 0) print *,'  ======================================================================'
		!if (nproc == 0) print *,"  (enkf.f90) After computing obganl"
		!if (nproc == 0) print *,'     deterministic = ',deterministic
		!if (nproc == 0) print *,'     anal_obtmp    = ',anal_obtmp
		!if (nproc == 0) print *,'     hpfhtoberrinv = ',hpfhtoberrinv
		!if (nproc == 0) print *,'     oberrvaruse   = ',oberrvaruse
		!if (nproc == 0) print *,'     obganl        = ',obganl
		!if (nproc == 0) print *,'  ============================================ liaofan at 2019.02.18==='
		!if (nproc == 0) print *,'  '
		!! =========================================================================  



      t3 = t3 + mpi_wtime() - t1
      t1 = mpi_wtime()

      if (covl_minfact < 0.99) then
			! modify localization based on HPaHT/HPbHT
         covl_fact = 1. - exp( -((1.-paoverpb_save(nob))/covl_efold) )
         if (covl_fact .lt. covl_minfact) covl_fact = covl_minfact
         corrlengthsq(nob) = (covl_fact*sqrt(corrlengthsq_orig(nob)))**2
         lnsigl(nob) = covl_fact*lnsigl_orig(nob)
      endif

		!! ==== Commented out on 2019.03.19 ========================================
		!! ==== Added by Liaofan on 2019.02.18 =====================================
		!if (nproc == 0) print *,'  ======================================================================'
		!if (nproc == 0) print *,"  (enkf.f90) After 'if (covl_minfact < 0.99) then'"
		!if (nproc == 0) print *,'     covl_minfact = ',covl_minfact
		!if (nproc == 0) print *,'     -----------------------------'
		!if (nproc == 0) print *,'     Note (2019.02.18): In a case (chpc 190201; case 02), covl_minfact=1'
		!if (nproc == 0) print *,'  ============================================ liaofan at 2019.02.18==='
		!if (nproc == 0) print *,'  '
		!! =========================================================================  

		lnsiglinv = one/lnsigl(nob)
		corrsqr = corrlengthsq(nob)
		corrlengthinv = one/corrlengthsq(nob)
		obtimelinv =  one/obtimel(nob)
		hpfhtcon = hpfhtoberrinv*r_nanalsm1

		!! ==== Commented out on 2019.03.19 ========================================
		!! ==== Added by Liaofan on 2019.02.18 =====================================
		!!	rn190218
		!if (nproc == 0) print *,'  ======================================================================'
		!if (nproc == 0) print *,"  (enkf.f90) After the above calculation"
		!if (nproc == 0) print *,'     lnsigl        = ',lnsigl
		!if (nproc == 0) print *,'     lnsiglinv     = ',lnsiglinv
		!if (nproc == 0) print *,'     corrlengthsq  = ',corrlengthsq
		!if (nproc == 0) print *,'     corrsqr       = ',corrsqr
		!if (nproc == 0) print *,'     corrlengthinv = ',corrlengthinv
		!if (nproc == 0) print *,'     obtimel       = ',obtimel
		!if (nproc == 0) print *,'     r_nanalsm1    = ',r_nanalsm1
		!if (nproc == 0) print *,'     hpfhtoberrinv = ',hpfhtoberrinv
		!if (nproc == 0) print *,'     hpfhtcon      = ',hpfhtcon
		!if (nproc == 0) print *,'  ============================================ liaofan at 2019.02.18 ==='
		!if (nproc == 0) print *,'  '
		!! =========================================================================  

		!! ==== Commented out on 2019.03.19 ========================================
		!! ==== Added by Liaofan on 2019.02.19 =====================================
		!if (nproc == 0) print *,'  ======================================================================'
		!if (nproc == 0) print *,"  (enkf.f90) Before computing nf2, sresults1"
		!if (nproc == 0) print *,'     lastiter            = ',lastiter
		!if (nproc == 0) print *,'     lupd_obspace_serial = ',lupd_obspace_serial
		!if (nproc == 0) print *,'     kdgrid              = ',kdgrid
		!if (nproc == 0) print *,'     numptsperproc       = ',numptsperproc
		!if (nproc == 0) print *,'     nob                 = ',nob
		!if (nproc == 0) print *,'     ---------------------------'
		!if (nproc == 0) print *,'     Note (2019.02.19): In CHPC 190201 Case 04: lastiter = T, '
		!if (nproc == 0) print *,'        lupd_obspace_serial = F, and kdgrid = T'
		!if (nproc == 0) print *,'  ============================================ liaofan at 2019.02.19 ==='
		!if (nproc == 0) print *,'  '
		!! =========================================================================  		
		
		! Note (2019.02.19): The following process is computed for my case (CHPC 190201 Case 04)
		! ==================================================================
		! Only need to recalculate nearest points when lat/lon is different
		! ==================================================================
      if(nobx == 1 .or. &
         abs(obloclat(nob)-obloclat(nobm)) .gt. tiny(obloclat(nob)) .or. &
         abs(obloclon(nob)-obloclon(nobm)) .gt. tiny(obloclon(nob)) .or. &
         abs(corrlengthsq(nob)-corrlengthsq(nobm)) .gt. tiny(corrlengthsq(nob))) then
			
			nobm=nob
			
			! determine localization length scales based on latitude of ob.
			nf2=0
			
			if (lastiter .and. .not. lupd_obspace_serial) then
				! search analysis grid points for those within corrlength of 
				! ob being assimilated (using a kd-tree for speed).
				if (kdgrid) then
					
					
					! ==== Added by Liaofan on 2019.02.18 =====================================
					! 	note (2019.02.19): in my case, CHPC 190201 Case 04, it shows that
					!		- lastiter = T
					!		- lupd_obspace_serial = F
					!		- kdgrid = F
					!		The following subroutine is computed!!!
					! =========================================================================  
					! ==== Added by Liaofan on 2019.02.19 =====================================
					! 	- Note (2019.02.18): The following is revised by me to add one more 
					!	  argument.  See subroutine kdtree2_r_nearest in kdtree2.f90 for details
					call kdtree2_r_nearest(tp=kdtree_grid,qv=obloc(:,nob),r2=corrsqr,&
						nfound=nf2,nalloc=numptsperproc(nproc+1),results=sresults1,nprocsub=nproc)					
					!call kdtree2_r_nearest(tp=kdtree_grid,qv=obloc(:,nob),r2=corrsqr,&
					!	nfound=nf2,nalloc=numptsperproc(nproc+1),results=sresults1) ! original
					! ========================================================================= 	
					
					!! ==== Commented out on 2019.03.19 ========================================
					!! ==== Added by Liaofan on 2019.02.19 =====================================
					!!	rn190218
					!if (nproc == 0) print *,'  ======================================================================'
					!if (nproc == 0) print *,"  (enkf.f90) After calling kdtree2_r_nearest: Part I"
					!if (nproc == 0) print *,'     kdtree_grid%dimen     = ',kdtree_grid%dimen
					!if (nproc == 0) print *,'     kdtree_grid%n         = ',kdtree_grid%n				
					!if (nproc == 0) print *,'     kdtree_grid%sort      = ',kdtree_grid%sort
					!if (nproc == 0) print *,'     kdtree_grid%rearrange = ',kdtree_grid%rearrange					
					!if (nproc == 0) print *,'     All dim of kdtree_grid%the_data        = ',size(kdtree_grid%the_data)
					!if (nproc == 0) print *,'     1st dim of kdtree_grid%the_data        = ',size(kdtree_grid%the_data,1)
					!if (nproc == 0) print *,'     2nd dim of kdtree_grid%the_data        = ',size(kdtree_grid%the_data,2)
					!if (nproc == 0) print *,'     All dim of kdtree_grid%rearranged_data = ',size(kdtree_grid%rearranged_data)
					!if (nproc == 0) print *,'     1st dim of kdtree_grid%rearranged_data = ',size(kdtree_grid%rearranged_data,1)
					!if (nproc == 0) print *,'     2nd dim of kdtree_grid%rearranged_data = ',size(kdtree_grid%rearranged_data,2)
					!if (nproc == 0) print *,'  ============================================ liaofan at 2019.02.19 ==='
					!if (nproc == 0) print *,'  '
					!
					!if (nproc == 0) print *,'  ======================================================================'
					!if (nproc == 0) print *,"  (enkf.f90) After calling kdtree2_r_nearest: Part II"
					!if (nproc == 0) print *,'     kdtree_grid%ind = ',kdtree_grid%ind					
					!if (nproc == 0) print *,'     -------------------------------------'		
					!if (nproc == 0) print *,'     kdtree_grid%the_data = ',kdtree_grid%the_data
					!if (nproc == 0) print *,'     -------------------------------------'		
					!if (nproc == 0) print *,'     kdtree_grid%rearranged_data = ',kdtree_grid%rearranged_data
					!if (nproc == 0) print *,'  ============================================ liaofan at 2019.02.19 ==='
					!if (nproc == 0) print *,'  '
					!
					!if (nproc == 0) print *,'  ======================================================================'
					!if (nproc == 0) print *,"  (enkf.f90) After calling kdtree2_r_nearest: PART III"
					!if (nproc == 0) print *,'     obloc         = ',obloc
					!if (nproc == 0) print *,'     corrsqr       = ',corrsqr
					!if (nproc == 0) print *,'     nf2           = ',nf2
					!if (nproc == 0) print *,'     numptsperproc = ',numptsperproc
					!if (nproc == 0) print *,'     sresults1     = ',sresults1
					!if (nproc == 0) print *,'  ============================================ liaofan at 2019.02.19 ==='
					!if (nproc == 0) print *,'  '
					!! =========================================================================  	
						
				else
					! use brute force search if number of grid points on this proc <= 3
					do npt=1,numptsperproc(nproc+1)
						
						r = sum( (obloc(:,nob)-grdloc_chunk(:,npt))**2, 1 )
					
						if (r < corrsqr) then
	                  nf2 = nf2 + 1
	                  sresults1(nf2)%idx = npt
	                  sresults1(nf2)%dis = r
						end if
					     
					end do
				end if
			end if
			
			!! ==== Commented out on 2019.03.19 ========================================
			!! ==== Added by Liaofan on 2018.09.12 =====================================
			!if (nproc == 0) print *,'	======================================================================'
			!if (nproc == 0) print *,"	(enkf.f90) After computing nf2.  This is for determining localization"
			!if (nproc == 0) print *,"	length scales based on latitude of ob."
			!if (nproc == 0) print *,'		nf2   = ',nf2
			!if (nproc == 0) print *,'		kdobs = ',kdobs
			!if (nproc == 0) print *,'	============================================ liaofan at 2018.09.12 ==='
			!! =========================================================================  
			do nob1=1,nf2
				dist = sqrt(sresults1(nob1)%dis*corrlengthinv)
				taper_disgrd(nob1) = taper(dist)
			end do

			! search ob priors for those within corrlength of the ob
			! being assimilated (using a kd-tree for speed).
			nf = 0
			
			if (kdobs) then
				! ==== Added by Liaofan on 2019.02.19 =====================================
				! 	- Note (2019.02.18): The following is revised by me to add one more 
				!	  argument.  See subroutine kdtree2_r_nearest in kdtree2.f90 for details
				call kdtree2_r_nearest(tp=kdtree_obs,qv=obloc(:,nob),r2=corrsqr,&
				     nfound=nf,nalloc=numobsperproc(nproc+1),results=sresults2,nprocsub=nproc)
				!call kdtree2_r_nearest(tp=kdtree_obs,qv=obloc(:,nob),r2=corrsqr,&
				!     nfound=nf,nalloc=numobsperproc(nproc+1),results=sresults2) ! original
				! ========================================================================= 	  
			else
				! use brute force search if number of obs on this proc <= 3
				do nob1=1,numobsperproc(nproc+1)
				   r = sum( (obloc(:,nob)-obloc_chunk(:,nob1))**2, 1 )
				   if (r < corrsqr) then
				       nf = nf + 1
				       sresults2(nf)%idx = nob1
				       sresults2(nf)%dis = r
				   end if     
				end do
			end if
			
			do nob1=1,nf
				! ozone obs only affect ozone (if univaroz is .true.).
				nob2 = sresults2(nob1)%idx
				
				if (univaroz .and. obtype(nob)(1:3) .eq. ' oz' .and. obtype(indxproc_obs(nproc+1,nob2))(1:3) .ne. ' oz') then
					taper_disob(nob1) = zero
				else
					dist = sqrt(sresults2(nob1)%dis*corrlengthinv)
					taper_disob(nob1) = taper(dist)
				endif
			end do
		else
			nsame=nsame+1
      end if

  
      t4 = t4 + mpi_wtime() - t1
      t1 = mpi_wtime()

      ! only need to update state variables on last iteration.
      if (univaroz .and. obtype(nob)(1:3) .eq. ' oz' .and. nvars .ge. nvarozone) then ! ozone obs only affect ozone
          nn1 = (nvarozone-1)*nlevs+1
          nn2 = nvarozone*nlevs
      else
          nn1 = 1
          nn2 = ndim
      end if
	
		!! === Commented out on 2019.03.19 ==========================================
		!! === Commented on 2018.09.27 ==============================================
		!!	rn190225
		!if (nproc == 0) print *,'	======================================================================'
		!if (nproc == 0) print *,"	(enkf.f90) Before 'if (nf2 > 0) then'"
		!if (nproc == 0) print *,'		nn1	       = ',nn1
		!if (nproc == 0) print *,'		nn2	       = ',nn2
		!if (nproc == 0) print *,'		nbackgrounds = ',nbackgrounds
		!if (nproc == 0) print *,'		nlevs_pres   = ',nlevs_pres
		!if (nproc == 0) print *,'		nf2          = ',nf2
		!if (nproc == 0) print *,'	============================================ liaofan at 2018.09.12 ==='	
		!! ==============================================================================
		
		! Commented out by liaofan on 2019.02.27
		!! ======= Added by liaofan on 2019.02.20 ============================================
		!!	rn190224, rn190225
		!if (nproc == 0) then
		!	
		!	do ii = 1,size(anal_chunk,2)
		!		do nb = 1,nbackgrounds
		!			do nn = nn1,nn2
		!						
		!				! Prepare the file name based on ii
		!				if (ii<10) then
		!					write(filename02,"(A,I1)") '00',ii
		!				else if (ii<100) then
		!					write(filename02,"(A,I2)") '0',ii
		!				else
		!					write(filename02,"(I3)") ii
		!				end if  
	   !
		!				! Prepare the file name based on nn
		!				if (nn<10) then
		!					write(filename03,"(A,I1)") '00',nn
		!				else if (nn<100) then
		!					write(filename03,"(A,I2)") '0',nn
		!				else
		!					write(filename03,"(I3)") nn
		!				end if  
		!				
		!				! Open the file
		!				open(unit=54,file='liaofan_ENKF_anal_chunk_plus_ensmean_chunk_ENKF01_nproc_00_ii_'//trim(filename02)//'_nn_'//trim(filename03)//'.txt')
		!	
		!				! Save the data
		!				write(54,*) anal_chunk(:,ii,nn,nb)+ensmean_chunk(ii,nn,nb)
		!		
		!				! Close the file
		!				close(54)
		!				
		!			end do
		!		end do
		!	end do
		!end if
		!! ===================================================================================


		
      if (nf2 > 0) then
			!$omp parallel do schedule(dynamic,1) private(ii,i,nb,obt,nn,nnn,lnsig,kfgain,taper1,taperv)
			do ii = 1,nf2 ! loop over nearby horiz grid points
				do nb = 1,nbackgrounds ! loop over background time levels
					
					obt = abs(obtime(nob)-(nhr_anal(nb)-fhr_assim))
					taper3=taper(obt*obtimelinv)*hpfhtcon
					taper1=taper_disgrd(ii)*taper3
					i = sresults1(ii)%idx
					
					do nn=1,nlevs_pres
						lnsig = abs(lnp_chunk(i,nn)-oblnp(nob))
						if(lnsig < lnsigl(nob))then
							taperv(nn)=taper1*taper(lnsig*lnsiglinv)
						else
							taperv(nn)=-2._r_single      ! negative number is a flag to not use
						end if
					end do

					! ======= Added by liaofan on 2018.09.12 ============================================
					if (nproc == 0) then
						
						! Prepare the file name
						if (ii<10) then
							write(filename,"(A,I1)") '00',ii
						else if (ii<100) then
							write(filename,"(A,I2)") '0',ii
						else
							write(filename,"(I3)") ii
						end if  
					
						! Open the file
						open(unit=53,file='liaofan_ENKF_taperv_nf2_'//trim(filename)//'.txt')
						
						! Save the data
						do iiii=1,nlevs_pres
							write(53,*) taperv(iiii)
						enddo
							
						! Close the file
						close(53)
						
					end if
					! ===================================================================================
								
					!if (nproc == 0) print *,'	======================================================================'
					!if (nproc == 0) print *,"	(enkf.f90) After computing taperv.  taperv is"
					!if (nproc == 0) print *,'		',taperv
					!if (nproc == 0) print *,'	============================================ liaofan at 2018.09.12 ==='	
					
					!!! === Commentted out on 2019.03.19 =========================================		
					!! === Commented on 2019.02.20 ==============================================
					!!	rn190224
					!if (nproc == 0 .and. ii==1) print *,'	======================================================================'
					!if (nproc == 0 .and. ii==1) print *,"	(enkf.f90) Before computing kfgain, ensmean_chunk, and anal_chunk"
					!if (nproc == 0 .and. ii==1) print *,'		nproc = ',nproc
					!if (nproc == 0 .and. ii==1) print *,'		ii    = ',ii
					!if (nproc == 0 .and. ii==1) print *,'		All dim of anal_chunk = ',size(anal_chunk)
					!if (nproc == 0 .and. ii==1) print *,'		1st dim of anal_chunk = ',size(anal_chunk,1)
					!if (nproc == 0 .and. ii==1) print *,'		2nd dim of anal_chunk = ',size(anal_chunk,2)
					!if (nproc == 0 .and. ii==1) print *,'		3rd dim of anal_chunk = ',size(anal_chunk,3)
					!if (nproc == 0 .and. ii==1) print *,'		4th dim of anal_chunk = ',size(anal_chunk,4)
					!if (nproc == 0 .and. ii==1) print *,'	============================================ liaofan at 2019.02.20 ==='
					!if (nproc == 0 .and. ii==1) print *,'  '
					!! ==============================================================================
					
					do nn=nn1,nn2
						nnn=index_pres(nn)
						if (taperv(nnn) > zero) then
							! gain includes covariance localization.
							! update all time levels
							kfgain=taperv(nnn)*sum(anal_chunk(:,i,nn,nb)*anal_obtmp)
													
							!! === Commentted out on 2019.03.19 =========================================						
							!! === Commented on 2019.02.22 ==============================================
							!!	rn190224, rn190225
							!if (nproc == 0 .and. ii==1) print *,'	======================================================================'
							!if (nproc == 0 .and. ii==1) print *,"	(enkf.f90) Before updating ensmean_chunk"
							!if (nproc == 0 .and. ii==1) print *,"	   -> ensmean_chunk(i,nn,nb) = ensmean_chunk(i,nn,nb) + kfgain*obinc_tmp"
							!if (nproc == 0 .and. ii==1) print *,'		nproc                  = ',nproc
							!if (nproc == 0 .and. ii==1) print *,'		ii                     = ',ii
							!if (nproc == 0 .and. ii==1) print *,'		i                      = ',i
							!if (nproc == 0 .and. ii==1) print *,'		nn                     = ',nn
							!if (nproc == 0 .and. ii==1) print *,'		kfgain                 = ',kfgain
							!if (nproc == 0 .and. ii==1) print *,'		obganl                 = ',obganl
							!if (nproc == 0 .and. ii==1) print *,'		anal_obtmp             = ',anal_obtmp
							!if (nproc == 0 .and. ii==1) print *,'		obinc_tmp              = ',obinc_tmp
							!if (nproc == 0 .and. ii==1) print *,'		ensmean_chunk(i,nn,nb) = ',ensmean_chunk(i,nn,nb)
							!if (nproc == 0 .and. ii==1) print *,'	------------------------------------------------------------'
							!! ==============================================================================									
											
							! update mean.
							ensmean_chunk(i,nn,nb) = ensmean_chunk(i,nn,nb) + kfgain*obinc_tmp
							
							!! === Commentted out on 2019.03.19 =========================================		
							!! === Commented on 2019.02.22 ==============================================
							!!	rn190224, rn190225
							!if (nproc == 0 .and. ii==1) print *,"	(enkf.f90) Before updating anal_chunk"
							!if (nproc == 0 .and. ii==1) print *,"	   -> anal_chunk(:,i,nn,nb) = anal_chunk(:,i,nn,nb) + kfgain*obganl(:)"
							!if (nproc == 0 .and. ii==1) print *,'		ensmean_chunk(i,nn,nb) = ',ensmean_chunk(i,nn,nb)
							!if (nproc == 0 .and. ii==1) print *,'		kfgain                 = ',kfgain
							!if (nproc == 0 .and. ii==1) print *,'		obganl                 = ',obganl
							!if (nproc == 0 .and. ii==1) print *,'		anal_chunk(:,i,nn,nb)  = ',anal_chunk(:,i,nn,nb)
							!if (nproc == 0 .and. ii==1) print *,'	------------------------------------------------------------'
							!! ==============================================================================
														
							! update perturbations.
							anal_chunk(:,i,nn,nb) = anal_chunk(:,i,nn,nb) + kfgain*obganl(:)
							
							!!! === Commentted out on 2019.03.19 =========================================		
							!! === Commented on 2019.02.22 ==============================================
							!!	rn190224, rn190225
							!if (nproc == 0 .and. ii==1) print *,"	(enkf.f90) After updating anal_chunk"
							!if (nproc == 0 .and. ii==1) print *,'		anal_chunk(:,i,nn,nb) = ',anal_chunk(:,i,nn,nb)
							!if (nproc == 0 .and. ii==1) print *,'	============================================ liaofan at 2019.02.22 ==='
							!if (nproc == 0 .and. ii==1) print *,'  '
							!! ==============================================================================
						end if
					end do
					
				end do ! end loop over background time levels. 
			end do ! end loop over nearby horiz grid points
			!$omp end parallel do
      end if ! if .not. lastiter or no close grid points

		! Commented out by liaofan on 2019.02.27
		!! ======= Added by liaofan on 2019.02.20 ============================================
		!!	rn190224, rn190225
		!if (nproc == 0) then
		!	
		!	do ii = 1,size(anal_chunk,2)
		!		do nb = 1,nbackgrounds
		!			do nn = nn1,nn2
		!						
		!				! Prepare the file name based on ii
		!				if (ii<10) then
		!					write(filename02,"(A,I1)") '00',ii
		!				else if (ii<100) then
		!					write(filename02,"(A,I2)") '0',ii
		!				else
		!					write(filename02,"(I3)") ii
		!				end if  
	   !
		!				! Prepare the file name based on nn
		!				if (nn<10) then
		!					write(filename03,"(A,I1)") '00',nn
		!				else if (nn<100) then
		!					write(filename03,"(A,I2)") '0',nn
		!				else
		!					write(filename03,"(I3)") nn
		!				end if  
		!				
		!				! Open the file
		!				open(unit=55,file='liaofan_ENKF_anal_chunk_plus_ensmean_chunk_ENKF02_nproc_00_ii_'//trim(filename02)//'_nn_'//trim(filename03)//'.txt')
		!	
		!				! Save the data
		!				write(55,*) anal_chunk(:,ii,nn,nb)+ensmean_chunk(ii,nn,nb)
		!		
		!				! Close the file
		!				close(55)
		!				
		!			end do
		!		end do
		!	end do
		!end if
		!! ===================================================================================

      t5 = t5 + mpi_wtime() - t1
      t1 = mpi_wtime()
		
		!! === Commented out on 2019.03.19 ==========================================		
		!! === Commented on 2019.02.21 ==============================================
		!if (nproc == 0) print *,'	======================================================================'
		!if (nproc == 0) print *,"	(enkf.f90) Before computing kfgain, ensmean_chunk, and anal_chunk"
		!if (nproc == 0) print *,'		nf            = ',nf
		!if (nproc == 0) print *,'		sresults2%idx = ',sresults2%idx
		!if (nproc == 0) print *,'	============================================ liaofan at 2019.02.21 ==='	
		!if (nproc == 0) print *,'  '
		!! ==============================================================================
				


      if (nf > 0) then
			! find indices of 'close' obs.
			!$omp parallel do  schedule(dynamic,1) private(nob1,nob2,nob3,lnsig,obt,kfgain)
			do nob1=1,nf
				
				! Note: only really need to do obs that have not yet been processed unless sat data
				! for bias correction update.
				nob2 = sresults2(nob1)%idx
				lnsig = abs(oblnp(nob)-oblnp_chunk(nob2))

				!! === Commented out on 2019.03.19 ==========================================
				!! === Commented on 2019.02.22 ==============================================
				!if (nproc == 0) print *,'	======================================================================'
				!if (nproc == 0) print *,"	(enkf.f90) In site the do loop of nob1=1,nf"
				!if (nproc == 0) print *,'		lnsig       = ',lnsig
				!if (nproc == 0) print *,'		lnsigl      = ',lnsigl
				!if (nproc == 0) print *,'		taper_disob = ',taper_disob
				!
				!if (nproc == 0) print *,'	============================================ liaofan at 2019.02.22 ==='	
				!if (nproc == 0) print *,'  '
				!! ==============================================================================	
				
				if (lnsig < lnsigl(nob) .and. taper_disob(nob1) > zero) then
					obt = abs(obtime(nob)-obtime_chunk(nob2))
					
					if (obt < obtimel(nob)) then
					
						
	               ! gain includes covariance localization.
	               kfgain = taper_disob(nob1)* &
                     taper(lnsig*lnsiglinv)*taper(obt*obtimelinv)* &
                     sum(anal_obchunk(:,nob2)*anal_obtmp)*hpfhtcon
							
						! update mean.
						ensmean_obchunk(nob2) = ensmean_obchunk(nob2) + kfgain*obinc_tmp

						!! === Commented out on 2019.03.19 ==========================================
						!! === Commented on 2019.02.22 ==============================================
						!if (nproc == 0) print *,'	======================================================================'
						!if (nproc == 0) print *,"	(enkf.f90) Before updating anal_obchunk"
						!if (nproc == 0) print *,"	   -> 'anal_obchunk(:,nob2) = anal_obchunk(:,nob2) + kfgain*obganl'"
						!if (nproc == 0) print *,'		All dim of anal_obchunk = ',size(anal_obchunk)
						!if (nproc == 0) print *,'		nob2                    = ',nob2
						!if (nproc == 0) print *,'		anal_obchunk(:,nob2)    = ',anal_obchunk(:,nob2)
						!if (nproc == 0) print *,'	============================================ liaofan at 2019.02.22 ==='	
						!if (nproc == 0) print *,'  '
						!! ==============================================================================	
						
						! update perturbations.
						anal_obchunk(:,nob2) = anal_obchunk(:,nob2) + kfgain*obganl
						nob3 = indxproc_obs(nproc+1,nob2) ! index in 1,....,nobstot

						!! === Commented out on 2019.03.19 ==========================================
						!! === Commented on 2019.02.22 ==============================================
						!if (nproc == 0) print *,'	======================================================================'
						!if (nproc == 0) print *,"	(enkf.f90) After updating anal_obchunk"
						!if (nproc == 0) print *,"	   -> 'anal_obchunk(:,nob2) = anal_obchunk(:,nob2) + kfgain*obganl'"
						!if (nproc == 0) print *,'		anal_obchunk(:,nob2) = ',anal_obchunk(:,nob2)
						!if (nproc == 0) print *,'		kfgain               = ',kfgain
						!if (nproc == 0) print *,'		obganl               = ',obganl
						!if (nproc == 0) print *,'	============================================ liaofan at 2019.02.22 ==='	
						!if (nproc == 0) print *,'  '
						!! ==============================================================================	
												
						! recompute ob space spread ratio  for unassimlated obs
						if (iassim_order == 2 .and. niter == 1) then
							if (indxassim2(nob3) /= 0) then
								paoverpb_chunk(nob2) = &
								oberrvar(nob3)/(oberrvar(nob3)+&
								sum(anal_obchunk(:,nob2)**2)*r_nanalsm1)
							else
								paoverpb_chunk(nob2) = 1.e10
							endif
						endif
						
					end if
				end if
			end do
			!$omp end parallel do

		

		end if ! no close obs.

      t6 = t6 + mpi_wtime() - t1
      ncount = ncount + 1

	end do obsloop ! loop over obs to assimilate


	! make sure posterior perturbations still have zero mean.
	! (roundoff errors can accumulate)
	if (lastiter .and. .not. lupd_obspace_serial) then
		!$omp parallel do schedule(dynamic) private(npt,nb,i)
		do npt=1,npts_max
			do nb=1,nbackgrounds
				do i=1,ndim
				   anal_chunk(1:nanals,npt,i,nb) = anal_chunk(1:nanals,npt,i,nb)-&
				   sum(anal_chunk(1:nanals,npt,i,nb),1)*r_nanals
				end do
			end do
		enddo
		!$omp end parallel do
	endif
	
	!$omp parallel do schedule(dynamic) private(nob)
	do nob=1,nobs_max
		anal_obchunk(1:nanals,nob) = anal_obchunk(1:nanals,nob)-&
		sum(anal_obchunk(1:nanals,nob),1)*r_nanals
	enddo
	!$omp end parallel do

	tend = mpi_wtime()
	
	if (nproc .eq. 0) then
		
      write(6,8003) niter,'timing on proc',nproc,' = ',tend-tbegin,t2,t3,t4,t5,t6,nrej

      nuse = 0; covl_fact = 0.
      do nob1=1,ncount
         nob = indxassim(nob1)
         if (iskip(nob) .ne. 1) then
            covl_fact = covl_fact + sqrt(corrlengthsq(nob)/corrlengthsq_orig(nob))
            nuse = nuse + 1
         endif
      enddo
      nskip = nobstot-nuse
      covl_fact = covl_fact/float(nuse)

      if (covl_fact < 0.99) print *,'mean covl_fact = ',covl_fact
      if (nskip > 0) print *,nskip,' out of',nobstot,'obs skipped,',nuse,' used'
      if (nsame > 0) print *,nsame,' out of', nobstot-nskip,' same lat/long'
      if (nrej >  0) print *,nrej,' obs rejected by varqc'
	endif
	8003  format(i2,1x,a14,1x,i5,1x,a3,6(f7.2,1x),i4)

	t1 = mpi_wtime()
	
	! distribute the O-A, HPaHT stats to all processors.
	buffertmp=zero
	do nob1=1,numobsperproc(nproc+1)
		nob2=indxproc_obs(nproc+1,nob1)
		buffertmp(nob2) = ensmean_obchunk(nob1)
	end do
	call mpi_allreduce(buffertmp,obfit_post,nobstot,mpi_real4,mpi_sum,mpi_comm_world,ierr)
	obfit_post = ob - obfit_post
	
	if (nproc == 0) print *,'time to broadcast obfit_post = ',mpi_wtime()-t1,' secs, niter =',niter
	! buffertmp=zero
	! do nob1=1,numobsperproc(nproc+1)
	!   nob2=indxproc_obs(nproc+1,nob1)
	!   buffertmp(nob2) = sum(anal_obchunk(:,nob1)**2)*r_nanalsm1
	! end do
	! call mpi_allreduce(buffertmp,obsprd_post,nobstot,mpi_real4,mpi_sum,mpi_comm_world,ierr)
	! if (nproc == 0) print *,'time to broadcast obfit_post,obsprd_post = ',mpi_wtime()-t1,' secs, niter =',niter
	! if (nproc == 0) then
	!    print *,'innovation statistics for posterior:'
	!    call print_innovstats(obfit_post, obsprd_post)
	! end if

	! satellite bias correction update.
	if (nobs_sat > 0 .and. lupd_satbiasc) call update_biascorr(niter)

enddo ! niter loop

! distribute the HPaHT stats to all processors.
t1 = mpi_wtime()
buffertmp=zero
do nob1=1,numobsperproc(nproc+1)
	nob2=indxproc_obs(nproc+1,nob1)
	buffertmp(nob2) = sum(anal_obchunk(:,nob1)**2)*r_nanalsm1
end do

call mpi_allreduce(buffertmp,obsprd_post,nobstot,mpi_real4,mpi_sum,mpi_comm_world,ierr)
if (nproc == 0) print *,'time to broadcast obsprd_post = ',mpi_wtime()-t1

predx = predx + deltapredx ! add increment to bias coeffs.
deltapredx = 0.0 

! free local temporary arrays.
deallocate(taper_disob,taper_disgrd)
! these allocated in loadbal, no longer needed
deallocate(anal_obchunk); deallocate(anal_obchunk_prior)
deallocate(sresults1,sresults2)
deallocate(indxassim,buffertmp)
if (iassim_order == 2) then
   deallocate(paoverpb_chunk)
   deallocate(indxassim2,indxassim3)
   deallocate(paoverpb_min,paoverpb_min1)
endif
deallocate(paoverpb_save)
deallocate(corrlengthsq_orig,lnsigl_orig)

end subroutine enkf_update

end module enkf
