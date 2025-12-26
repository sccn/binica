# Binica Enhancements Summary

## Changes Implemented

### 1. Fixed Random Number Initialization ✓

**Problem:** Darwin vs Linux showed large differences (relative diff: 1.31 for weights)
**Root Cause:** Time-based seed `time(NULL)` was non-deterministic
**Solution:** Implemented configurable fixed seed with platform-independent RNG

#### Implementation
- Added `seed` configuration parameter (default: 1)
- Enabled `FIX_SEED` by default for reproducibility
- Uses R250 generator + LCG seeding (platform-independent)
- Configuration keywords: `seed` or `rngseed`

#### Test Results
```
Same seed (42), two runs on Darwin:
  Weights: BIT-EXACT IDENTICAL ✓
  Sphere:  BIT-EXACT IDENTICAL ✓

Different seeds (42 vs 99):
  Weights: DIFFERENT (expected) ✓
  Sphere:  DIFFERENT (expected) ✓
```

### 2. Optional 64-bit Double Precision Output ✓

**Problem:** Original code used 32-bit float I/O (precision loss)
**Solution:** Added optional 64-bit double precision output

#### Implementation
- Added `doublewrite` configuration parameter (default: off for backward compatibility)
- New function: `fb_matwrite_double()` for 64-bit output
- Conditional output based on flag
- Preserved MMAP support
- Minimal code changes (added functionality, didn't replace)

#### Test Results
```
Without doublewrite:
  File size: 64 bytes (4×4×4 = float32) ✓

With doublewrite on:
  File size: 128 bytes (4×4×8 = float64) ✓
```

### 3. Comparison Tools ✓

Created MATLAB scripts for Darwin vs Linux comparison:

#### compare_darwin_linux.m
- Full EEGLAB-based comparison
- Numerical statistics (Frobenius norm, correlation)
- Component topography visualization
- Outputs: PNG plots with side-by-side topographies

#### compare_matrices_simple.m
- Standalone (no EEGLAB required)
- Matrix-level comparison
- Scatter plots and correlation heatmaps
- Output: `data/matrix_comparison.png`

### 4. Documentation ✓

Created comprehensive documentation:

- **RNG_REPRODUCIBILITY.md** - Random number generator implementation and cross-platform testing
- **COMPARISON_README.md** - How to use comparison scripts
- **COMPARISON_RESULTS.md** - Analysis of Darwin vs Linux differences
- **test_cross_platform.sh** - Automated cross-platform reproducibility test

## Configuration Options

### Minimal Configuration (backward compatible)
```
DataFile       data.fdt
chans          32
datalength     30504
WeightsOutFile data.wts
SphereFile     data.sph
```
Defaults: seed=1, doublewrite=off, 32-bit float output

### Recommended Configuration (reproducible + precise)
```
DataFile       data.fdt
chans          32
datalength     30504
WeightsOutFile data.wts
SphereFile     data.sph

seed           1
doublewrite    on
extended       1
lrate          5.0e-4
stop           1.0e-6
maxsteps       512
```
Fixed seed for reproducibility, 64-bit precision output

## Next Steps: Cross-Platform Testing

### Hypothesis
With the same fixed seed, **will Darwin and Linux produce identical results?**

**Scenario A: RNG was the only issue**
- Sphere matrices: ~1e-13 difference (numerical noise)
- Weight matrices: ~1e-13 difference (numerical noise)
- **Conclusion**: Perfect cross-platform reproducibility achieved

**Scenario B: BLAS differences dominate**
- Sphere matrices: ~1e-13 difference (deterministic SVD)
- Weight matrices: ~1e-8 to 1e-10 difference (iterative optimization accumulates BLAS differences)
- **Conclusion**: RNG controlled, but BLAS implementation still creates small differences

### Testing Procedure

1. **Generate results on both platforms with seed=1:**
```bash
# Darwin
./ica_darwin < config_seed1.sc
mv data.wts data.wts_darwin
mv data.sph data.sph_darwin

# Linux
./ica_linux < config_seed1.sc
mv data.wts data.wts_linux
mv data.sph data.sph_linux
```

2. **Compare results:**
```matlab
run('compare_matrices_simple.m')
```

3. **Expected outcomes:**

| Sphere Diff | Weights Diff | Interpretation |
|-------------|--------------|----------------|
| ~1e-13 | ~1e-13 | RNG was the issue, now solved |
| ~1e-13 | ~1e-8 | BLAS differences accumulate during iteration |
| ~1e-13 | ~1e-5 | Significant BLAS/architecture differences |

## File Changes Summary

### Modified Files
- `ica.h` - Added `FIX_SEED` define, `rngseed` extern declaration
- `ica.c` - Added `rngseed` variable, modified SRAND call to use rngseed
- `interfc.c` - Added `seed` keyword parsing, `doublewrite` flag, `fb_matwrite_double()` function
- `memap.c` - Added `#include <unistd.h>`
- `run_ica_and_plot.sh` - Added `seed 1` and `doublewrite on` to config
- `plot_ica_matlab.m` - Updated to read `float64`, added documentation
- `Makefile.darwin` - Already existed from previous session

### New Files
- `compare_darwin_linux.m` - EEGLAB-based comparison with topographies
- `compare_matrices_simple.m` - Standalone matrix comparison
- `test_cross_platform.sh` - Automated reproducibility test
- `RNG_REPRODUCIBILITY.md` - RNG implementation documentation
- `COMPARISON_README.md` - Comparison tool user guide
- `COMPARISON_RESULTS.md` - Analysis of Darwin vs Linux results
- `SUMMARY.md` - This file

## Key Improvements

### Reproducibility
✓ **Same platform, same config → identical results** (bit-exact)
✓ **Configurable seed for Monte Carlo studies**
✓ **Platform-independent RNG** (R250 + LCG)
✓ **Default fixed seed** for maximum reproducibility

### Precision
✓ **Optional 64-bit output** (8KB vs 4KB for 32×32 matrices)
✓ **Backward compatible** (default: 32-bit for compatibility)
✓ **Preserves MMAP support**

### Documentation
✓ **Comprehensive user guides**
✓ **Cross-platform testing procedures**
✓ **MATLAB comparison tools**
✓ **Configuration examples**

## Outstanding Question

**Does the same seed produce identical results on Darwin and Linux?**

**Your observation:** "When I run the same twice on this machine, I get the same result"

This is now **expected and guaranteed** because:
- Fixed seed ensures identical random initialization
- Same platform → same BLAS → same iteration path
- Deterministic behavior confirmed by testing

**Cross-platform test needed:** Run with seed=1 on both Darwin and Linux to determine if BLAS differences cause iteration paths to diverge, or if results are truly identical.

## References

### RNG Implementation
- Kirkpatrick & Stoll (1981) - R250 shift-register generator
- Park & Miller (1988) - Minimal standard LCG

### Current Darwin vs Linux Results (time-based seed)
- Sphere: 3.18e-13 relative diff (excellent)
- Weights: 1.31 relative diff (large)
- Component correlations: -0.35 to 0.96

### Next Test: Darwin vs Linux with seed=1
- Expected sphere: ~1e-13 (unchanged, deterministic)
- Expected weights: **TO BE DETERMINED**
  - If ~1e-13: RNG was the only issue ✓
  - If ~1e-8: BLAS differences accumulate during iteration
