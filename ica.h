/******************************************************************************/
/* For all support and information please contact:                            */
/*                                                                            */
/*   Sigurd Enghoff                                                           */
/*   The Salk Institute, CNL                                                  */
/*   enghoff@salk.edu                                                         */
/*                                                                            */
/* Additional ICA software:                                                   */
/*   http://www.cnl.salk.edu/~enghoff/                                        */
/*                                                                            */
/* Modification:                                                              */
/*   Chenge version from Version 1.3 (September 20, 1999) to 1.4 (Feb. 2002)  */
/*   Jeng-Ren Duann, 2002-02-14                                               */
/*   CNL, Salk Inst.                            
/*                                                                            */
/******************************************************************************/

#ifndef __defs_h
#define __defs_h

#include "f2c.h"

#define VER_INFO               "Version 1.4  (Feb. 14, 2002)"

/*#ifdef PVM
#define PROB_WINDOW
#endif*/

/* If R250 is defined random number are generated using the r250 algorithm    */
/* otherwise standard srand and rand function calls are used                  */
#define R250

/* If KURTOSIS_ESTIMATE is defined sub- and super-Gaussian distributions are  */
/* estimated using:                                                           */
/*    k = E{u^2}^2 / E{x^4} - 3                                               */
/* else:                                                                      */
/*    k = E{sech(u)^2} * E{u^2} - E{tanh(u) * u}                              */

#define KURTOSIS_ESTIMATE

#define MAX_WEIGHT             1e8
#define DEFAULT_STOP           0.000001
#define DEFAULT_ANNEALDEG      60
#define DEFAULT_ANNEALSTEP     0.90
#define DEFAULT_EXTANNEAL      0.98
#define DEFAULT_MAXSTEPS       512
#define DEFAULT_MOMENTUM       0.0

#define DEFAULT_BLOWUP         1000000000.0
#define DEFAULT_BLOWUP_FAC     0.8
#define DEFAULT_RESTART_FAC    0.9

#define MIN_LRATE              0.000001
#define MAX_LRATE              0.1
#define DEFAULT_LRATE(chans)   0.015/log((doublereal)chans)

#define DEFAULT_BLOCK(length)  (integer)sqrt((doublereal)length/3.0)

/* Extended-ICA option: */
#define DEFAULT_EXTENDED       0
#define DEFAULT_EXTBLOCKS      1
#define DEFAULT_NSUB           1

#define DEFAULT_EXTMOMENTUM    0.5
#define MAX_PDFSIZE            6000
#define MIN_PDFSIZE            2000
#define SIGNCOUNT_THRESHOLD    25

#ifdef KURTOSIS_ESTIMATE
#define DEFAULT_SIGNSBIAS      0.02
#else
#define DEFAULT_SIGNSBIAS      0.0
#endif

#define SIGNCOUNT_STEP         2

#define DEFAULT_BIASFLAG       1

#define MIN(x,y) (((x) > (y)) ? (y) : (x))
#define DEGCONST               180.0/ICA_PI
#define ICA_PI                 3.14159265358979324

#define DEFAULT_PCAFLAG        0
#define DEFAULT_SPHEREFLAG     1
#define DEFAULT_POSACT         1
#define DEFAULT_VERBOSE        1

#define NWINDOW                5
#define FRAMEWINDOW            0
#define FRAMESTEP              1
#define EPOCHWINDOW            2
#define EPOCHSTEP              3
#define BASELINE               4

#define EOL 0x0A
/* Fixing the seed causes multiple runs of a given */
/* configuration to yield identical results */
/* #define FIX_SEED */

#ifdef R250
#define SRAND(seed) r250_init(seed)
#define RAND        r250
#else
#define SRAND(seed) srand(seed)
#define RAND        rand
#endif

typedef struct {
    integer    idx;
    doublereal val;
} idxelm;

typedef struct {
    char *token;
    void *prev;
} key;

extern integer extended, extblocks, pdfsize, nsub;
extern integer verbose, block, maxsteps;

extern doublereal lrate, annealstep, annealdeg, nochange, momentum;

extern void error(char*);

extern void zero(integer, doublereal*);
extern void eye(integer, doublereal*);
extern void rmmean(doublereal*, integer, integer);
extern void syproj(doublereal*, doublereal*, integer, integer, doublereal*);
extern void geproj(doublereal*, doublereal*, integer, integer, doublereal*);
extern void pcaproj(doublereal*, doublereal*, integer, integer, integer, doublereal*);
extern void varsort(doublereal*, doublereal*, doublereal*, doublereal*, doublereal*, integer*, integer, integer, integer);
extern void do_sphere(doublereal*, integer, integer, doublereal*);
extern void pca(doublereal*, integer, integer, doublereal*);
extern void posact(doublereal*, doublereal*, integer, integer, doublereal*);
extern void runica(doublereal*, doublereal*, integer, integer, integer, doublereal*, integer*);

extern doublereal dsum_(integer*, doublereal*, integer*);
extern doublereal ddot_(integer*, doublereal*, integer*, doublereal*, integer*);
extern integer idamax_(integer*, doublereal*, integer*);
extern integer ilaenv_(integer*, char*, char*, integer*, integer*, integer*, integer*);
extern void dscal_(integer*, doublereal*, doublereal*, integer*);
extern void dcopy_(integer*, doublereal*, integer*, doublereal*, integer*);
extern void dswap_(integer*, doublereal*, integer*, doublereal*, integer*);
extern void daxpy_(integer*, doublereal*, doublereal*, integer*, doublereal*, integer*);
extern void dgemv_(char*, integer*, integer*, doublereal*, doublereal*, integer*, doublereal*, integer*, doublereal*, doublereal*, integer*);
extern void dgemm_(char*, char*, integer*, integer*, integer*, doublereal*, doublereal*, integer*, doublereal*, integer*, doublereal*, doublereal*, integer*);
extern void dsymm_(char*, char*, integer*, integer*, doublereal*, doublereal*, integer*, doublereal*, integer*, doublereal*, doublereal*, integer*);
extern void dsyrk_(char*, char*, integer*, integer*, doublereal*, doublereal*, integer*, doublereal*, doublereal*, integer*);
extern void dsyev_(char*, char*, integer*, doublereal*, integer*, doublereal*, doublereal*, integer*, integer*);
extern void dgesv_(integer*, integer*, doublereal*, integer*, integer*, doublereal*, integer*, integer*);
extern void dgetri_(integer*, doublereal*, integer*, integer*, doublereal*, integer*, integer*);
extern void dgetrf_(integer*, integer*, doublereal*, integer*, integer*, integer*);

#endif
