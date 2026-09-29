 PROGRAM read_soils
 implicit none
 integer,parameter :: nx=1440, ny=600
 real,dimension(nx,ny) :: soils
 character(len=30) :: fname
!*** select clay, silt, or sand file
 fname = 'tex_statsfao_mod44w_025.1gd4r'
! fname = 'clayfao.1gd4r.bin'
! fname = 'siltfao.1gd4r.bin'
! fname = 'sandfao.1gd4r.bin'
 open(98,file=trim(fname),form='unformatted',status='old', &
      access='direct',recl=nx*ny*4,CONVERT='BIG_ENDIAN')
 read(98,rec=1) soils
 open(100,file="tex_statsfao.txt")
 write(100,*) soils
 close(100)
 close(98)
 END
