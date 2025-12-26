# Darwin vs Linux ICA Comparison

## Files Required

Place your platform-specific ICA results in the `data/` directory:
- `eeglab_data.wts_darwin` - Darwin (macOS) weights matrix
- `eeglab_data.sph_darwin` - Darwin (macOS) sphere matrix
- `eeglab_data.wts_linux` - Linux weights matrix
- `eeglab_data.sph_linux` - Linux sphere matrix

All files should be 64-bit double precision binary matrices (8KB for 32×32 matrices).

## Comparison Scripts

### 1. Full Comparison with Topographies
**Script:** `compare_darwin_linux.m`

**Requirements:**
- EEGLAB installed at `~/eeglab`
- EEGLAB dataset: `data/eeglab_data.set`

**Usage:**
```matlab
cd /Users/arno/GitHub/experiments/binica
/Applications/MATLAB_R2025b.app/bin/matlab -batch "run('compare_darwin_linux.m')"
```

**Output:**
- Console: Numerical statistics, correlations, component analysis
- `data/darwin_linux_comparison.png` - Topography plots (4 components × 3 views)
- `data/darwin_linux_correlation.png` - Scatter plots showing element correlations

**Metrics:**
- Max/mean absolute differences
- Frobenius norm differences
- Relative differences (||W1-W2||/||W1||)
- Element-wise correlations
- Component topography correlations

### 2. Simple Matrix Comparison
**Script:** `compare_matrices_simple.m`

**Requirements:**
- MATLAB only (no EEGLAB needed)

**Usage:**
```matlab
cd /Users/arno/GitHub/experiments/binica
/Applications/MATLAB_R2025b.app/bin/matlab -batch "run('compare_matrices_simple.m')"
```

**Output:**
- Console: Matrix statistics and correlations
- `data/matrix_comparison.png` - Matrix visualizations (10 subplots)

**Plots:**
- Weight/sphere matrices (Darwin, Linux, Difference)
- Scatter plots (Darwin vs Linux elements)
- Column correlation heatmaps

## Interpreting Results

### Relative Difference Thresholds

| Relative Difference | Interpretation |
|---------------------|----------------|
| < 1e-12 | Excellent - numerical noise only |
| < 1e-8  | Good - acceptable for ICA |
| < 1e-5  | Moderate - platform differences present |
| > 1e-5  | Significant - check precision/algorithm |

### Expected Sources of Variation

**Minimal differences (< 1e-12):**
- Same platform, compiler, BLAS library
- 64-bit precision throughout

**Small differences (1e-12 to 1e-10):**
- Different BLAS/LAPACK implementations
- Same CPU architecture (e.g., both ARM64 or both x86-64)

**Moderate differences (1e-10 to 1e-8):**
- Different CPU architectures (ARM64 vs x86-64)
- Different compiler optimizations
- Different floating-point contraction settings

**Large differences (> 1e-6):**
- 32-bit vs 64-bit file I/O precision
- Different random seeds
- Algorithm implementation differences

## Example Output

```
============================================
WEIGHTS MATRIX COMPARISON
============================================
Max absolute difference:     2.345678e-10
Mean absolute difference:    1.234567e-11
Frobenius norm of diff:      3.456789e-10
Relative difference:         2.123456e-11
Element correlation:         0.999999999999954

============================================
SPHERE MATRIX COMPARISON
============================================
Max absolute difference:     1.234567e-10
Mean absolute difference:    5.678901e-12
Frobenius norm of diff:      2.345678e-10
Relative difference:         1.234567e-11
Element correlation:         0.999999999999967
```

## Troubleshooting

**File not found:**
```matlab
Error using fopen: No such file or directory
```
→ Ensure files are named correctly and in `data/` directory

**Size mismatch:**
```matlab
Error: Matrix dimensions must agree
```
→ Check that both platforms used same number of channels (default: 32)

**Different precision:**
- If comparing 32-bit vs 64-bit, change `'float64'` to `'float32'` in the fread calls
- Or regenerate with matching `doublewrite` setting

## File Format

Binary matrices stored in column-major order (MATLAB/Fortran style):
- **32-bit:** 4 bytes/element, file size = N×N×4 bytes
- **64-bit:** 8 bytes/element, file size = N×N×8 bytes

For 32×32 matrices:
- 32-bit: 4,096 bytes (4KB)
- 64-bit: 8,192 bytes (8KB)
