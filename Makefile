PLAT = _LINUX

CC        = gcc
CFLAGS    = -O3 -ansi 
#BLASLIB   = ./CLAPACK/lsblaspii1.2f_03.00.a
BLASLIB   = ./CLAPACK/blas$(PLAT).a
LAPACKLIB = ./CLAPACK/lapack$(PLAT).a
F2CLIB    = ./CLAPACK/F2CLIBS/libF77$(PLAT).a ./CLAPACK/F2CLIBS/libI77$(PLAT).a
LIBS      = $(LAPACKLIB) $(BLASLIB) $(F2CLIB) -lm
OBJS      = ica.o interfc.o r250.o randlcg.o dsum.o

ica_linux: Makefile.linux ica.h memap.h $(OBJS)
	$(CC) -o ica_linux $(OBJS) $(LIBS)

ica.o: Makefile.linux ica.h memap.h ica.c
	$(CC) -c ica.c $(CFLAGS)

interfc.o: Makefile.linux ica.h memap.h interfc.c
	$(CC) -c interfc.c $(CFLAGS)

memap.o: Makefile.linux memap.h memap.c
	$(CC) -c memap.c $(CFLAGS)

r250.o: Makefile.linux r250.h r250.c
	$(CC) -c r250.c $(CFLAGS)

randlcg.o: Makefile.linux randlcg.h randlcg.c
	$(CC) -c randlcg.c $(CFLAGS)

dsum.o: Makefile.linux dsum.c
	$(CC) -c dsum.c $(CFLAGS)

clean:
	rm -f *.o
