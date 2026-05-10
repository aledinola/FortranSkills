module mod_interp
    use mod_types
    use mod_core, only: bsearch
    implicit none

    interface sub_s2interp
        module procedure sub_s2interp_elt, sub_s2interp_vec, sub_s2interp_elt_loc, sub_s2interp_vec_loc, sub_s2interp_elt_loc_mass
    end interface
    interface sub_s2interp_precomp
        module procedure sub_s2interp_elt_loc_getTheta
    end interface

    integer, parameter, private :: search_cutoff = 20 ! If number of elements is less than this, lsearch is used, o/w bsearch. For random data, this should be close to 25. 

contains

    ! "search" attempts to provide the best of lsearch and bsearch. For small arrays, calls lsearch. For large, bsearch.
    subroutine search(ilo,xhat,x)
        implicit none
        real(rt), dimension(1:), intent(in) :: x
        real(rt), intent(in) :: xhat
        integer, intent(out) :: ilo
        
        if (size(x)<=search_cutoff) then
            call lsearch(ilo,xhat,x)
        else
            call bsearch(ilo,xhat,x)
        end if

!         if (xhat<x(1) .and. ilo/=1) STOP 'search: wrong case 1'
!         if (xhat>x(size(x)) .and. ilo/=size(x)-1) STOP 'search: wrong case 2'
!         if (size(x)==1 .and. ilo/=1) STOP 'search: wrong case 3'
!         if (size(x)>=2 .and. xhat>=x(1) .and. xhat<=x(size(x)) .and. (xhat<x(ilo) .or. xhat>x(ilo+1))) STOP 'search: wrong case 4'

    end subroutine

    ! Interpolation/Extrapolation search
    ! Tries to find ilo by assuming x is linear in a given interval
    ! If in fact x is linear, this is a very fast method. But worst case performance is O(n)
    ! Finds an i such that xhat \in [x(i),x(i+1)] if such an interval exists.
    subroutine isearch(ilo,xhat,x)
        implicit none
        real(rt), dimension(1:), intent(in) :: x
        real(rt), intent(in) :: xhat
        integer, intent(out) :: ilo

        if (size(x)==1) then
            ilo = 1
            return
        end if

        if (xhat<x(1)) then
            ilo = 1
        elseif (xhat>=x(size(x)-1)) then
            ilo = size(x)-1
        else 
            
            ! Take a guess at what it should be based on linear spacing
            ilo = ceiling( 1d-14 + (size(x)-1)*(xhat-x(1))/(x(size(x))-x(1)) ) ! adding a small contant helps ensure that if xhat is on the x grid, the ilo is correctly found

            ! If this fails, call bsearch
            if (ilo<1 .or. ilo>=size(x)) then
                call bsearch(ilo,xhat,x)
                return
            end if
            if (xhat<x(ilo) .or. xhat>x(ilo+1)) then
                call bsearch(ilo,xhat,x)
                return
            end if


!             if (ilo>=size(x)) then
!                 ilo = size(x)-1
!                 if (xhat<x(ilo)) then
!                     ! Error: switch to bsearch
!     !                 write(*,'(A)',advance='no') '1'
!                     call bsearch(ilo,xhat,x)
!                 end if
!             elseif (ilo<1) then
!                 ilo = 1
!                 if (xhat>x(2)) then
!                     ! Error: switch to bsearch
!     !                 write(*,'(A)',advance='no') '2'
!                     call bsearch(ilo,xhat,x)
!                 end if
!             else
!                 ! Check that x = max(min(x,x(n)),x(1)) has x \in [x(i),x(i+1)]
!     !             write(*,'(A)',advance='no') 'g'
!                 if (xhat<x(ilo) .or. xhat>x(ilo+1)) then
!                     ! Error: switch to bsearch
!     !                 write(*,'(A)',advance='no') '3'
!                     call bsearch(ilo,xhat,x)
!                 end if
!             end if
        end if
        
    end subroutine isearch

!     subroutine isearch(ilo,xhat,x)
!         implicit none
!         real(rt), dimension(1:), intent(in) :: x
!         real(rt), intent(in) :: xhat
!         integer, intent(out) :: ilo
!         ! local
!         integer :: itry,ihi
!         
!         ilo = 1
!         ihi = size(x)
! 
!         do while (ihi-ilo>1) ! Tests that there is a point between ilo and ihi (if not, return ilo!)
! 
!             ! If x(i) is linear in i between [ilo,ihi], then x(i) = x(ilo) + (x(ihi)-x(ilo))/(ihi-ilo)*(i-ilo)
!             ! So, xhat = x(i) occurs for i equal to 
!             ! xhat = x(ilo) + (x(ihi)-x(ilo))/(ihi-ilo)*(i-ilo)
!             ! (xhat-x(ilo))/(x(ihi)-x(ilo))*(ihi-ilo)  = i-ilo
!             ! i = ilo + (ihi-ilo)*(xhat-x(ilo))/(x(ihi)-x(ilo))
!             ! The last terms with x values is in [0,1] IF x is sorted. 
! 
!             itry = floor(ilo + (ihi-ilo)*(xhat-x(ilo))/(x(ihi)-x(ilo)))
!             
!             ! The following two if statemetns may only be necessary on the first pass 
!             ! (to check whether xhat<x(1) or xhat>x(n)), but since using mixed integer and double arithmetic,
!             ! probably safer to leave them.
!             
!             ! If itry is less than or equal to ilo, and x is sorted, this means xhat<x(ilo) so return ilo
!             ! Note: if itry==ilo, this can mean xhat>=x(ilo) and so must continue search
!             if (itry<ilo) then
!                 return 
!             end if
! 
!             ! If itry is greater than or equal to ihi, this means xhat>=x(ihi) so return ilo=ihi-1
!             if (itry>=ihi) then
!                 ilo = ihi-1
!                 return
!             end if
! 
!             ! Now itry is in [ilo,...,ihi-1] so following x checks are safe
!             
!             ! Construct the new bracket and test whether have found true ilo
!             if (x(itry)>xhat) then
!                 ! Here, ihi should be replaced. Note: already tested itry>=ihi and it was false
!                 ihi = itry 
!             else
!                 ! HERE: x(itry)<=xhat
!                 ! Since user is expecting near-linear case, test whether have succeeded in finding interval
!                 if (x(itry+1)>=xhat) then
!                     ! HERE: xhat \in [x(itry),x(itry+1)]
!                     ilo = itry
!                     return 
!                 end if
! 
!                 ! Here, ilo should be replaced. 
!                 ilo = max(itry,ilo+1) 
! 
!             end if
! 
!         end do
! 
!     end subroutine isearch

    ! This routine requires "step" as argument. The user should ensure 
    ! step = real(size(x)-1),8)/(x(size(x))-x(1)). 
    subroutine isearch_with_step(ilo,xhat,x,step)
        implicit none
        real(rt), dimension(1:), intent(in) :: x
        real(rt), intent(in) :: xhat,step
        integer, intent(out) :: ilo
        ! local
        integer :: itry,ihi
        
        ! Check whether exactly works
        ilo = floor(1e0_rt + step*(xhat-x(1)))
        if (ilo>=1 .and. ilo<=size(x)-1) then
            if (xhat>=x(ilo) .and. xhat<=x(ilo+1)) return            
        end if  

        ! If it didn't work, just call isearch for simplicity
        call isearch(ilo,xhat,x)

    end subroutine isearch_with_step
    
    ! Use sequential/linear search to find the lowerbound on a bracketing interval
    ! This has far worse theoretical performance than binary search O(n) compared to 
    ! O(log2(n)), but it is much easier for the compiler to understand and use effectively.
    ! Consequently for small arrays, it is faster.
    subroutine lsearch(ilo,xhat,x)
        implicit none
        real(rt), dimension(1:), intent(in) :: x
        real(rt), intent(in) :: xhat
        integer, intent(out) :: ilo
        ! local
!         integer :: ihi

!    do ihi = 2,size(x)
!        ! If here, then size(x)-1>=1 <=> size(x)>=2 (if size(x)==1, we just return ilo = 1)
! 
!        ! Three cases to be concerned with
!        ! (1) xhat<x(1)
!        ! (2) xhat>=x(n)
!        ! (3) xhat>=x(1) .and. xhat<x(n)
! 
!        ! Test whether xhat<x(ilo). 
!        ! In case (1), this will always evaluate to true. So we should exit immediately returning ilo=ilo-1.
!        ! In case (2), this will never evaluate to true. 
!        ! In case (3), this will evaluate to true when xhat<x(ilo) and there was no j<ilo such that xhat<x(j).
!        !   Consequently, we have xhat>=x(j) for all j<ilo, and in particular, xhat>=x(ilo-1). This means, xhat \in [x(ilo-1),x(ilo))
!        !   So, return ilo-1, just as we did in case (1).
!        if (xhat<x(ihi)) then
!            ilo = ihi-1
!            return
!        end if
!    end do
!    ! If still here, we have case (2) or the size of x is 1. So, we return ilo = n-1 if size>1 and 1 o/w
!    ilo = max(size(x)-1,1)
        

        do ilo = 1,size(x)-1
            ! If here, then size(x)-1>=1 <=> size(x)>=2 (if size(x)==1, we just return ilo = 1)

            ! Three cases to be concerned with
            ! (1) xhat<x(1)
            ! (2) xhat>=x(n)
            ! (3) xhat>=x(1) .and. xhat<x(n)

            ! Test whether xhat<x(ilo+1). 
            ! In case (1), this will always evaluate to true. So we should exit immediately returning ilo=1
            ! In case (2), this will never evaluate to true. 
            ! In case (3), this will evaluate to true when xhat<x(ilo+1) and there was no j<ilo+1 such that xhat<x(j).
            !   Consequently, we have xhat>=x(j) for all j<ilo+1, and in particular, xhat>=x(ilo). This means,
            !   xhat \in [x(ilo),x(ilo+1)). So, return ilo, just as we did in case (1).
            if (xhat<x(ilo+1)) return
        end do
        ! If still here, we have case (2) or the size of x is 1. So, we return ilo = n-1 if size>1 and 1 o/w
        ilo = max(size(x)-1,1)

    end subroutine

    subroutine bsearch_old(ilo,xhat,x)
        implicit none
        real(rt), dimension(1:), intent(in) :: x
        real(rt), intent(in) :: xhat
        integer, intent(out) :: ilo
        !local
        integer :: ihi,mid

        if (size(x)<=1) then
            ilo = 1
            STOP 'bsearch: size(x) is only 1.  should be at least 2'
        elseif (xhat<=x(1)) then
            ilo = 1
            return
        elseif (xhat>=x(size(x))) then
            ilo = size(x)-1
            return
        else

            ilo = 1
            ihi = size(x)
            mid = (ihi+ilo)/2
            
            do while (mid>ilo)
            
                if (xhat>x(mid)) then
                    ilo = mid
                elseif (xhat<x(mid)) then
                    ihi = mid
                else
                    ilo = mid
                    return
                end if
                mid = (ihi+ilo)/2

            end do

        end if

        ! Check the result as a precaution.  Make sure x in fact lies between.
        ! If this has a severe negative performance impact, I should get rid of this
        if (xhat<x(ilo) .or. xhat>x(ilo+1)) then
            write(*,*) 'bsearch: error, bracketing interval not found.  is x sorted?'
            write(*,*) 'bsearch: xhat x(ilo) x(ilo+1) ilo ihi', xhat, x(ilo),x(ilo+1), ilo, ihi
        end if 

    end subroutine 

    ! Computes the simplical 2-dimensional interpolant 
    !
    ! Input :: X,Y,V,xi,yi,isEqSpaced 
    ! Output :: Vi
    ! 
    ! X and Y are the grids V is defined on. X and Y must both be strictly increasing.
    ! V is a matrix (size(X),size(Y)) s.t. V(i,j) = f(X(i),X(j))
    ! xi and yi are two vectors of the same length giving desired values
    !   (xi(i),yi(i)) where the interpolant should be computed
    ! Vi is the interpolated value, i.e. V(i) = fhat(xi(i),yi(i))
    !
    ! space determines what spacing is assumed for X and Y according to
    !   0: X and Y have no spacing requirements (binary search is used)
    !   1: X and Y are both equally spaced (inversion of linspacing formula used)
    !   2: The positions of xi,yi in X,Y are given explicitly by vectors xiloc,yiloc.
    !      If this option is selected, optional arguments xiloc and yiloc must be passed. 
    !      Further, to work properly, must have xi(i) \in [X(xiloc(i)),X(xiloc(i+1))] and 
    !      similarly for y
    !   3+: TBD
    subroutine sub_s2interp_elt(Vi,X,Y,V,xi,yi,space)! ,doDebug) 
        implicit none
        real(rt), dimension(1:), intent(in) :: X,Y
        real(rt), dimension(1:,1:), intent(in) :: V
        real(rt), intent(in) :: xi,yi
        real(rt), intent(out) :: Vi ! Interpolated V values
        integer, intent(in) :: space
        !logical, intent(in), optional :: doDebug
        ! local
        real(rt) :: Vicopy(1)

        ! It would be more efficient to copy routine in and make adjustments for scalar, 
        ! but I don't pursue this now
        call sub_s2interp_vec(Vicopy,X,Y,V,(/xi/),(/yi/),space)
        Vi = Vicopy(1)

    end subroutine sub_s2interp_elt
    subroutine sub_s2interp_vec(Vi,X,Y,V,xi,yi,space)
        implicit none
        real(rt), dimension(1:), intent(in) :: X,Y
        real(rt), dimension(1:,1:), intent(in) :: V
        real(rt), dimension(1:), intent(in) :: xi,yi
        real(rt), dimension(1:size(xi)), intent(out) :: Vi ! Interpolated V values
        integer, intent(in) :: space
        ! logical, intent(in), optional :: doDebug
        !local
        integer :: nX,nY,i,xiloc,yiloc
        real(rt) :: stepX,stepY,thetaxi,thetayi

        nX = size(X)
        nY = size(Y)

        if (size(V,1)/=nX .or. size(V,2)/=nY) STOP 'sub_s2interp: ERROR: V must have size nX,nY'
        if (size(xi)/=size(yi)) STOP 'sub_s2interp: ERROR: xi and yi must have the same length'

        if (space==1) then
            stepX = (X(nX)-X(1))/real(nX-1,rt)
            stepY = (Y(nY)-Y(1))/real(nY-1,rt)
        end if

        ! Iterate over the interpolation points
        do i = 1,size(xi)

            ! Get the grid locations for each 
            if (space==1) then
                xiloc = eqSpacedLoc(X,nX,stepX,xi(i))
                yiloc = eqSpacedLoc(Y,nY,stepY,yi(i))
            else
                call search(xiloc,xi(i),X)
                call search(yiloc,yi(i),Y)
            end if

            ! Convert to the unit rectangle via a linear change of variables 
            thetaxi = (xi(i)-X(xiloc))/(X(xiloc+1)-X(xiloc))
            thetayi = (yi(i)-Y(yiloc))/(Y(yiloc+1)-Y(yiloc))

            ! thetaxi+thetaya {>=,<=} 1 determines the simplex so we can do the interpolation
            if (thetaxi+thetayi<=1e0_rt) then
                Vi(i) = V(xiloc,yiloc) + &
                        (V(xiloc,yiloc+1)-V(xiloc,yiloc))*thetayi + &
                        (V(xiloc+1,yiloc)-V(xiloc,yiloc))*thetaxi
            else
                Vi(i) = V(xiloc+1,yiloc+1) -  &
                        (V(xiloc+1,yiloc+1)-V(xiloc+1,yiloc))*(1e0_rt-thetayi) - &
                        (V(xiloc+1,yiloc+1)-V(xiloc,yiloc+1))*(1e0_rt-thetaxi)
            end if

        end do

    end subroutine sub_s2interp_vec
    subroutine sub_s2interp_elt_loc(Vi,X,Y,V,xi,yi,space,xiloc,yiloc)
        implicit none
        real(rt), dimension(1:), intent(in) :: X,Y
        real(rt), dimension(1:,1:), intent(in) :: V
        real(rt), intent(in) :: xi,yi
        real(rt), intent(out) :: Vi ! Interpolated V values
        integer, intent(in) :: space
        integer, intent(in) :: xiloc,yiloc
        ! local
        real(rt) :: thetaxi,thetayi

        if (size(V,1)/=size(X) .or. size(V,2)/=size(Y)) STOP 'sub_s2interp: ERROR: V must have size nX,nY'
        if (space/=3) STOP 'sub_s2interp_vec_loc: ERROR: space should be 3 in this scenario'

        ! Convert to the unit rectangle via a linear change of variables 
        thetaxi = (xi-X(xiloc))/(X(xiloc+1)-X(xiloc))
        thetayi = (yi-Y(yiloc))/(Y(yiloc+1)-Y(yiloc))

        ! thetaxi+thetaya {>=,<=} 1 determines the simplex so we can do the interpolation
        if (thetaxi+thetayi<=1e0_rt) then
            Vi = V(xiloc,yiloc) + &
                    (V(xiloc,yiloc+1)-V(xiloc,yiloc))*thetayi + &
                    (V(xiloc+1,yiloc)-V(xiloc,yiloc))*thetaxi
        else
            Vi = V(xiloc+1,yiloc+1) -  &
                    (V(xiloc+1,yiloc+1)-V(xiloc+1,yiloc))*(1e0_rt-thetayi) - &
                    (V(xiloc+1,yiloc+1)-V(xiloc,yiloc+1))*(1e0_rt-thetaxi)
        end if

    end subroutine sub_s2interp_elt_loc
    subroutine sub_s2interp_vec_loc(Vi,X,Y,V,xi,yi,space,xiloc,yiloc)
        implicit none
        real(rt), dimension(1:), intent(in) :: X,Y
        real(rt), dimension(1:,1:), intent(in) :: V
        real(rt), dimension(1:), intent(in) :: xi,yi
        integer, dimension(1:), intent(in) :: xiloc,yiloc ! Positions of xi and yi in grid
        real(rt), dimension(1:size(xi)), intent(out) :: Vi ! Interpolated V values
        integer, intent(in) :: space
        !local
        integer :: i
        real(rt) :: thetaxi,thetayi

        if (size(V,1)/=size(X) .or. size(V,2)/=size(Y)) &
            STOP 'sub_s2interp: ERROR: V must have size nX,nY'
        if (size(xi)/=size(yi)) &
            STOP 'sub_s2interp: ERROR: xi and yi must have the same length'
        if (size(xiloc)/=size(yiloc) .or. size(xiloc)/=size(xi)) &
            STOP 'sub_s2interp: ERROR: xi,yi,xiloc,yiloc must have the same length'
        if (space/=3) STOP 'sub_s2interp_vec_loc: ERROR: space should be 3 in this scenario'

        ! Iterate over the interpolation points
        do i = 1,size(xi)

            ! Convert to the unit rectangle via a linear change of variables 
            thetaxi = (xi(i)-X(xiloc(i)))/(X(xiloc(i)+1)-X(xiloc(i)))
            thetayi = (yi(i)-Y(yiloc(i)))/(Y(yiloc(i)+1)-Y(yiloc(i)))

            ! thetaxi+thetaya {>=,<=} 1 determines the simplex so we can do the interpolation
            if (thetaxi+thetayi<=1e0_rt) then
                Vi(i) = V(xiloc(i),yiloc(i)) + &
                        (V(xiloc(i),yiloc(i)+1)-V(xiloc(i),yiloc(i)))*thetayi + &
                        (V(xiloc(i)+1,yiloc(i))-V(xiloc(i),yiloc(i)))*thetaxi
            else
                Vi(i) = V(xiloc(i)+1,yiloc(i)+1) -  &
                        (V(xiloc(i)+1,yiloc(i)+1)-V(xiloc(i)+1,yiloc(i)))*(1e0_rt-thetayi) - &
                        (V(xiloc(i)+1,yiloc(i)+1)-V(xiloc(i),yiloc(i)+1))*(1e0_rt-thetaxi)
            end if

        end do

    end subroutine sub_s2interp_vec_loc






    ! This routine is the ultimate in terms of performance because just evaluates the formula
    ! without computing any weights. This gets rid of 2 divisions and 4 subtractions since the
    ! thetaxi and thetayi are passed as arguments. The thetas are of the form
    ! thetaxi = (xi-X(xiloc))/(X(xiloc+1)-X(xiloc)) ...

    subroutine sub_s2interp_elt_loc_getTheta(thetaxi,thetayi,X,Y,xi,yi,xiloc,yiloc)
        implicit none
!         !DEC$ ATTRIBUTES INLINE :: sub_s2interp_elt_loc_getTheta 
        real(rt), dimension(1:), intent(in) :: X,Y
        real(rt), intent(in) :: xi,yi
        integer, intent(in) :: xiloc,yiloc
        real(rt), intent(out) :: thetaxi,thetayi

        ! Computes the theta
        thetaxi = (xi-X(xiloc))/(X(xiloc+1)-X(xiloc))
        thetayi = (yi-Y(yiloc))/(Y(yiloc+1)-Y(yiloc))

    end subroutine sub_s2interp_elt_loc_getTheta 
    subroutine sub_s2interp_elt_loc_mass(Vi,X,Y,V,xi,yi,space,xiloc,yiloc,thetaxi,thetayi)
        implicit none
!         !DEC$ ATTRIBUTES INLINE :: sub_s2interp_elt_loc_mass
        real(rt), dimension(1:), intent(in) :: X,Y
        real(rt), dimension(1:,1:), intent(in) :: V
        real(rt), intent(in) :: xi,yi
        real(rt), intent(out) :: Vi ! Interpolated V values
        integer, intent(in) :: space
        integer, intent(in) :: xiloc,yiloc
        real(rt), intent(in) :: thetaxi,thetayi

        ! thetaxi+thetaya {>=,<=} 1 determines the simplex so we can do the interpolation
        if (thetaxi+thetayi<=1e0_rt) then
            Vi = V(xiloc,yiloc) + &
                    (V(xiloc,yiloc+1)-V(xiloc,yiloc))*thetayi + &
                    (V(xiloc+1,yiloc)-V(xiloc,yiloc))*thetaxi
        else
            Vi = V(xiloc+1,yiloc+1) -  &
                    (V(xiloc+1,yiloc+1)-V(xiloc+1,yiloc))*(1e0_rt-thetayi) - &
                    (V(xiloc+1,yiloc+1)-V(xiloc,yiloc+1))*(1e0_rt-thetaxi)
        end if

    end subroutine sub_s2interp_elt_loc_mass

!     !DEC$ ATTRIBUTES INLINE :: eqSpacedLoc
    function eqSpacedLoc(X,nX,stepX,xval) result(xiloc)
        implicit none
        real(rt), dimension(1:), intent(in) :: X
        real(rt), intent(in) :: xval,stepX
        integer, intent(in) :: nX 
        integer :: xiloc

        ! 6 operations
        xiloc = max(min(floor(1.e0_rt+(xval-X(1))/stepX),nX-1),1)    

    end function eqSpacedLoc


    subroutine test_s2interp()
        implicit none
        real(rt), allocatable :: X(:),Y(:),V(:,:),Xi(:),Yi(:),Vi(:)
        real(rt) :: h
        integer :: i,j

        allocate(X(20),Y(30))
        allocate(V(size(X),size(Y)))
        allocate(Xi(size(X)*size(Y)),Yi(size(X)*size(Y)),Vi(size(X)*size(Y)))

        X(1) = -1e0_rt
        X(size(X)) = 15e0_rt
        h = (X(size(X))-X(1))/real(size(X)-1,rt)
        do i = 2,size(X)-1
            X(i) = h + X(i-1)
        end do

        Y(1) = 2e0_rt
        Y(size(Y)) = 3e0_rt
        h = (Y(size(Y))-Y(1))/real(size(Y)-1,rt)
        do i = 2,size(Y)-1
            Y(i) = h + Y(i-1)
        end do
        
        do j = 1,size(Y)
            do i = 1,size(X)
                V(i,j) = f(x(i),y(j))
            end do
        end do

        ! First check that it actually interpolates
        do i = 1,size(Y)
            Xi(1:size(X)) = X
            Yi(1:size(X)) = Y(i)
            call sub_s2interp(Vi(1:size(X)),X,Y,V,Xi(1:size(X)),Yi(1:size(X)),1) 
            if (maxval(abs(Vi(1:size(X))-f(Xi(1:size(X)),Yi(1:size(X)))))>sqrt(epsilon(0._rt))) &
                STOP 'sub_s2interp failed interp check'
        end do

        ! Now check error at random points in the state space
        call random_number(Xi)
        call random_number(Yi)
        Xi = X(1) + Xi*(X(size(X))-X(1))
        Yi = Y(1) + Yi*(Y(size(Y))-Y(1))

        call sub_s2interp(Vi,X,Y,V,Xi,Yi,1) 

!         print*,'Min error is ',minval(abs(Vi-f(Xi,Yi)))
!         print*,'Avg error is ',sum(abs(Vi-f(Xi,Yi)))/real(size(Vi),8)
!         print*,'Max error is ',maxval(abs(Vi-f(Xi,Yi)))

        if (maxval(abs(Vi-f(Xi,Yi)))>sqrt(epsilon(0._rt))) then
            STOP 'sub_s2interp failed random check'
        end if


        ! do i = 1,size(Xi)
        !     write(*,'(A,4f6.2)')'x,y,Vi,f',Xi(i),Yi(i),Vi(i),f(Xi(i),Yi(i))
        ! end do


!         call usedir('~/Desktop/data/')
! 
!         call myprint('X',X)
!         call myprint('Y',Y)
!         call myprint('V',V)
!         call myprint('Xi',Xi)
!         call myprint('Yi',Yi)
!         call myprint('Vi',Vi)

        print*,'test_s2interp: passed'


    end subroutine test_s2interp

    elemental function f(x,y)
        real(rt), intent(in) :: x,y
        real(rt) :: f
        ! f = x*y + 3e0_rt*x - 2e0_rt*y + 5e0_rt
        f = 3e0_rt*x - 2e0_rt*y + 5e0_rt
        ! f = x + y
        ! f = sqrt(x**2 + y**2) 
        ! f = log(.01+abs(x))*y + y**2 - .01e0_rt*x**3 
        
    end function

    subroutine test_search
        use mod_core
        implicit none
        real(rt) :: X(1000)
        integer :: i
        integer, parameter :: ntrials = 10000
        real(rt), allocatable :: xhat(:)
        integer, allocatable :: j(:)

        allocate(xhat(ntrials),j(ntrials))
        call random_number(xhat)
        
        ! Linearly spaced data
        X = linspace(.02e0_rt,.98e0_rt,size(X)) 

        ! Random data
        do i = 1,size(X)
            call random_number(X(i))
            if (i>1) X(i) = X(i) + X(i-1)
        end do
        X = (X-X(1))/(X(size(X))-X(1)) ! [0,1]
        X = .02e0_rt + .96e0_rt*X ! [0.02,.98]


        ! Test interpolation search
        do i = 1,ntrials
            call isearch(j(i),xhat(i),X)
        end do
        call check('isearch')
        print*,'test_search: isearch passed'

        do i = 1,ntrials
            call bsearch(j(i),xhat(i),X)
        end do
        call check('bsearch')
        print*,'test_search: bsearch passed'

        do i = 1,ntrials
            call lsearch(j(i),xhat(i),X)
        end do
        call check('lsearch')
        print*,'test_search: lsearch passed'

        do i = 1,ntrials
            call search(j(i),xhat(i),X)
        end do
        call check('search')
        print*,'test_search: lsearch passed'

    contains

        subroutine check(msg)
            implicit none
            character(len=*), intent(in) :: msg
            
            do i = 1,ntrials
                if (xhat(i)<X(1)) then 
                    if (j(i)/=1) then
                        print*,msg,': j(i) should equal one but is ',j(i),' xhat(i) ',xhat(i),' X(1) ',X(1)
                        STOP 'test_search: error 1'
                    end if
                elseif (xhat(i)>X(size(X))) Then
                    if (j(i)/=size(X)-1) then
                        print*,msg
                        STOP 'test_search: error 2'
                    end if
                else
                    if (xhat(i)<X(j(i)) .or. xhat(i)>=X(j(i)+1)) then
                        print*,msg
                        STOP 'test_search: error 3'
                    end if
                end if
            end do
        end subroutine

    end subroutine

end module mod_interp
