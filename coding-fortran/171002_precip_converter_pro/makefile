#! /bin/sh -v

#-----------------------------------------------------------
# 1. Set library path. 
# 2. Define the fortran compiler and options 
#    or add settings if your compiler is not included.
#-----------------------------------------------------------

# 1. Set library path
#    ----------------
LIB_W3=/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/installation/12_install/packages/w3lib-2.0.6/libw3.a 
LIB_G2=/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/installation/12_install/packages/g2lib-3.1.0/libg2.a  

# 2. Define the fortran compiler and options 
#    ---------------------------------------
# 2.1 Options for IBM AIX
#     -------------------
#FC=xlf90
#FLAGS=-O2

# 2.2 Options fot LINUX GFORTRAN 
#     --------------------------
FC=gfortran
FLAGS=-fconvert=big-endian

# 2.3 Options for LINUX IFORT 
#     -----------------------
#FC=ifort 
#FLAGS='-convert big_endian'

# 2.4 Options fot LINUX PGI
#     ----------------------
#FC=pgf90
#FLAGS=-byteswapio

# 3.  Compile the code
#     ----------------
write_rainobs: write_rainobs.o
	${FC} -o write_rainobs.exe write_rainobs.o ${LIB_W3} ${LIB_G2}
.SUFFIXES: .f90 .o
.f90.o:
	${FC} ${FLAGS} -c $< 
clean:
	rm -f *.o *.exe
