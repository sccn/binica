Extended Infomax ICA Binary compiled for Windows 10 x64
Based on original source win32 Visual Studio 6 (2001) source by 
Sigurd Enghoff (http://cnl.salk.edu/~enghoff/download1/)
Modified by Ernest Pedapati and Ellen Russo
ernest.pedapati [at] gmail [dot] com

SOFTWARE REQUIREMENTS:

      ANSI C compiler
      BLAS and LAPACK math libraries
      MATLAB version 5.0 or higher (*)

(*) MEX implementation only

HOW TO COMPILE:
The ICA software requires the BLAS and LAPACK libraries. A public domain implementation of the library packages is available from NETLIB at http://www.netlib.org/clapack/.
NOTE: hardware optimized implementations of the BLAS routines are available for most architectures and have proven to increase execution speed by 4-500%.

Makefiles have been constructed for several platforms. To compile the ICA software using an existing Makefile; modify the library paths to fit the paths on you system. Next, make the designated Makefile.

Example:
      make -f Makefile.alpha


If you compile the ICA software for multiple architectures, make sure to run a 'make-clean' between each make session.

Example:
      make -f Makefile.alpha clean


A Makefile must be constructed to compile the ICA software for a platform for which no Makefile exists. You may modify any of the existing Makefiles to fit your system.

Defining MMAP causes the ICA software to use memory mapping rather than memory allocation for data storage. Memory mapping allows the ICA software to return freed memory to the kernel, thus significantly decreases memory usage. However, memory mapping may not work on all systems.

PLEASE READ THE LICENSE FILE FIRST - GNU GPL
Infomax ICA implemented here might also be under a patent by the Salk Institute 
and any commercial application using this type of algorithm (or the recompiled 
binary files distributed here) should contact the Salk Institute patent office.

See also this implementation in CUDA https://github.com/fraimondo/cudaica

For more information, see also the wiki page https://github.com/sccn/binica/wiki

Please help maintain this repository.
