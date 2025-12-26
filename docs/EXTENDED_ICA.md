# Extended ICA Documentation

## Overview

Binica implements **Extended Infomax ICA** (Lee, Girolami & Sejnowski, 1998), which automatically handles both sub-Gaussian and super-Gaussian sources.

## Standard vs Extended ICA

### Standard Logistic ICA
- Assumes all sources are **super-Gaussian** (positive kurtosis)
- Uses fixed logistic nonlinearity: `g(u) = 1/(1+exp(-u))`
- Good for: Speech, natural images, typical EEG
- **Configuration:** `extended 0`

### Extended ICA
- Automatically detects **sub-Gaussian** and **super-Gaussian** sources
- Uses adaptive nonlinearity: switches between tanh (sub-G) and logistic (super-G)
- Good for: Mixed source types, EEG with artifacts
- **Configuration:** `extended 1` or `extended N`

## Configuration Options

### Option 1: Auto-Detection (Recommended)
```
extended       1
```
**Behavior:**
- Calculates probability density function (PDF) every block
- Automatically determines which components are sub/super-Gaussian
- Adapts nonlinearity for each component
- Uses 6000 data points for PDF estimation

**Use when:** You don't know the source characteristics (most EEG cases)

### Option 2: Periodic PDF Calculation
```
extended       5
```
**Behavior:**
- Calculates PDF every N blocks (N=5 in example)
- Reduces computational overhead
- Still adapts to source statistics

**Use when:** Large datasets where PDF calculation every block is slow

### Option 3: Fixed Sub-Gaussian Count
```
extended       -3
```
**Behavior:**
- Assumes exactly N sub-Gaussian components (N=3 in example)
- No PDF calculation (faster)
- Fixed assignment of nonlinearities

**Use when:** You know the number of sub-Gaussian sources (e.g., from prior analysis)

### Option 4: Standard ICA (No Extended)
```
extended       0
```
**Behavior:**
- Classic logistic ICA
- All components assumed super-Gaussian
- Fastest option

**Use when:** All sources are super-Gaussian (rare for EEG)

## Output Interpretation

### With Extended ICA

When running with `extended 1`, the output shows:
```
Finding 32 ICA components using extended ICA.
PDF will be calculated initially every 1 blocks using 6000 data points.
...
Inverting negative activations: 1 2 -3 -4 -5 -6 -7 8 9 10 11 12 -13 14 -15 16 -17 18 -19 -20 21 -22 -23 -24 -25 26 -27 -28 -29 -30 -31 -32
```

**Interpretation:**
- Positive numbers (1, 2, 8, etc.): **Super-Gaussian** components
- Negative numbers (-3, -4, -5, etc.): **Sub-Gaussian** components
- The sign indicates which nonlinearity was used

### Component Statistics

**Super-Gaussian (positive kurtosis):**
- Sparse, peaky distributions
- Examples: Muscle artifacts, eye blinks, alpha rhythm

**Sub-Gaussian (negative kurtosis):**
- Flat, uniform-like distributions
- Examples: Line noise, slow drifts, some artifacts

## Example Configurations

### Typical EEG Analysis
```
DataFile       eeg_data.fdt
chans          64
datalength     256000

WeightsOutFile eeg_data.wts
SphereFile     eeg_data.sph

seed           1
doublewrite    on
extended       1        # Auto-detect (recommended)
lrate          5.0e-4
stop           1.0e-6
maxsteps       512
```

### Large Dataset (Optimize Performance)
```
DataFile       big_data.fdt
chans          128
datalength     1000000

WeightsOutFile big_data.wts
SphereFile     big_data.sph

seed           1
doublewrite    on
extended       10       # Calculate PDF every 10 blocks (faster)
lrate          5.0e-4
stop           1.0e-6
maxsteps       512
```

### Known Sub-Gaussian Count
```
DataFile       data.fdt
chans          32
datalength     30504

WeightsOutFile data.wts
SphereFile     data.sph

seed           1
doublewrite    on
extended       -5       # Exactly 5 sub-Gaussian components
lrate          5.0e-4
stop           1.0e-6
maxsteps       512
```

### Standard ICA (No Extended)
```
DataFile       speech_data.fdt
chans          8
datalength     100000

WeightsOutFile speech.wts
SphereFile     speech.sph

seed           1
doublewrite    on
extended       0        # Standard logistic ICA
lrate          1.0e-3   # Can use higher learning rate
stop           1.0e-6
maxsteps       256
```

## Parameters Affected by Extended ICA

### Learning Rate Annealing
Extended ICA uses different default annealing:
- **Standard ICA:** `annealstep = 0.90`
- **Extended ICA:** `annealstep = 0.98` (slower, more stable)

### PDF Size
Controls how many data points used for PDF estimation:
- **Default:** 6000 points
- **Minimum:** 2000 points
- **Configuration:** Not typically changed by user

### Block Size
Affects how often PDF is recalculated:
- **Default:** Calculated heuristically from data length
- **Extended ICA:** PDF calculated every `extended` blocks

## Performance Considerations

### Computational Cost

| Mode | Relative Speed | Accuracy |
|------|---------------|----------|
| `extended 0` | 100% (fastest) | Good for super-G only |
| `extended -N` | 95% | Good if N is correct |
| `extended 10` | 85% | Very good |
| `extended 1` | 80% | Best (recommended) |

### Memory Requirements
Extended ICA requires additional memory for:
- Sign vector (N components)
- PDF calculation buffer (6000 points × N channels)

For typical EEG (32 channels, 30504 points):
- Standard ICA: ~8 MB
- Extended ICA: ~10 MB

## Troubleshooting

### Issue: "PDF calculation failed"
**Solution:** Reduce PDF size or use `extended -N` mode

### Issue: All components classified as super-Gaussian
**Solution:** Check data preprocessing - may have removed DC offsets or trends

### Issue: Slow convergence
**Solutions:**
- Use `extended 5` or `extended 10` for faster PDF calculation
- Increase learning rate: `lrate 1.0e-3`
- Increase annealing: `annealstep 0.99`

### Issue: Too many sub-Gaussian components
**Possible causes:**
- Line noise not removed (appears sub-Gaussian)
- DC offsets present
- Very low-frequency drift

## Algorithm Details

### Extended Infomax Update Rule

For each component i:
- **If super-Gaussian (k_i > 0):**
  ```
  g(u_i) = tanh(u_i)
  ```

- **If sub-Gaussian (k_i < 0):**
  ```
  g(u_i) = -tanh(u_i) + 2/(1+exp(-u_i))
  ```

Where k_i is the sign parameter determined by kurtosis estimation.

### Kurtosis Estimation
```
kurtosis = E[u^4] - 3(E[u^2])^2
```

- Positive kurtosis → Super-Gaussian → Use tanh
- Negative kurtosis → Sub-Gaussian → Use modified nonlinearity

## References

1. **Extended ICA:**
   Lee, T.-W., Girolami, M., & Sejnowski, T.J. (1999). "Independent Component Analysis Using an Extended Infomax Algorithm for Mixed Sub-Gaussian and Super-Gaussian Sources". Neural Computation, 11(2), 417-441.

2. **Original Infomax:**
   Bell, A.J. & Sejnowski, T.J. (1995). "An Information-Maximization Approach to Blind Separation and Blind Deconvolution". Neural Computation, 7(6), 1129-1159.

3. **Natural Gradient:**
   Amari, S. (1998). "Natural Gradient Works Efficiently in Learning". Neural Computation, 10(2), 251-276.

## Best Practices

### For EEG Analysis
1. **Always use extended ICA** unless you have specific reasons not to
2. **Start with `extended 1`** for automatic detection
3. **Use seed=1** for reproducibility
4. **Enable doublewrite** for numerical precision
5. **Monitor convergence** - check wchange decreases smoothly

### For Publications
1. **Report extended ICA usage:** "Extended Infomax ICA (Lee et al., 1999)"
2. **Document configuration:** Include full .sc file or parameters
3. **Report component classifications:** How many sub vs super-Gaussian
4. **Note seed value:** For reproducibility

### For Comparison Studies
1. **Use same extended mode** across all datasets
2. **Fix seed** for reproducible comparisons
3. **Match learning parameters** (lrate, maxsteps, stop)
4. **Document BLAS library** for cross-platform work

## Current run_ica_and_plot.sh Configuration

The script is already configured for **Extended ICA with auto-detection**:

```bash
extended       1        # Auto-detect sub/super-Gaussian (recommended)
```

This is the **recommended setting** for most EEG applications, providing:
- ✓ Automatic adaptation to source statistics
- ✓ Robust handling of mixed artifact types
- ✓ No need to know source characteristics a priori
- ✓ Best separation quality

To use different extended modes, simply modify the `extended` parameter in the configuration section of `run_ica_and_plot.sh`.
