! mod_matlab: 
! A collection of Matlab style routines in Fortran.  Uses BLAS and LAPACK libraries. 
! These routines have not been extensively tested, and some have not really been
! tested at all.  Use with caution!
!
! The routine interfaces are intentionally meant to resemble their matlab counterpart.
! As such, I feel that I should mention that I have explicitly copied some lines of code,
! in particular the interfaces (e.g. function eye(n) result(I)) from the Matlab documentation.
! Here is a basic citation:
! Matlab Help Files.  Mathworks, Cambridge MA. 2002.
! 
! Additionally, many of the matrix algorithms (like Chol) were constructed either
! following Wikipedia or the Intel MKL documentation. 
!
! Various other routines are borrowed from various collections on the internet (e.g.
! the hp filter routine is modified from a Matlab exchange code). I have done
! my best to make acknowledgements where they are do. If you find code that has 
! not been properly acknowledged, please let me know and I'll rectify the situation 
! immediately.
!
! Author: Grey Gordon 2010-2013
! Soli Deo Gloria
!
module mod_matlab

    use mod_core ! Some core routines, like tic,toc,linspace,...
    use mod_sort, only: issorted, &
                        defsort=>msort ! Here I am naming msort as the default sort routine 
                                       ! Leave this as the default because (1) it comes from
                                       ! ORDERPACK 2.0 and so is probably better tested 
                                       ! (2) it is quick and (3) mergesort is stable 
    use mod_plot
    implicit none

    private :: defsort ! Make the routine private

    ! Overload 
    interface dot
        real(8) function ddot(n,dx,incx,dy,incy)
            integer :: incx,incy,n
            real(8) :: dx(*),dy(*)
        end function 
        real(4) function sdot(n,dx,incx,dy,incy)
            integer :: incx,incy,n
            real(4) :: dx(*),dy(*)
        end function 
    end interface

    interface gesvd
        subroutine dgesvd(jobu,jobvt,m,n,a,lda,s,u,ldu,vt,ldvt,work,lwork,info)
            character :: jobu, jobvt
            integer :: info, lda, ldu, ldvt, lwork, m, n
            real(8) :: a(lda,*), s(*), u(ldu,*), vt(ldvt,*), work(*)
        end subroutine
        subroutine sgesvd(jobu,jobvt,m,n,a,lda,s,u,ldu,vt,ldvt,work,lwork,info)
            character :: jobu, jobvt
            integer :: info, lda, ldu, ldvt, lwork, m, n
            real(4) :: a(lda,*), s(*), u(ldu,*), vt(ldvt,*), work(*)
        end subroutine
    end interface

    interface gesv
        subroutine dgesv( n, nrhs, a, lda, ipiv, b, ldb, info )
            integer            info, lda, ldb, n, nrhs
            integer            ipiv( * )
            double precision   a( lda, * ), b( ldb, * )
        end subroutine
        subroutine sgesv( n, nrhs, a, lda, ipiv, b, ldb, info )
            integer            info, lda, ldb, n, nrhs
            integer            ipiv( * )
            real a( lda, * ), b( ldb, * )
        end subroutine
    end interface

    interface gemm
        subroutine dgemm(transa,transb,m,n,k,alpha,a,lda,b,ldb,beta,c,ldc)
            double precision alpha,beta
            integer k,lda,ldb,ldc,m,n
            character transa,transb
            double precision a(lda,*),b(ldb,*),c(ldc,*)
        end subroutine 
        subroutine sgemm(transa,transb,m,n,k,alpha,a,lda,b,ldb,beta,c,ldc)
            real(4) alpha,beta
            integer k,lda,ldb,ldc,m,n
            character transa,transb
            real(4) a(lda,*),b(ldb,*),c(ldc,*)
        end subroutine
    end interface

    interface gemv
          subroutine dgemv(trans,m,n,alpha,a,lda,x,incx,beta,y,incy)
                double precision alpha,beta
                integer incx,incy,lda,m,n
                character trans
                double precision a(lda,*),x(*),y(*)
        end subroutine 
          subroutine sgemv(trans,m,n,alpha,a,lda,x,incx,beta,y,incy)
                real(4) alpha,beta
                integer incx,incy,lda,m,n
                character trans
                real(4) a(lda,*),x(*),y(*)
        end subroutine 
    end interface

    interface gbtrf
        subroutine dgbtrf( m, n, kl, ku, ab, ldab, ipiv, info )
            integer            info, kl, ku, ldab, m, n
            integer            ipiv( * )
            double precision   ab( ldab, * )
        end subroutine
        subroutine sgbtrf( m, n, kl, ku, ab, ldab, ipiv, info )
            integer            info, kl, ku, ldab, m, n
            integer            ipiv( * )
            real               ab( ldab, * )
        end subroutine
    end interface

    interface gbtrs
        subroutine dgbtrs( trans, n, kl, ku, nrhs, ab, ldab, ipiv, b, ldb, info )
            character          trans
            integer            info, kl, ku, ldab, ldb, n, nrhs
            integer            ipiv( * )
            double precision   ab( ldab, * ), b( ldb, * )
        end subroutine
        subroutine sgbtrs( trans, n, kl, ku, nrhs, ab, ldab, ipiv, b, ldb, info )
            character          trans
            integer            info, kl, ku, ldab, ldb, n, nrhs
            integer            ipiv( * )
            real               ab( ldab, * ), b( ldb, * )
        end subroutine
    end interface

    interface hseqr
        subroutine dhseqr( job, compz, n, ilo, ihi, h, ldh, wr, wi, z, ldz, work, lwork, info )
        integer            ihi, ilo, info, ldh, ldz, lwork, n
        character          compz, job
        double precision   h( ldh, * ), wi( * ), work( * ), wr( * ), z( ldz, * )
        end subroutine
        subroutine shseqr( job, compz, n, ilo, ihi, h, ldh, wr, wi, z, ldz, work, lwork, info )
        integer            ihi, ilo, info, ldh, ldz, lwork, n
        character          compz, job
        real               h( ldh, * ), wi( * ), work( * ), wr( * ), z( ldz, * )
        end subroutine
    end interface

    
    interface gttrf
        subroutine dgttrf( n, dl, d, du, du2, ipiv, info )
            integer            info, n
            integer            ipiv( * )
            double precision   d( * ), dl( * ), du( * ), du2( * )
        end subroutine
        subroutine sgttrf( n, dl, d, du, du2, ipiv, info )
            integer            info, n
            integer            ipiv( * )
            real               d( * ), dl( * ), du( * ), du2( * )
        end subroutine
    end interface

    interface gttrs
        subroutine dgttrs( trans, n, nrhs, dl, d, du, du2, ipiv, b, ldb, info )
            character          trans
            integer            info, ldb, n, nrhs
            integer            ipiv( * )
            double precision   b( ldb, * ), d( * ), dl( * ), du( * ), du2( * )
        end subroutine 
        subroutine sgttrs( trans, n, nrhs, dl, d, du, du2, ipiv, b, ldb, info )
            character          trans
            integer            info, ldb, n, nrhs
            integer            ipiv( * )
            real               b( ldb, * ), d( * ), dl( * ), du( * ), du2( * )
        end subroutine 
    end interface


    ! Overload procedures
    interface corr
        module procedure corr_mat, corr_vecs, corr_mats, corr_matvec, corr_vecmat
    end interface corr
    interface cumsum
        module procedure cumsum_vec, cumsum_vec_int, cumsum_mat
    end interface cumsum
    interface cumprod
        module procedure cumprod_r, cumprod_i
    end interface cumprod
    interface diag
        module procedure diag_mat, diag_vec, diag_mat_k
    end interface diag
    interface diff
        module procedure diff_vec, diff_mat
    end interface diff
    interface find1
        module procedure find1_xs
    end interface find1
    interface find
        module procedure find_x, find_xk, find_xks
    end interface find
    interface finda
        module procedure find_x_alloc
    end interface
    interface hist
        module procedure hist_x, hist_xn
    end interface hist
    interface horzcat
        module procedure horzcat2, horzcat3, horzcat4, horzcat2mat
    end interface horzcat
    interface interp1
        module procedure interp1_3dim, interp1_mat, interp1_vec, interp1_scal, interp1_scal_mat, interp1_scal_3d
    end interface interp1
    interface interp1q
        module procedure interp1q_scal,interp1q_vec,interp1q_scal_ymat,interp1q_vec_ymat
    end interface interp1q
    interface interp1qf ! even faster version of interp1q, but requires xi be sorted
        module procedure interp1q_scal,interp1q_scal_ymat,interp1qf_vec,interp1qf_vec_ymat ! note: when the xi are scalrs, should be equivalent to interp1q
    end interface interp1qf
    interface interp2q
        module procedure interp2q_scal_ymat,interp2q_vec_ymat,interp2q_scal
    end interface interp2q
    interface mean
        module procedure mean_vec, mean_mat
    end interface mean   
    interface meshgrid
        module procedure meshgrid_int2d,meshgrid_int3d,meshgrid_double2d,meshgrid_double3d
    end interface meshgrid
    interface mldivide
        module procedure mldivide_full, mldivide_band, mldivide_full_mat, mldivide_tridiag
    end interface
    interface mtimes
        module procedure mtimes_matmat, mtimes_matvec
    end interface 
    interface mydot
        module procedure mydot_4d
    end interface 
    interface ndgrid 
        module procedure ndgrid_double2d
    end interface ndgrid
    interface num2str
        module procedure num2str_double, num2str_int
    end interface
    interface ones
        module procedure ones_sqmat, ones_mat, ones_vec2
    end interface ones
    interface plot
        module procedure plot_y_fine,plot_xy_fine,plot_y2_fine,plot_xy2_fine
    end interface plot
    interface plot_coarse
        module procedure plot_y_coarse,plot_xy_coarse
    end interface plot_coarse
    interface rand
        module procedure scal_rand,vec_rand,mat_rand
    end interface rand
    interface randN
        module procedure scal_randN,vec_randN, mat_randN
    end interface randN
    interface repmat
        module procedure repmat_mat_2, repmat_scal_2, repmat_scal_1
    end interface repmat
    interface sort
        module procedure fn_sort_vec
    end interface sort   
    interface sort2
        module procedure sub_sort_vec_i, sub_sort_vec, sub_sort_mat
    end interface sort2
    interface squeeze
        module procedure squeeze_vec, squeeze_mat, squeeze_vec_i
    end interface squeeze
    interface sortrows
        module procedure sortrows_real, sortrows_int
    end interface
    interface std
        module procedure std_vec, std_mat
    end interface std
    interface supnorm
        module procedure supnorm_4d
    end interface supnorm
    interface true
        module procedure true_sqmat, true_mat
    end interface true
    interface unique
        module procedure unique_real, unique_real_vec, unique_int, unique_real_vec_noinds, unique_int_vec_noinds
    end interface unique
    interface vec
        module procedure vec_mat, vec_3d, vec_4d, vec_mat_i, vec_3d_i, vec_4d_i
    end interface vec
    interface vertcat
        module procedure vertcat2mat
    end interface vertcat

    logical, private :: randomSeedInitialized = .FALSE.
    type stream
        integer :: m
        integer, allocatable :: seeds(:)
    end type

    ! Parameter constants
    real(rt), parameter :: pi = 3.14159265358979323846264338327950288419716939937510582097494459e0_rt
    real(rt), parameter :: sqrt_of_2 = sqrt(2e0_rt)
    real(rt), parameter :: sqrt_of_2pi = sqrt(2e0_rt*pi)

contains

! Solves a tridiagonal system A*X = B for X where A is tridiagonal
function mldivide_tridiag(Al,Ad,Au,B) result(X)
    implicit none
    real(rt), intent(in) :: Al(:),Ad(:),Au(:),B(:)
    real(rt) :: X(size(B))

    if (size(Ad)/=size(Al)+1) stop 'ERROR: mldivide_tridiag: input: wrong size'
    if (size(Ad)/=size(Au)+1) stop 'ERROR: mldivide_tridiag: input: wrong size'
    if (size(Ad)/=size(B)) stop 'ERROR: mldivide_tridiag: input: wrong size'

    call mldivide_tridiag_core(X,'N',size(Ad),Al,Ad,Au,size(B),1,B)

end function
subroutine mldivide_tridiag_core(X,tA,n,Al,Ad,Au,rowB,colB,B)
    implicit none
    character(len=1), intent(in) :: tA
    integer, intent(in) :: n,rowB,colB
    real(rt), intent(in) :: Al(:),Ad(:),Au(:),B(rowB,*)
    real(rt), intent(out) :: X(rowB,*)
    ! local
    real(rt), allocatable :: Au2(:)
    integer, allocatable :: ipiv(:)
    integer :: info

    allocate(Au2(n-2))
    allocate(ipiv(n))

    ! LU factorization
    call gttrf(n,Al,Ad,Au,Au2,ipiv,info)

    if (info/=0) write(0,*) 'WARNING: mldivid_tridiag: gttrf had an error'

    ! Solution
    call gttrs(tA,n,colB,Al,Ad,Au,Au2,ipiv,B,rowB,info)
    if (info/=0) write(0,*) 'WARNING: mldivid_tridiag: gttrs had an error'

    ! Output
    X(:,1:colB) = B(:,1:colB)


end subroutine



! From http://fortranwiki.org/fortran/show/random_seed with slight modifications
subroutine init_random_seed(shift)
    implicit none
    integer, intent(in), optional :: shift
    integer :: i, n, clock
    integer, dimension(:), allocatable :: seed

    call random_seed(size = n)
    allocate(seed(n))

    call system_clock(count=clock)

    if (present(shift)) then
        seed = clock + 37 * (/ (i - 1, i = 1, n) /) + 67*shift
    else
        seed = clock + 37 * (/ (i - 1, i = 1, n) /)
    end if
    call random_seed(put = seed)

    deallocate(seed)
end subroutine

! Computes the supnorm of two vectors v0,v1 (maximum absolute value between them)
function supnorm_4d(v0,v1) result(supnorm)
    implicit none
    real(rt), intent(in) :: v0(:,:,:,:),v1(:,:,:,:)
    real(rt) :: supnorm
    supnorm = supnorm_core(v0,v1,size(v0))
end function 
function supnorm_core(v0,v1,n) result(supnorm)
    implicit none
    integer, intent(in) :: n
    real(rt) :: v0(*),v1(*)
    real(rt) :: supnorm
    ! local
    real(rt) :: m
    integer :: i

    m = abs(v0(1) - v1(1))
    do i = 2,n
        m = max(m,abs(v0(i) - v1(i)))
    end do
    supnorm = m

end function 

! BLAS ddot call
function mydot_4d(x,y) result(myddot)
    implicit none
    real(rt), dimension(:,:,:,:), intent(in) :: x,y
    real(rt) :: myddot
    real(rt) :: ddot
    external :: ddot
    myddot = ddot(size(x),x,1,y,1)
end function 


! Code is based of the matlab ind2sub.m
! Given an integer vector siz that gives the shape of
! some array and the linear index i, convert the linear
! index into an i1,i2,... such that 
!  a(i) = a(i1,i2,...)
function ind2sub(siz,i) result(ivec)
    integer, intent(in) :: siz(:)
    integer :: i
    integer :: ivec(size(siz))
    ! local
    integer :: d
    integer :: j,k
    integer :: cumprodivec(size(siz))

    cumprodivec(1) = 1
    cumprodivec(2:size(siz)) = cumprod(siz(1:size(siz)-1))

    j = i
    do d = size(siz),1,-1
        k = mod(j-1,cumprodivec(d)) + 1
        ivec(d) = (j-k)/cumprodivec(d) + 1
        j = k
    end do

end function

! Same as Matlab's vertcat. 
function vertcat2mat(x1,x2) result(x)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: x1,x2
    real(rt) :: x(size(x1,1)+size(x2,1),size(x1,2))

    if (size(x1,2)/=size(x2,2)) STOP 'vertcat: ERROR: x1,x2 dimensions don''t conform'

    x(1:size(x1,1),:) = x1
    x(size(x1,1)+1:size(x1,1)+size(x2,1),:) = x2

end function 

! Same as Matlab's horzcat. 
function horzcat2mat(x1,x2) result(x)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: x1,x2
    real(rt) :: x(size(x1,1),size(x1,2)+size(x2,2))

    if (size(x1,1)/=size(x2,1)) STOP 'horzcat: ERROR: x1,x2 dimensions don''t conform'

    x(:,1:size(x1,2)) = x1
    x(:,size(x1,2)+1:size(x1,2)+size(x2,2)) = x2

end function 
function horzcat2(x1,x2) result(x)
    implicit none
    real(rt), dimension(1:), intent(in) :: x1,x2
    real(rt) :: x(size(x1),2)

    if (size(x1)/=size(x2)) STOP 'horzcat: ERROR: x1,x2 dimensions don''t conform'

    x(:,1) = x1
    x(:,2) = x2

end function 
function horzcat3(x1,x2,x3) result(x)
    implicit none
    real(rt), dimension(1:), intent(in) :: x1,x2,x3
    real(rt) :: x(size(x1),3)

    if (size(x1)/=size(x2)) STOP 'horzcat: ERROR: x1,x2 dimensions don''t conform'
    if (size(x1)/=size(x3)) STOP 'horzcat: ERROR: x1,x3 dimensions don''t conform'

    x(:,1) = x1
    x(:,2) = x2
    x(:,3) = x3

end function 
function horzcat4(x1,x2,x3,x4) result(x)
    implicit none
    real(rt), dimension(1:), intent(in) :: x1,x2,x3,x4
    real(rt) :: x(size(x1),4)

    if (size(x1)/=size(x2)) STOP 'horzcat: ERROR: x1,x2 dimensions don''t conform'
    if (size(x1)/=size(x3)) STOP 'horzcat: ERROR: x1,x3 dimensions don''t conform'
    if (size(x1)/=size(x4)) STOP 'horzcat: ERROR: x1,x3 dimensions don''t conform'

    x(:,1) = x1
    x(:,2) = x2
    x(:,3) = x3
    x(:,4) = x4

end function 

! Given a matrix X that has a singleton dimension, will convert to a vector. O/w error is thrown.
function mat2vec(X) result(Y)
    implicit none
    real(rt), intent(in) :: X(1:,1:)
    real(rt) :: Y(size(X))

    if (size(X,1)==1) then
        Y = X(1,:)
    elseif (size(X,2)==1) then
        Y = X(:,1)
    else
        STOP 'mat2vec: ERROR: X must have a singleton dim'
    end if

end function

! Given a vector X, reshapes it into a matrix w size (nX,1) 
function vec2mat(X) result(Y)
    implicit none
    real(rt), intent(in) :: X(1:)
    real(rt) :: Y(1:size(X),1)
    
    Y = reshape(X,(/size(X),1/))

end function vec2mat
! Given a length one vector X, return a scalar
function vec2scal(X) result(Y)
    implicit none
    real(rt), intent(in) :: X(1)
    real(rt) :: Y
    Y = X(1)
end function

! Similar to repmat in Matlab, will take X and tile it (a,b) times. 
! Can only be called using a matrix X (if need to use a vector, first use
! vec2mat).
!
! Note: could overload this by doing repmat(X,a,b,c,d,...)
function repmat_mat_2(X,a,b) result(R)
    implicit none
    real(rt), intent(in) :: X(1:,1:)
    integer, intent(in) :: a,b
    real(rt) :: R(1:size(X,1)*a,1:size(X,2)*b)
    ! local
    integer :: i,j,nx1,nx2

    nx1 = size(X,1)
    nx2 = size(X,2)

    ! Tile
    do j = 1,nx2*b
        do i = 1,nx1*a
            R(i,j) = X(1+mod(i-1,nx1),1+mod(j-1,nx2))
        end do
    end do

end function repmat_mat_2
function repmat_scal_2(X,a,b) result(R)
    implicit none
    real(rt), intent(in) :: X
    integer, intent(in) :: a,b
    real(rt) :: R(a,b)

    R = x

end function repmat_scal_2
function repmat_scal_1(X,a) result(R)
    implicit none
    real(rt), intent(in) :: X
    integer, intent(in) :: a
    real(rt) :: R(a)

    R = x

end function repmat_scal_1

! HP Filters the series y using smoothing parameter w
! Returns the deviation "dev"
! w = 100 is common for annual
! w = 1600 is common for quarterly
! This code is based off Wilmer Henao's HP filter code for matlab 
! Copyright (c) 2003, Wilmer Henao
! All rights reserved.
! 
! Redistribution and use in source and binary forms, with or without 
! modification, are permitted provided that the following conditions are 
! met:
! 
!     * Redistributions of source code must retain the above copyright 
!       notice, this list of conditions and the following disclaimer.
!     * Redistributions in binary form must reproduce the above copyright 
!       notice, this list of conditions and the following disclaimer in 
!       the documentation and/or other materials provided with the distribution
!             
!       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
!       AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
!       IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
!       ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
!       LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
!       CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
!       SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
!       INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
!       CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
!       ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
!       POSSIBILITY OF SUCH DAMAGE.
function hpfilter(y,w) result(dev) 
    implicit none
    real(rt), dimension(:), intent(in) :: y
    real(rt), intent(in) :: w !
    real(rt), dimension(size(y)) :: dev
    !local
    integer :: m,j
    real(rt), allocatable :: B(:,:), d(:,:)

    allocate(B(size(y),size(y)),d(size(y),3))
    
    ! Ensure that there is something to filter by checking the stdev is not zero
    if (std(y)<10.0_rt*epsilon(0._rt)) then
        print*,'hpfilter: WARNING: input series had little or no variability: stdev is ',&
                std(y),' max is ',maxval(y),' min is ',minval(y),' returning zero deviation.'
        dev = 0._rt
        return
    end if



    m = size(y)
    
    d = spread((/w, -4.e0_rt*w, (6.e0_rt*w+1.e0_rt)/2.e0_rt /),1,m)
    d(1,2) = -2.e0_rt*w;            d(m-1,2) = -2.e0_rt*w
    d(1,3) = (1.e0_rt+w)/2.e0_rt;      d(m,3) = (1.e0_rt+w)/2.e0_rt
    d(2,3) = (5.e0_rt*w+1.e0_rt)/2.e0_rt; d(m-1,3) = (5.e0_rt*w+1.e0_rt)/2.e0_rt

    ! Produce the banded matrix
!     B = 0.e0_rt
!     do j = 1,m
!         B(j,j) = d(j,3)
!         if (j<m) B(j+1,j) = d(j,2)
!         if (j<m-1) B(j+2,j) = d(j,1)        
!     end do
!     B = B + transpose(B)

    do j = 1,m
        B(j,j) = 2e0_rt*d(j,3)
        if (j<m) then
            B(j+1,j) = d(j,2)
            B(j,j+1) = d(j,2)
        end if
        if (j<m-1) then
            B(j+2,j) = d(j,1)        
            B(j,j+2) = d(j,1)        
        end if
    end do

    !!! NOTE: it is quite slow to call mldivide here.
    !!! Because B is a banded sparse matrix, we could use the routine
    !!! dgbtrf followed by dgbtrs to compute the result.

    !!! DO NOT!!! USE THIS COMMENTED LINE OF CODE W/O FIRST SETTING B=0 ON OFF DIAGONAL ELEMENTS
!     dev = y - mldivide(B,y)

    !!! Do use this
    dev = y - mldivide_band(B,y,2,2)

    deallocate(B,d)

end function hpfilter

!  [auto]=autocorr(x,F,mu)
!  Computes the autocorrelation of some discrete process with grid x,
!  transition matrix F, and initial distribution mu.
function autocorr(x,F,mu) result(auto)
    implicit none
    real(rt), intent(in) :: x(1:),F(1:,1:),mu(1:)
    real(rt) :: auto
    !local
    real(rt) :: Ex,Exp,sigx,sigxp,accum
    real(rt), allocatable :: mup(:)
    integer :: i

    allocate(mup(size(mu)))

    ! Check that mu is a distribution
    if (abs(sum(mu)-1.e0_rt)>1d-15) STOP 'autocorr: mu is not a distribution, it doesnt sum to 1'
    if (any(mu<0.e0_rt)) STOP 'autocorr: mu is not a distribution, it has negative elements'
    ! Check that F is a transition matrix
    if (any(abs(sum(F,2)-1.e0_rt)>1d-15)) STOP 'F is not a transition matrix'
    ! Check that x,F, and mu have the correct dimensions
    if (size(x)/=size(mu)) STOP 'autocorr: x and mu sizes don''t agree'
    if (size(x)/=size(F,1)) STOP 'autocorr: x and F1 sizes don''t agree'
    if (size(x)/=size(F,2)) STOP 'autocorr: x and F2 sizes don''t agree'

    ! Compute mean today
    Ex = dot_product(x,mu)
    
    ! Compute stdev today
    sigx = sqrt(dot_product(mu,(x-Ex)**2))
    
    ! Compute dsn tomorrow
    mup = matmul(mu,F)

    ! Compute mean tomorrow
    Exp = dot_product(x,mup)
    
    ! Compute stdev tomorrow
    sigxp = sqrt(dot_product(mup,(x-Exp)**2))

    ! Compute autocorrelation
    accum = 0.e0_rt
    do i = 1,size(x)
        accum = accum + mu(i)*(x(i)-Ex)*(dot_product(F(i,:),(x-Exp)))
    end do
    auto = accum/(sigx*sigxp)

    deallocate(mup)

end function autocorr

! Computes the Cholesky decomposition of A into an upper triangular matrix U satisfying U'*U=A
! I believe this algorithm is based on the descriptions of how to compute the Cholesky decomp
! in the Intel MKL help files. 
function chol(Ain) result(U)
    implicit none
    real(rt), intent(in) :: Ain(1:,1:)
    real(rt) :: U(size(Ain,1),size(Ain,2))
    !local
    character(len=1) :: uplo
    real(rt), allocatable :: A(:,:) 
    integer :: m,n,info, i,j

    allocate(A(size(Ain,1),size(Ain,2)))

    m = size(A,1)
    n = size(A,2)
    if (m/=n) STOP 'chol: matrix must be square'

    uplo = 'U' ! This is the Matlab convention
    
    A = Ain

    call dpotrf( uplo, n, A, n, info )
    
    select case (info)
        case (:-1)
            STOP 'chol: in call to dpotrf, the ith parameter had an illegal value'
        case (0)
            ! Success
        case (1:)
            STOP 'chol: A is not positive definite and so the factorization could not be completed'
    end select

    U = 0.e0_rt
    do i = 1,m
        do j=i,m
            U(i,j) = A(i,j)
        end do
    end do

    deallocate(A)

end function chol


! Compares two strings. Returns equal in the Matlab style way rather than Fortran (which allows unequal
! length strings to be equal by padding the right with spaces).
function strcmp(s1,s2) result(tf)
    implicit none
    character(len=*), intent(in) :: s1,s2
    logical :: tf

    if (len(s1)/=len(s2)) then
        tf = .false.
    else
        tf = s1==s2
    end if

end function strcmp

! Computes the determinant of a matrix A by  
function det(Ain) result(d)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: Ain
    real(rt) :: d
    !local
    real(rt), allocatable :: A(:,:)
    integer, allocatable :: ipiv(:) 
    integer :: nRowChanges
    integer :: m,n,info
    
    allocate(A(size(Ain,1),size(Ain,2)))
    allocate(ipiv(size(Ain,1)))
    
    m = size(A,1)
    n = size(A,2)
    if (m/=n) STOP 'det: matrix must be square'

    ! Copy over since the dgetrf overwrites A
    A = Ain

    call dgetrf(m,n,A,m,ipiv,info)

    ! Check for an error from dgetrf
    select case (info)
        case (:-1)
            STOP 'det: in call to dgetrf, the ith parameter had an illegal value'
        case (0)

        case (1:)
            write(*,*) 'WARNING: det: in LU factorization, u_ii had zero value.  This may result in problems'
    end select

    ! Count the number of row changes (if even, then the determinant of the Perm matrix is 1, o/w it is -1)
    nRowChanges = count(ipiv /= colon(1,size(Ain,1)))
    
    ! Calculate determinant
    if (mod(nRowChanges,2) == 0) then !if number of row changes was even
        d = product(diag(A))
    else
        d = -product(diag(A))
    end if

    ! Clean up
    deallocate(A,ipiv)
    

end function det

! Sort a vector of indices returning only the unique values
subroutine unique_int_vec_noinds(B,A)
    use mod_orderpack, only: unirnk
    implicit none
    integer, intent(in) :: A(:)
    integer, allocatable, intent(out) :: B(:)
    ! local
    integer, allocatable :: tmp(:)
    integer :: nuni ! number of unique

    allocate(tmp(size(A)))
    call unirnk(A,tmp,nuni)
    allocate(B(nuni))
    B = A(tmp(1:nuni))

end subroutine 

subroutine unique_real_vec_noinds(B,A)
    implicit none
    real(rt), intent(in) :: A(:)
    real(rt), allocatable, intent(out) :: B(:)
    ! local
    integer, allocatable :: redo(:),undo(:)

    allocate(undo(size(A)))
    call unique_real_vec(B,redo,undo,A)

end subroutine 
! Given A, finds the unique elements and places them in B. 
! Also, computes redo and undo integer vectors s.t. A(redo)==B
! and B(undo)==A.
subroutine unique_real_vec(B,redo,undo,A)
    implicit none
    real(rt), intent(in) :: A(1:)
    real(rt), allocatable, intent(out) :: B(:)
    integer, allocatable, intent(out) :: redo(:)
    integer, intent(out) :: undo(size(A))
    !local
    real(rt), allocatable :: Asort(:)
    integer, allocatable :: IsortA(:), IrecoverA(:), D(:)
    integer :: nunique

    allocate(Asort(size(A)),IsortA(size(A)),IrecoverA(size(A)),D(size(A)))

    !First sort
    call sort2(Asort,IsortA,A)
    IrecoverA(IsortA) = colon(1,size(A))
    
    !Get indicator vector of unique locations
    D(1) = 1
    D(2:size(A)) = merge(1,0,Asort(1:size(A)-1)/=Asort(2:size(A)))

    !Then allocate the right amount
    nunique = sum(D)
    allocate(B(nunique),redo(nunique))
    
    !Then copy over the unique values
    B = pack(Asort,D==1)
    redo = pack(IsortA,D==1)

    undo = cumsum(D)
    undo(IsortA) = undo

    deallocate(Asort,IsortA,IrecoverA,D)

end subroutine unique_real_vec

! Same as above, but with A a matrix. Currently only does unique rows.
subroutine unique_real(B,redo,undo,A,byRows)
    implicit none
    real(rt), intent(in) :: A(1:,1:)
    real(rt), allocatable, intent(out) :: B(:,:)
    integer, intent(out) :: undo(size(A,1))
    integer, allocatable, intent(out) :: redo(:)
    character(len=*), intent(in), optional :: byRows
    !local
    real(rt), allocatable :: Asort(:,:)
    integer, allocatable :: rank(:), undorank(:), keepRows(:) 
    integer :: i, nKeep

    allocate(Asort(size(A,1),size(A,2)),rank(size(A,1)),undorank(size(A,1)),keepRows(size(A,1)))

    if (present(byRows)) then
        call uniqueByRows()
    else
        STOP 'havent programmed this'
!         call uniqueVals()
    end if

    deallocate(Asort,rank,undorank,keepRows)

contains

    subroutine uniqueByRows()
        implicit none

        ! Sort A by rows
        call sortrows(Asort,rank,A)
        undorank(rank) = colon(1,size(A,1)) !Undoes the sorting

        ! Compare each row with the next row
        nKeep = 1
        keepRows(1) = 1
        undo(1) = nKeep
        do i = 2,size(Asort,1)
            if (any(Asort(i-1,:)/=Asort(i,:))) then
                !if i is unique, keep it
                nKeep = nKeep + 1
                keepRows(nKeep) = i
                undo(i) = nKeep
            else
                !if the row is not unique, find the last row that was and use its index
                undo(i) = nKeep
            end if
        end do
        undo=undo(undorank)        

        ! Get B and redo
        allocate(B(nKeep,size(A,2)),redo(nKeep))
        redo = rank(keepRows(1:nKeep))
        B = Asort(keepRows(1:nKeep),:)

    end subroutine uniqueByRows

end subroutine unique_real
subroutine unique_int(B,redo,undo,A,byRows)
    implicit none
    integer, intent(in) :: A(1:,1:)
    integer, allocatable, intent(out) :: B(:,:)
    integer, intent(out) :: undo(size(A,1))
    integer, allocatable, intent(out) :: redo(:)
    character(len=*), intent(in), optional :: byRows
    !local
    integer, allocatable :: Asort(:,:), rank(:), undorank(:), keepRows(:) 
    integer :: i, nkeep

    allocate(Asort(size(A,1),size(A,2)),rank(size(A,1)),undorank(size(A,1)),keepRows(size(A,1)))

    if (present(byRows)) then
        call uniqueByRows()
    else
        STOP 'ERROR: unique_int: havent programmed this'
!         call uniqueVals()
    end if

    deallocate(Asort,rank,undorank,keepRows)

contains

    subroutine uniqueByRows()
        implicit none

        ! Sort A by rows
        call sortrows(Asort,rank,A)
        undorank(rank) = colon(1,size(A,1)) !Undoes the sorting

        ! Compare each row with the next row
        nKeep = 1
        keepRows(1) = 1
        undo(1) = nKeep
        do i = 2,size(Asort,1)
            if (any(Asort(i-1,:)/=Asort(i,:))) then
                !if i is unique, keep it
                nKeep = nKeep+1
                keepRows(nKeep) = i
                undo(i) = nKeep
            else
                !if the row is not unique, find the last row that was and use its index
                undo(i) = nKeep
            end if
        end do
        undo=undo(undorank)        

        ! Get B and redo
        allocate(B(nKeep,size(A,2)),redo(nKeep))
        redo = rank(keepRows(1:nKeep))
        B = Asort(keepRows(1:nKeep),:)

    end subroutine

end subroutine unique_int

! Sorts A by rows
subroutine sortrows_real(B,redo,A)
    use mod_orderpack, only: mrgrnk
    implicit none
    real(rt), intent(in) :: A(1:,1:)
    real(rt), intent(out) :: B(size(A,1),size(A,2))
    integer, intent(out) :: redo(size(A,1))
    ! local
    integer, allocatable :: tmp_redo(:)
    integer :: icol,ncol,nrow

    ! Sort according to columns from right to left. I believe this 
    ! ensures that when there are equal elements, they are ranked according to
    ! the column to their right as long as the sort is table

    ncol = size(A,2)
    nrow = size(A,1)
    
    redo = colon(1,nrow)

    allocate(tmp_redo(nrow))

    do icol = ncol,1,-1
        
        ! Redo gives the current assortment necessary to redo all changes
        B(:,icol) = A(redo,icol) ! Copy over to prevent a temporary copy being made by the compiler
        call mrgrnk(B(:,icol),tmp_redo) ! Gets the ranking but does not change B which is changed at the end
        redo = redo(tmp_redo)

    end do

    deallocate(tmp_redo)

    ! At the last pass, have to redo all 
    B = A(redo,:)


end subroutine sortrows_real

!Sorts A by rows (keeping each row as a unit)
! Also returns an integer vector redo s.t. B=A(redo,:)
subroutine sortrows_int(B,redo,A)
    use mod_orderpack, only: mrgrnk
    implicit none
    integer, intent(in) :: A(1:,1:)
    integer, intent(out) :: B(size(A,1),size(A,2))
    integer, intent(out) :: redo(size(A,1))
    ! local
    integer, allocatable :: tmp_redo(:)
    integer :: icol,ncol,nrow
    
    ! Sort according to columns from right to left. I believe this 
    ! ensures that when there are equal elements, they are ranked according to
    ! the column to their right as long as the sort is table

    ncol = size(A,2)
    nrow = size(A,1)
    
    redo = colon(1,nrow)

    allocate(tmp_redo(nrow))

    do icol = ncol,1,-1
        
        ! Redo gives the current assortment necessary to redo all changes
        B(:,icol) = A(redo,icol) ! Copy over to prevent a temporary copy being made by the compiler
        call mrgrnk(B(:,icol),tmp_redo) ! Gets the ranking but does not change B which is changed at the end
        redo = redo(tmp_redo)

    end do

    deallocate(tmp_redo)

    ! At the last pass, have to redo all 
    B = A(redo,:)


end subroutine sortrows_int

! Computes n choose k
function choose(n,k) result(val)
    implicit none
    integer, intent(in) :: n,k
    integer :: val

    if (k>n .or. k<0) STOP 'choose: k is unacceptable'

    val = pure_choose(n,k)

end function choose
elemental function pure_choose(n,k) result(val)
    implicit none
    integer, intent(in) :: n,k
    integer :: val
    
    if (k>=n-k) then
        val = product(colon(k+1,n))/pure_factorial(n-k)
    else
        val = product(colon(n-k+1,n))/pure_factorial(k)        
    end if

end function

! Computes the factorial of n
function factorial(n) result(val)
    implicit none
    integer, intent(in) :: n
    integer :: val

    if (n<0) then
        write(*,*) 'factorial: n value',n
        STOP 'factorial: n is less than zero!'
    end if

    val = pure_factorial(n) 

end function factorial
elemental function pure_factorial(n) result(val)
    implicit none
    integer, intent(in) :: n
    integer :: val
    !local
    integer :: ind,tmp

    tmp = 1
    do ind = 2,n
        tmp = tmp*ind
    end do
    val = tmp

end function 

! Converts a number to a string
function num2str_double(A,format) result(str)
    implicit none
    real(rt), intent(in) :: A
    character(len=*), intent(in) :: format
    character(len=50) :: str
    write(str,format) A
end function
function num2str_int(A,format) result(str)
    implicit none
    integer, intent(in) :: A
    character(len=*), intent(in) :: format
    character(len=50) :: str
    write(str,format) A
end function

! Very basic histogram plotting to std out
subroutine hist_x(x)
    implicit none
    real(rt), dimension(1:), intent(in) :: x
    call hist_xn(x,40)
end subroutine
subroutine hist_xn(x,n)
    implicit none
    real(rt), dimension(1:), intent(in) :: x
    integer, intent(in) :: n
    integer, parameter :: max_xpixels = 40,ypixels=20
    character(len=min(n,max_xpixels)) :: horizontal_line
    integer :: i, y_ind, x_ind, xpixels
    integer :: ylocmax
    real(rt), allocatable :: x_axis(:), y_axis(:) 
    logical, allocatable :: xy_filled(:,:) 
    integer, allocatable :: x_count(:) 
    
    allocate(x_axis(min(n,max_xpixels)),y_axis(1:ypixels),xy_filled(min(n,max_xpixels),ypixels),x_count(min(n,max_xpixels)-1))

    xpixels = min(n,max_xpixels)

    !Generate xaxis/bins
    x_axis = linspace(minval(x),maxval(x),xpixels)

    !Create a count for each bin
    ! This is a very slow method, but speed is not essential here yet. 
    x_count(1) = count(x<=x_axis(1))
    do i = 2,xpixels-2
        x_count(i) = count(x_axis(i)<=x .and. x<x_axis(i+1))
    end do
    x_count(xpixels-1) = count(x>=x_axis(xpixels))

    !Generate yaxis
    y_axis = linspace(0.e0_rt,real(maxval(x_count),rt),ypixels)

    !Fill in the plot
    xy_filled = .FALSE.
    do i = 1,size(x_count)
        ylocmax = int(real(x_count(i),8)/y_axis(ypixels)*real(ypixels,8))
        xy_filled(i,1:ylocmax) = .TRUE.
    end do

    !Draw plot to screen
    do y_ind = ypixels,1,-1
        do x_ind = 1,xpixels
            if (xy_filled(x_ind,y_ind)) then
                horizontal_line(x_ind:x_ind) = '.'
            else 
                horizontal_line(x_ind:x_ind) = ' '
            end if
        end do
        write(*,'(f10.5,A,A)') y_axis(y_ind),'|',horizontal_line
    end do
    do x_ind = 1,xpixels
        horizontal_line(x_ind:x_ind) = '-'
    end do
    write(*,*) '          ',horizontal_line
    write(*,*) 'x_range: ',x_axis(1),',',x_axis(xpixels)

    deallocate(x_axis,y_axis,xy_filled,x_count)

end subroutine

!Very basic plotting to std out
!Only have a limited number of pixels to work with    
subroutine plot_y_coarse(y)
    implicit none
    real(rt), dimension(1:), intent(in) :: y
    !local
    real(rt), dimension(1:size(y)) :: x
    x = real(colon(1,size(y)),rt)
    call plot_xy_coarse(x,y)
end subroutine plot_y_coarse
subroutine plot_xy_coarse(x,y,xpixels,ypixels,xlb,xub,ylb,yub,uid)
    implicit none
    real(rt), dimension(1:), intent(in) :: x,y
    real(rt), intent(in), optional :: xlb,xub,ylb,yub
    integer, intent(in), optional :: xpixels,ypixels,uid
    !local
    integer :: xp, yp, unitno
    real(rt), allocatable :: x_axis(:),y_axis(:)
    real(rt) :: xpt,ypt
    logical, allocatable :: xy_filled(:,:)
    logical :: lx,ly
    integer :: i, y_ind, x_ind
    character(len=10000) :: horizontal_line

    unitno = 6 ! stdout
    xp = 40
    yp = 20

    if (present(xpixels)) xp = xpixels 
    if (present(ypixels)) yp = ypixels 
    if (present(uid)) unitno = uid

    allocate(x_axis(xp))
    allocate(y_axis(yp))
    allocate(xy_filled(xp,yp))

    !Check input
    if (size(x)/=size(y)) STOP 'plot: wrong size'       

    !Generate axes
    x_axis(1)  = minval(x); if (present(xlb)) x_axis(1) = xlb
    x_axis(xp) = maxval(x); if (present(xub)) x_axis(xp) = xub
    y_axis(1)  = minval(y); if (present(ylb)) y_axis(1) = ylb
    y_axis(yp) = maxval(y); if (present(yub)) y_axis(yp) = yub

    x_axis = linspace(x_axis(1),x_axis(xp),xp)
    y_axis = linspace(y_axis(1),y_axis(yp),yp)

    !Fill plot
    xy_filled = .false.
    do i = 1,size(x)
        xpt = x(i)
        ypt = y(i)

        call bsearch(x_ind,x(i),x_axis)
        call bsearch(y_ind,y(i),y_axis)

        lx = .true.
        ly = .true.
        if (x(i)<x_axis(1)) lx = .false.
        if (y(i)<y_axis(1)) ly = .false.
        if (x(i)>x_axis(xp)) lx = .false.
        if (y(i)>y_axis(yp)) ly = .false.

        xy_filled(x_ind,y_ind) = lx .and. ly
                    
    end do

    !Draw plot to screen
    do y_ind = yp,1,-1
        horizontal_line = ' '
        do x_ind = 1,xp
            if (xy_filled(x_ind,y_ind)) horizontal_line(x_ind:x_ind) = 'o'
        end do
        write(unitno,'(f10.5,A,A)') y_axis(y_ind),'|',horizontal_line(1:xp)
    end do
    do x_ind = 1,xp
        horizontal_line(x_ind:x_ind) = '-'
    end do
    write(unitno,'(2A)') '          +',horizontal_line(1:xp)

    write(unitno,'(A11)',advance='no') ''
    do x_ind = 1,xp/10-1 ! divides the xp space into 10 because the space taken below is 10
        write(unitno,'(f10.5)',advance='no') x_axis(x_ind*10 - 10 + 1)
    end do
    write(unitno,'(f10.5)') x_axis(xp)

end subroutine plot_xy_coarse




subroutine plot_y_fine(y,title_,xlabel_,ylabel_)
    implicit none
    real(rt), intent(in) :: y(:)
    character(len=*), intent(in), optional :: title_,xlabel_,ylabel_

    call clear()
    if (present(title_)) call title(title_)
    if (present(xlabel_)) call xlabel(xlabel_)
    if (present(ylabel_)) call ylabel(ylabel_)

    call triplet(real(colon(1,size(y)),rt),y,'')
    call drawnow()
    call clear()

end subroutine 
subroutine plot_y2_fine(y,title_,xlabel_,ylabel_)
    implicit none
    real(rt), intent(in) :: y(:,:)
    character(len=*), intent(in), optional :: title_,xlabel_,ylabel_

    call clear()
    if (present(title_)) call title(title_)
    if (present(xlabel_)) call xlabel(xlabel_)
    if (present(ylabel_)) call ylabel(ylabel_)
   
    call triplet(real(colon(1,size(y,1)),rt),y,'')
    call drawnow()
    call clear()

end subroutine plot_y2_fine


subroutine plot_xy_fine(x,y,title_,xlabel_,ylabel_)
    implicit none
    real(rt), intent(in) :: x(:), y(:)
    character(len=*), intent(in), optional :: title_,xlabel_,ylabel_

    call clear()
    if (present(title_)) call title(title_)
    if (present(xlabel_)) call xlabel(xlabel_)
    if (present(ylabel_)) call ylabel(ylabel_)

    call triplet(x,y,'')
    call drawnow()
    call clear()

end subroutine plot_xy_fine
subroutine plot_xy2_fine(x,y,title_,xlabel_,ylabel_)
    implicit none
    real(rt), intent(in) :: x(:), y(:,:)
    character(len=*), intent(in), optional :: title_,xlabel_,ylabel_

    call clear()
    if (present(title_)) call title(title_)
    if (present(xlabel_)) call xlabel(xlabel_)
    if (present(ylabel_)) call ylabel(ylabel_)

    call triplet(x,y,'')
    call drawnow()
    call clear()

end subroutine plot_xy2_fine

! subroutine plot_y_fine(y,title)
!     implicit none
!     real(rt), intent(in) :: y(1:)
!     character(len=*), intent(in), optional :: title
! 
!     if (present(title)) call plot_xy_fine(real(colon(1,size(y)),8),y,title)
!     if (.not. present(title)) call plot_xy_fine(real(colon(1,size(y)),8),y)
! 
! end subroutine
! subroutine plot_xy_fine(x,y,title,xlabel,ylabel,extra)
!     implicit none
!     real(rt), intent(in) :: x(:), y(:)
!     character(len=*), intent(in), optional :: title,xlabel,ylabel,extra
!     ! local
!     character(len=1000) :: t,xl,yl,ex
!     logical :: useDefArg(4)
! 
!     useDefArg(1) = present(title)
!     useDefArg(2) = present(xlabel)
!     useDefArg(3) = present(ylabel)
!     useDefArg(4) = present(extra)
! 
!     t=' '; if (present(title)) t=title
!     xl=' '; if (present(xlabel)) xl=xlabel 
!     yl=' '; if (present(ylabel)) yl=ylabel
!     ex=' '; if (present(extra)) ex=extra
! 
!     call plot_xy2_fine(x,reshape(y,[size(y),1]),title,xlabel,ylabel,extra,useDefArg)
! 
! end subroutine plot_xy_fine
! subroutine plot_y2_fine(y,title,xlabel,ylabel,extra)
!     implicit none
!     real(rt), intent(in) :: y(:,:)
!     character(len=*), intent(in), optional :: title,xlabel,ylabel,extra
!     ! local
!     real(rt), allocatable :: x(:)
!     character(len=1000) :: t,xl,yl,ex
!     logical :: useDefArg(4)
! 
!     useDefArg(1) = present(title)
!     useDefArg(2) = present(xlabel)
!     useDefArg(3) = present(ylabel)
!     useDefArg(4) = present(extra)
! 
!     t=' '; if (present(title)) t=title
!     xl=' '; if (present(xlabel)) xl=xlabel 
!     yl=' '; if (present(ylabel)) yl=ylabel
!     ex=' '; if (present(extra)) ex=extra
! 
!     allocate(x(size(y,1)))
!     x = colon(1,size(y,1))
! 
!     call plot_xy2_fine(x,y,title,xlabel,ylabel,extra,useDefArg)
! 
! end subroutine plot_y2_fine 
! 
! ! plot_x_y2_fine plots x,y data using a (not compliant Fortran standard) system call to gnuplot.
! ! Many options are available and for the most part self-descriptive. Temporary files are saved 
! ! to /tmp/ (which of course is *nix) standard.
! !
! ! Arguments are mostly obvious. The unobvious ones are 
! ! extra 
! ! -> allows the user to pass any commands to gnuplot before the data is plotted.
! ! -> ex: "set style data scatter" will produce a scatter plot instead of the default line plot.
! ! 
! ! useDefArg 
! ! -> should not be called by the user (internal mechanism)
! ! 
! subroutine plot_xy2_fine(x,y,title,xlabel,ylabel,extra,useDefArg)
!     !$ use omp_lib ! conditional compilation, will only be examined by compiler if openmp is enabled
! 
!     implicit none
!     real(rt), intent(in) :: x(:), y(:,:)
!     character(len=*), intent(in), optional :: title,xlabel,ylabel,extra
!     logical, intent(in), optional :: useDefArg(4) ! Logical specifying which Default arguments
!     !local
!     integer :: i,j,ni,nj, unitno
!     logical :: isPresent_xlabel, isPresent_ylabel, isPresent_title, isPresent_extra
!     character(len=3), parameter :: newline = ', \'
!     character(len=3) :: tmpchar
!     character(len=5) :: jp1AsString,jAsString,tmpChar5
!     character(len=1000) :: dls(size(y,2)), ms(size(y,2)),cls(size(y,2)) ! data labels and methods
!     character(len=100) :: configfile, datafile 
!     integer(4) :: ierr
! 
! !     interface 
! !         function system(str) result(ierr)
! !             implicit none
! !             integer(4) :: ierr
! !             character(*) :: str
! !         end function 
! !     end interface
! 
!     ! Must ensure that only one thread executes this at a time otherwise they may modify 
!     ! the files at the same time. W/o the critical, this routine is not thread safe. Even 
!     ! with the critical, it is only thead safe if the system call to gnuplot is thread safe.
!     ! 
!     ! NOTE: I must not understand critical sections well enough, because I nested two and that
!     ! cause the program to hang. B/c of that, I am not using the critical section
! !         !$OMP CRITICAL
! 
!     ! As an extra precaution, I try to make sure the threads write to unique files
!     write(tmpChar5,'(i0)') 1
!     !$ write(tmpChar5,'(i0)') omp_get_thread_num() ! only compiled if openmp is enabled
!     datafile = '/tmp/greysdeleteme'//trim(tmpChar5)//'.dat'
!     configfile = '/tmp/greysdeleteme'//trim(tmpChar5)//'.cfg'
!     unitno = 726
!     !$ unitno = 726+omp_get_thread_num()
!     
! !         datafile = '/tmp/greysdeleteme.dat'
! !         configfile = '/tmp/greysdeleteme.cfg'
! !         unitno = 726
! 
!     if (present(useDefArg)) then
!         isPresent_title = useDefArg(1)
!         isPresent_xlabel = useDefArg(2)
!         isPresent_ylabel = useDefArg(3)
!         isPresent_extra = useDefArg(4)
!     else
!         isPresent_title = present(title) 
!         isPresent_xlabel = present(xlabel)
!         isPresent_ylabel = present(ylabel)
!         isPresent_extra = present(extra)
!     end if
! 
!     ! Check inputs
!     ni = size(x)
!     nj = size(y,2)
!     if (size(y,1)/=ni) STOP 'sub_plot_x_y2: x and y dims don''t agree'
! 
!     ! Set defaults and replace them if optional arg present
!     do j = 1,nJ
!         write(jAsString,'(i0)') j
!         dls(j) = 'data '//jAsString
!     end do
!     ms = 'line'
!     cls = ''
! 
!     ! Write data to a temporary file
!     open(unitno,file=trim(datafile),status='unknown')
!     write(unitno,*) '# Temporary data file created by grey''s plot routine' 
!     do i = 1,ni
!         write(unitno,'(1PE24.15E3)',advance='no') x(i)
!         do j = 1,nj
!             write(unitno,'(1PE24.15E3)',advance='no') y(i,j)
!         end do
!         write(unitno,*) 
!     end do
!     close(unitno)
! 
!     ! Write config to a temporary file
!     open(unitno,file=trim(configfile),status='unknown')
!     write(unitno,*) '# Temporary gnuplot configuration file created by grey''s plot routine'
!     write(unitno,*) 'set style data line' ! set line as default style 
!     if (isPresent_xlabel) write(unitno,*) 'set xlabel "'//trim(xlabel)//'"'
!     if (isPresent_ylabel) write(unitno,*) 'set ylabel "'//trim(ylabel)//'"'
!     if (isPresent_title) write(unitno,*) 'set title "'//trim(title)//'"'
!     if (isPresent_extra) write(unitno,*) trim(extra)//' ' ! extra pre options
! 
!     write(unitno,'(A)',advance='no') 'plot' ! this is the first part of the command
!     do j = 1,nj
!         
!         ! Create j+1 as a string
!         write(jp1AsString,'(i0)') j+1
! 
!         ! Determine whether new line is needed
!         if (j<nj) then
!             tmpchar = newline
!         else
!             tmpchar = '   '
!         end if
! 
!         ! Output the command
!         ! NOTE: must use advance no here to prevent ifort from breaking the line
! !         write(unitno,'(A)',advance='no') ' "'//trim(datafile)//'" using 1:' &
! !                 //trim(jp1AsString)//' title "'//trim(dls(j)) // &
! !               '" with '//trim(ms(j))//' '//trim(cls(j))//' '//trim(tmpchar)
!         write(unitno,'(A)',advance='no') ' "'//trim(datafile)//'" using 1:' &
!                 //trim(jp1AsString)//' title "'//trim(dls(j))//'" '//trim(tmpchar)
!         ! Make a new line
!         write(unitno,*)
! 
!     end do
! 
! !     if (isPresent_savefile) then 
! !         write(unitno,*) 'set terminal postscript'
! !         write(unitno,*) 'set output "'//trim(savefile)//'"'
! !         write(unitno,*) 'replot'
! !         write(unitno,*) 'set term x11' ! Not strictly necessary
! !     end if
! 
!     close(unitno)
! 
!     ! Now use a nonstandard fortran routine (appearing in ifort and gfortran) to call gnuplot
!     ! NOTE: if gnuplot is not available or an error is received, just report it and the program
!     ! will continue.
! !     ierr = system('gnuplot -persist '//trim(configfile)) ! was using until 5/14/14
!     call execute_command_line('gnuplot -persist '//trim(configfile),exitstat=ierr)
!     if (ierr/=0) print*,'sub_plot_x_y2: WARNING: error in calling gnuplot'
! 
! !         !$OMP END CRITICAL
! 
! end subroutine plot_xy2_fine

! Cumulatively sums the vector x
function cumsum_vec(x_in) result(x_out)
    implicit none
    real(rt), dimension(1:), intent(in) :: x_in
    real(rt), dimension(1:size(x_in)) :: x_out
    integer :: i
    real(rt) :: accum

    accum = 0e0_rt
    do i = 1,size(x_in)
        accum = accum + x_in(i)
        x_out(i) = accum
    end do

end function cumsum_vec
function cumsum_vec_int(x_in) result(x_out)
    implicit none
    integer, dimension(1:), intent(in) :: x_in
    integer, dimension(1:size(x_in)) :: x_out
    integer :: i,accum

    accum = 0
    do i = 1,size(x_in)
        accum = accum + x_in(i)
        x_out(i) = accum
    end do

end function cumsum_vec_int

! Cumulatively sums the rows of x
function cumsum_mat(x_in) result(x_out)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: x_in
    real(rt), dimension(1:size(x_in,1),1:size(x_in,2)) :: x_out  ! illegal to reference x_out
    ! local
    integer :: i,d 
    real(rt) :: accum

    do d = 1,size(x_in,2)

        accum = 0e0_rt
        do i = 1,size(x_in,1)
            accum = accum + x_in(i,d)
            x_out(i,d) = accum
        end do

    end do

end function cumsum_mat


subroutine sub_cumsum(x_out,x_in)
    implicit none
    real(rt), dimension(:), intent(in) :: x_in
    real(rt), dimension(1:size(x_in)), intent(inout) :: x_out
    integer :: i

    x_out(1)=x_in(1)
    do i=2,size(x_in)
        x_out(i) = x_in(i) + x_out(i-1)
    end do

end subroutine sub_cumsum
subroutine sub_cumsum_mat(x_out,x_in,DIM)
    implicit none
    real(rt), dimension(:,:), intent(in) :: x_in
    real(rt), dimension(1:size(x_in,1),1:size(x_in,2)), intent(inout) :: x_out
    integer, intent(in) :: DIM 
    integer :: col_ind, row_ind

    if (DIM==1) then
        do col_ind = 1,size(x_in,2)
            call sub_cumsum(x_out(:,col_ind),x_in(:,col_ind))
        end do
    elseif (DIM==2) then
        do row_ind = 1,size(x_in,1)
            call sub_cumsum(x_out(row_ind,:),x_in(row_ind,:))
        end do
    else
        STOP 'error in cumsum'
    end if

end subroutine sub_cumsum_mat

subroutine ndgrid_double2d(xx,yy,x,y)
    implicit none
    real(rt), intent(in) :: x(:), y(:)
    real(rt), intent(out) :: xx(:,:), yy(:,:)
    ! local
    integer :: ix, iy
    if (any(shape(xx)/=[size(x),size(y)])) write(0,*) 'ERROR: ndgrid: size xx does not conform with x,y'
    if (any(shape(yy)/=[size(x),size(y)])) write(0,*) 'ERROR: ndgrid: size yy does not conform with x,y'
    do ix = 1,size(x)
        do iy = 1,size(y)
            xx(ix,iy) = x(ix)
            yy(ix,iy) = y(iy)
        end do
    end do
end subroutine ndgrid_double2d

! Uses the same convention as the Matlab routines. ndgrid might be more natural.
subroutine meshgrid_int2d(xx,yy,x,y)
    implicit none
    integer, intent(in) :: x(1:), y(1:)
    integer, intent(out) :: xx(size(y),size(x)), yy(size(y),size(x))
    xx = spread(x,1,size(y))
    yy = spread(y,2,size(x))
end subroutine meshgrid_int2d
subroutine meshgrid_int3d(xxx,yyy,zzz,x,y,z)
    implicit none
    integer, intent(in) :: x(1:), y(1:), z(1:)
    integer, intent(out) :: xxx(size(y),size(x),size(z)), yyy(size(y),size(x),size(z)), zzz(size(y),size(x),size(z))
    xxx = spread(spread(x,1,size(y)),3,size(z))
    yyy = spread(spread(y,2,size(x)),3,size(z))
    zzz = spread(spread(z,1,size(y)),2,size(x))
end subroutine meshgrid_int3d
subroutine meshgrid_double2d(xx,yy,x,y)
    implicit none
    real(rt), intent(in) :: x(1:), y(1:)
    real(rt), intent(out) :: xx(size(y),size(x)), yy(size(y),size(x))
    xx = spread(x,1,size(y))
    yy = spread(y,2,size(x))
end subroutine meshgrid_double2d
subroutine meshgrid_double3d(xxx,yyy,zzz,x,y,z)
    implicit none
    real(rt), intent(in) :: x(1:), y(1:), z(1:)
    real(rt), intent(out) :: xxx(size(y),size(x),size(z)), yyy(size(y),size(x),size(z)), zzz(size(y),size(x),size(z))
    xxx = spread(spread(x,1,size(y)),3,size(z))
    yyy = spread(spread(y,2,size(x)),3,size(z))
    zzz = spread(spread(z,1,size(y)),2,size(x))
end subroutine meshgrid_double3d

! As in the matlab routine, fix rounds x to the nearest integer between x and 0.
! In fortran, this is just the "int" conversion routine.
elemental function fix(x)
    implicit none
    real(rt), intent(in) :: x
    integer :: fix

    fix = int(x)

!     fix = floor(x)
!     if (x<0.e0_rt) fix = fix + 1
end function fix

! Uniform random number draw between 0 and 1.
function scal_rand() result(btwn01)
    implicit none
    real(rt) :: btwn01
    call random_number(btwn01)
end function scal_rand
function vec_rand(n) result(btwn01)
    implicit none
    integer, intent(in) :: n
    real(rt), dimension(1:n) :: btwn01
    call random_number(btwn01)
end function vec_rand
function mat_rand(n1,n2) result(btwn01)
    implicit none
    integer, intent(in) :: n1,n2
    real(rt), dimension(1:n1,1:n2) :: btwn01
    call random_number(btwn01)
end function mat_rand

!Generates random normal variables using the Box-Muller method as described in Wikipedia
function scal_randn() result(RV)
    implicit none
    real(rt) :: RV
    !local
    real(rt) :: tmp(1)
    tmp = randn(1)
    RV = tmp(1)
end function 
function vec_randN(n) result(RVs)
    implicit none
    integer, intent(in) :: n
    real(rt), dimension(1:n) :: RVs
    !local
    real(rt) :: U(2),twopiU1,sqrtneg2logU2
    integer :: i
    
    do i = 1,n,2
        ! Fill U with two U[0,1]
        call random_number(U)
        do while (U(2)==0._rt)
            call random_number(U)
        end do

        
        ! Precompute
        twopiU1 = 2.e0_rt*pi*U(1)
        sqrtneg2logU2 = sqrt(-2.e0_rt*log(U(2)))
        
        ! Fill the random variables
        RVs(i) = cos(twopiU1)*sqrtneg2logU2
        if (i+1<=n) RVs(i+1) = sin(twopiU1)*sqrtneg2logU2

    end do

end function vec_randN
function mat_randN(n1,n2) result(RVs)
    implicit none
    integer, intent(in) :: n1,n2
    real(rt), dimension(n1,n2) :: RVs
    RVs = reshape(vec_randN(n1*n2),(/n1,n2/))
end function

! reset(.) set the seed of Fortran's random number generator.
! To reset to a default stream, do the following:   call reset(getDefaultStream())
subroutine reset(streamIn)
    implicit none
    type(stream) :: streamIn
    integer :: m
    call random_seed(size=m)
    if (m/=streamIn%m) STOP 'reset: stream size and seed size do not agree'

    call random_seed(put=streamIn%seeds)
end subroutine reset
! Sets a default stream in a Fortran standard compliant way.
function getDefaultStream() result(streamOut)
    implicit none
    type(stream) :: streamOut
    integer :: m

    if (.not. randomSeedInitialized) then
        call random_seed()
        randomSeedInitialized = .true.
    end if

    call random_seed(size=m)
    streamOut%m = m

    if (allocated(streamOut%seeds)) deallocate(streamOut%seeds)
    allocate(streamOut%seeds(m))

    streamOut%seeds = 5

end function getDefaultStream


!Vectorize (equivalent to matlab colon)
function vec_mat(X) result(vec)
    implicit none
    real(rt), dimension(1:,1:) :: X
    real(rt), dimension(1:size(X)) :: vec
    vec = reshape(X,(/size(X)/))
end function vec_mat
function vec_3d(X) result(vec)
    implicit none
    real(rt), dimension(1:,1:,1:) :: X
    real(rt), dimension(1:size(X)) :: vec
    vec = reshape(X,(/size(X)/))
end function vec_3d
function vec_4d(X) result(vec)
    implicit none
    real(rt), dimension(1:,1:,1:,1:) :: X
    real(rt), dimension(1:size(X)) :: vec
    vec = reshape(X,(/size(X)/))
end function vec_4d
function vec_mat_i(X) result(vec)
    implicit none
    integer, dimension(1:,1:) :: X
    integer, dimension(1:size(X)) :: vec
    vec = reshape(X,(/size(X)/))
end function vec_mat_i
function vec_3d_i(X) result(vec)
    implicit none
    integer, dimension(1:,1:,1:) :: X
    integer, dimension(1:size(X)) :: vec
    vec = reshape(X,(/size(X)/))
end function vec_3d_i
function vec_4d_i(X) result(vec)
    implicit none
    integer, dimension(1:,1:,1:,1:) :: X
    integer, dimension(1:size(X)) :: vec
    vec = reshape(X,(/size(X)/))
end function vec_4d_i

! Wraps blas dgemm with a simplified interface. 
! Has the options to transpose and can handle nD arrays. The penalty to nD arrays is
! two shape arguments must be passed.
! C = alpha*op(A)*op(B) + beta*C
subroutine mtimes_matmat(C,A,B,tA,tB,alpha,beta)
    implicit none
    real(rt), intent(out) :: C(:,:)
    real(rt), intent(in) :: A(:,:),B(:,:)
    character(len=1), intent(in), optional :: tA,tB
    real(rt), intent(in), optional :: alpha, beta
    ! local
    character(len=1) :: tAselect,tBselect
    real(rt) :: alphaselect,betaselect

    ! Set the most reasonable defaults and override if necessary
    tAselect = 'N'; if (present(tA)) tAselect = tA
    tBselect = 'N'; if (present(tB)) tBselect = tB
    alphaselect = 1e0_rt; if (present(alpha)) alphaselect = alpha
    betaselect = 0e0_rt; if (present(beta)) betaselect = beta
    
    call mygemm(C,A,B,size(A,1),size(A,2),size(B,1),size(B,2),tAselect,tBselect,alphaselect,betaselect)

end subroutine 

! C = alpha*op(A)*B + beta*C
subroutine mtimes_matvec(C,A,B,tA,alpha,beta)
    implicit none
    real(rt), intent(out) :: C(:)
    real(rt), intent(in) :: A(:,:),B(:)
    character(len=1), intent(in), optional :: tA
    real(rt), intent(in), optional :: alpha, beta
    ! local
    character(len=1) :: tAselect
    real(rt) :: alphaselect,betaselect

    ! Set the most reasonable defaults and override if necessary
    tAselect = 'N'; if (present(tA)) tAselect = tA
    alphaselect = 1e0_rt; if (present(alpha)) alphaselect = alpha
    betaselect = 0e0_rt; if (present(beta)) betaselect = beta
    
    call mygemv(C,A,B,size(A,1),size(A,2),tAselect,alphaselect,betaselect)

end subroutine 



subroutine mygemm(C,A,B,sA1,sA2,sB1,sB2,tA,tB,alpha,beta)
    implicit none
    integer, intent(in) :: sA1,sA2,sB1,sB2
    real(rt), intent(out) :: C(1,*) ! make a 2d array, should not matter, but needed to match the exact interface of gemm
    real(rt), intent(in) :: A(sA1,*),B(sB1,*)
    character(len=1), intent(in), optional :: tA,tB
    real(rt), intent(in), optional :: alpha, beta
    ! local
    character(len=1) :: tAselect,tBselect
    real(rt) :: alphaselect,betaselect
    integer :: m,n,k

    ! Set the most reasonable defaults and override if necessary
    tAselect = 'N'; if (present(tA)) tAselect = tA
    tBselect = 'N'; if (present(tB)) tBselect = tB
    alphaselect = 1e0_rt; if (present(alpha)) alphaselect = alpha
    betaselect = 0e0_rt; if (present(beta)) betaselect = beta

    ! Get the dimensions accounting for transposes
    m = merge(sA1,sA2,tAselect=='N') ! m is # rows of C and opA 
    n = merge(sB2,sB1,tBselect=='N') ! n is # columns of C and opB
    k = merge(sB1,sB2,tBselect=='N') ! k is # columns of opA and rows of opB
    
    ! Check for incompatible dimensions
    if (merge(sA2,sA1,tAselect=='N')/=k) STOP 'mygemm: dimensions are not compatible'

    ! Call BLAS
    call gemm(tAselect,tBselect,m,n,k,alphaselect,A,sA1,B,sB1,betaselect,C,m)

end subroutine 

! Wraps blas gemv with a simplified interface. 
! Has the options to transpose and can handle nD arrays. The penalty to nD arrays is
! two shape arguments must be passed.
! C = alpha*op(A)*B + beta*C
subroutine mygemv(C,A,B,sA1,sA2,tA,alpha,beta)
    implicit none
    integer, intent(in) :: sA1,sA2
    real(rt), intent(out) :: C(*)
    real(rt), intent(in) :: A(sA1,*),B(*)
    character(len=1), intent(in), optional :: tA
    real(rt), intent(in), optional :: alpha, beta
    ! local
    character(len=1) :: tAselect
    real(rt) :: alphaselect,betaselect
    integer :: m,n

    ! Set the most reasonable defaults and override if necessary
    tAselect = 'N'; if (present(tA)) tAselect = tA
    alphaselect = 1e0_rt; if (present(alpha)) alphaselect = alpha
    betaselect = 0e0_rt; if (present(beta)) betaselect = beta

    ! Get the dimensions accounting for transposes
    m = sA1
    n = sA2

    ! Call BLAS
    call gemv(tAselect,m,n,alphaselect,A,sA1,B,1,betaselect,C,1)

end subroutine 



! Construct a true matrix
function true_sqmat(a) result(true)
    integer, intent(in) :: a
    logical :: true(a,a)
    true = .TRUE.
end function true_sqmat
function true_mat(a,b) result(true)
    integer, intent(in) :: a,b
    logical :: true(a,b)
    true = .TRUE.
end function true_mat

! logspace(a,b,n) places n points from 10^a to 10^b according to linear spacing in log10. 
function logspace(d1,d2,n) result(grid)
    implicit none
    real(rt), intent(in) :: d1,d2
    integer, intent(in) :: n
    real(rt), dimension(1:n) :: grid

    grid = 10e0_rt**(linspace(d1,d2,n))

end function logspace

! Produces a matrix filled with ones according to the Matlab convention
function ones_sqmat(dim) result(mat)
    implicit none
    integer, intent(in) :: dim
    real(rt), dimension(1:dim,1:dim) :: mat    
    mat = 1.e0_rt
end function ones_sqmat
function ones_mat(dim1,dim2) result(mat)
    implicit none
    integer, intent(in) :: dim1,dim2
    real(rt), dimension(1:dim1,1:dim2) :: mat    
    mat = 1.e0_rt
end function ones_mat
function ones_vec2(dims) result(mat)
    implicit none
    integer, dimension(1:2),intent(in) :: dims
    real(rt), dimension(1:dims(1)) :: mat
    if (dims(2)/=1) STOP 'ones_vec2: use ones_mat2 for a matrix.  This only handles vectors'
    mat = 1.e0_rt
end function ones_vec2

! Computes the OLS regression of X on Y to obtain Y = X*B + eps with eps orthogonal
function regress(Y,X) result(B)
    implicit none
    real(rt), dimension(1:), intent(in) :: Y
    real(rt), dimension(1:,1:), intent(in) :: X
    real(rt), dimension(1:size(X,2)) :: B
    !local
    real(rt), allocatable :: xpx(:,:), xpy(:) 
    integer :: ny,nb

    ny = size(Y)
    nb = size(X,2)

    ! Check inputs
    if (ny/=size(X,1)) STOP 'regress: matrix dimensions dont agree: y/=size(x,1)'

    allocate(xpx(nb,nb))
    allocate(xpy(nb))

    ! Calc X'X and X'Y
    call mygemm(Xpx,X,X,ny,nb,ny,nb,tA='T')
    call mygemv(XpY,X,Y,ny,nb,tA='T')

    ! Check the condition of X'X to check for possibly multicollinearity
    if (cond(XpX)>1d10) then 
        write(*,*) 'regress: warning: possible multicollinearity in regressors'
        write(*,*) 'regress: X''X has condition number', cond(XpX)
    end if

    ! Solve (X'X)B=(X'Y) (i.e. B = (X'X)^-1(X'Y))
    B = mldivide(XpX,XpY)

end function regress

! Computes the condition number of the matrix X
function cond(X) result(k)
    
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: X
    real(rt) :: k
    !local
    real(rt), dimension(1:size(X,1)) :: e 
    real(rt) :: mine

    ! Get the eigenvalues of X
    e = eig(X)

    ! 
    mine = minval(abs(e))
    if (mine/=0.e0_rt) then
        k = maxval(abs(e))/mine
    else 
        k = huge(0.e0_rt)
    endif
end function cond

! Computes the eigenvalues of a matrix.
! Follows the algorithm laid out in the Intel MKL help files.
function eig(A_in) result(e)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: A_in
    real(rt), dimension(1:size(A_in,1)) :: e
    !local
    real(rt), dimension(1:size(A_in,1),1:size(A_in,2)) :: A
    real(rt), dimension(1:size(A_in,1),1:size(A_in,2)) :: H,Z
    real(rt), dimension(1:size(A_in,1)) :: wr,wi
    integer, parameter :: blocksize = 64
    real(rt), dimension(1:size(A_in,1)*blocksize) :: work
    real(rt), dimension(1:size(A_in,1)-1) :: tau
    integer :: n, ilo, ihi, lda, lwork, info, ldh, ldz
    character(len=1) :: job,compz
    !Ensure the A is square
    if (size(A_in,1)/=size(A_in,2)) STOP 'A not square'

    !Compute the hessenberg form of the matrix A=Q*H*Q^{H}
    A = A_in
    n = size(A_in,1)
    ilo = 1
    ihi = n
    lda = n
    lwork = size(work)
    call dgehrd(n, ilo, ihi, a, lda, tau, work, lwork, info) !note A is overwritten with details of H and Q
    
    !Compute the eigenvalues of the hessenberg matrix
    job = 'E'
    compz = 'N'
    H = A
    ldh = size(H,1)    
    !Z is not referenced and so need not be set    
    ldz = size(Z,1)
    !Can use the same work arrays as before
    call hseqr(job, compz, n, ilo, ihi, h, ldh, wr, wi, z, ldz, work, lwork, info)
    !wr and wi contain the real and imaginary parts of the eigenvalues unless info>0

    select case (info)
        case (0)
            !Executed successfully
            !Right only the real part of the eigenvalues
            e = wr
            if (any(abs(wi)>1d-14)) then
                write(*,*) 'eig: warning: some eigenvalues are complex!'
                write(*,*) 'eig:          only writing the real parts'
            end if                
        case (:-1)
            write(*,*) 'eig: the ', info, ' parameter has an illegal value'
            STOP
            !The info-th parameter had an illegal value
        case (1:)
            write(*,*) 'eig: not all eigenvalues found'
            STOP 
            !Elements 1,2,...,ilo-1 and i+1,i+2,...,n of wr and wi contain the real and imag parts of 
            !those eigenvalues which have been successfully found.        
    end select

end function eig

! Computes the inverse of a matrix. 
! Currently, only works for 2x2 matrices. Otherwise, one should generally use mldivide.
function inv(X) result(Xinv)
    
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: X
    real(rt), dimension(1:size(X,1),1:size(X,2)) :: Xinv
    !local
    real(rt) :: determ, a,b,c,d
    if (any(shape(X)/=(/2,2/))) STOP 'inv: only built for 2x2 matrices'
    a = X(1,1)
    b = X(1,2)
    c = X(2,1)
    d = X(2,2)
    determ = a*d-b*c
    Xinv = reshape((/d,-c,-b,a/),(/2,2/))/determ
end function inv


!Removes one singleton dimension from A
function squeeze_vec_i(A) result(B)
    implicit none
    integer, dimension(1:) :: A
    integer :: B

    if (size(A)>1) then
        STOP 'squeeze_vec: A is not a length 1 vector!'
    end if

    B = A(1)

end function squeeze_vec_i
function squeeze_vec(A) result(B)
    implicit none
    real(rt), dimension(1:) :: A
    real(rt) :: B

    if (size(A)>1) then
        STOP 'squeeze_vec: A is not a length 1 vector!'
    end if

    B = A(1)

end function squeeze_vec
function squeeze_mat(A) result(B)
    implicit none
    real(rt), dimension(1:,1:) :: A
    real(rt), dimension(1:size(A)) :: B

    if (.NOT.(any(shape(A)==1))) then
        write(*,*) 'squeeze_mat: No singleton dimension to remove'
        STOP
!     elseif (count(shape(A)>1)) then
!         write(*,*) 'squeeze_mat: More than one singleton dimension to remove'
!         STOP
    end if   

    if (size(A,1)==1) then
        B = A(1,:)
    elseif (size(A,2)==1) then
        B = A(:,1)
    else
        STOP 'squeeze_mat: case not found'
    end if
end function squeeze_mat

! Computes the mean of X
function mean_vec(X,mask) result(mean)
    implicit none
    logical, dimension(:), intent(in), optional :: mask
    real(rt), dimension(:), intent(in) :: X
    real(rt) :: mean
    ! local
    integer :: n

    if (present(mask)) then
        n = count(mask)
        if (n>0) then
            mean = sum(X,mask=mask)/real(n,rt)
        else
            mean = -1234.0_rt
        end if
    else
        mean = sum(X)/real(size(X),rt)
    end if
end function mean_vec
function mean_mat(X) result(mean)
    
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: X
    real(rt), dimension(1:size(X,2)) :: mean
    mean = sum(X,1)/real(size(X,1),rt)
end function mean_mat

! X = mldivide(A,B)
! mldivide computes an "X" s.t. AX = B if possible. 
! I am not sure what happens when this is not possible.
function mldivide_full_mat(A,b) result(x)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: A
    real(rt), dimension(1:,1:), intent(in) :: B
    real(rt), dimension(1:size(A,2),1:size(b,2)) :: x
    !local
    real(rt), dimension(:,:), allocatable :: A_local, b_local
    integer, dimension(:), allocatable :: ipiv
    integer :: info

    allocate(A_local(size(A,1),size(A,2)), b_local(size(b,1),size(b,2)), ipiv(size(A,1)))
    
    !Check inputs
    if (size(A,1)/=size(A,2)) then
        write(*,*) shape(A)
        STOP 'mldivide: A not square.  Cant handle this currently.'
    end if

    ! Copy A and b over because these are overwritten
    A_local = A
    b_local = b
    call gesv(size(A_local,1), size(b_local,2), A_local, size(A_local,1), ipiv, b_local, size(b_local,1), info )
    x = b_local
    
    ! Check for failure
    select case (info)
        case(0)
        case (:-1)
            write(*,*) 'mldivide: the ', -info, ' parameter had an illegal value'
        case(1:)
            write(*,*) 'mldivide: U(i,i) for i=', info, ' is exactly zero.  The factorization ', &
                    'has been completed, but the factor U is exactly singular, so the solution ', &
                    'could not be computed.'
    end select

    deallocate(A_local, b_local, ipiv)
    
end function mldivide_full_mat

! x = mldivide(A,b)
! mldivide computes an "x" s.t. Ax = b if possible. 
! I am not sure what happens when this is not possible.
function mldivide_full(A,b) result(x)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: A
    real(rt), dimension(1:), intent(in) :: b
    real(rt), dimension(1:size(A,2)) :: x
    !local
    real(rt), dimension(:,:), allocatable :: A_local, b_local
    integer, dimension(:), allocatable :: ipiv
    integer :: info

    allocate(A_local(size(A,1),size(A,2)), b_local(size(b),1), ipiv(size(A,1)))
    
    !Check inputs
    if (size(b)/=size(A,1)) then
        write(*,*) size(b), size(A,1)
        STOP 'mldivide: b wrong size'
    end if
    if (size(A,1)/=size(A,2)) then
        write(*,*) shape(A)
        STOP 'mldivide: A not square.  Cant handle this currently.'
    end if

    ! Copy A and b over because these are overwritten
    A_local = A
    b_local(:,1) = b
    call gesv(size(A_local,1), 1, A_local, size(A_local,1), ipiv, b_local, size(b_local,1), info )
    x = b_local(:,1)
    
    ! Check for failure
    select case (info)
        case(0)
        case (:-1)
            write(*,*) 'mldivide: the ', -info, ' parameter had an illegal value'
        case(1:)
            write(*,*) 'mldivide: U(i,i) for i=', info, ' is exactly zero.  The factorization ', &
                    'has been completed, but the factor U is exactly singular, so the solution ', &
                    'could not be computed.'
    end select

    deallocate(A_local, b_local, ipiv)
    
end function mldivide_full

! mldivide_band
! Solves for x in Ax=b when A is a banded matrix with kl subdiagonals, ku superdiagonals, 
! with the one main diagonal (kl>=0,ku>=0). For user convenience, I am not economizing
! on storage here, so A is a full square matrix (the banded matrix is created internally)
!
function mldivide_band(A,b,kl,ku) result(x)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: A
    real(rt), dimension(1:), intent(in) :: b
    real(rt), dimension(1:size(A,2)) :: x
    integer, intent(in) :: kl,ku
    !local
    real(rt), dimension(:,:), allocatable :: Ab, btmp ! banded A, tmp b
    integer, dimension(:), allocatable :: ipiv
    integer :: m,n,ldab,ldb,info,nrhs, i,j

    !Check inputs
    if (size(b)/=size(A,1)) then
        write(*,*) size(b), size(A,1)
        STOP 'mldivide_band: b wrong size'
    end if
    if (size(A,1)/=size(A,2)) then
        write(*,*) shape(A)
        STOP 'mldivide_band: A not square.  Cant handle this currently.'
    end if
    if (ku<0 .or. kl<0) then
        STOP 'mldivide_band: ku and kl must be nonnegative'
    end if

    ! Begin
    m = size(A,1) ! Also is size(A,2)
    n = size(A,2) ! Also is size(A,1)
    ldab = 2*kl + ku + 1 ! The extra kl is used for storage
    ldb = n ! Rows in b
    nrhs = 1 ! Columns of b

    allocate(Ab(ldab,n), btmp(n,nrhs), ipiv(n))

    ! Convert A into banded form
    do j = 1,n
        do i = max(1,j-ku),min(m,j+kl) 
            ab(kl + ku + 1 + i - j, j) = A(i,j) ! storage scheme in lapack 
        end do
    end do

    ! Copy over b as it will be overwritten
    btmp(:,1) = b

    ! Compute the lu factorization
    call gbtrf( m, n, kl, ku, ab, ldab, ipiv, info )

    ! Check for failure of lu factorization
    select case (info)
        case(0)
        case (:-1)
            write(*,*) 'mldivide_band: in LU factorizing, the ', -info, ' parameter had an illegal value'
            stop
        case(1:)
            write(*,*) 'mldivide_band: in LU factorizing, U(i,i) for i=', info, ' is exactly zero.  The factorization ', &
                    'has been completed, but the factor U is exactly singular, so the solution ', &
                    'could not be computed. Setting result to 0 and returning. Results will likely be wrong.'
            x = 0d0
            return 
    end select

    ! Compute the solution using the factorized A
    call gbtrs( 'N', n, kl, ku, nrhs, ab, ldab, ipiv, btmp, ldb, info )

    ! Copy out the solution
    x = btmp(:,1)
    
    ! Check for failure
    select case (info)
        case(0)
        case (:-1)
            write(*,*) 'mldivide_band: in solving, the ', -info, ' parameter had an illegal value'
    end select

    deallocate(Ab, btmp, ipiv)
    
end function mldivide_band

! normcdf(x,my,sigma) evaluates the normal cdf.
! x is pt to be eval
! mu is mean
! sigma is stdev
elemental function normcdf(x,mu,sigma) result(F)
    implicit none
    real(rt), intent(in) :: x,mu,sigma
    real(rt) :: F
    F=.5e0_rt*(1.e0_rt+erf((x-mu)/(sigma*sqrt_of_2)))
end function normcdf

! Standard normal cdf
elemental function stdnormcdf(x) result(F)
    implicit none
    real(rt), intent(in) :: x
    real(rt) :: F
    F=.5e0_rt*(1e0_rt+erf(x/sqrt_of_2))
end function 

! Normal density
elemental function normpdf(x,mu,sigma) result(f)
    implicit none
    real(rt), intent(in) :: x,mu,sigma
    real(rt) :: f
    !local

    f = exp(-(x-mu)**2/(2e0_rt*sigma**2))/(sigma*sqrt_of_2pi)

end function 

! Inverse of standard normal cdf
function stdnormcdfinv(F) result(x)
    use mod_types
    implicit none
    real(rt), intent(in) :: F
    real(rt) :: x
    interface 
        function r8_normal_01_cdf_inverse(F)
            use mod_types
            implicit none
            real(rt) :: F
            real(rt) :: r8_normal_01_cdf_inverse
        end function
    end interface

    x = r8_normal_01_cdf_inverse(F)

end function 
function normcdfinv(F,mu,sigma) result(x)
    use mod_types
    implicit none
    real(rt), intent(in) :: F,mu,sigma
    real(rt) :: x
    interface 
        function r8_normal_01_cdf_inverse(F)
            use mod_types
            implicit none
            real(rt) :: F
            real(rt) :: r8_normal_01_cdf_inverse
        end function
    end interface

    x = mu + sigma*r8_normal_01_cdf_inverse(F)

end function 

! Standard normal density
elemental function stdnormpdf(x) result(f)
    implicit none
    real(rt), intent(in) :: x
    real(rt) :: f
    !local

    f = exp(-x**2/2e0_rt)/sqrt_of_2pi

end function 



! A driver for the dgesvd LAPACK routine. 
! svd(U,S,V,A) produces matrices such that A = U*S*V' where U and V are
! "unitary" matrices and S is diagonal.
subroutine svd(U,S,V,A_in)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: A_in
    real(rt), dimension(1:size(A_in,1),1:size(A_in,2)), intent(out) :: S    
    real(rt), dimension(1:size(A_in,1),1:size(A_in,1)), intent(out) :: U
    real(rt), dimension(1:size(A_in,2),1:size(A_in,2)), intent(out) :: V
    !local
    real(rt), dimension(1:size(A_in,1),1:size(A_in,2)) :: A
    real(rt), dimension(1:size(A_in,2),1:size(A_in,2)) :: Vt
    real(rt), dimension(1:min(size(A_in,1),size(A_in,2))) :: s_values
    integer :: info
    character(len=1) :: jobu, jobvt
    integer :: m,n,lda,lwork,ldu,ldvt
    real(rt), dimension(:), allocatable :: work

    !Fortran 77 interface (Lapack)
    jobu = 'A'
    jobvt = 'A'
    m = size(A_in,1)
    n = size(A_in,2)
    lda = max(1,m)
    ldu = max(1,m)
    ldvt = max(1,n)
    lwork = 64 * max(3*min(m, n)+max(m, n), 5*min(m,n)) 
    
    allocate(work(1:max(1,lwork)))
    
    A = A_in
    call gesvd(jobu, jobvt, m, n, A, lda, s_values, U, ldu, Vt, ldvt, work, lwork, info) !A = U*S*Vt
    S = diag(s_values)
    V = transpose(Vt)
    
    deallocate(work)

    select case (info)
        case(0)
        case (:-1)
            write(*,*) 'svd: in reduction to bidiagonal, the ', -info, ' parameter had an illegal value'
        case (1:)
            write(*,*) 'svd: WARNING: ', info, ' of the superdiagonals failed to converge.'
    end select    
   
end subroutine svd


! x = nullspace(A,option)
! Computes the nullspace of A (i.e. x s.t. Ax = 0) using singular value decomposition.
! I have an optional argument "option" that normalizes x so it sums to one. Obviously,
! A had better not have full rank (<=> x=0) if this is selected!
! 
function nullspace(A,option) result(x_out)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: A
    real(rt), dimension(1:size(A,2)) :: x_out
    character(len=*), intent(in), optional :: option
    !local
    real(rt), dimension(1:size(A,2)) :: x
    real(rt), dimension(1:size(A,1),1:size(A,2)) :: S
    real(rt), dimension(1:size(A,1),1:size(A,1)) :: U
    real(rt), dimension(1:size(A,2),1:size(A,2)) :: V    
    real(rt) :: zero_toler    
    integer :: j
    logical, dimension(1:size(A,2)) :: is_singularcol
    
    call svd(U,S,V,A) !A = U*S*V'
       
    ! zero_toler = max(size(A,1),size(A,2))*maxval(S)*epsilon(0.e0_rt)
    ! The above was recommended, but I find a slightly higher tolerance is better
    zero_toler = 10e0_rt*max(size(A,1),size(A,2))*maxval(S)*epsilon(0.e0_rt)

    if (count(diag(S)<zero_toler)/=1) then
        print*,'null: nullity of A does not equal one.  '//&
               'This is okay, ... but not for transition matrices which this function was designed for.  '//&
               'Slight modifications are necessary if this is not what you want.'
        print*,'diag(S) should have exactly one element less than zero_toler'
        print*,'zero_toler is', zero_toler
        print*,'diag(S) is ', diag(S)
        print*,' '
        call disp('Matrix given:',A)
        call disp('If did null(eye - transpose(pi)), then pi was',transpose(eye(size(A,1))-A))
        call disp('The summation of pi across rows is',sum(transpose(eye(size(A,1))-A),dim=2))
        print*,'The above''s difference from 1 is ',1e0_rt-sum(transpose(eye(size(A,1))-A),dim=2)
        print*,' ' 
        print*,'If you believe you are using a transition matrix, it is likely that '
        print*,'1) the rows don''t sum to one'
        print*,'2) there are multiple ergodic sets instead of a unique one (indeterminacy)'
        print*,'3) the rows almost sum to one but not precisely'
        STOP
    end if

    is_singularcol = diag(S)<zero_toler
    do j=1,size(V,2)
        if (is_singularcol(j)) x = V(:,j)
    end do

    if (present(option)) then
        if (option=='normalize') then
            x = x/sum(x)
        else 
            write(*,*) 'did you mean normalize? may experience unexpected results'
        end if
    end if

    x_out = x
    
end function nullspace

! Finds all the indices of all the true elements of X.
subroutine find_x_alloc(I,x)
    implicit none
    integer, intent(out), allocatable :: I(:)
    logical, intent(in) :: x(1:)

    allocate(I(count(x)))

    I = pack(colon(1,size(x)),x)

end subroutine find_x_alloc

pure function find_x(X) result(I)
    implicit none
    logical, dimension(1:), intent(in) :: X
    integer, dimension(1:count(X)) :: I
    !local
    integer, dimension(1:size(X)) :: index_vec
    index_vec = colon(1,size(X))
    I = pack(index_vec,X)
end function find_x
! Returns a length k vector. Returns the indices of the first k
! true elements of X. If k true elements of X don't exist, a fatal
! error is called.
function find_xk(X,k) result(I)
    implicit none
    logical, dimension(1:), intent(in) :: X
    integer, intent(in) :: k
    integer, dimension(1:k) :: I !min(count(X),k)
    !local
    integer :: iind,xind
    
    iind = 1
    do xind = 1,size(X)
        if (X(xind)) then
            I(iind) = xind
            if (iind>=k) return
            iind = iind+1            
        end if
    end do
    STOP 'find_xk: ERROR: k true values did not exist'
    I(iind:k) = -1

end function find_xk
! Same as above, but either returns the first k elements or the last k depending on the 
! value of string \in {"first","last"}
function find_xks(X,k,string) result(I)
    implicit none
    logical, dimension(1:), intent(in) :: X
    integer, intent(in) :: k
    integer, dimension(1:k) :: I
    character(len=*), intent(in) :: string
    !local
    integer :: iind,xind

    if (string=='last') then
        iind = 1
        do xind = size(X),1,-1
            if (X(xind)) then
                I(iind) = xind
                if (iind>=k) return
                iind = iind+1            
            end if
        end do
        STOP 'find_xks: WARNING: k true values did not exist'
        I(iind:k) = -1
    elseif (string=='first') then
        iind = 1
        do xind = 1,size(X)
            if (X(xind)) then
                I(iind) = xind
                if (iind>=k) return
                iind = iind+1            
            end if
        end do
        STOP 'find_xks: WARNING: k true values did not exist'
        I(iind:k) = -1
    else 
        STOP 'find_xks: case not found'
    end if

end function find_xks

function find1_xs(X,string) result(I)
    implicit none
    logical, dimension(1:), intent(in) :: X
    integer :: I
    character(len=*), intent(in) :: string
    ! local
    integer :: Ivec(1)

    Ivec = find_xks(X,1,string)
    I = Ivec(1)

end function

! Computes the sample standard deviation estimate of X. The estimate is consistent
! in that it is normalized by sqrt(N-1).
function std_mat(X) result(Y)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: X
    real(rt), dimension(1:size(X,2)) :: Y
    !local
    integer :: N, j
    
    !Check dimensions
    if (size(X,1)<=1) STOP 'std: X must have at least N>1 rows'
    
    N = size(X,1)
    do j = 1,size(X,2)
        Y(j) = std_vec(X(:,j))
    end do
end function std_mat
function std_vec(x,mask) result(y)
    implicit none
    real(rt), dimension(:), intent(in) :: x
    logical, dimension(:), intent(in), optional :: mask
    real(rt) :: y

    if (present(mask)) then
        y = std_core(x,size(x),mask)
    else
        y = std_core(x,size(x))
    end if

end function std_vec

! std_core
function std_core(x,n,mask) result(s)
    implicit none
    real(rt), intent(in) :: x(*)
    integer, intent(in) :: n
    logical, intent(in), optional :: mask(*)
    real(rt) :: s
    ! local
    real(rt) :: Ex,Ex2
    integer :: i,m

    Ex = 0e0_rt
    Ex2 = 0e0_rt
    m = 0
    if (present(mask)) then
        do i = 1,n
            if (mask(i)) then
                Ex = Ex + x(i)
                Ex2 = Ex2 + x(i)**2
                m = m + 1
            end if
        end do
    else
        m = n
        do i = 1,n
            Ex = Ex + x(i)
            Ex2 = Ex2 + x(i)**2
        end do
    end if

    Ex = Ex/m

    s = sqrt(max(0._rt,Ex2/m - Ex**2)) ! in case the std is actually 0, bound at zero so don't take sqrt of -eps

end function 



! corr_core
function corr_core(x,y,n,mask) result(c)
    implicit none
    real(rt), intent(in) :: x(*),y(*)
    integer, intent(in) :: n
    logical, intent(in), optional :: mask(*)
    real(rt) :: c
    ! local
    real(rt) :: Ex,Ey,Ex2,Ey2,Exy,sdx,sdy
    integer :: i,m

    Ex = 0e0_rt
    Ex2 = 0e0_rt
    Ey = 0e0_rt
    Ey2 = 0e0_rt
    Exy = 0e0_rt
    m = 0
    if (present(mask)) then
        do i = 1,n
            if (mask(i)) then
                Ex = Ex + x(i)
                Ey = Ey + y(i)
                Ex2 = Ex2 + x(i)**2
                Ey2 = Ey2 + y(i)**2
                Exy = Exy + x(i)*y(i)
                m = m + 1
            end if
        end do
    else
        m = n
        do i = 1,n
            Ex = Ex + x(i)
            Ey = Ey + y(i)
            Ex2 = Ex2 + x(i)**2
            Ey2 = Ey2 + y(i)**2
            Exy = Exy + x(i)*y(i)
        end do
    end if

    sdx = sqrt(max(0._rt,m*Ex2 - Ex**2)) ! in case numerical error induces = -epsilon, bound at 0
    sdy = sqrt(max(0._rt,m*Ey2 - Ey**2))

    if (sdx>0e0_rt .and. sdy>0e0_rt) then
        c = (m*Exy-Ex*Ey)/sdx/sdy
    else
        c = -sqrt(huge(0._rt))
    end if

end function 

! corr(X,Y) with X,Y vectors, then corr is the unbiased small sample
! correlation estimate.
! See the matlab documentation for the complicated behavior of corr.
function corr_vecs(X,Y) result(rho)
    implicit none
    real(rt), dimension(:), intent(in) :: X, Y
    real(rt) :: rho

    rho = corr_core(x,y,size(x))

!     !local
!     integer :: N
!     
!     !Check dimensions
!     if (size(X,1)/=size(Y,1)) STOP 'corr_vecs: X must have at least N>1 rows'    
!     N = size(X,1)
!     
!     rho = sum((X-mean(X))*(Y-mean(Y)))/(real(N-1,rt)*std(X)*std(Y))
    
end function corr_vecs
function corr_mat(X) result(rho)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: X
    real(rt), dimension(1:size(X,2),1:size(X,2)) :: rho
    !local
    integer :: N, j1,j2
    
    !Check dimensions
    if (size(X,1)<=1) STOP 'corr: X must have at least N>1 rows'    
    N = size(X,1)
    
    do j1 = 1,size(X,2)
        do j2 = 1,size(X,2)
            rho(j1,j2) = corr_vecs(X(:,j1),X(:,j2))
        end do
    end do
    
end function corr_mat
function corr_mats(X1,X2) result(rho)
    
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: X1,X2
    real(rt), dimension(1:size(X1,2),1:size(X2,2)) :: rho
    !local
    integer :: N, j1,j2
    
    !Check dimensions
    if (size(X1,1)<=1) STOP 'corr: X must have at least N>1 rows'    
    if (size(X1,1)/=size(X2,1)) STOP 'corr: X1 and X2 must have the same number of rows'    

    N = size(X1,1)
    
    do j1 = 1,size(X1,2)
        do j2 = 1,size(X2,2)
            rho(j1,j2) = corr_vecs(X1(:,j1),X2(:,j2))
        end do
    end do
    
end function corr_mats
function corr_matvec(X1,X2) result(rho)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: X1
    real(rt), dimension(1:), intent(in) :: X2
    real(rt), dimension(1:size(X1,2)) :: rho
    rho = (/corr_mats(X1,reshape(X2,(/size(X2),1/)))/)
end function corr_matvec
function corr_vecmat(X1,X2) result(rho)
    
    implicit none
    real(rt), dimension(1:), intent(in) :: X1
    real(rt), dimension(1:,1:), intent(in) :: X2
    real(rt), dimension(1:size(X2,2)) :: rho
    rho = (/corr_mats(reshape(X1,(/size(X1),1/)),X2)/)
end function corr_vecmat

! diag(X) for X a matrix produces the diagonal elements of X
! diag(X) for X a vector produces a diagonal matrix with X along the main 
! diagonal and 0 elsewhere.
function diag_mat(X) result(V)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: X
    real(rt), dimension(1:min(size(X,1),size(X,2))) :: V
    !local
    integer :: i
    
    if (size(X,1)/=size(X,2)) write(*,*) 'diag_mat: WARNING: X is not square.'
    
    do i = 1,min(size(X,1),size(X,2))
        V(i) = X(i,i)
    end do

end function diag_mat
function diag_mat_k(X,k) result(V)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: X
    integer, intent(in) :: k
    real(rt), dimension(1:size(X,1)-abs(k)) :: V
    !local
    integer :: i
    
    if (size(X,1)/=size(X,2)) STOP 'diag_mat_k: ERROR: X is not square. This routine needs to be changed to handle that case.'
    if (k>size(X,1)) STOP 'diag_mat_k: ERROR: k exceeds dim of X'
    
    if (k>=0) then
        do i = 1,size(X,1)-abs(k)
            V(i) = X(i,i+k)
        end do
    else
        do i = 1,size(X,1)-abs(k)
            V(i) = X(i-k,i)
        end do
    end if

end function diag_mat_k
pure function diag_vec(V) result(X)
    
    implicit none
    real(rt), dimension(1:), intent(in) :: V
    real(rt), dimension(1:size(V),1:size(V)) :: X
    !local
    integer :: i      
    X = 0.e0_rt
    forall (i = 1:size(V))
        X(i,i) = V(i)
    end forall
end function diag_vec

! Differences x. If x is a matrix, then this is done for each column.
function diff_vec(x) result(d)
    
    implicit none
    real(rt), dimension(1:), intent(in) :: x
    real(rt), dimension(1:size(x,1)-1) :: d
    !local
    integer :: n
    
    n = size(x,1)    
    d = x(2:n)-x(1:n-1)        
    
end function diff_vec

function diff_mat(x) result(d)
    
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: x
    real(rt), dimension(1:size(x,1)-1,1:size(x,2)) :: d
    !local
    integer :: n
    
    n = size(x,1)    
    d = x(2:n,:)-x(1:n-1,:)
    
end function diff_mat

! Sorts x into y. Returns i s.t. x(i) = y. If dim is selected, then 
! sorts along that dimension. If mode is selected, then either sorts
! ascending or descending according to "ascend" / "descend"
subroutine sub_sort_vec_i(y,i,x,dim,mode)
    implicit none
    integer, dimension(1:), intent(in) :: x
    integer, dimension(1:size(x)), intent(inout) :: y
    integer, dimension(1:size(x)), intent(out) :: i
    integer, intent(in), optional :: dim
    character(len=*), intent(in), optional :: mode
    !local
    ! integer, dimension(1:size(x)) :: ylocal
    character(len=20) :: mode_eff

    ! Just here so I don't get bothered about unused variables
    if (present(dim)) then
    end if
        
    mode_eff = 'ascend'
    if (present(mode)) mode_eff = mode

    if (mode_eff=='ascend') then
        y = x
        call defsort(y,i)
    elseif (mode_eff=='descend') then
        y = -x
        call defsort(y,i)
        y = -y
    else
        write(*,*) 'sort: mode not found. stopping'
        STOP
    end if
   
end subroutine sub_sort_vec_i
subroutine sub_sort_vec(y,i,x,dim,mode)
    use mod_sort
    implicit none
    real(rt), dimension(1:), intent(in) :: x
    real(rt), dimension(1:size(x)), intent(inout) :: y
    integer, dimension(1:size(x)), intent(out) :: i
    integer, intent(in), optional :: dim
    character(len=*), intent(in), optional :: mode
    !local
    character(len=20) :: mode_eff

    ! Just here so I don't get bothered about unused variables
    if (present(dim)) then
    end if
        
    mode_eff = 'ascend'
    if (present(mode)) mode_eff = mode

    if (mode_eff=='ascend') then
        y = x
        call defsort(y,i)
    elseif (mode_eff=='descend') then
        y = -x
        call defsort(y,i)
        y = -y
    else
        write(*,*) 'sort: mode not found. stopping'
        STOP
    end if
   
end subroutine sub_sort_vec
subroutine sub_sort_mat(y,i,x,dim,mode)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: x
    real(rt), dimension(1:size(x,1),1:size(x,2)), intent(inout) :: y
    integer, dimension(1:size(x,1),1:size(x,2)), intent(out) :: i
    integer, intent(in), optional :: dim
    character(len=*), intent(in), optional :: mode
    !local
    integer :: ind    
        
    if (present(dim)) then        
        if (dim==2) then
            !sort each row
            do ind = 1,size(x,1)
                if (present(mode)) then
                    call sub_sort_vec(y(ind,:),i(ind,:),x(ind,:),1,mode)
                else
                    call sub_sort_vec(y(ind,:),i(ind,:),x(ind,:))
                end if            
            end do
            return        
        end if
    end if

    !sort each column
    do ind = 1,size(x,2)
        if (present(mode)) then
            call sub_sort_vec(y(:,ind),i(:,ind),x(:,ind),1,mode)
        else
            call sub_sort_vec(y(:,ind),i(:,ind),x(:,ind),1)
        end if
    end do
    
end subroutine sub_sort_mat
function fn_sort_vec(x,dim,mode) result(y)
    
    implicit none
    real(rt), dimension(1:), intent(in) :: x
    real(rt), dimension(1:size(x)) :: y
    integer, intent(in), optional :: dim
    character(len=*), intent(in), optional :: mode
    !local
    integer, dimension(1:size(x)):: i
    integer :: mycase
    
    mycase = merge(1,0,present(dim))+merge(2,0,present(mode))
       
    select case (mycase)
        case (0)
            call sub_sort_vec(y,i,x)
        case (1)
            call sub_sort_vec(y,i,x,dim=dim)
        case (2) 
            call sub_sort_vec(y,i,x,mode=mode)
        case (3)
            call sub_sort_vec(y,i,x,dim,mode)
    end select
    
end function fn_sort_vec


! interp1qs (s for special)
! Linearly interpolate along dimension d of some arbitrarily-dimensioned array y
! To handle arbitrary dimensions, the shape of y must be passed as an argument, as
! well as the desired dimension for interpolation.
! The shape of yi is inferred from the shape of y and the length of xi.
subroutine interp1qs(yi,x,y,xi,d,shapey)
    implicit none
    real(rt), intent(in) :: x(:),xi(:)
    real(rt), intent(in) :: y(*)
    real(rt), intent(out) :: yi(*)
    integer, intent(in) :: d,shapey(:)
    ! 
    integer :: nx,nxi,nlead,nlag

    if (shapey(d)/=size(x)) STOP 'ERROR: interp1qs: shape of y, d, and x do not agree'  

    nx = size(x)
    nxi = size(xi)

    ! To do the interpolation, it is most convenient to reshape y and yi into thre
    ! The first index is dimensions 1,...,d-1 stacked
    ! The second index is dimension d (the interpolation dimension)
    ! The third index is dimensions d+1,...,n stacked
    if (d>1) then
        nlead = product(shapey(1:d-1))
    else
        nlead = 1
    end if

    if (d<size(shapey)) then
        nlag = product(shapey(d+1:size(shapey)))
    else
        nlag = 1
    end if

    ! Call the core interpolation routine
    call interp1qs_core(yi,y,nx,nxi,nlead,nlag,x,xi)
    

end subroutine

    subroutine interp1qs_core(yi,y,nx,nxi,nlead,nlag,x,xi)
        implicit none
        real(rt), intent(in) :: x(:),xi(*)
        integer, intent(in) :: nx,nxi,nlead,nlag
        real(rt), intent(in) :: y(nlead,nx,*)
        real(rt), intent(out) :: yi(nlead,nxi,*)
        integer :: ixi,ilo
        real(rt) :: mlo

        ! When passed y and yi, can access naturally using a three dimensional array
        do ixi = 1,nxi

            ! Get the index ilo s.t. xi(ixi) \in [x(ilo),x(ilo+1)]
            call bsearch(ilo,xi(ixi),x)

            ! Get the corresponding weight
            mlo = (x(ilo+1)-xi(ixi))/(x(ilo+1)-x(ilo))

            ! Do the interpolation step
            yi(1:nlead,ixi,1:nlag) =      mlo *y(1:nlead,ilo  ,1:nlag) + &
                                     (1e0_rt-mlo)*y(1:nlead,ilo+1,1:nlag)

        end do

    end subroutine

! Get interp1q location and weights
subroutine interp1qlocweight(ilo,mlo,xi,x)
    implicit none
    real(rt), intent(in) :: xi,x(:)
    integer, intent(out) :: ilo
    real(rt), intent(out) :: mlo
    
    call bsearch(ilo,xi,x)
    mlo = (x(ilo+1)-xi)/(x(ilo+1)-x(ilo))

end subroutine
subroutine noexinterp1qlocweight(ilo,mlo,xi,x)
    implicit none
    real(rt), intent(in) :: xi,x(:)
    integer, intent(out) :: ilo
    real(rt), intent(out) :: mlo
    
    call bsearch(ilo,xi,x)
    mlo = (x(ilo+1)-xi)/(x(ilo+1)-x(ilo))
    mlo = min(max(0e0_rt,mlo),1e0_rt) 

end subroutine


! interp1q
! Constructs and evaluates the linear interpolant of (x,y), evaluating at xi.
! Assumes x is sorted
function interp1q_scal(x,y,xi) result(yi)
    use mod_interp, only: search
    implicit none
    real(rt), dimension(:), intent(in) :: x,y
    real(rt), intent(in) :: xi
    real(rt) :: yi
    ! local 
    integer :: ilo 

    if (size(x)==size(y) .and. size(x)>1) then
        ! Find the location of xi in the x grid assuming it is sorted
        call search(ilo,xi,x)

        ! Do the interpolation
        yi = y(ilo) + (y(ilo+1)-y(ilo))*(xi-x(ilo))/(x(ilo+1)-x(ilo))
    elseif (size(x)==size(y) .and. size(x)==1) then
        yi = y(1) 
        return
    else
        write(0,*) 'interp1_scal: input: sizes wrong: #x ',size(x),' #y',size(y)
        stop 
    end if

end function interp1q_scal
function interp1q_vec(x,y,xi) result(yi)
    use mod_interp, only: search
    implicit none
    real(rt), dimension(:), intent(in) :: x
    real(rt), dimension(:), intent(in) :: y
    real(rt), dimension(:), intent(in) :: xi
    real(rt), dimension(size(xi)):: yi
    ! local 
    integer :: i

    do i = 1,size(xi)
        yi(i) = interp1q_scal(x,y,xi(i))
    end do

end function interp1q_vec
function interp1q_scal_ymat(x,y,xi) result(yi)
    use mod_interp, only: search
    implicit none
    real(rt), dimension(:), intent(in) :: x
    real(rt), dimension(:,:), intent(in) :: y
    real(rt), intent(in) :: xi
    real(rt), dimension(size(y,2)) :: yi
    ! local 
    integer :: nx, ny
    integer :: ilo 

    nx = size(x)
    ny = size(y,1)
    if (nx/=ny) STOP 'interp1_scal: dims dont agree'
    if (nx==1) then
        yi = y(1,:) 
        return
    end if

    ! Find the location of xi in the x grid assuming it is sorted
    call search(ilo,xi,x)

    ! Do the interpolation
    yi(:) = y(ilo,:) + (y(ilo+1,:)-y(ilo,:))*(xi-x(ilo))/(x(ilo+1)-x(ilo))

end function interp1q_scal_ymat
function interp1q_vec_ymat(x,y,xi) result(yi)
    use mod_interp, only: search
    implicit none
    real(rt), dimension(:), intent(in) :: x
    real(rt), dimension(:,:), intent(in) :: y
    real(rt), dimension(:), intent(in) :: xi
    real(rt), dimension(size(xi),size(y,2)):: yi
    ! local 
    integer :: i

    do i = 1,size(xi)
        yi(i,:) = interp1q_scal_ymat(x,y,xi(i))
    end do

end function interp1q_vec_ymat

! This fast interpolation routine assumes that x and xi are sorted.
function interp1qf_vec(x,y,xi) result(yi)
    implicit none
    real(rt), intent(in) :: x(:),y(:),xi(:)
    real(rt) :: yi(size(xi))
    call interp1qf_core(yi,x,y,xi,1)
end function
function interp1qf_vec_ymat(x,y,xi) result(yi)
    implicit none
    real(rt), intent(in) :: x(:),y(:,:),xi(:)
    real(rt) :: yi(size(xi),size(y,2))
    call interp1qf_core(yi,x,y,xi,size(y,2))
end function
subroutine interp1qf_core(yi,x,y,xi,ncol)
    use mod_interp, only: search
    implicit none
    real(rt), intent(in) :: x(:),y(size(x),*),xi(:)
    integer, intent(in) :: ncol
    real(rt), dimension(size(xi),*), intent(out):: yi
    ! local 
    real(rt) :: mlo
    integer :: i,ilo,m,j

    m = size(x)

    ! Limit the upper bound of the search range by resetting m
    i = size(xi)
    call search(ilo,xi(i),x)
    mlo = (x(ilo+1)-xi(i))/(x(ilo+1)-x(ilo))
    yi(i,1:ncol) = y(ilo,1:ncol)*mlo + y(ilo+1,1:ncol)*(1e0_rt-mlo)
    m = ilo+1 

    ! The lower bound is repeatedly updated below
    ilo = 1

    do i = 1,size(xi)-1

        ! Find the location of xi in the x grid assuming x and xi are sorted
        j = ilo
        call search(ilo,xi(i),x(j:m)) 
        ilo = ilo - 1 + j

        ! print*,'xi(i)',xi(i),'ilo',ilo,'[x,x]',x(ilo:ilo+1)

        ! Do the interpolation
        mlo = (x(ilo+1)-xi(i))/(x(ilo+1)-x(ilo))
        yi(i,1:ncol) = y(ilo,1:ncol)*mlo + y(ilo+1,1:ncol)*(1e0_rt-mlo)

    end do

end subroutine interp1qf_core


! Fast two dimensional interpolation that is similar conceptually
! to interp1q
function interp2q_scal(x1,x2,y,xi1,xi2) result(yi)
    use mod_interp, only: search
    implicit none
    real(rt), dimension(:), intent(in) :: x1,x2
    real(rt), dimension(:,:), intent(in) :: y
    real(rt), intent(in) :: xi1,xi2
    real(rt) :: yi
    ! local 
    integer :: ilo1,ilo2
    real(rt) :: mlo1,mlo2

    if (size(x1)/=size(y,1)) STOP 'ERROR: interp2q_scal_ymat: sizes do not match'
    if (size(x2)/=size(y,2)) STOP 'ERROR: interp2q_scal_ymat: sizes do not match'

    if (size(x1)<=1 .or. size(x2)<=1) then
        STOP 'ERROR: x1 or x2 has size <= 1'
    end if

    ! Find the location of xi in the x grid assuming it is sorted
    call search(ilo1,xi1,x1)
    call search(ilo2,xi2,x2)

    ! Do the interpolation
    mlo1 = (x1(ilo1+1)-xi1)/(x1(ilo1+1)-x1(ilo1))
    mlo2 = (x2(ilo2+1)-xi2)/(x2(ilo2+1)-x2(ilo2))

    yi = y(ilo1  ,ilo2  )*(    mlo1)*(    mlo2) + &
         y(ilo1+1,ilo2  )*(1e0_rt-mlo1)*(    mlo2) + &
         y(ilo1  ,ilo2+1)*(    mlo1)*(1e0_rt-mlo2) + &
         y(ilo1+1,ilo2+1)*(1e0_rt-mlo1)*(1e0_rt-mlo2) 

end function interp2q_scal
function interp2q_scal_ymat(x1,x2,y,xi1,xi2) result(yi)
    use mod_interp, only: search
    implicit none
    real(rt), dimension(:), intent(in) :: x1,x2
    real(rt), dimension(:,:,:), intent(in) :: y
    real(rt), intent(in) :: xi1,xi2
    real(rt), dimension(size(y,3)) :: yi
    ! local 
    integer :: ilo1,ilo2
    real(rt) :: mlo1,mlo2

    if (size(x1)/=size(y,1)) STOP 'ERROR: interp2q_scal_ymat: sizes do not match'
    if (size(x2)/=size(y,2)) STOP 'ERROR: interp2q_scal_ymat: sizes do not match'

    if (size(x1)<=1 .or. size(x2)<=1) then
        STOP 'ERROR: x1 or x2 has size <= 1'
    end if

    ! Find the location of xi in the x grid assuming it is sorted
    call search(ilo1,xi1,x1)
    call search(ilo2,xi2,x2)

    ! Do the interpolation
    mlo1 = (x1(ilo1+1)-xi1)/(x1(ilo1+1)-x1(ilo1))
    mlo2 = (x2(ilo2+1)-xi2)/(x2(ilo2+1)-x2(ilo2))

    yi(:) = y(ilo1  ,ilo2  ,:)*(    mlo1)*(    mlo2) + &
            y(ilo1+1,ilo2  ,:)*(1e0_rt-mlo1)*(    mlo2) + &
            y(ilo1  ,ilo2+1,:)*(    mlo1)*(1e0_rt-mlo2) + &
            y(ilo1+1,ilo2+1,:)*(1e0_rt-mlo1)*(1e0_rt-mlo2) 

end function interp2q_scal_ymat
function interp2q_vec_ymat(x1,x2,y,xi1,xi2) result(yi)
    use mod_interp, only: search
    implicit none
    real(rt), dimension(:), intent(in) :: x1,x2,xi1,xi2
    real(rt), dimension(:,:,:), intent(in) :: y
    real(rt), dimension(size(xi1),size(xi2),size(y,3)):: yi
    ! local 
    integer :: i1,i2

    if (size(x1)/=size(y,1)) STOP 'ERROR: interp2q_vec_ymat: sizes do not match'
    if (size(x2)/=size(y,2)) STOP 'ERROR: interp2q_vec_ymat: sizes do not match'

    do i2 = 1,size(xi2)
        do i1 = 1,size(xi1)
            yi(i1,i2,:) = interp2q_scal_ymat(x1,x2,y,xi1(i1),xi2(i2))
        end do
    end do

end function interp2q_vec_ymat

! interp1
! Constructs and evaluates the linear interpolant of (x,y), evaluating at xi.
function interp1_scal_3d(x,y,xi) result(yi)
    implicit none
    real(rt), dimension(:), intent(in) :: x
    real(rt), dimension(:,:,:), intent(in) :: y
    real(rt), intent(in) :: xi
    real(rt), dimension(size(y,2),size(y,3)) :: yi
    ! local

    call interp1_scal_core(yi,x,y,xi,size(x),size(y,2)*size(y,3))

end function 
function interp1_scal_mat(x,y,xi) result(yi)
    implicit none
    real(rt), dimension(:), intent(in) :: x
    real(rt), dimension(:,:), intent(in) :: y
    real(rt), intent(in) :: xi
    real(rt), dimension(size(y,2)) :: yi
    ! local

    call interp1_scal_core(yi,x,y,xi,size(x),size(y,2))

end function 
function interp1_scal(x,y,xi) result(yi)
    implicit none
    real(rt), dimension(1:), intent(in) :: x
    real(rt), dimension(1:), intent(in) :: y
    real(rt), intent(in) :: xi
    real(rt) :: yi
    ! local
    real(rt) :: yitmp(1)

    call interp1_scal_core(yitmp,x,y,xi,size(x),1)
    yi = yitmp(1)

end function interp1_scal
subroutine interp1_scal_core(yi,x,y,xi,nx,ncol)
    implicit none
    integer, intent(in) :: nx,ncol
    real(rt), dimension(:), intent(in) :: x
    real(rt), dimension(nx,*), intent(in) :: y
    real(rt), intent(in) :: xi
    real(rt), dimension(*):: yi
    !local for new algorithm   
    integer :: i, ilo, ihi, ilo_old, ihi_old

    !Special algorithm for xi==1
    if (nx/=size(x)) STOP 'ERROR: interp1_scal_core: x doesnt have nx elements'
    if (nx==1) then
        yi(1:ncol) = y(1,1:ncol) 
        return
    end if

    ! Find the closest indices below and above xi. That is, find i,j s.t. x(i)<=xi<=x(j)
    ilo = -1
    ihi = -1
    ilo_old = -1
    ihi_old = -1
    do i = 1,nx
        if (x(i)<xi) then
            ! Determine whether x(i) is greater than current x(ilo). If it is, replace ilo with i
            if (ilo/=-1) then
                ! We keep the order x(ilo_old)<=x(ilo)<xi whenever ilo_old/=-1/=ilo
                if (x(i)>x(ilo)) then
                    ilo_old = ilo
                    ilo = i
                elseif (ilo_old==-1) then
                    ilo_old = i
                elseif (x(i)>x(ilo_old)) then
                    ilo_old = i
                end if
            else 
                ilo = i
            end if
        elseif (x(i)>xi) then
            ! Determine whether x(i) is less than current x(ihi). If it is, replace ihi with i
            if (ihi/=-1) then
                ! We keep the order x(ihi_old)>=x(ihi)>xi whenever ihi_old/=-1/=ihi
                if (x(i)<x(ihi)) then
                    ihi_old = ihi
                    ihi = i
                elseif (ihi_old==-1) then
                    ihi_old = i
                elseif (x(i)<x(ihi_old)) then
                    ihi_old = i
                end if
            else
                ihi = i
            end if
        else
            ! Exact match, so return value
            yi(1:ncol) = y(i,1:ncol)
            return
        end if
    end do

    ! If still here, have found bracketing interval.
    ! If ilo/=-1 and ihi/=-1, then have x(ilo)<xi<x(ihi) and x(ilo) largest and x(ihi) smallest that satisfy.
    ! If ilo==-1 and ihi/=-1, then xi_in is less than any value of x. Consequently, ihi and ihi_old are the bracketing interval.
    ! If ilo/=-1 and ihi==-1, then xi_in is greater than any value of x. Consequently, ilo and ilo_old are the bracketing interval.
    ! The case of ilo==-1 and ihi==-1 is impossible, because either ilo or ihi is replaced at each step or the function returns
    if (ilo/=-1 .and. ihi/=-1) then
    elseif (ilo==-1 .and. ihi/=-1) then
        if (ihi_old==-1) then
            print*,'xi',xi
            print*,'x',x
            STOP 'interp1_scal: ERROR: not expecting ihi_old to be -1 here'
        end if
        ! ihi and ihi_old bracket it
        ilo = ihi_old
    elseif (ilo/=-1 .and. ihi==-1) then
        if (ilo_old==-1) then
            print*,'xi',xi
            print*,'x',x
            STOP 'interp1_scal: ERROR: not expecting ilo_old to be -1 here'
        end if
        ihi = ilo_old
    else
        print*,'ilo',ilo
        print*,'ihi',ihi
        print*,'xi',xi
        print*,'x',x
        STOP 'interp1_scal: ERROR: not expecting this case'
    end if

    ! Do the linear interpolation.
!     print*,'x',x
!     print*,'xi',xi
!     print*,'x(ilo)',x(ilo)
!     print*,'x(ihi)',x(ihi)
!     print*,'ilo',ilo
!     print*,'ihi',ihi

    yi(1:ncol) = y(ilo,1:ncol) + (y(ihi,1:ncol)-y(ilo,1:ncol))*(xi-x(ilo))/(x(ihi)-x(ilo))

end subroutine interp1_scal_core

function interp1_vec(x_in,y_in,xi_in) result(yi_out)
    implicit none
    real(rt), dimension(:), intent(in) :: x_in
    real(rt), dimension(:), intent(in), target :: y_in
    real(rt), dimension(:), intent(in) :: xi_in
    real(rt), dimension(size(xi_in)), target :: yi_out
    !local
!     real(rt), dimension(1:size(y_in),1:1) :: y
!     real(rt), dimension(1:size(xi_in),1:1) :: yi
!     real(rt), pointer :: y_in_ptr(:,:)

    ! Instead of doing the explict copying here, I should use pointers to "reshape" the values
!     y(:,1) = y_in    
!     yi = interp1_mat(x_in,y,xi_in)
!     yi_out = yi(:,1)


!     ! Create a pointer to y_in to reshape it implicitly, then call interp1_mat routine
!     y_in_ptr(1:size(y_in),1:1) => y_in
!     yi_out = reshape(interp1_mat(x_in,y_in_ptr,xi_in),(/size(xi_in)/))

    call interp1_core(yi_out,x_in,y_in,xi_in,size(x_in),size(xi_in),1)

end function interp1_vec

function interp1_3dim(x_in,y_in,xi_in) result(yi_out)
    use mod_sort, only: issorted
    implicit none
    real(rt), dimension(:), intent(in) :: x_in
    real(rt), dimension(:,:,:), intent(in) :: y_in
    real(rt), dimension(:), intent(in) :: xi_in
    real(rt), dimension(size(xi_in),size(y_in,2),size(y_in,3)) :: yi_out
    !local
!     integer :: ind
! 
!     ! Instead of doing the explict copying here, I should use pointers to "reshape" the values
!     do ind = 1,size(y_in,3)
!         yi_out(:,:,ind) = interp1_mat(x_in,y_in(:,:,ind),xi_in)
!     end do

    call interp1_core(yi_out,x_in,y_in,xi_in,size(x_in),size(xi_in),size(y_in,2)*size(y_in,3))

end function interp1_3dim

function interp1_mat(x_in,y_in,xi_in) result(yi_out)    
    use mod_sort, only: issorted
    implicit none
    real(rt), dimension(1:), intent(in) :: x_in
    real(rt), dimension(1:,1:), intent(in) :: y_in
    real(rt), dimension(1:), intent(in) :: xi_in
    real(rt), dimension(1:size(xi_in),1:size(y_in,2)) :: yi_out

    call interp1_core(yi_out,x_in,y_in,xi_in,size(x_in),size(xi_in),size(y_in,2)) 

!     !local
!     real(rt), allocatable :: x(:),y(:,:),xi(:),yi(:,:),theta(:)
!     integer, allocatable :: Isortx(:),Isortxi(:),Irecoverxi(:),xLoInds(:)
!     integer :: nx,nxi,col_ind,ncol,xi_ind,ny
!     logical :: issorted_ascend_x,issorted_descend_x,issorted_ascend_xi,issorted_descend_xi
! 
!     allocate(xLoInds(1:size(xi_in)))
!     allocate(theta(1:size(xi_in)))
!     allocate(x(1:size(x_in)))
!     allocate(y(1:size(y_in,1),1:size(y_in,2)))
!     allocate(xi(1:size(xi_in)))
!     allocate(yi(1:size(xi_in),1:size(y_in,2))) 
!     allocate(Isortx(1:size(x_in)))
!     allocate(Isortxi(1:size(xi_in)),Irecoverxi(1:size(xi_in)))
! 
!     nx = size(x_in)
!     ny = size(y_in,1)
!     ncol = size(y_in,2)
!     nxi = size(xi_in)
!  
!     if (nx/=ny) STOP 'interp1: x and y do not conform'
! 
!     x = x_in
!     y = y_in
!     xi = xi_in
! 
!     if (any(isNaN(xi))) then
!         write(*,*) 'xi'
!         call disp(xi)
!         STOP 'interp1: xi contains NaNs'
!     end if
! 
!     !Check whether data is sorted either in ascending or descending order
!     issorted_ascend_x = issorted(x,'ascend')
!     issorted_descend_x = .FALSE.
!     if (.NOT. issorted_ascend_x) issorted_descend_x = issorted(x,'descend')
! 
!     issorted_ascend_xi = issorted(xi,'ascend')
!     issorted_descend_xi = .FALSE.
!     if (.NOT. issorted_ascend_xi) issorted_descend_xi = issorted(xi,'descend')
! 
!     !Sort ascending if data is not sorted
!     if (issorted_ascend_x) then
!         !Do nothing
!     elseif (issorted_descend_x) then
!         !Reverse the order or x and y
!         x = reverse(x)
!         y = reverse_mat(y)
!     else
!         call sort2(x,Isortx,x)
!         do col_ind = 1,ncol
!             y(:,col_ind) = y(Isortx,col_ind)
!         end do
!     end if
!     if (issorted_ascend_xi) then
!         !Do nothing
!     elseif (issorted_descend_xi) then
!         xi = reverse(xi)
!     else
!         call sort2(xi,Isortxi,xi)
!         Irecoverxi(Isortxi) = 1 .colon. nxi
!     end if
! 
!     !NEW ALGORITHM: FIRST FINDS INDICES FOR TWO POINTS USED IN INTERPOLATING, SECOND DOES THE CALCULATION
! 
!     !Find bracketing intervals for all xi
!     xi_ind = 1
!     call bsearch(xLoInds(xi_ind),xi(xi_ind),x)
!     if (xLoInds(xi_ind)+1>nx) STOP 'interp1_mat: error'
! 
!     do xi_ind = 2,nxi
!         call bsearch(xLoInds(xi_ind),xi(xi_ind),x(xLoInds(xi_ind-1):nx)) 
!               !Since xi is ascending, we need only check the upper interval
!         xLoInds(xi_ind) = xLoInds(xi_ind) + xLoInds(xi_ind-1) - 1
!         if (xLoInds(xi_ind)+1>nx) STOP 'interp1_mat: error'    
!     end do
! 
!     ! Perform the interpolation
!     theta = (xi-x(xLoInds))/(x(xLoInds+1)-x(xLoInds))
!     do col_ind = 1,ncol
!         yi(:,col_ind) = y(xLoInds,col_ind) + theta*(y(xLoInds+1,col_ind)-y(xLoInds,col_ind))
!     end do
! 
!     !Unsort the data
!     if (issorted_ascend_xi) then
!         !Do nothing
!     elseif (issorted_descend_xi) then
!         yi = reverse_mat(yi)
!     else
!         do col_ind = 1,ncol
!             yi(:,col_ind) = yi(Irecoverxi,col_ind)
!         end do
!     end if
! 
!     !Write to result
!     yi_out = yi
! 
!     ! Clean up
!     deallocate(x,y,xi,yi,Isortx,Isortxi,Irecoverxi,xLoInds,theta)

end function interp1_mat

subroutine interp1_core(yi_out,x_in,y_in,xi_in,nx,nxi,ncol) 
    use mod_sort, only: issorted
    implicit none
    integer, intent(in) :: nx,nxi,ncol
    real(rt), dimension(:), intent(in) :: x_in
    real(rt), dimension(:), intent(in) :: xi_in
    real(rt), dimension(nx,*), intent(in) :: y_in
    real(rt), dimension(nxi,*) :: yi_out
    !local
    real(rt), allocatable :: x(:),y(:,:),xi(:),yi(:,:),theta(:)
    integer, allocatable :: Isortx(:),Isortxi(:),Irecoverxi(:),xLoInds(:)
    integer :: col_ind,xi_ind,ny 
    logical :: issorted_ascend_x,issorted_descend_x,issorted_ascend_xi,issorted_descend_xi

    ny = nx

    allocate(xLoInds(nxi))
    allocate(theta(nxi))
    allocate(x(nx))
    allocate(y(nx,ncol))
    allocate(xi(nxi))
    allocate(yi(nxi,ncol)) 
    allocate(Isortx(nx))
    allocate(Isortxi(nxi),Irecoverxi(nxi))
 
    if (nx/=size(x)) STOP 'interp1: x and nx do not agree'
    if (nxi/=size(xi)) STOP 'interp1: x and nx do not agree'

    ! Cover over inputs
    x = x_in
    y = y_in(:,1:ncol)
    xi = xi_in

!     if (any(isNaN(xi))) then
!         call disp('xi',xi)
!         STOP 'interp1: xi contains NaNs'
!     end if

    ! Check whether data is sorted either in ascending or descending order
    issorted_ascend_x = issorted(x,'ascend')
    issorted_descend_x = .FALSE.
    if (.NOT. issorted_ascend_x) issorted_descend_x = issorted(x,'descend')

    issorted_ascend_xi = issorted(xi,'ascend')
    issorted_descend_xi = .FALSE.
    if (.NOT. issorted_ascend_xi) issorted_descend_xi = issorted(xi,'descend')

    ! Sort ascending if data is not sorted
    if (issorted_ascend_x) then
        !Do nothing
    elseif (issorted_descend_x) then
        !Reverse the order or x and y
        x = reverse(x)
        y = reverse_mat(y)
    else
        call sort2(x,Isortx,x)
        do col_ind = 1,ncol
            y(:,col_ind) = y(Isortx,col_ind)
        end do
    end if
    if (issorted_ascend_xi) then
        !Do nothing
    elseif (issorted_descend_xi) then
        xi = reverse(xi)
    else
        call sort2(xi,Isortxi,xi)
        Irecoverxi(Isortxi) = colon(1,nxi)
    end if

    ! NEW ALGORITHM: FIRST FINDS INDICES FOR TWO POINTS USED IN INTERPOLATING, SECOND DOES THE CALCULATION

    ! Find bracketing intervals for all xi
    xi_ind = 1
    call bsearch(xLoInds(xi_ind),xi(xi_ind),x)
    if (xLoInds(xi_ind)+1>nx) STOP 'interp1_mat: error'

    do xi_ind = 2,nxi
        call bsearch(xLoInds(xi_ind),xi(xi_ind),x(xLoInds(xi_ind-1):nx)) !Since xi is ascending, 
                                                                         ! we need only check the upper interval
        xLoInds(xi_ind) = xLoInds(xi_ind) + xLoInds(xi_ind-1) - 1
        if (xLoInds(xi_ind)+1>nx) STOP 'interp1_mat: error'    
    end do

    ! Perform the interpolation
    ! NOTE: this could be expressed as matrix multiplication of yi = y + matmul(theta,...)
    theta = (xi-x(xLoInds))/(x(xLoInds+1)-x(xLoInds))
    do col_ind = 1,ncol
        yi(:,col_ind) = y(xLoInds,col_ind) + theta*(y(xLoInds+1,col_ind)-y(xLoInds,col_ind))
    end do

    ! Unsort the data
    if (issorted_ascend_xi) then
        !Do nothing
    elseif (issorted_descend_xi) then
        yi = reverse_mat(yi)
    else
        do col_ind = 1,ncol
            yi(:,col_ind) = yi(Irecoverxi,col_ind)
        end do
    end if

    ! Write to result
    yi_out(:,1:ncol) = yi

    ! Clean up
    deallocate(x,y,xi,yi,Isortx,Isortxi,Irecoverxi,xLoInds,theta)

end subroutine interp1_core

! Changes the order of the elements in x
function reverse(x) result(xr)
    
    implicit none
    real(rt), dimension(1:), intent(in) :: x
    real(rt), dimension(1:size(x)) :: xr
    !local
    integer :: i,nx
    nx = size(x)
    do i = 1,nx
        xr(i) = x(nx-i+1)
    end do
end function reverse
! Changes the order of the rows in y
function reverse_mat(y) result(yr)
    implicit none
    real(rt), dimension(1:,1:), intent(in) :: y
    real(rt), dimension(1:size(y,1),1:size(y,2)) :: yr
    !local
    integer :: i,ny
    ny = size(y,1)
    do i = 1,ny
        yr(i,:) = y(ny-i+1,:)
    end do
end function reverse_mat

! Compute the cumulative product of the vector x
function cumprod_r(x) result(y)
    implicit none
    real(rt), intent(in) :: x(1:)
    real(rt) :: y(size(x))
    !local
    real(rt) :: tmp
    integer :: i


    y(1) = x(1)
    tmp = x(1)
    do i = 2,size(x)
        tmp = tmp*x(i)
        y(i) = tmp
    end do

end function cumprod_r

function cumprod_i(x) result(y)
    implicit none
    integer, intent(in) :: x(1:)
    integer  :: y(size(x))
    !local
    integer :: tmp
    integer :: i

    y(1) = x(1)
    tmp = x(1)
    do i = 2,size(x)
        tmp = tmp*x(i)
        y(i) = tmp
    end do

end function cumprod_i

end module mod_matlab


!!! TEST ROUTINES FOR MOD_MATLAB
module mod_matlab_test
    use mod_matlab
    implicit none
contains

    !!! A

    !!! B
    !!! C
    subroutine test_colon
        implicit none
        integer :: x(6)

        x = colon(-3,2)
        if (any(x/=(/-3,-2,-1,0,1,2/))) STOP 'test_colon: failed test 1'
        
        print*,'test_colon: passed'
    end subroutine test_colon
    subroutine test_cumsum
        implicit none
        real(rt) :: A(5),cumA(5),cumAtrue(5)
        real(rt), parameter :: approx0 = epsilon(0.e0_rt)

        A = (/100e0_rt,-3.e0_rt,17e0_rt,-1.e0_rt, 2e0_rt/)
        cumAtrue = reshape((/100e0_rt,97e0_rt,114e0_rt,113e0_rt,115e0_rt/),(/5/))
        cumA = cumsum(A)
        
        if (maxval(abs(cumA-cumAtrue))>approx0) STOP 'test_cumsum: cumsum failed test 1'

        ! Matlab code
!         A = [100,-3,17,-1,2]';
!         formatMatFortran(cumsum(A))

        print*,'test_cumsum: passed'

    end subroutine test_cumsum
    !!! D
    !!! E
    subroutine test_eye
        implicit none
        real(rt) :: A(1,1), B(2,2)

        A = eye(1)
        B = eye(2)

        if (A(1,1)/=1.e0_rt) STOP 'test_eye: eye failed test 1'        
        if (abs(B(1,1)-1e0_rt)>1d-15 .or. abs(B(2,2)-1e0_rt)>1d-15 &
           .or. abs(B(1,2))>1d-15 .or. abs(B(2,1))>1d-15) STOP 'test_eye: eye failed test 2'
        print*,'B',B
        if (any(B/=reshape((/1e0_rt,0e0_rt,0e0_rt,1e0_rt/),(/2,2/)))) STOP 'test_eye: eye failed test 3'

        print*,'test_eye: passed'
    end subroutine test_eye
    !!! F
    subroutine test_find
        implicit none
        real(rt) :: x(100)
        integer :: I(6), J(2), K(1)

        x = linspace(-6.1e0_rt,5.1e0_rt,100)
        I = find(x>4e0_rt .and. x<4.7e0_rt)
        if (any(I/=(/91,92,93,94,95,96/))) then
            print*,'I',I
            print*,'X(I)',X(I)
            STOP 'test_find: failed test 1'
        end if
        J = find(x>4e0_rt .and. x<4.7e0_rt,2,'first')
        if (any(J/=(/91,92/))) STOP 'test_find: failed test 2'
        K = find(x>4e0_rt .and. x<4.7e0_rt,1,'last')
        if (any(K/=(/96/))) STOP 'test_find: failed test 3'

        !Matlab Code
!         x = linspace(-6e0_rt,5e0_rt);
!         tmp = x>4e0_rt & x<4.7e0_rt;
!         I = find(tmp);        
!         formatMatFortran(I,1)
!         I = find(tmp,2,'first');
!         formatMatFortran(I,1)
!         I = find(tmp,1,'last');
!         formatMatFortran(I,1)

        print*,'test_find: passed'
    end subroutine test_find
    !!! G
    !!! H
    !!! I
    subroutine test_interp1
        implicit none
        real(rt) :: x(5),y(5,2), xi(8), yi(8,2), yitrue(8,2)
        integer :: i,j
        real(rt), parameter :: approx0 = epsilon(0.e0_rt)*1d3
        real(rt) :: tmp
        x = (/1.e0_rt, -1.1e0_rt, 2.2e0_rt, 5.e0_rt,-3.e0_rt/)
        y(:,1) = .5e0_rt*x + 1e0_rt
        y(:,2) = x**3
        xi = (/-6.e0_rt,1.1e0_rt,-3.e0_rt,-1.1e0_rt,-.5e0_rt,3.33e0_rt,10e0_rt,0e0_rt/) !Contains some interpolation, 
                                !some extrapolation, and some exact values in arbitrary order
        yitrue = reshape((/-2e0_rt,1.55e0_rt,-0.5e0_rt,0.45e0_rt,0.75e0_rt,2.665e0_rt,6e0_rt,1e0_rt,-67.53e0_rt,&
                    1.804e0_rt,-27e0_rt,-1.331e0_rt,-0.665e0_rt,56.7972e0_rt,329.2e0_rt,-0.11e0_rt/),(/8,2/))

        ! Test interp1(vec,mat,vec)
        yi = interp1(x,y,xi)
        if (maxval(abs(yi-yitrue))>approx0) STOP 'test_interp1: interp1 failed test 1'

        ! Test interp1(vec,vec,pt)
        yi = -sqrt(huge(0._rt))
        do j = 1,size(yi,2)
            do i = 1,size(yi,1)
                yi(i,j) = interp1(x,y(:,j),xi(i))
                if (abs(yi(i,j)-yitrue(i,j))>approx0) then
                    print*,'y',y(:,j)
                    print*,'yi',yi(i,j)
                    print*,'yitrue',yitrue(i,j)
                    STOP 'test_interp1: interp1 failed test 2'
                end if
            end do
        end do

        

        ! Test interp1(vec,vec,vec)
        yi = -huge(0e0_rt)
        do j = 1,size(yi,2)
            yi(:,j) = interp1(x,y(:,j),xi)
        end do        
        if (maxval(abs(yi-yitrue))>approx0) STOP 'test_interp1: interp1 failed test 3'

        ! Matlab code
!         x = [1,-1.1,2.2,5,-3]';
!         xi = [-6.e0_rt,1.1e0_rt,-3.e0_rt,-1.1e0_rt,-.5e0_rt,3.33e0_rt,10e0_rt,0e0_rt]';
!         y(:,1) = .5*x + 1;
!         y(:,2) = x.^3;
!         yitrue = interp1(x,y,xi,'linear','extrap');
!         formatMatFortran(yitrue)


        tmp = interp1(&
        (/ 0.24576e0_rt, 0.27585e0_rt, 0.30594e0_rt, 0.33604e0_rt, 0.36613e0_rt, &
        0.39622e0_rt, 0.42631e0_rt, 0.45641e0_rt, 0.4865e0_rt, 0.51659e0_rt, &
        0.54668e0_rt, 0.57678e0_rt, 0.60687e0_rt, 0.63696e0_rt, 0.66705e0_rt, &
        0.69715e0_rt, 0.72724e0_rt, 0.75733e0_rt, 0.78743e0_rt, 0.81752e0_rt, &
        0.84761e0_rt, 0.8777e0_rt, 0.9078e0_rt, 0.93789e0_rt, 0.96798e0_rt, &
        0.99807e0_rt, 1.02817e0_rt, 1.05826e0_rt, 1.08835e0_rt, 1.11845e0_rt, &
        1.14854e0_rt, 1.17863e0_rt, 1.20872e0_rt, 1.23882e0_rt, 1.26891e0_rt, &
        1.299e0_rt, 1.32909e0_rt, 1.35919e0_rt, 1.38928e0_rt, 1.41937e0_rt, &
        1.44947e0_rt, 1.47956e0_rt, 1.50965e0_rt, 1.53974e0_rt, 1.56984e0_rt, &
        1.59993e0_rt, 1.63002e0_rt, 1.66011e0_rt, 1.69021e0_rt, 1.7203e0_rt/), &
        real(colon(1,50),rt),0.245757053346832e0_rt)

        if (abs(tmp-0.999902072011698e0_rt)>1e-6_rt) then
            print*,'tmp',tmp
            STOP 'test_interp1: interp1 failed test 4' 
        end if

        print*,'test_interp1: passed'

    end subroutine test_interp1
    subroutine test_interp1q()
        call test_interp1q_opt(1)
    end subroutine
    subroutine test_interp1qf()
        call test_interp1q_opt(2)
    end subroutine
    subroutine test_interp1q_opt(opt)
        implicit none
        integer, intent(in) :: opt
        real(rt) :: x(7), y(7), xi(6), yi(6),yitrue(6)
        integer :: i

        x = (/ -12.1e0_rt, -0.1e0_rt, 0e0_rt, 0.2e0_rt, 4e0_rt, 9e0_rt, 100e0_rt/)
        y = x**3 - 10e0_rt*x
        xi = (/ -13e0_rt, -0.1e0_rt, -0.05e0_rt, 0e0_rt, 5e0_rt, 99.6e0_rt/)
        yitrue = (/ -1774.428e0_rt, 0.999e0_rt, 0.4995e0_rt, 0e0_rt, 147e0_rt, 9.946115999999999e+05_rt/)

        ! Test the vec routine
        if (opt==1) then
            yi = interp1q(x,y,xi)
        else
            yi = interp1qf(x,y,xi)
            print*,'yi',yi,'yitrue',yitrue
        end if
        if (any(abs(yi-yitrue)>100e0_rt*epsilon(0e0_rt)*abs(yitrue))) STOP 'test_interp1q: failed test 1'

        ! Test the scal routine
        do i = 1,size(xi)
            if (opt==1) then
                yi(i) = interp1q(x,y,xi(i))
            else
                yi(i) = interp1qf(x,y,xi(i))
            end if
        end do
        if (any(abs(yi-yitrue)>100e0_rt*epsilon(0e0_rt)*abs(yitrue))) STOP 'test_interp1q: failed test 2'
        
        ! Test random data against interp1
        call random_seed

        call random_number(x)
        x = x + .00000001e0_rt
        x = cumsum(x) ! x is now random, but increasing
        call random_number(y)
        y = 10e0_rt*y ! y is random 

        call random_number(xi)
        xi = x(1) + (x(size(x))-x(1))*xi 
        xi(1) = minval(x) - .01e0_rt
        xi(2) = maxval(x) + .01e0_rt

        if (opt==1) then
            yi = interp1q(x,y,xi)
            yitrue = interp1(x,y,xi)
            if (any(abs(yi-yitrue)>100e0_rt*epsilon(0e0_rt)*abs(yitrue))) &
                STOP 'test_interp1q: failed test 3: interp1 and interp1q don''t agree'
        else
            ! Can't do unsorted xi
        end if

        print*, 'test_interp1q: passed'

    end subroutine 
    subroutine test_interp1qs()
        implicit none
        real(rt) :: x(7), y(7), xi(6), yi(6),yitrue(6), y2(20,7,5), yi2(20,6,5), err(20,6,5)
        integer :: i,j

        x = (/ -12.1e0_rt, -0.1e0_rt, 0e0_rt, 0.2e0_rt, 4e0_rt, 9e0_rt, 100e0_rt/)
        y = x**3 - 10e0_rt*x
        xi = (/ -13e0_rt, -0.1e0_rt, -0.05e0_rt, 0e0_rt, 5e0_rt, 99.6e0_rt/)
        yitrue = (/ -1774.428e0_rt, 0.999e0_rt, 0.4995e0_rt, 0e0_rt, 147e0_rt, 9.946115999999999e+05_rt/)

        ! Test the routine for just vectors
        call interp1qs(yi,x,y,xi,1,shape(y))
        if (any(abs(yi-yitrue)>100e0_rt*epsilon(0e0_rt)*abs(yitrue))) STOP 'test_interp1qs: failed test 1'

!         print*,'yi',yi
!         print*,'yitrue',yitrue

        ! Test the routine by interpolating in the second dimension.
        ! Have the function just be the i*(x**3 - 10e0_rt*x) + j
        do j = 1,size(y2,3)
            do i = 1,size(y2,1)
                y2(i,:,j) = y*real(i,rt) + real(j,rt)
            end do
        end do

        call interp1qs(yi2,x,y2,xi,2,shape(y2))

        do j = 1,size(y2,3)
            do i = 1,size(y2,1)
                err(i,:,j) =  yi2(i,:,j) - real(i,rt)*yitrue - real(j,rt)
                if (any(abs(err(i,:,j))>100e0_rt*epsilon(0e0_rt)*abs(real(i,rt)*yitrue+real(j,rt)))) STOP 'test_interp1qs: failed test 2'
            end do
        end do


        ! Test the scal routine
!         do i = 1,size(xi)
!             yi(i) = interp1q(x,y,xi(i))
!         end do
!         if (any(abs(yi-yitrue)>100e0_rt*epsilon(0e0_rt)*abs(yitrue))) STOP 'test_interp1q: failed test 2'
!         
!         ! Test random data against interp1
!         call random_seed
! 
!         call random_number(x)
!         x = x + .00000001e0_rt
!         x = cumsum(x) ! x is now random, but increasing
!         call random_number(y)
!         y = 10e0_rt*y ! y is random 
! 
!         call random_number(xi)
!         xi = x(1) + (x(size(x))-x(1))*xi 
!         xi(1) = minval(x) - .01e0_rt
!         xi(2) = maxval(x) + .01e0_rt
! 
!         yi = interp1q(x,y,xi)
!         yitrue = interp1(x,y,xi)
!         if (any(abs(yi-yitrue)>100e0_rt*epsilon(0e0_rt)*abs(yitrue))) &
!             STOP 'test_interp1q: failed test 3: interp1 and interp1q don''t agree'
! 
        print*, 'test_interp1qs: passed'

    end subroutine 
    !!! J
    !!! K
    !!! L
    subroutine test_linspace
        implicit none
        real(rt) :: a,b
        integer :: n
        real(rt), parameter :: approx0 = epsilon(0.e0_rt)
        a = -3e0_rt
        b = 4e0_rt
        n = 5
        if (maxval(abs((/-3e0_rt,-1.25e0_rt,0.5e0_rt,2.25e0_rt,4e0_rt/) - linspace(a,b,n)))>approx0) &
            STOP 'test_linspace: linspace failed test 1'

        print*,'test_linspace: passed'

    end subroutine test_linspace
    !!! M
    subroutine test_mtimes
        implicit none
        real(rt) :: A(2,3),B(3,4),C(2,4), Ctrue(2,4), D(4), E(3), Etrue(3), F(2), G(4), Gtrue(4)
        real(rt), parameter :: approx0 = sqrt(epsilon(0.e0_rt))

        A = reshape((/2e0_rt,-6e0_rt,5e0_rt,12e0_rt,1.1e0_rt,0e0_rt/),(/2,3/))
        B = reshape((/-0.01e0_rt,6e0_rt,100e0_rt,1e0_rt,5e0_rt,-1e0_rt,3.1e0_rt,4e0_rt,-100e0_rt,9e0_rt,3e0_rt,0e0_rt/),(/3,4/))
        Ctrue = reshape((/139.98e0_rt,72.06e0_rt,25.9e0_rt,54e0_rt,-83.8e0_rt,29.4e0_rt,33e0_rt,-18e0_rt/),(/2,4/))
        D = (/-1.2e0_rt,-1.4e0_rt,6e0_rt,9e0_rt/)
        Etrue = [98.212e0_rt,36.8e0_rt,-718.6e0_rt]
        F = (/-2e0_rt,-1e0_rt/)
        Gtrue = (/-352.02e0_rt,-105.8e0_rt,138.2e0_rt,-48e0_rt/)

        call mtimes(C,A,B)
        call mtimes(E,B,D)
        call mtimes(G,transpose(C),F) !G=F*C = (C'*F')' with F and G vectors so no transpose required

        if (maxval(abs(C-Ctrue))>approx0*maxval(abs(Ctrue))) STOP 'test_mtimes: mtimes failed test 1'
        if (maxval(abs(E-Etrue))>approx0*maxval(abs(Etrue))) then
            print*,'E',E
            print*,'Etrue',Etrue
            STOP 'test_mtimes: mtimes failed test 2'
        end if
        if (maxval(abs(G-Gtrue))>approx0*maxval(abs(Gtrue))) STOP 'test_mtimes: mtimes failed test 3'

        !Matlab code
!         A = [2 5 1.1; -6 12 0];
!         B = [-.01 1 3.1 9; 6 5 4 3; 100 -1 -100 0];
!         C = A*B;
!         formatMatFortran(C)
!         D = [-1.2;-1.4;6;9];
!         E = B*D;
!         formatMatFortran(E)
!         F = [-2,-1];
!         G = F*C
!         formatMatFortran(G)

        print*,'test_mtimes: passed'

    end subroutine test_mtimes
    subroutine test_mygemm
        use omp_lib
        implicit none
        real(rt), allocatable :: X(:,:),Y(:,:),Z(:,:),Zcheck(:,:),timer(:,:)
        integer :: i,n,l,m


        allocate(timer(10,3))

        do i = 1,10
            n = 2**i
            allocate(X(n,n),Y(n,n),Z(n,n),Zcheck(n,n))

            do m = 1,n
                do l = 1,n
                    X(l,m) = real(l,rt)/n + 3e0_rt*real(m,rt)/n
                    Y(l,m) = real(m,rt)/n + 3e0_rt*real(l,rt)/n
                end do
            end do

            timer(i,1) = real(omp_get_wtime(),rt)

            Zcheck = matmul(X,Y)

            timer(i,2) = real(omp_get_wtime(),rt)

            call mygemm(Z,X,Y,n,n,n,n,'N','N')

            timer(i,3) = real(omp_get_wtime(),rt)

            if (maxval(abs(Z-Zcheck))>maxval(abs(Zcheck))*sqrt(epsilon(0._rt))) then
                print*,'max|Z-Zcheck|=',maxval(abs(Z-Zcheck))
                print*,'tolerance=',maxval(abs(Zcheck))*sqrt(epsilon(0._rt))
                stop 'test_mygemm: failed'
            end if

            write(*,'(A,i8,3(A,f16.8))') 'test_mygemm: n ',n,' mygemm time ',timer(i,3)-timer(i,2),&
                                        ' matmul time ',timer(i,2)-timer(i,1),' mygemm / matmul : ',&
                                        (timer(i,3)-timer(i,2))/max(1e-6_rt,timer(i,2)-timer(i,1))

            deallocate(X,Y,Z,Zcheck)
        end do

        print*,'test_mygemm: passed'


    end subroutine
    !!! N
    subroutine test_null
        implicit none
        real(rt) :: A(3,3),dsn(3) 

        A = reshape((/0.95e0_rt,0.2e0_rt,0.001e0_rt,0.05e0_rt,0.7e0_rt,0.7e0_rt,0e0_rt,0.1e0_rt,0.299e0_rt/),(/3,3/))

        dsn = nullspace(eye(3)-transpose(A))        

        if (any(abs(dsn-(/0.969604e0_rt,0.242228e0_rt,0.0345547e0_rt/))>max(1e-5_rt,sqrt(epsilon(0._rt))))) then
            print*,'dsn',dsn
            print*,'test_null: warning at test 1'
        end if

        dsn = dsn/sum(dsn)
        if (any(abs(dsn-(/0.777932e0_rt,0.194344e0_rt,0.0277239e0_rt/))>max(1e-5_rt,sqrt(epsilon(0._rt))))) then
            print*,'dsn',dsn
            STOP'test_null: failed test 2'
        end if

        !Matlab code
!         A = [.95 .05 0; .2 .7 .1; .001 .7 .299];
!         formatMatFortran(A)
!         dsn = null(eye(3) - A');
!         formatMatFortran(dsn)
!         dsn = dsn/sum(dsn);
!         formatMatFortran(dsn)

        print*,'test_null: passed'

    end subroutine test_null
    !!! O
    !!! P
    !!! Q
    !!! R
    subroutine test_repmat
        implicit none
        real(rt) :: A(4),B(2,3)
        real(rt) :: true1(8,3),true2(2,12),true3(2,6)

        A = (/1e0_rt,2e0_rt,3e0_rt,4e0_rt/)
        B = reshape((/1e0_rt, 7e0_rt,         2e0_rt,         8e0_rt,         3e0_rt,   9e0_rt/),(/2,3/))

        true1 = reshape((/1e0_rt,2e0_rt,3e0_rt,4e0_rt,1e0_rt,2e0_rt,3e0_rt,4e0_rt,1e0_rt,2e0_rt,3e0_rt,4e0_rt,1e0_rt,&
                  2e0_rt,3e0_rt,4e0_rt,1e0_rt,2e0_rt,3e0_rt,4e0_rt,1e0_rt,2e0_rt,3e0_rt,4e0_rt/),(/8,3/))
        true2 = reshape(&
                (/         1e0_rt,         1e0_rt,         2e0_rt,         2e0_rt,         3e0_rt, &
                           3e0_rt,         4e0_rt,         4e0_rt,         1e0_rt,         1e0_rt, &
                           2e0_rt,         2e0_rt,         3e0_rt,         3e0_rt,         4e0_rt, &
                           4e0_rt,         1e0_rt,         1e0_rt,         2e0_rt,         2e0_rt, &
                           3e0_rt,         3e0_rt,         4e0_rt,         4e0_rt/)&
                           ,(/2,12/))
        true3 = reshape((/ 1e0_rt, 7e0_rt, 2e0_rt, 8e0_rt, 3e0_rt, &
                           9e0_rt, 1e0_rt, 7e0_rt, 2e0_rt, 8e0_rt, &
                           3e0_rt, 9e0_rt/)&
                        ,(/2,6/))

        if (any(repmat(vec2mat(A),2,3)/=true1)) STOP 'test_repmat: failed 1'
        if (any(repmat(transpose(vec2mat(A)),2,3)/=true2)) STOP 'test_repmat: failed 2'
        if (any(repmat(B,1,2)/=true3)) STOP 'test_repmat: failed 3'

        print*,'test_repmat: passed'


    end subroutine
    !!! S
    subroutine test_sort
        implicit none
        real(rt) :: A(11),sortedAtrue(11),sortedA(11)
        real(rt), parameter :: approx0 = epsilon(0.e0_rt)
        A = (/20.6046e0_rt,-46.8167e0_rt,-22.3077e0_rt,-45.3829e0_rt,-40.2868e0_rt,32.3458e0_rt,19.4829e0_rt,&
             -18.2901e0_rt,45.0222e0_rt,-46.5554e0_rt,-45.3829e0_rt/) !random but with one duplicate

        !Test ascending sort
        sortedAtrue = (/-46.8167e0_rt,-46.5554e0_rt,-45.3829e0_rt,-45.3829e0_rt,-40.2868e0_rt,-22.3077e0_rt,&
                        -18.2901e0_rt,19.4829e0_rt,20.6046e0_rt,32.3458e0_rt,45.0222e0_rt/)
        sortedA = sort(A)
        if (maxval(abs(sortedA-sortedAtrue))>approx0) STOP 'test_sort: sort failed test 1'

        ! Test descending sort
        sortedA = 0.e0_rt
        sortedAtrue = (/45.0222e0_rt,32.3458e0_rt,20.6046e0_rt,19.4829e0_rt,-18.2901e0_rt,-22.3077e0_rt,-40.2868e0_rt,&
                        -45.3829e0_rt,-45.3829e0_rt,-46.5554e0_rt,-46.8167e0_rt/)
        sortedA = sort(A,mode='descend')
        if (maxval(abs(sortedA-sortedAtrue))>approx0) STOP 'test_sort: sort failed test 2'        

        !Matlab code
!         A = [20.6046  -46.8167  -22.3077  -45.3829  -40.2868   32.3458   19.4829  -18.2901   45.0222  -46.5554  -45.3829]';
!         formatMatFortran(sort(A))
!         formatMatFortran(sort(A,'descend'))

        print*,'test_sort: passed'

    end subroutine test_sort
    subroutine test_sort2
        implicit none
        real(rt) :: A(11),sortedAtrue(11),sortedA(11)
        integer :: B(11),sortedBtrue(11),sortedB(11)
        real(rt) :: C(2,3),sortedCtrue(2,3),sortedC(2,3)
        real(rt) :: D(2,3),sortedDtrue(2,3),sortedD(2,3)
        integer :: I(11),J(2,3),k
        real(rt), parameter :: approx0 = epsilon(0.e0_rt)

        A = (/20.6046e0_rt,-46.8167e0_rt,-22.3077e0_rt,-45.3829e0_rt,-40.2868e0_rt,32.3458e0_rt,&
              19.4829e0_rt,-18.2901e0_rt,45.0222e0_rt,-46.5554e0_rt,-45.3829e0_rt/) !random but with one duplicate
        B = (/45,32,20,19,-18,-22,-40,-45,-45,-46,-46/)
    
        !Test ascending sort
        sortedAtrue = (/-46.8167e0_rt,-46.5554e0_rt,-45.3829e0_rt,-45.3829e0_rt,-40.2868e0_rt,&
                        -22.3077e0_rt,-18.2901e0_rt,19.4829e0_rt,20.6046e0_rt,32.3458e0_rt,45.0222e0_rt/)
        call sort2(sortedA,I,A)
        if (maxval(abs(sortedA-sortedAtrue))>approx0) STOP 'test_sort2: sort2 failed test 1'
        if (any(A(I)/=sortedA)) STOP 'test_sort2: sort2 failed test 2'

        ! Test descending sort
        sortedA = 0.e0_rt
        sortedAtrue = (/45.0222e0_rt,32.3458e0_rt,20.6046e0_rt,19.4829e0_rt,-18.2901e0_rt,-22.3077e0_rt,&
                        -40.2868e0_rt,-45.3829e0_rt,-45.3829e0_rt,-46.5554e0_rt,-46.8167e0_rt/)
        call sort2(sortedA,I,A,mode='descend')
        if (maxval(abs(sortedA-sortedAtrue))>approx0) STOP 'test_sort2: sort2 failed test 3'        
        if (any(A(I)/=sortedA)) STOP 'test_sort2: sort2 failed test 4'

        !Test ascending sort with integers
        sortedBtrue = (/-46,-46,-45,-45,-40,-22,-18,19,20,32,45/)
        call sort2(sortedB,I,B)
        if (maxval(abs(sortedB-sortedBtrue))>approx0) STOP 'test_sort2: sort2 failed test 5'
        if (any(B(I)/=sortedB)) STOP 'test_sort2: sort2 failed test 6'

        !Test descending sort with integers
        sortedBtrue = (/45,32,20,19,-18,-22,-40,-45,-45,-46,-46/)
        call sort2(sortedB,I,B,mode='descend')
        if (maxval(abs(sortedB-sortedBtrue))>approx0) STOP 'test_sort2: sort2 failed test 7'
        if (any(B(I)/=sortedB)) STOP 'test_sort2: sort2 failed test 8'
        
        !Test ascending sort with matrix dim=1
        C = reshape((/3e0_rt,0e0_rt,7e0_rt,4e0_rt,5e0_rt,2e0_rt/),(/2,3/))
        sortedCtrue = reshape((/0e0_rt,3e0_rt,4e0_rt,7e0_rt,2e0_rt,5e0_rt/),(/2,3/)) 
        call sort2(sortedC,J,C,dim=1)
        if (maxval(abs(sortedC-sortedCtrue))>approx0) STOP 'test_sort2: sort2 failed test 9'
        do k = 1,size(C,2)
            if (any(C(J(:,k),k)/=sortedC(:,k))) STOP 'test_sort2: sort2 failed test 10'
        end do

        !Test ascending sort with matrix dim=2
        C = reshape((/3e0_rt,0e0_rt,7e0_rt,4e0_rt,5e0_rt,2e0_rt/),(/2,3/))
        sortedCtrue = reshape((/3e0_rt,0e0_rt,5e0_rt,2e0_rt,7e0_rt,4e0_rt/),(/2,3/))
        call sort2(sortedC,J,C,dim=2)
        if (maxval(abs(sortedC-sortedCtrue))>approx0) STOP 'test_sort2: sort2 failed test 11'
        do k = 1,size(C,1)
            if (any(C(k,J(k,:))/=sortedC(k,:))) STOP 'test_sort2: sort2 failed test 12'
        end do

        !Test ascending sort with matrix dim=1
        D = reshape((/3,0,7,4,5,2/),(/2,3/))
        sortedDtrue = reshape((/0,3,4,7,2,5/),(/2,3/)) 
        call sort2(sortedD,J,D,dim=1)
        if (maxval(abs(sortedD-sortedDtrue))>approx0) STOP 'test_sort2: sort2 failed test 13'
        do k = 1,size(D,2)
            if (any(D(J(:,k),k)/=sortedD(:,k))) STOP 'test_sort2: sort2 failed test 14'
        end do

        !Test ascending sort with matrix dim=2
        D = reshape((/3,0,7,4,5,2/),(/2,3/))
        sortedDtrue = reshape((/3,0,5,2,7,4/),(/2,3/))
        call sort2(sortedD,J,D,dim=2)
        if (maxval(abs(sortedD-sortedDtrue))>approx0) STOP 'test_sort2: sort2 failed test 15'
        do k = 1,size(D,1)
            if (any(D(k,J(k,:))/=sortedD(k,:))) STOP 'test_sort2: sort2 failed test 16'
        end do

        !Matlab code
!         A = [20.6046  -46.8167  -22.3077  -45.3829  -40.2868   32.3458   19.4829  -18.2901   45.0222  -46.5554  -45.3829]';
!         formatMatFortran(sort(A))
!         formatMatFortran(sort(A,'descend'))
!         B = [20  -46  -22  -45  -40 32 19 -18 45 -46 -45]';
!         formatMatFortran(sort(B),1)
!         formatMatFortran(sort(B,'descend'),1)
!         C = [3 7 5; 0 4 2];
!         formatMatFortran(sort(C,1))
!         formatMatFortran(sort(C,2))

        print*,'test_sort2: passed'
        
    end subroutine test_sort2

    subroutine test_sortrows
        implicit none
        integer :: XI(6,7),sortedXI(6,7),truesortedXI(6,7),redo(6),XIorig(6,7)
        real(rt) :: rXI(6,7),rsortedXI(6,7),rtruesortedXI(6,7),rXIorig(6,7)

        XI = reshape([    95,  95,  95,  95,  76,  76,  45,   7,   7,   7,  61,  79,  92,  73,  73,  40,&
                          93,  91,  41,  89,   5,  35,  81,   0,  13,  20,  19,  60,  27,  19,   1,  74,&
                          44,  93,  46,  41,  84,  52,  20,  67,  83,   1],[6,7])
        XIorig = XI
        truesortedXI = reshape([  76,  76,  95,  95,  95,  95,  61,  79,   7,   7,   7,  45,  93,  91,  40,  73,&
                                  73,  92,  81,   0,  35,   5,  89,  41,  27,  19,  60,  19,  20,  13,  46,  41,&
                                  93,  44,  74,   1,  83,   1,  67,  20,  52,  84],[6,7])
        rXI = real(XI,rt)
        rXIorig = rXI
        rtruesortedXI = real(truesortedXI,rt)

        call sortrows(sortedXI,redo,XI)

        if (any(sortedXI/=truesortedXI)) STOP 'test_sortrows: failed sorting integers'
        if (any(XIorig(redo,:)/=truesortedXI)) STOP 'test_sortrows: redo does not work for integers'
        
        call sortrows(rsortedXI,redo,rXI)

        if (any(rsortedXI/=rtruesortedXI)) STOP 'test_sortrows: failed sorting reals'
        if (any(rXIorig(redo,:)/=rtruesortedXI)) STOP 'test_sortrows: redo does not work for reals'

        print*,'test_sortrows: passed'

    end subroutine test_sortrows
    !!! T
    !!! U
    subroutine test_unique
        implicit none
        integer :: A(10) = [-4,-4,5,0,1,5,-2,3,3,5]
        integer :: Btrue(6) = [-4,-2,0,1,3,5]
        integer, allocatable :: B(:)

        call unique(B,A)

        if (any(B/=Btrue)) STOP 'test_unique: failed unique integer test'

        print*,'test_unique: passed'


    end subroutine 
    !!! V
    !!! W
    !!! X
    !!! Y
    !!! Z

end module mod_matlab_test



