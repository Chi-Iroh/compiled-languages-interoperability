subroutine f90_hello() bind(C)
  write(*,'(A)') 'Hello, world from FORTRAN !'
end subroutine f90_hello
