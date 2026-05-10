module mod_types_private
    implicit none
    include 'mpif.h'
end module 
module mod_types
    use mod_types_private, only: MPI_REAL,MPI_DOUBLE_PRECISION
    implicit none

    ! Single precision
    ! integer, parameter :: rt = 4 
    ! integer, parameter :: mympi_rt = MPI_REAL 

    ! Double precision
    integer, parameter :: rt = 8
    integer, parameter :: mympi_rt = MPI_DOUBLE_PRECISION 

    private 
    public :: rt, mympi_rt
end module 
