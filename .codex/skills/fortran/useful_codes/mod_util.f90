! Collection of utility programs
! -> isNaN and isInvalidNumber
! -> sleep
! -> getcmdarg_? : gets a requested command argument (the type must be specified by "?", d for real(rt), i for integer, s for string)
! -> *_delim_arg : process a delimited string
module mod_util
    use mod_types
    implicit none
    private :: getcmdarg_core

    type timer 
        real(8) :: refpt
        logical :: ispaused = .false.
        real(8) :: total = 0d0
    contains
        ! procedure, pass :: init => timer_init
        procedure, pass :: stop => timer_stop
        procedure, pass :: start => timer_start
        procedure, pass :: elapsed => timer_elapsed
    end type
contains
    

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! Compute the time
!     subroutine timer_init(this)
!         use omp_lib
!         implicit none
!         class(timer) :: this
!         this%refpt = omp_get_wtime()
!         this%ispaused = .false.
!         this%total = 0d0
!     end subroutine 
    subroutine timer_stop(this)
        use omp_lib
        implicit none
        class(timer) :: this
        this%total = this%total + (omp_get_wtime()-this%refpt)
        this%ispaused = .true.
    end subroutine
    subroutine timer_start(this)
        use omp_lib
        implicit none
        class(timer) :: this
        this%refpt = omp_get_wtime()
        this%ispaused = .false.
    end subroutine
    real(8) function timer_elapsed(this)
        use omp_lib
        implicit none
        class(timer) :: this

        if (this%ispaused) then
            timer_elapsed = this%total 
        else
            timer_elapsed = this%total + (omp_get_wtime()-this%refpt)
        end if

    end function

    



    subroutine test_util()
        implicit none
        real(rt) :: x

! NOTE: in the compiler, I am now chanking for overflows etc. So this causes it to crash.
        x = -1._rt
!         if (.not. isNaN(log(x))) print*,'WARNING: isNaN failed to detect a NaN (this may ',&
!                                         'happen if the compiler optimizes too much or is not IEEE compliant)'
!         if (.not. isInvalidNumber(log(x))) STOP 'ERROR: isInvalidNumber failed test 1'
        if (isInvalidNumber(3e0_rt)) STOP 'ERROR: isInvalidNumber failed test 2'

        print*,'test_util: passed'

    end subroutine 

    ! NOTE: this may not work depending on compiler options. E.g., if -ffast-math is enabled, then IEEE arithmetic rules
    ! are ignored.
!     function isNaN(x) result(tf)
!         use ieee_arithmetic, only: ieee_is_nan ! F2003 intrinsic
!         implicit none
!         real(rt) :: x
!         logical :: tf
! 
!         ! NaN is not equal to anything, not even itself
!         tf = ieee_is_nan(x)
! 
!     end function 
    elemental function isNaN(x) result(tf)
        implicit none
        real(rt), intent(in) :: x 
        logical :: tf

        ! NaN is not equal to anything, not even itself
        tf = x/=x

    end function 

    ! This works even with ffast math
    elemental function isInvalidNumber(x) result(tf)
        implicit none
        real(rt), intent(in) :: x
        logical :: tf

        ! This should evaluate to false if x is a normal number (not infinite, not NaN)
        tf = .not. ( x>=-huge(0d0) .and. x<=huge(0d0))

    end function 


    ! http://stackoverflow.com/questions/6931846/sleep-in-fortran
    subroutine sleep(sec)
        use, intrinsic :: iso_c_binding, only: c_int
        implicit none
        integer, intent(in) :: sec
        integer (c_int) :: sec_c
        integer (c_int) :: err

        interface
            function callcsleep(seconds)  bind ( C, name="sleep" )
                use, intrinsic :: iso_c_binding, only: c_int
                import
                implicit none
                integer (c_int) :: callcsleep
                integer (c_int), value :: seconds
            end function 
        end interface

        sec_c = int(sec,c_int)

        err = callcsleep(sec_c)

    end subroutine

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! DISPLAY A DOUBLE PRECISION VECTOR IN A NICE FORMAT
    function printx(x) result(str)
        implicit none
        integer, parameter :: stride = 17
        real(rt), intent(in) :: x(:)
        character(len=1+stride*size(x)) :: str
        ! local
        integer :: ix

        if (1+stride*size(x)>len(str)) then
            str = 'size(x) is too large, cannot display'
            return 
        end if

        str = '' ! blank it out
        write(str(1:1),'(A)') '['
        do ix = 1,size(x)-1
            write(str(2+stride*(ix-1):1+stride*ix),'(d15.8,A)') x(ix),','
        end do
        write(str(2+stride*(ix-1):1+stride*ix),'(d15.8,A)') x(size(x)),']'

    end function


    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! PARSING
    ! Given a delimited string, such as "xtoler=1d-6,printmod=1" (in this case, the delimiter could be ","), gives the ith
    ! argument (1 would be "xtoler=1d-6" and 2 would be "printmod=1" in this example). There is also a routine to determine
    ! how many arguments there are.
    function count_delim_arg(str,del) result(n)
        implicit none
        character(len=*) :: str
        character(len=1) :: del
        integer :: n
        ! local
        integer :: i,nloc

        nloc = 0
        do i = 1,len(str)
            if (str(i:i)==del) nloc = nloc + 1
        end do
        n = nloc + 1

    end function 
    function get_delim_arg(str,del,i) result(arg)
        implicit none
        character(len=*) :: str
        character(len=1) :: del
        integer, intent(in) :: i
        character(len=len(str)) :: arg
        ! local
        integer :: j,n,ta,tb

        if (i>count_delim_arg(str,del)) then
            arg = 'error_getting_arg'
            return
        end if

        n = 0
        tb = 1 
        do j = 1,len(str)
            if (str(j:j)==del .or. j==len(str)) then
                ta = tb
                tb = j
                n = n + 1
                if (n==i) exit
            end if
        end do

        ! Here, should have str(ta:tb) almost as the argument. 
        ! However, str(ta) and str(tb) may or may not be delimiters.
        if (ta>1) then 
            ta = ta + 1
        end if
        if (tb<len(str)) then
            tb = tb - 1
        end if

        ! Output the string
        arg = '' ! put blank, or else there can be garbage
        arg(1:tb-ta+1) = str(ta:tb)

    end function 
    subroutine test_delim_arg()
        implicit none
        character(len=200) :: str,chk
        character(len=20) :: a,b,c
        integer :: n 

        a = "argone"
        b = "argtwo"
        c = "argthree"
        
        str = trim(a)//";"//trim(b)//";"//trim(c)

        
        n = count_delim_arg(str,";")

        if (n/=3) stop 'test_delim_arg: failed test 1'

        chk = get_delim_arg(str,";",1)
        if (trim(chk)/=trim(a)) then
            print*,'trim(a)  :',trim(a),'len_trim(a)',len_trim(a)
            print*,'trim(chk):',trim(chk),'len_trim(chk)',len_trim(chk)
            print*,'trim(chk)==trim(a)',trim(chk)==trim(a)
            print*,'trim(chk)/=trim(a)',trim(chk)/=trim(a)
            print*,'chk(1:1)==a(1:1)',chk(1:1)==a(1:1)
            print*,'chk(2:2)==a(2:2)',chk(2:2)==a(2:2)
            print*,'chk(3:3)==a(3:3)',chk(3:3)==a(3:3)
            print*,'chk(4:4)==a(4:4)',chk(4:4)==a(4:4)
            print*,'chk(5:5)==a(5:5)',chk(5:5)==a(5:5)
            print*,'chk(6:6)==a(6:6)',chk(6:6)==a(6:6)
            print*,'chk(7:7)==a(7:7)',chk(7:7)==a(7:7)
            stop 'test_delim_arg: failed test 2a'
        end if
        chk = get_delim_arg(str,";",2)
        if (trim(chk)/=trim(b)) stop 'test_delim_arg: failed test 2b'
        chk = get_delim_arg(str,";",3)
        if (trim(chk)/=trim(c)) stop 'test_delim_arg: failed test 2c'

        print*,'test_delim_arg: passed'

    end subroutine




    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! GET COMMAND LINE ARGUMENTS
    function getcmdarg_d(i) result(arg)
        implicit none
        integer, intent(in) :: i
        real(rt) :: arg
        ! local
        real(rt) :: xd
        integer :: xi
        character(1024) :: xs

        call getcmdarg_core(i,xd,xi,xs,'d')
        arg = xd
        
    end function 
    function getcmdarg_i(i) result(arg)
        implicit none
        integer, intent(in) :: i
        integer :: arg
        ! local
        real(rt) :: xd
        integer :: xi
        character(1024) :: xs

        call getcmdarg_core(i,xd,xi,xs,'i')
        arg = xi
        
    end function 
    function getcmdarg_s(i) result(arg)
        implicit none
        integer, intent(in) :: i
        character(len=1024) :: arg
        ! local
        real(rt) :: xd
        integer :: xi
        character(1024) :: xs

        call getcmdarg_core(i,xd,xi,xs,'s')
        arg = adjustl(trim(xs))
        
    end function 

    subroutine getcmdarg_core(i,xd,xi,xs,type_expected)
        implicit none
        integer, intent(in) :: i ! which command argument is desired
        real(rt), intent(inout) :: xd ! output (if real)
        integer, intent(inout) :: xi ! output (if integer)
        character(*), intent(inout) :: xs ! output (if string)
        character(1), intent(in) :: type_expected ! d for double, i for integer, s for string
        ! local
        character(len=1024) :: str

        if (i>command_argument_count()) then
            xd = -1d0
            xi = -1
            xs = "-1"
            write(0,'(A,i5,A,i5,A)') 'WARNING: getcmdarg: arg ',i,' couldn''t be obtained, only ',&
                                               command_argument_count(),' arguments present'
            return
        end if

        ! Get the argument as a string
        call get_command_argument(i,str)

        ! Convert it to the specified type
        select case (type_expected)
            case ('d')
                read(str,'(d30.16)') xd
            case ('i')
                read(str,'(i30)') xi
            case ('s')
                xs = trim(adjustl(str))
        end select

    end subroutine 
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    function conv_i_to_s(i) result(s)
        implicit none
        integer, intent(in) :: i
        character(len=11) :: s ! largest integer is 2147483647 (10 digits)
        ! local
        integer :: j,k
        character(len=1) :: t

        s = ' '

        j = abs(i)

        if (j==0) then
            s = '0'
            return
        end if

        k = 0
        do while (j>0)
            k = k+1
            write(s(k:k),'(i1)') mod(j,10)
            j = j/10
        end do

        ! Now reverse it
        do j = 1,k/2
            t = s(j:j)
            s(j:j) = s(k-j+1:k-j+1)
            s(k-j+1:k-j+1) = t
        end do

        ! If negative, shift right and add -
        if (i<0) then
            do j = k,1,-1
                s(j+1:j+1) = s(j:j)
            end do
            s(1:1) = '-'
        end if

    end function


end module

! program main
!     use mod_cmdarg
!     implicit none
!     character(1024) :: str
! 
!     call get_command(str)
!     print*,repeat('*',100)
!     print*,'Full command line: ',trim(adjustl(str))
!     print*,repeat('*',100)
!     print*,'command argument #0 (name of program):    ', trim(getcmdarg_s(0))
!     print*,'command argument #1 (expecting double):   ', getcmdarg_d(1)
!     print*,'command argument #2 (expecting integer):  ', getcmdarg_i(2)
!     print*,'command argument #3 (expecting string):   ', trim(getcmdarg_s(3))
!     print*,'command argument #4 (only 3 args, error): ', trim(getcmdarg_s(4))
!     print*,repeat('*',100)
! 
! end program
