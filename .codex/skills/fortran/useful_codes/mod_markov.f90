module mod_markov
    
!##### DESCRIPTION #############
! This module contains routines to simulate Markov process
! The core functions are *simul_iid* and *sample_pmf_fast*
! They serve the same purpose: simulate a random draw from
! a discrete probability distribution, given by vector pi
! Speed considerations:
! use simul_iid       if size(pi)<80
! use sample_pmf_fast if size(pi)>=80
! Note: of course the exact threshold depends on the computer
    
implicit none

private
public :: simul_iid, sample_pmf_fast
public :: markov_simul, markov_simul_agedep, markov_stationary_dist
    
    
contains
 
    
subroutine myerror(message)
    implicit none
    character(len=*), intent(in) :: message

    write(*,*) "ERROR: ", message
    write(*,*) "Program will terminate.."
    pause 
    stop 

end subroutine myerror

FUNCTION cumsum(arr) RESULT(ans)
    ! Purpose: it replicates matlab cumsum function
    real(8), INTENT(IN) :: arr(:)
    ! Note that a Fortran function can return a value with an ALLOCATABLE
    ! attribute. The function result must be declared as ALLOCATABLE
    ! in the calling unit but will not be allocated on entry to the function.
    real(8), allocatable :: ans(:)
    INTEGER :: n,j

    n=size(arr)

    allocate(ans(n))
    ans(1)=arr(1)

    do j=2,n
	    ans(j)=ans(j-1)+arr(j)
    end do
	
END FUNCTION cumsum
!=======================================================================!

PURE FUNCTION locate(xx,x)
	IMPLICIT NONE
	REAL(8), DIMENSION(:), INTENT(IN) :: xx
	REAL(8), INTENT(IN) :: x
	INTEGER :: locate
	INTEGER :: n,il,im,iu
	n=size(xx)
	il=0
	iu=n+1
	do
		if (iu-il <= 1) exit
		im=(iu+il)/2
		if (x >= xx(im)) then
			il=im
		else
			iu=im
		end if
	end do
	if (x == xx(1)) then
		locate=1
	else if (x == xx(n)) then
		locate=n-1
	else
		locate=il
	end if
END FUNCTION locate
!=======================================================================!
    
function simul_iid(z_prob,dbg) result(ind_sim)
    implicit none
    
    !##### DESCRIPTION #############
    !Simulate a random draw from a discretized distribution 
    ! Note: this is fast if the size of z_prob is small
    ! When z_prob is large (say, more than 100 elements), sample_pmf is faster
    
    !##### INPUTS/OUTPUTS #############
    real(8), intent(in) :: z_prob(:) !discretized prob vector, must be >=0 and sum to 1
    integer, intent(in) :: dbg       !0-1 flag
    integer :: ind_sim               !index for the draw
    
    !##### LOCALS #############
    integer :: n, i
    real(8) :: u ! random number (a scalar)
    real(8) :: check, prob_sum
    
    !##### ROUTINE CODE #############
    n = size(z_prob)
    
    if (dbg==1) then
        if ( any(z_prob<0d0) .or. any(z_prob>1d0) ) then
            call myerror("simul_iid: 0<=prob<=1 violated")
        endif
        check = sum(z_prob)
        if (abs(check-1d0)>1d-6) then
            call myerror("simul_iid: prob does not sum to one")
        endif
    endif
    
    call RANDOM_NUMBER(u)

    do i = 1,n-1
        !Cumulative sum p1+p2+..+pi
        prob_sum = sum(z_prob(1:i))
        if (u <= prob_sum ) then
            ind_sim = i
            return
        endif !END IF
    enddo !end for

    ! Else, choose the last value
    ind_sim = n
    
end function simul_iid

function sample_pmf_fast(pi) result(F)
        implicit none
        ! PURPOSE:
        ! Draw random number from probability mass function
        ! described in vector pi, where sum(pi)=1 (not necessary).
        ! ! Note: this is fast if the size of z_prob is large
        ! When z_prob is small (say, less than 100 elements), simul_iid is faster
        ! Declare inputs:
        real(8), intent(in) :: pi(:)
        ! Declare function result:
        integer :: F
        ! Local variables
        real(8) :: rand ! random number (a scalar)
        real(8) :: pi_norm(size(pi)), pi_cdist(size(pi))
        integer :: i1,i
        !--------------------------------------------------------!
     		
     	! normalize pi so that the sum is equal to 1	
     	pi_norm = pi/sum(pi)

        ! Cumulative 
        !pi_cdist = cumsum(pi_norm)
        pi_cdist(1) = pi_norm(1)
        do i = 2,size(pi_norm)
            pi_cdist(i) = pi_cdist(i-1) + pi_norm(i)
        enddo
        
        ! Draw random number 
        call RANDOM_NUMBER(rand)
        
        F = locate(pi_cdist,rand)+1
        
        !if (F<1 .or. F>size(pi)) then
        !    call myerror("sample_pmf_fast: result is out of bounds")
        !endif
        
     
end function sample_pmf_fast    

function sample_pmf_fast_old(pi,rand) result(F)
        implicit none
        ! PURPOSE:
        ! Draw random number from probability mass function
        ! described in vector pi, where sum(pi)=1 (not necessary).
        ! It requires a random uniform number as input.
        ! Declare inputs:
        real(8), intent(in) :: pi(:)
     	real(8),intent(in) :: rand
        ! Declare function result:
        integer :: F
        ! Local variables
        real(8) :: pi_norm(size(pi)), pi_cdist(size(pi))
        integer :: i1
        !--------------------------------------------------------!
     		
     	! normalize pi so that the sum is equal to 1	
     	pi_norm = pi/sum(pi)

        ! Cumulative 
        pi_cdist = cumsum(pi_norm)
        
        F = locate(pi_cdist,rand)+1
        
        if (F<1 .or. F>size(pi)) then
            call myerror("sample_pmf_fast: result is out of bounds")
        endif
        
     
end function sample_pmf_fast_old

subroutine markov_simul(ysim,Ptran,Tsim,y1,dbg_in)
    implicit none
    
    !##### DESCRIPTION #############
    ! Routine for simulating a Markov chain with time-independent
    ! transition matrix (standard case). To increase speed, set
    ! the debug flag to zero.
    ! This subroutine calls the function simulate_iid.
    
     !##### INPUTS/OUTPUTS #############
    real(8), intent(in)  :: Ptran(:,:) ! Transition matrix, dim: (ns,ns)
    integer, intent(in)  :: Tsim       ! Lenght of the time series to simulate
    integer, intent(in)  :: y1         ! Initial condition 
    integer, intent(out) :: ysim(:)    ! Simulated time series s.t. y_sim(1)=y1, dim: (Tsim)
    integer, intent(in),optional :: dbg_in ! 0-1 debug flag
    
    !##### LOCALS #############
    integer :: n, i, ns, t, dbg
    real(8) :: check, prob_sum
    real(8), allocatable :: row_sum(:)
    
    !##### ROUTINE CODE #############
    if (present(dbg_in)) then
        dbg = dbg_in
    else
        dbg = 0
    endif
    
    ns = size(Ptran,dim=1)
    
    ! Check if inputs are correct (only if debug flag = 1)
    if (dbg==1) then
        if (size(Ptran,1)/=size(Ptran,2)) then
            call myerror("markov_simul: Ptran is not square")
        endif
        if ( any(Ptran<0d0) .or. any(Ptran>1d0) ) then
            call myerror("markov_simul: 0<=prob<=1 violated")
        endif
        row_sum = sum(Ptran,dim=2)
        if (maxval(abs(row_sum-1d0)) > 1d-6) then
            call myerror("markov_simul: Rows of Ptran do not sum to one")
        endif
        if (Tsim < 2) then
            call myerror("markov_simul: Tsim must be at least 2")
        endif
        if ( y1<1 .or. y1>ns) then
            call myerror("markov_simul: initial condition is out of bounds")
        endif
        if ( size(ysim)/=Tsim ) then
            call myerror("markov_simul: ysim has wrong size")
        endif
    endif
    
    ! Simulate series of length Tsim
    ysim(1) = y1
    
    do t = 1,Tsim-1
        ysim(t+1) = simul_iid(Ptran(ysim(t),:),dbg)    
    enddo
    
    
end subroutine markov_simul

subroutine markov_simul_agedep(ysim,Ptran,Tsim,y1,dbg_in)
    implicit none
    
    !##### DESCRIPTION #############
    ! Routine for simulating a Markov chain with time-dependent
    ! transition matrix. 
    ! This subroutine calls the function simulate_iid.
    
     !##### INPUTS/OUTPUTS #############
    real(8), intent(in)  :: Ptran(:,:,:)    ! Transition matrix, dim: (ns,ns,T)
    integer, intent(in)  :: Tsim            ! Lenght of the time series to simulate (Tsim<=T)
    integer, intent(in)  :: y1              ! Initial condition 
    integer, intent(in), optional :: dbg_in ! 0-1 debug flag
    integer, intent(out) :: ysim(:)         ! Simulated time series s.t. y_sim(1)=y1, dim: (Tsim)
    
    !##### LOCALS #############
    integer :: n, i, ns, t, TT, dbg
    real(8), allocatable :: row_sum(:), mat(:,:)
    
    !##### ROUTINE CODE #############
    if (present(dbg_in)) then
        dbg = dbg_in
    else
        dbg = 0
    endif
    
    ns = size(Ptran,dim=1) ! No. of states in the Markov chain
    TT = size(Ptran,dim=3) ! No. of age periods in the Markov chain
    
    ! Check if inputs are correct (only if debug flag = 1)
    if (dbg==1) then
        if (size(Ptran,1)/=size(Ptran,2)) then
            call myerror("markov_simul_agedep: Ptran is not square")
        endif
        if ( any(Ptran<0d0) .or. any(Ptran>1d0) ) then
            call myerror("markov_simul_agedep: 0<=prob<=1 violated")
        endif
        do t = 1,size(Ptran,3)
            mat = Ptran(:,:,t)
            row_sum = sum(mat,dim=2)
            if (any(abs(row_sum-1d0)>1d-6)) then
                write(*,*) "Time t = ",t
                call myerror("markov_simul_agedep: Rows of Ptran do not sum to one")
            endif
        enddo
        if (Tsim < 2) then
            call myerror("markov_simul_agedep: Tsim must be at least 2")
        endif
        if ( y1<1 .or. y1>ns) then
            call myerror("markov_simul_agedep: initial condition is out of bounds")
        endif
        if (Tsim>TT) then
            call myerror("markov_simul_agedep: Condition Tsim<=TT violated")
        endif
        if ( size(ysim)/=Tsim ) then
            call myerror("markov_simul_agedep: ysim has wrong size")
        endif
    endif
    
    ! Simulate series of length Tsim
    ysim(1) = y1
    
    ! Note that it must be that Tsim-1<=TT
    do t = 1,Tsim-1
        ysim(t+1) = simul_iid(Ptran(ysim(t),:,t),dbg)    
    enddo
    
end subroutine markov_simul_agedep

subroutine markov_stationary_dist(stat_dist,Ptran,dbg_in)
    implicit none
    !##### DESCRIPTION #############
    ! Compute the stationary distribution associated to
    ! transition matrix Ptran. We assume the stat dist 
    ! exists and is unique.
    
     !##### INPUTS/OUTPUTS #############
    real(8), intent(in)  :: Ptran(:,:)       ! Transition matrix, dim: (ns,ns)
    integer, intent(in), optional  :: dbg_in ! 0-1 flag for debug
    real(8), intent(out) :: stat_dist(size(Ptran,1))
    
    !##### LOCALS #############
    integer :: ns, ii, dbg
    real(8), allocatable :: row_sum(:), prob(:)
    
    !##### ROUTINE CODE #############
    if (present(dbg_in)) then
        dbg = dbg_in
    else
        dbg = 0
    endif
    
    ! Check if inputs are correct (only if debug flag = 1)
    if (dbg==1) then
        if (size(Ptran,1)/=size(Ptran,2)) then
            call myerror("markov_simul: Ptran is not square")
        endif
        if ( any(Ptran<0d0) .or. any(Ptran>1d0) ) then
            call myerror("markov_simul: 0<=prob<=1 violated")
        endif
        row_sum = sum(Ptran,dim=2)
        if (maxval(abs(row_sum-1d0)) > 1d-6) then
            call myerror("markov_simul: Rows of Ptran do not sum to one")
        endif
    endif
    
    ns = size(Ptran,1)
    
    ! Initialize vector for invariant distribution
    allocate(prob(ns))
    prob = 1d0/dble(ns)
    
    ! Iterations
    do ii = 1,1000
        prob = matmul(prob,Ptran)
    enddo
    
    stat_dist = prob

end subroutine markov_stationary_dist


    
end module mod_markov
    