#! /bin/sh -v


export GSI_PATH = /uufs/chpc.utah.edu/common/home/zpu-group10/pu02/installation/11_install/gsi/comGSIv3.6_EnKFv1.2_prog04_for_understanding_codes

include ${GSI_PATH}/dtc/configure.gsi

FC   = $(SFC)
FLAGS= $(FFLAGS_DEFAULT)   
INCLD=  -I${GSI_PATH}/dtc/include
LIBS =  -L${GSI_PATH}/src -lgsi

all: read_diag_conv

read_diag_conv: read_diag_conv.o
	${FC} -o read_diag_conv.exe ${FLAGS} read_diag_conv.o ${LIBS} 
	rm read_diag_conv.o

.SUFFIXES : .f90  .o

.f90.o :
	${FC} ${FLAGS} ${INCLD} -c $<

clean:
	/bin/rm -f *.o *.exe
