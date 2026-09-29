 PROGRAM read_porosity
 implicit none
 integer,parameter :: nx=1440, ny=600
 real,dimension(nx,ny) :: por
 character(len=30) :: fname
!*** select top(0-2cm), middle(2-150cm), or bottom (150-350cm) layer
 fname = 'porfaot.1gd4r'
! fname = 'porfaom.1gd4r'
!! fname = 'porfaob.1gd4r'
! fname = 'porfaob.1gd4r'
 open(98,file=trim(fname),form='unformatted',status='old', &
      access='direct',recl=nx*ny*4,CONVERT='BIG_ENDIAN')
 read(98,rec=1) por
 open(100,file="porfaot.txt")
 write(100,*) por
 close(100)
 close(98)
 END
