# BINICA - Binary Independent Component Analysis

Extended Infomax ICA implementation in C with platform-independent reproducibility.

Based on original source code by **Sigurd Enghoff** (CNL / Salk Institute, 2001)
Modified by **Ernest Pedapati** and **Ellen Russo**
Enhanced for cross-platform reproducibility and 64-bit precision

## Features

- ✓ **Extended ICA** - Handles both sub-Gaussian and super-Gaussian sources
- ✓ **Cross-platform reproducible** - Fixed RNG seed ensures identical results
- ✓ **64-bit precision** - Optional double precision output
- ✓ **Optimized BLAS** - Uses Apple Accelerate (macOS) or OpenBLAS/MKL (Linux)
- ✓ **EEGLAB compatible** - Direct integration with EEGLAB MATLAB toolbox
- ✓ **Memory efficient** - Optional memory mapping (MMAP) support

## Quick Start

```bash
# Compile
make -f Makefile.darwin  # macOS
# or
make -f Makefile.linux   # Linux
# or
make -f Makefile.windows # Windows

# Run ICA
./ica_darwin < config.sc         # macOS
# or
./ica_linux < config.sc          # Linux
# or
./ica_windows.exe < config.sc    # Windows

# Run full pipeline (automated)
./run_ica_and_plot.sh ./data/eeglab_data 32 30504  # Unix/macOS (includes MATLAB plotting)
# or
run_ica_windows.bat data\eeglab_data 32 30504      # Windows (Batch)
# or
.\run_ica_windows.ps1 data\eeglab_data 32 30504    # Windows (PowerShell)
```

## Software Requirements

### Compiler
- **ANSI C compiler** (GCC, Clang, or compatible)
- C99 standard or later

### Libraries
- **BLAS** (Basic Linear Algebra Subprograms)
- **LAPACK** (Linear Algebra Package)

**Recommended BLAS implementations:**
- **macOS:** Apple Accelerate framework (included)
- **Linux:** OpenBLAS, Intel MKL, or ATLAS
- **Windows:** OpenBLAS (precompiled version included in `openblas_win/`)
- **Performance note:** Hardware-optimized BLAS implementations can increase execution speed by 400-500%

Public domain BLAS/LAPACK available from [NETLIB](http://www.netlib.org/clapack/)

### Optional
- **MATLAB** R2015b or higher (for visualization and EEGLAB integration)
- **EEGLAB** toolbox (for EEG-specific functionality)

## Directory Structure

```
binica/
├── ica_darwin              # Compiled executable (macOS)
├── Makefile.darwin         # macOS build configuration
├── Makefile.linux          # Linux build configuration (if exists)
│
├── src/                    # C source files
│   ├── ica.c              # Main ICA algorithm
│   ├── interfc.c          # Configuration and I/O interface
│   ├── memap.c            # Memory mapping utilities
│   ├── r250.c             # R250 random number generator
│   ├── randlcg.c          # Linear congruential generator (seeding)
│   └── dsum.c             # BLAS helper functions
│
├── include/                # Header files
│   ├── ica.h              # Main ICA header
│   ├── memap.h            # Memory mapping header
│   ├── r250.h             # RNG header
│   └── randlcg.h          # LCG header
│
├── obj/                    # Object files (generated during build)
│
├── scripts/                # Shell scripts
│   ├── run_ica_and_plot.sh       # Full ICA + visualization pipeline
│   └── test_cross_platform.sh   # Cross-platform reproducibility test
│
├── matlab/                 # MATLAB analysis scripts
│   ├── compare_darwin_linux.m    # Full comparison with topographies
│   ├── compare_matrices_simple.m # Standalone matrix comparison
│   └── plot_ica_matlab.m         # Topography visualization
│
├── data/                   # Data files and results
│   ├── *.fdt              # Binary float data (input)
│   ├── *.set              # EEGLAB dataset files
│   ├── *.wts              # ICA weight matrices (output)
│   ├── *.sph              # ICA sphere matrices (output)
│   └── *.sc               # ICA configuration files
│
├── docs/                   # Documentation
│   ├── RNG_REPRODUCIBILITY.md    # Random number generator details
│   ├── EXTENDED_ICA.md           # Extended ICA usage guide
│   ├── COMPARISON_README.md      # Cross-platform comparison guide
│   ├── COMPARISON_RESULTS.md     # Analysis of platform differences
│   └── SUMMARY.md                # Implementation summary
│
└── old/                    # Archived files (legacy)
```

## Configuration Example

Create a configuration file (e.g., `config.sc`):

```
# Input data
DataFile       data/eeglab_data.fdt
chans          32
datalength     30504

# Output files
WeightsOutFile data/eeglab_data.wts
SphereFile     data/eeglab_data.sph

# Reproducibility
seed           1

# Precision
doublewrite    on

# Extended ICA (recommended for EEG)
extended       1

# Learning parameters
lrate          5.0e-4
stop           1.0e-6
maxsteps       512
```

## Running ICA

### Quick Run (Automated Scripts)

**Windows (Batch):**
```batch
run_ica_windows.bat data\eeglab_data 32 30504
```

**Windows (PowerShell):**
```powershell
.\run_ica_windows.ps1 data\eeglab_data 32 30504
```

**Unix/macOS:**
```bash
./run_ica_and_plot.sh ./data/eeglab_data 32 30504
```

These scripts will:
1. Create an ICA configuration file
2. Run the ICA analysis
3. Generate weights and sphere matrices

### Manual Run

**Windows:**
```batch
# Create or edit your configuration file (e.g., config.sc)
# Then run:
ica_windows.exe < config.sc
```

**Unix/macOS:**
```bash
./ica_darwin < config.sc  # macOS
./ica_linux < config.sc   # Linux
```

## Building from Source

When compiling for different platforms, always clean between builds.

### macOS (Darwin)

```bash
make -f Makefile.darwin clean
make -f Makefile.darwin
```

**Requirements:**
- Xcode Command Line Tools: `xcode-select --install`
- Apple Accelerate framework (included with macOS)

### Linux

```bash
make -f Makefile.linux clean
make -f Makefile.linux
```

### Windows

```bash
# Using WinLibs MinGW-w64 and OpenBLAS (preinstalled in this repository)
# Add MinGW-w64 GCC to your PATH, then:
make -f Makefile.windows clean
make -f Makefile.windows
```

**Requirements:**
- MinGW-w64 GCC compiler (recommended: WinLibs via winget)
- OpenBLAS library (included in `openblas_win/` directory)

**Installation (first time only):**
```bash
# Install WinLibs MinGW-w64 using Windows Package Manager
winget install --id BrechtSanders.WinLibs.MCF.UCRT
```

**Important:** The `libopenblas.dll` file must be in the same directory as `ica_windows.exe` or in your system PATH. The Makefile automatically copies it to the root directory after compilation.

### Expanse supercomputer (Rocky Linux)

```bash
module load cpu/0.15.4 gcc/10.2.0
module load openblas/0.3.10-openmp
make -f Makefile.expanse clean
make -f Makefile.expnase
```

**Requirements:**
- GCC compiler
- BLAS/LAPACK library:
  ```bash
  # Debian/Ubuntu
  sudo apt-get install libopenblas-dev

  # RedHat/CentOS
  sudo yum install openblas-devel

  # Or Intel MKL for best performance
  ```

### Memory Mapping (MMAP)

**MMAP Support:** Define `MMAP` in `CFLAGS` to enable memory mapping for data storage.

**Benefits:**
- Returns freed memory to kernel
- Significantly decreases memory usage
- Better handling of large datasets

**Note:** Memory mapping may not work on all systems. If you encounter issues, compile without `-DMMAP`.

**Example:**
```makefile
# Enable MMAP
CFLAGS = -O3 -I$(INCDIR) -DMMAP
```

## Configuration Options

### Required Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `DataFile` | Input binary data file (float32) | `data/eeg.fdt` |
| `chans` | Number of channels | `32` |
| `datalength` | Number of time points | `30504` |
| `WeightsOutFile` | Output weights matrix | `data/eeg.wts` |
| `SphereFile` | Output sphere matrix | `data/eeg.sph` |

### Optional Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `seed` | 1 | RNG seed for reproducibility |
| `doublewrite` | off | 64-bit precision output (on/off) |
| `extended` | 0 | Extended ICA mode (0, N, or -N) |
| `lrate` | auto | Learning rate |
| `stop` | 1e-6 | Convergence threshold |
| `maxsteps` | 128 | Maximum training iterations |
| `blocksize` | auto | Block size for updates |
| `annealstep` | auto | Learning rate annealing factor |
| `annealdeg` | 60 | Angle threshold for annealing |
| `momentum` | 0 | Momentum term |
| `sphering` | on | Sphere data before ICA |
| `bias` | on | Use bias adjustment |
| `posact` | on | Force positive activations |

## Extended ICA Modes

| Mode | Description |
|------|-------------|
| `extended 0` | Standard logistic ICA (all super-Gaussian) |
| `extended 1` | Auto-detect sub/super-Gaussian (recommended) |
| `extended N` | Calculate PDF every N blocks |
| `extended -N` | Assume exactly N sub-Gaussian components |

## Random Number Generator

Uses **R250 shift-register generator** with **LCG seeding** for:
- ✓ Platform independence
- ✓ Bit-exact reproducibility
- ✓ Same seed → identical results across platforms

**Default:** `seed 1` (deterministic)

**For non-reproducible runs:** Comment out `#define FIX_SEED` in `include/ica.h` and recompile.

## Cross-Platform Reproducibility

With the same seed, different platforms should produce:
- **Sphere matrices:** Identical within numerical precision (~1e-13)
- **Weight matrices:** May differ due to BLAS implementation variations

To test reproducibility:
```bash
./scripts/test_cross_platform.sh
```

See `docs/RNG_REPRODUCIBILITY.md` for details.

## MATLAB Integration

### Load ICA Results

```matlab
% Load weights and sphere (64-bit)
fid = fopen('data/eeglab_data.wts', 'rb');
weights = fread(fid, [32, 32], 'float64')';
fclose(fid);

fid = fopen('data/eeglab_data.sph', 'rb');
sphere = fread(fid, [32, 32], 'float64')';
fclose(fid);

% Import into EEGLAB
EEG.icaweights = weights;
EEG.icasphere = sphere;
EEG = eeg_checkset(EEG);
```

### Compare Platforms

```matlab
% Compare Darwin vs Linux results
cd matlab
run('compare_matrices_simple.m')
```

## File Formats

### Input Data (.fdt)
- Binary float32 format
- Multiplexed by channel: `[chan1_t1, chan2_t1, ..., chanN_t1, chan1_t2, ...]`
- Size: `channels × timepoints × 4 bytes`

### Output Matrices (.wts, .sph)
- **32-bit (default):** `channels × channels × 4 bytes`
- **64-bit (doublewrite on):** `channels × channels × 8 bytes`
- Row-major order (C style)

## Common Issues

### Compilation Errors

**Issue:** `Accelerate/Accelerate.h not found`
```bash
# Install Xcode Command Line Tools
xcode-select --install
```

**Issue:** `BLAS library not found` (Linux)
```bash
# Install OpenBLAS
sudo apt-get install libopenblas-dev  # Debian/Ubuntu
sudo yum install openblas-devel       # RedHat/CentOS
```

### Runtime Errors

**Issue:** `invalid number of elements`
- Check file size: Should be `channels × timepoints × 4` bytes
- Verify data format is float32 (not float64)

**Issue:** Different results on same platform
- Check that seed is set: `seed 1`
- Verify `#define FIX_SEED` in `include/ica.h`

## Performance Tips

1. **Large datasets:** Use `extended 5` or `extended 10` instead of `extended 1`
2. **Fast convergence:** Increase learning rate: `lrate 1.0e-3`
3. **Memory constraints:** Enable MMAP or reduce block size
4. **Parallel processing:** Run multiple seeds in parallel for Monte Carlo studies
5. **Optimized BLAS:** Use hardware-optimized libraries (Intel MKL, Apple Accelerate)

## Related Projects

- **CUDA Implementation:** [cudaica](https://github.com/fraimondo/cudaica) - GPU-accelerated ICA
- **EEGLAB Plugin:** [EEGLAB](https://sccn.ucsd.edu/eeglab/) - MATLAB toolbox for EEG analysis
- **Wiki:** [binica wiki](https://github.com/sccn/binica/wiki) - Additional documentation and examples

## Contributing

Contributions are welcome! Please help maintain this repository by:
- Reporting bugs and issues
- Submitting pull requests
- Improving documentation
- Testing on different platforms

## References

1. Bell, A.J. & Sejnowski, T.J. (1995). "An Information-Maximization Approach to Blind Separation and Blind Deconvolution". *Neural Computation*, 7(6), 1129-1159.

2. Lee, T.-W., Girolami, M., & Sejnowski, T.J. (1999). "Independent Component Analysis Using an Extended Infomax Algorithm for Mixed Sub-Gaussian and Super-Gaussian Sources". *Neural Computation*, 11(2), 417-441.

3. Kirkpatrick, S., & Stoll, E. (1981). "A Very Fast Shift-Register Sequence Random Number Generator". *Journal of Computational Physics*, 40.

## License and Patents

**License:** GNU General Public License (GPL)
See `License.txt` for full details.

**IMPORTANT PATENT NOTICE:**
The Infomax ICA algorithm implemented in this software may be covered by patents held by the Salk Institute for Biological Studies. Any **commercial application** using this algorithm or the compiled binaries should contact the Salk Institute patent office for licensing information.

**Academic and research use:** Generally permitted under the GPL license.
**Commercial use:** Requires separate licensing from the Salk Institute.

## Citation

If you use this software in your research, please cite:

```bibtex
@article{lee1999extended,
  title={Independent component analysis using an extended infomax algorithm for mixed subgaussian and supergaussian sources},
  author={Lee, Te-Won and Girolami, Mark and Sejnowski, Terrence J},
  journal={Neural computation},
  volume={11},
  number={2},
  pages={417--441},
  year={1999}
}
```

## Contact and Support

- **Original implementation:** Sigurd Enghoff (http://cnl.salk.edu/~enghoff/download1/)
- **Modifications:** Ernest Pedapati (ernest.pedapati [at] gmail [dot] com)
- **Issues and questions:** See documentation in `docs/` or create a GitHub issue
- **Wiki:** https://github.com/sccn/binica/wiki

---

**Credits:**
- Original C implementation: Sigurd Enghoff (CNL / Salk Institute, 2001)
- Windows compilation: Ernest Pedapati and Ellen Russo
- Cross-platform enhancements: Arnaud Delorme
