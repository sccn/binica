@echo off
REM run_ica_windows.bat - Run binica ICA on Windows
REM Usage: run_ica_windows.bat <dataset_basename> [n_channels] [n_timepoints]
REM
REM Example: run_ica_windows.bat data\eeglab_data 32 30504

setlocal enabledelayedexpansion

REM ICA executable for Windows
set ICA_BIN=ica_windows.exe

REM Parse command line arguments
if "%~1"=="" (
    set DATASET=data\eeglab_data
) else (
    set DATASET=%~1
)

if "%~2"=="" (
    set NCHANS=32
) else (
    set NCHANS=%~2
)

if "%~3"=="" (
    set NPOINTS=30504
) else (
    set NPOINTS=%~3
)

REM Derived paths
set DATAFILE=%DATASET%.fdt
set SETFILE=%DATASET%.set
set WTSFILE=%DATASET%.wts_windows
set SPHFILE=%DATASET%.sph_windows
set CONFIGFILE=%DATASET%_ica.sc

REM Extract basename for display
for %%F in ("%DATASET%") do set BASENAME=%%~nxF

echo ========================================
echo Running binica ICA (Windows)
echo ========================================
echo Dataset: %DATASET%
echo Channels: %NCHANS%
echo Data points: %NPOINTS%
echo.

REM Check if data file exists
if not exist "%DATAFILE%" (
    echo Error: Data file %DATAFILE% not found
    exit /b 1
)

REM Check if ICA executable exists
if not exist "%ICA_BIN%" (
    echo Error: ICA executable %ICA_BIN% not found
    echo Please compile the project first: make -f Makefile.windows
    exit /b 1
)

REM Create ICA configuration file
echo Creating ICA configuration file...
(
echo # ICA configuration for %BASENAME%
echo DataFile       %DATAFILE%
echo chans          %NCHANS%
echo datalength     %NPOINTS%
echo.
echo WeightsOutFile %WTSFILE%
echo SphereFile     %SPHFILE%
echo.
echo # Reproducibility
echo seed           1
echo.
echo # Precision
echo doublewrite    on
echo.
echo # Extended ICA options:
echo # extended 0   = Standard logistic ICA ^(no extended^)
echo # extended 1   = Extended ICA, auto-detect sub/super-Gaussian ^(recommended^)
echo # extended N   = Extended ICA, calculate PDF every N blocks
echo # extended -N  = Extended ICA, assume exactly N sub-Gaussian components
echo extended       1
echo.
echo # Learning parameters
echo lrate          5.0e-4
echo stop           1.0e-6
echo maxsteps       512
) > "%CONFIGFILE%"

echo Configuration saved to: %CONFIGFILE%
echo.

REM Run binica ICA
echo Running binica ICA...
echo Command: %ICA_BIN% ^< %CONFIGFILE%
echo.

%ICA_BIN% < "%CONFIGFILE%"

if errorlevel 1 (
    echo.
    echo Error: ICA failed
    exit /b 1
)

echo.
echo ========================================
echo ICA completed successfully!
echo ========================================
echo Output files:
echo   Weights: %WTSFILE%
echo   Sphere:  %SPHFILE%
echo   Config:  %CONFIGFILE%
echo.

endlocal
