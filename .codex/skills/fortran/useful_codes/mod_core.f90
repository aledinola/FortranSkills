! A collection of core routines used by many of the libgrey routines. These are designed to be basic, i.e., they have no dependencies.

! Routines
module mod_core
    use mod_types
    implicit none

    interface disp
        module procedure disp_scal, disp_vec, disp_mat, disp_3d, disp_vec_i, disp_mat_i, &
                         disp_scal_title, disp_vec_title, disp_mat_title, disp_3d_title, &
                         disp_vec_title_i, disp_mat_title_i, disp_mat_title_l, disp_mat_l
    end interface disp

    integer(8), private :: datetime_start(8)


contains

! Define a function continue to prevent the use of 
integer function continue()
    implicit none
    print*,'Don''t use continue, use cycle. Continue it doesn''t do what you think!'
    continue = -1
end function

! Produces a square n by n identity matrix
function eye(n) result(mat)
    implicit none
    integer, intent(in) :: n
    real(rt), dimension(n,n) :: mat    
    integer :: i

    mat = 0d0
    do i = 1,n
        mat(i,i) = 1d0
    end do

end function eye

subroutine disp_mat_title_l(title,X)
    implicit none
    character(len=*), intent(in) :: title
    logical, dimension(1:,1:), intent(in) :: X    
    write(*,'(A)') title
    call disp_mat_l(X)
end subroutine 
subroutine disp_mat_l(X)
    implicit none
    logical, dimension(1:,1:), intent(in) :: X    
    integer :: i
    character(len=5) :: dim2
    write(dim2,'(i5)') size(X,2)
    do i = 1,size(X,1)
        write(*,'('//dim2//'L2)') X(i,:)
    end do
end subroutine disp_mat_l

subroutine disp_mat_title_i(title,X)
    implicit none
    character(len=*), intent(in) :: title
    integer, dimension(1:,1:), intent(in) :: X    
    write(*,'(A)') title
    call disp_mat_i(X)
end subroutine 
subroutine disp_mat_i(X)
    implicit none
    integer, dimension(1:,1:), intent(in) :: X    
    integer :: i
    character(len=5) :: dim2
    write(dim2,'(i5)') size(X,2)
    do i = 1,size(X,1)
        write(*,'('//dim2//'i8)') X(i,:)
    end do
end subroutine disp_mat_i

subroutine disp_vec_title_i(title,X)
    implicit none
    character(len=*), intent(in) :: title
    integer, dimension(1:), intent(in) :: X    
    write(*,'(A)') title
    call disp_vec_i(X)
end subroutine
subroutine disp_vec_i(X)
    implicit none
    integer, dimension(1:), intent(in) :: X    
    integer :: i
    do i = 1,size(X,1)
        write(*,'(i8)') X(i)
    end do
end subroutine disp_vec_i


subroutine disp_vec(X,uid)
    implicit none
    real(rt), dimension(:), intent(in) :: X    
    integer, intent(in), optional :: uid
    if (     present(uid)) call disp_core(X,size(X,1),1,1,'',uid)
    if (.not.present(uid)) call disp_core(X,size(X,1),1,1,'',6)
end subroutine 
subroutine disp_mat(X,uid)
    implicit none
    real(rt), dimension(:,:), intent(in) :: X    
    integer, intent(in), optional :: uid
    if (     present(uid)) call disp_core(X,size(X,1),size(X,2),1,'',uid)
    if (.not.present(uid)) call disp_core(X,size(X,1),size(X,2),1,'',6)
end subroutine 
subroutine disp_3d(X,uid)
    implicit none
    real(rt), dimension(:,:,:), intent(in) :: X    
    integer, intent(in), optional :: uid
    if (     present(uid)) call disp_core(X,size(X,1),size(X,2),size(X,3),'',uid)
    if (.not.present(uid)) call disp_core(X,size(X,1),size(X,2),size(X,3),'',6)
end subroutine 
subroutine disp_vec_title(title,X,uid)
    implicit none
    real(rt), dimension(:), intent(in) :: X    
    character(len=*), intent(in) :: title
    integer, intent(in), optional :: uid
    if (     present(uid)) call disp_core(X,size(X,1),1,1,title,uid)
    if (.not.present(uid)) call disp_core(X,size(X,1),1,1,title,6)
end subroutine 
subroutine disp_mat_title(title,X,uid)
    implicit none
    real(rt), dimension(:,:), intent(in) :: X    
    character(len=*), intent(in) :: title
    integer, intent(in), optional :: uid
    if (     present(uid)) call disp_core(X,size(X,1),size(X,2),1,title,uid)
    if (.not.present(uid)) call disp_core(X,size(X,1),size(X,2),1,title,6)
end subroutine 
subroutine disp_3d_title(title,X,uid)
    implicit none
    real(rt), dimension(:,:,:), intent(in) :: X    
    character(len=*), intent(in) :: title
    integer, intent(in), optional :: uid
    if (     present(uid)) call disp_core(X,size(X,1),size(X,2),size(X,3),title,uid)
    if (.not.present(uid)) call disp_core(X,size(X,1),size(X,2),size(X,3),title,6)
end subroutine 

subroutine disp_core(X,n1,n2,n3,title,uid)
    implicit none
    integer, intent(in) :: n1,n2,n3,uid
    character(len=*), intent(in) :: title
    real(rt), intent(in) :: X(n1,n2,*)
    ! local
    integer :: i1,i2,i3

    ! If no title or uid is present, then use title='' and uid=6
    do i3 = 1,n3
        if (n3>1) then
            write(uid,'(A,i4,A)') title//'(:,:,',i3,')'
        else
            if (title/='') write(uid,'(A)') title
        end if
        do i1 = 1,n1
            do i2 = 1,n2-1
                write(uid,'(f12.5)',advance='no') X(i1,i2,i3)
            end do
            write(uid,'(f12.5)') X(i1,n2,i3)
        end do
    end do

end subroutine



subroutine disp_scal_title(title,X)
    implicit none
    character(len=*), intent(in) :: title
    real(rt), intent(in) :: X    
    write(*,'(A)') title
    call disp_scal(X)
end subroutine 
subroutine disp_scal(X)
    implicit none
    real(rt), intent(in) :: X    
    write(*,'(f12.5)') X
end subroutine disp_scal

! Acts just like the colon in Matlab
pure function colon(a,b)
    implicit none
    integer, intent(in) :: a,b
    integer, dimension(1:b-a+1) :: colon
    integer :: i
    do i = a,b
        colon(i-a+1) = i
    end do
end function colon

! Use binary search to find the lowerbound on a bracketing interval for 
! Given sorted ascending array, find lowerbound on bracketing interval. Note that
! ilo will always be in 1,...,size(x)-1.
! 
! This is supposed to work much like the C++ standard library where the interface comes from
subroutine bsearch(ilo,xhat,x)
    implicit none
    real(rt), dimension(1:), intent(in) :: x
    real(rt), intent(in) :: xhat
    integer, intent(out) :: ilo
    !local
    integer :: ihi,mid
        
    ilo = 1
    ihi = size(x)
    mid = (ihi+ilo)/2 ! mid will have ilo<=mid<ihi as long as ihi>ilo. If ihi=ilo, then mid=ilo, so the 
                      ! while loop is not entered and ilo=1 is returned 
    
    do while (mid>ilo) ! mid=ilo means ihi=ilo+1.

        ! Here, we must have ihi>ilo and ilo<=mid<ihi

        ! Bisect. 
        ! If xhat<x(1), then xhat>=x(mid) will never occur and ilo will never be modified.
        ! If xhat>=x(nx), then xhat>=x(mid) will always occur (note mid<ihi). Consequently, 
        !      ilo = mid occurs until mid==ilo, which only occures if ihi==ilo+1.
        if (xhat>=x(mid)) then
            ilo = mid
        else
            ihi = mid
        end if

        mid = (ihi+ilo)/2 

    end do

    ! Check the result as a precaution.  Make sure x in fact lies between.
    ! If this has a severe negative performance impact, I should get rid of this
    ! if (xhat<x(1) .and. ilo/=1) STOP 'bsearch: wrong case 1'
    ! if (xhat>x(size(x)) .and. ilo/=size(x)-1) STOP 'bsearch: wrong case 2'
    ! if (size(x)==1 .and. ilo/=1) STOP 'bsearch: wrong case 3'
    ! if (size(x)>=2 .and. xhat>=x(1) .and. xhat<=x(size(x)) .and. (xhat<x(ilo) .or. xhat>x(ilo+1))) STOP 'bsearch: wrong case 4'

end subroutine 

! linspace(a,b,n) (of course) constructs a grid of n linearly spaced points between
! a and b. If n==1, then the grid is just "a", consistent with Matlab. If n<=0, the routine
! stops with an error.
function linspace(x1,x2,n) result(grid)
    implicit none
    real(rt), intent(in) :: x1,x2
    integer, intent(in) :: n
    real(rt), dimension(1:n) :: grid
    !local
    integer :: i 

    if (n>1) then
        grid(1) = x1
        do i=2,n-1
            grid(i) = x1 + (x2-x1)*(real(i,rt)-1._rt)/(real(n,rt)-1._rt)
        end do   
        grid(n) = x2
    elseif (n==1) then
        grid(1) = x1
    else
        STOP 'linspace: ERROR: grid has size <= 0'
    end if
end function linspace

! Tic and toc for timing routines.
! Because of the odd behavior of the system clock, there is a known bug here that is 
! more likely to be experienced for long run times.
subroutine tic()
    implicit none
    ! call cpu_time(time_start)
    ! call system_clock(count=count_start,count_rate=countrate_start)
    call date_and_time(values=datetime_start)
end subroutine tic
subroutine toc(time_out)
    implicit none
    real(rt), intent(out), optional :: time_out
    integer(8) :: datetime_end(8), ta(8)
    real(rt) :: minutes,seconds
    logical :: addmonth

    call date_and_time(values=datetime_end)

    ! Starting at the start time, go by minutes and increment
    ta = datetime_start
    minutes = 0d0
    do while (minutes<=144000) ! go for up to 100 days (place the max in case there is an error below)
        if (all(ta([1,2,3,5,6])==datetime_end([1,2,3,5,6]))) exit
        minutes = minutes + 1._rt

        ta(6) = ta(6) + 1 ! add a minute
        if (ta(6)>59) then
            ta(6) = 0
            ta(5) = ta(5) + 1 ! add an hour
            if (ta(5)>23) then
                ta(5) = 0 
                ta(3) = ta(3) + 1 ! add a day
                select case (ta(2))
                    case (2)
                        addmonth = ta(3)>28
                    case (4,6,9,11)
                        addmonth = ta(3)>30
                    case default
                        addmonth = ta(3)>31
                end select
                if (addmonth) then
                    ta(3) = 1 ! reset day to 1
                    ta(2) = ta(2) + 1 ! add a month
                    if (ta(2)>12) then
                        ta(1) = ta(1) + 1 ! add a year
                    end if
                end if
            end if
        end if
    end do

    ! Now have the measure down to minutes, get seconds and milliseconds
    seconds = datetime_end(7) - datetime_start(7) + (datetime_end(8) - datetime_start(8))/1000d0

    if (present(time_out)) then
        time_out = minutes + seconds/60d0
    else
        write(*,'(A,f14.6,A,f14.6,A,f14.6,A,f14.6,A)') 'Elapsed time: ',&
            (minutes+seconds/60d0)/60d0,' (hr) or ',&
            minutes+seconds/60d0,' (min) or ',&
            minutes*60d0 + seconds,' (sec) or ',&
            minutes*60d3 + seconds*1d3,' (ms)'
    end if

    
end subroutine toc

end module mod_core
