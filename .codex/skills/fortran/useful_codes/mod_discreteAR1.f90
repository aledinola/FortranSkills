! This module contains several ways to discretize an AR1 process
! -- sub_rouwenhorst
! -- sub_tauchen
! Additional, it provides a routine that will sample from an AR1 process.
! -- sub_drawAR1
module mod_discreteAR1
    use mod_types
    implicit none
contains

subroutine drawMarkovLifeCycle(ix,Fxpcxt,Fx0)
    implicit none
    real(rt), intent(in) :: Fxpcxt(:,:,:), Fx0(:)
    integer, intent(out) :: ix(:)
    ! local
    integer :: nx, it, nt

    nx = size(Fxpcxt,1)
    nt = size(ix)
    if (size(Fxpcxt,2)/=nx) stop 'ERROR: drawMarkovLifeCycle: input wrong dim'
    if (size(Fxpcxt,3)/=nt .and. size(Fxpcxt,3)/=nt-1) stop 'ERROR: drawMarkovLifeCycle: input wrong dim'
    if (size(Fx0)/=nx) stop 'ERROR: drawMarkovLifeCycle: input wrong dim'

    ! Get initial draw
    ix(1) = drawIid(Fx0,0) 

    ! Simulate the rest
    do it = 1,nt-1
        ix(it+1) = drawIid(Fxpcxt(:,ix(it),iT),0)
    end do
    

end subroutine

! Draw from the markov chain given current state i
! There are two options in this routine
! option == 0, slow but easy for user, F is the mdf
! option == 1, fast but involved for user, F is the cumulative summation transpose of the markov chain
! If u01 is present, then it is used as a random variable (o/w, one is drawn)
function drawIid(F,option,u01) result(izp)
    use mod_matlab, only: cumsum,find
    implicit none
    real(rt), dimension(1:), intent(in) :: F 
    integer, intent(in) :: option
    real(rt), optional, intent(in) :: u01
    integer :: izp
    ! local
    real(rt) :: randval
    real(rt), allocatable :: Ftmp(:)
    
    if (present(u01)) then
        randval = u01
    else
        call random_number(randval)
    end if

    if (option==0) then
        ! Slow: temporary created
        allocate(Ftmp(size(F)))
        Ftmp = cumsum(F)
        do izp = 1,size(F)
            if (randval<=Ftmp(izp)) return
        end do


    else
        ! Fast
        do izp = 1,size(F)
            if (randval<=F(izp)) return
        end do

    end if
    
    
end function drawIid

! Same as drawIid(F,iz) but takes randval as input
function drawIidcore(F,randval) result(izp_out)
    use mod_matlab, only: cumsum,bsearch
    implicit none
    real(rt), dimension(:), intent(in) :: F 
    integer :: izp_out
    real(rt), intent(in) :: randval 
    ! local
    integer :: izp
    
    ! Find the izp such that randval \in (F(izp-1,iZ),F(izp,iZ)]
    ! If randval<F(1), return 1
    ! If randval>F(n), then issue an error
    ! If randval\in (F(1),F(2)], return 2 
    ! If randval\in (F(i),F(i+1)], return i+1
    ! Note: bsearch finds the i such that randval \in (F(i),F(i+1)), so need to add 1
    if (randval<=F(1)) then
        izp = 1
    elseif (randval>=F(size(F,1))) then
        izp = size(F,1)
        print*,'WARNING: drawAR1: F must not sum to 1, simulation will be wrong'
    else
        call bsearch(izp,randval,F)
        izp = izp + 1
    end if

    izp_out = izp

end function

! drawAR1core(F,iz,randval) result(izp)
! Same as drawAR1(F,iz,option=1) but takes randval as input
function drawAR1core(F,iz,randval) result(izp_out)
    use mod_matlab, only: cumsum,bsearch
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: F ! Either the transition matrix or the cumulatively summed transpose 
    integer, intent(in) :: iz !, option
    integer :: izp_out
    real(rt), intent(in) :: randval 
    ! local
    integer :: izp
    
    ! Find the izp such that randval \in (F(izp-1,iZ),F(izp,iZ)]
    ! If randval<F(1), return 1
    ! If randval>F(n), then issue an error
    ! If randval\in (F(1),F(2)], return 2 
    ! If randval\in (F(i),F(i+1)], return i+1
    ! Note: bsearch finds the i such that randval \in (F(i),F(i+1)), so need to add 1
    if (randval<=F(1,iZ)) then
        izp = 1
    elseif (randval>=F(size(F,1),iZ)) then
        izp = size(F,1)
        print*,'WARNING: drawIidcore: F must not sum to 1, simulation will be wrong'
    else
        call bsearch(izp,randval,F(:,iZ))
        izp = izp + 1
    end if

    izp_out = izp

end function
! drawAR1(F,iz,option) result(izp)
! 
! Given iz, will generate izp according to a discrete markov chain.
! If option==0, the Markov chain is taken to be F.
! If option==1, the Markov chain is given implicitly and F is treated as the cumulatively
!               summed transpose of it (with the convention that the markov matrix has 
!               pi(i,j) with i being today and j being tomorrow. 
! 
function drawAR1(F,iz,option) result(izp_out)
    use mod_matlab, only: cumsum,bsearch
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: F ! Either the transition matrix or the cumulatively summed transpose 
    integer, intent(in) :: iz, option
    integer :: izp_out
    ! local
!     integer :: izp
    real(rt) :: randval
!     real(rt), allocatable :: Ftmp(:)
    
    call random_number(randval)

    if (option==0) then
        izp_out = drawAR1core(cumsum(transpose(F)),iz,randval) 
    elseif (option==1) then
        izp_out = drawAR1core(F,iz,randval)
    end if
    
end function 

! Construct a Markov chain of specified length. Normally, F
! is assumed to be F_ij = F(z'=j|z=i). However, if opt is 
! present and equal to 1, then F is assumed to be the cumsum 
! of the transpose of the Markov matrix.
subroutine drawMarkov(iseq,F,i1,opt)
    use mod_matlab, only: cumsum,find
    implicit none
    integer, intent(inout) :: iseq(1:)
    real(rt), dimension(1:,1:), intent(in) :: F ! The transition matrix
    integer, intent(in) :: i1
    integer, intent(in), optional :: opt
    ! local
    integer :: t,nseq
    real(rt), allocatable :: Fcumtrans(:,:)
    logical :: isspecial

    nseq = size(iseq)

    if (present(opt)) then
        isspecial = opt==1
    else
        isspecial = .false.
    end if

    if (.not. isspecial) then
        allocate(Fcumtrans(size(F,1),size(F,2)))

        Fcumtrans = transpose(F)
        Fcumtrans = cumsum(Fcumtrans)

        iseq(1) = i1
        do t = 2,nseq
            iseq(t) = drawAR1(Fcumtrans,iseq(t-1),1)
        end do

        deallocate(Fcumtrans)
    else

        iseq(1) = i1
        do t = 2,nseq
            iseq(t) = drawAR1(F,iseq(t-1),1)
        end do

    end if

end subroutine drawMarkov

! Adda cooper algorithm. 
! Based on Martin Floden's 2005 code
! %[Z,PI] = addacooper(n,mu,rho,sigma)
! % Approximate n-state AR(1) process following Tauchen (1986) and Tauchen & Hussey (1991). 
! % See Adda & Cooper (2003) pp 57-.
! %
! % Z(t+1) = mu*(1-rho) + rho*Z(t) + eps(t+1)
! %
! % where  std(eps) = sigma
! %
! % Martin Floden, 2005
! 
subroutine sub_addacooper_grid(Z,mu,rho,sigma)
    use mod_matlab
    ! use mod_quad
    implicit none
    real(rt), intent(out) :: Z(:)
    real(rt), intent(in) :: mu,rho,sigma
    ! local
    integer :: i,n
    real(rt) :: sigmaUNC
    real(rt), allocatable :: E(:)

    n = size(Z)

    if (n==1) then
        Z = mu
        return
    elseif (n<=0) then
        STOP 'ERROR: sub_addacooper: n<=0'
    end if

    sigmaUNC = sigma/sqrt(1e0_rt-rho**2)

    allocate(E(n+1))
    E = 0e0_rt
    Z = 0e0_rt

    E(1)   = mu - 8e0_rt*sigmaUNC ! 10 unconditional standard deviations below mean
    E(n+1) = mu + 8e0_rt*sigmaUNC
    do i = 2,n
        E(i) = sigmaUNC*normcdfinv(real(i-1,rt)/real(n,rt),0e0_rt,1e0_rt) + mu
    end do 

    do i = 1,n
        Z(i) = n*sigmaUNC*(stdnormpdf((E(i)-mu)/sigmaUNC) - stdnormpdf((E(i+1)-mu)/sigmaUNC)) + mu
    end do

end subroutine
subroutine sub_addacooper(Z,Fzz,mu,rho,sigma)
    use mod_matlab
    use mod_quad
    implicit none
    real(rt), intent(out) :: Z(:),Fzz(:,:)
    real(rt), intent(in) :: mu,rho,sigma
    ! local

    integer :: i,j,n
    real(rt) :: sigmaUNC,E1,E2
    real(rt), allocatable :: E(:),MFPI(:,:),xquad(:),wquad(:)
    integer, parameter :: nquad = 1000

    allocate(xquad(nquad),wquad(nquad))


    n = size(Z)
    if (size(Fzz,1)/=n) STOP 'ERROR: sub_addacooper size mismatch'
    if (size(Fzz,2)/=n) STOP 'ERROR: sub_addacooper size mismatch'


    if (n==1) then
        Z = mu
        Fzz = 1e0_rt
        return
    elseif (n<=0) then
        STOP 'ERROR: sub_addacooper: n<=0'
    end if

    sigmaUNC = sigma/sqrt(1e0_rt-rho**2);

    allocate(E(n+1))
    allocate(MFPI(n,n))
    E = 0e0_rt
    Z = 0e0_rt
    Fzz = 0e0_rt
    MFPI = 0e0_rt

    E(1)   = mu - 8e0_rt*sigmaUNC ! 10 unconditional standard deviations below mean
    E(n+1) = mu + 8e0_rt*sigmaUNC
    do i = 2,n
        E(i) = sigmaUNC*normcdfinv(real(i-1,rt)/real(n,rt),0e0_rt,1e0_rt) + mu
    end do 

    do i = 1,n
        Z(i) = n*sigmaUNC*(stdnormpdf((E(i)-mu)/sigmaUNC) - stdnormpdf((E(i+1)-mu)/sigmaUNC)) + mu
    end do

    do i = 1,n
        do j = 1,n
            E1 = E(j)
            E2 = E(j+1)
            ! PI(i,j) = quadl(th_fcn,E(i),E(i+1),1e-10)
            call chebyquad(xquad,wquad,E(i),E(i+1))
            Fzz(i,j) = dot_product(th_fcn(xquad),wquad)
!             if (any(isnan(xquad))) STOP 'ERROR'
!             if (any(isnan(wquad))) STOP 'ERROR'
! 
!             if (isnan(Fzz(i,j))) STOP 'ERROR'
!             print*,'Fzz(i,j)',Fzz(i,j)
            MFPI(i,j) = stdnormcdf((E(j+1)-mu*(1e0_rt-rho)-rho*Z(i))/sigma) - stdnormcdf((E(j)-mu*(1e0_rt-rho)-rho*Z(i))/sigma)
        end do
    end do

    do i = 1,n
        Fzz(i,:) = Fzz(i,:) / sum(Fzz(i,:))
        MFPI(i,:) = MFPI(i,:) / sum(MFPI(i,:))
    end do

contains

    function th_fcn(u) result(f)
        implicit none
        real(rt), intent(in) :: u(:)
        real(rt) :: f(size(u))

        f = real(n,rt)/sqrt(2e0_rt*pi*sigmaUNC**2) * (exp(-(u-mu)**2 / (2e0_rt*sigmaUNC**2)) * &
            (stdnormcdf((E2-mu*(1e0_rt-rho)-rho*u)/sigma) - stdnormcdf((E1-mu*(1e0_rt-rho)-rho*u)/sigma)))

    end function

end subroutine
        


!Rouwenhorst method as presented in Kopecky and Suen RED 2010
! Based on Karen Kopecky's Code
subroutine sub_rouwenhorst(z,P,rho,sig,n)
    use mod_matlab
    implicit none
    real(rt), intent(in) :: rho,sig
    integer, intent(in) :: n
    real(rt), intent(out) :: z(n),P(n,n)
    !local
    real(rt) :: mu_eps, q, nu
    real(rt), allocatable :: P0(:,:),P1(:,:)
    integer :: i

    if (n<=0) then
        STOP 'sub_rouwenhorst: n must be > 0'
    elseif (n==1) then
        z = 0e0_rt
        P = 1e0_rt
        return
    end if
    
    mu_eps = 0.e0_rt
    q = (rho+1.e0_rt)/2.e0_rt
    nu = ((real(n,rt)-1.e0_rt)/(1.e0_rt-rho**2))**(.5e0_rt) * sig
    
    allocate(P0(2,2))
    P0(1,:) = (/q, 1.e0_rt-q/)
    P0(2,:) = (/1.e0_rt-q, q/)
    
    do i = 2,n-1
        allocate(P1(i+1,i+1))
        P1 = 0.e0_rt
        !        
        P1(1:i,1:i) = q*P0 + P1(1:i,1:i)
        !
        P1(1:i,2:i+1) = (1.e0_rt-q)*P0 + P1(1:i,2:i+1)
        !
        P1(2:i+1,1:i) = (1.e0_rt-q)*P0 + P1(2:i+1,1:i)
        !
        P1(2:i+1,2:i+1) = q*P0 + P1(2:i+1,2:i+1)
        !
        P1(2:i,:) = P1(2:i,:)/2.e0_rt
        deallocate(P0)
        allocate(P0(i+1,i+1))
        P0 = P1
        deallocate(P1)
    end do
    
    P = P0
    deallocate(P0)
    
    z = linspace(mu_eps/(1.e0_rt-rho) - nu, mu_eps/(1.e0_rt-rho) + nu,n)
    

end subroutine sub_rouwenhorst

! subtauchen
! Generates Markov chain approximating an AR(1) function of the form
! y=ar1*y_{-1}+e,  e~N(0,sd_eps**2)
! ar1  is AR(1) coeff
! sd_eps is SD of normally distributed shock
! cover gives cover*SD coverage, e.g. 3 = 99% coverage, 2 = 95%
!
! Parts of this code may be motivated by Floden
subroutine sub_tauchen(y,transition,ar1,sd_eps,n,cover)
    use mod_matlab, only: linspace
    implicit none
    !Input/Output
    real(rt), intent(in)                      :: ar1        !ar(1) coeff
    real(rt), intent(in)                      :: sd_eps     !SD of normally distributed shocks
    real(rt), intent(in)                      :: cover      !number of SDs to cover (3=>99%)  
    integer,  intent(in)                      :: n          !no of tauchen points
    real(rt), dimension(:), intent(out)     :: y          !shock values
    real(rt), dimension(:,:), intent(out) :: transition !transition matrix
    ! local
    real(rt) :: sd_y            !Unconditional stdev of y

    if (n==1) then
        y = 0e0_rt
        transition = 1e0_rt
        return
    end if

    !Define discrete states of markov chain
    sd_y = sd_eps/sqrt(1-ar1**2)
    y = linspace(-cover*sd_y,cover*sd_y,n)

    ! Call tauchen with predetermined grid
    call sub_tauchen_fixedgrid(transition,y,ar1,sd_eps)

end subroutine sub_tauchen

! Iid shock version of tauchen, just call sub_tauchen and takes a row of the trans
subroutine sub_tauchen_iid(y,prob,sd_eps,n,cover)
    implicit none
    !Input/Output
    real(rt), intent(in)                  :: sd_eps     !SD of normally distributed shocks
    real(rt), intent(in)                  :: cover      !number of SDs to cover (3=>99%)  
    integer,  intent(in)                 :: n          !no of tauchen points
    real(rt), dimension(1:n), intent(out) :: y          !shock values
    real(rt), dimension(1:n), intent(out) :: prob !transition matrix
    ! local
    real(rt), dimension(:,:), allocatable :: transition

    allocate(transition(n,n))
    call sub_tauchen(y,transition,0e0_rt,sd_eps,n,cover)
    prob = transition(1,:)
    deallocate(transition)
    
end subroutine

subroutine sub_tauchen_iid_fixedgrid(prob,y,sd_eps)
    implicit none
    real(rt), intent(in) :: sd_eps
    real(rt), dimension(:), intent(in) :: y
    real(rt), dimension(size(y)), intent(out) :: prob !transition matrix
    ! local 
    real(rt), dimension(:,:), allocatable :: transition
    integer :: n

    n = size(y)

    allocate(transition(n,n))
    call sub_tauchen_fixedgrid(transition,y,0e0_rt,sd_eps) ! no autocorrelation
    prob = transition(1,:)
    deallocate(transition)

end subroutine 

subroutine sub_tauchen_iid_fixedgrid_with_mean(prob,y,sd_eps,mean)
    implicit none
    real(rt), intent(in) :: sd_eps,mean
    real(rt), dimension(:), intent(in) :: y
    real(rt), dimension(size(y)), intent(out) :: prob !transition matrix
    ! local 
    real(rt), dimension(:,:), allocatable :: transition
    integer :: n

    n = size(y)

    allocate(transition(n,n))
    call sub_tauchen_fixedgrid_with_mean(transition,y,0e0_rt,sd_eps,mean) ! no autocorrelation
    prob = transition(1,:)
    deallocate(transition)

end subroutine 

subroutine sub_tauchen_fixedgrid(transition,y,ar1,sd_eps)
    implicit none
    !Input/Output
    real(rt), intent(in)                      :: ar1        !ar(1) coeff
    real(rt), intent(in)                      :: sd_eps     !SD of normally distributed shocks
    real(rt), dimension(1:), intent(in)      :: y          !shock values
    real(rt), dimension(1:size(y),1:size(y)), intent(out) :: transition !transition matrix

    call sub_tauchen_fixedgrid_with_mean(transition,y,ar1,sd_eps,0e0_rt)

end subroutine sub_tauchen_fixedgrid

! Approximates 
! y = mean + ar1*y_{-1} + sd_eps*eps, eps~N(0,1)
! using tauchen on the fixed grid y.  
! NOTE: mean is not the unconditional mean of y, but the conditional mean of y|(y_{-1}=0)
! 
subroutine sub_tauchen_fixedgrid_with_mean(transition,y,ar1,sd_eps,mean)
    implicit none
    !Input/Output
    real(rt), intent(in) :: ar1, sd_eps, mean
    real(rt), dimension(1:), intent(in) :: y !shock values
    real(rt), dimension(1:size(y),1:size(y)), intent(out) :: transition !transition matrix
    !Variable Declaration
    integer :: n ! size of y
    integer :: y_ind            !shock
    integer :: yp_ind           !shock next period
    real(rt) :: mean_cond_on_y  !mean of y' cdnal on y
    real(rt) :: normcdfhigh     !cdf at ub of interval
    real(rt) :: normcdflow      !cdf at lb of interval
    real(rt), dimension(1:size(y)) :: betweenpts_high !interval ub
    real(rt), dimension(1:size(y)) :: betweenpts_low  !interval lb

    n = size(y)

    if (n==1) then
        transition = 1e0_rt
        return
    end if

    !Define intervals for tauchen points
    do y_ind = 1, n-1
        betweenpts_high(y_ind)=y(y_ind)+(y(y_ind+1) - y(y_ind))/2e0_rt        
    enddo

    do y_ind = 2, n
        betweenpts_low(y_ind)=y(y_ind)-(y(y_ind) - y(y_ind-1))/2e0_rt        
    enddo

    !Calculate transition probabilities
    do y_ind = 1,n
        mean_cond_on_y = mean + ar1*y(y_ind) 
        
        normcdfhigh=.5e0_rt*(1.0e0_rt+erf((betweenpts_high(1)-mean_cond_on_y)/(sd_eps*sqrt(2e0_rt))))
        normcdflow=0.e0_rt
        transition(y_ind, 1) = normcdfhigh-normcdflow
        
        normcdfhigh=1.e0_rt
        normcdflow=.5e0_rt*(1.0e0_rt+erf((betweenpts_low(n)-mean_cond_on_y)/(sd_eps*sqrt(2e0_rt))))
        transition(y_ind, n) = normcdfhigh-normcdflow
        
        do yp_ind = 2,n-1
            normcdfhigh=.5e0_rt*(1.0e0_rt+erf((betweenpts_high(yp_ind)-mean_cond_on_y)/(sd_eps*sqrt(2e0_rt))))
            normcdflow=.5e0_rt*(1.0e0_rt+erf((betweenpts_low(yp_ind)-mean_cond_on_y)/(sd_eps*sqrt(2e0_rt))))
            transition(y_ind,yp_ind) = (normcdfhigh - normcdflow)            
        enddo
    enddo

end subroutine sub_tauchen_fixedgrid_with_mean

end module mod_discreteAR1
