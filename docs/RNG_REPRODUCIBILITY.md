# Random Number Generator and Cross-Platform Reproducibility

## Overview

Binica now uses a **deterministic, platform-independent random number generator** for full reproducibility across different systems.

## Implementation Details

### RNG Algorithm
- **Generator**: R250 shift-register sequence (Kirkpatrick & Stoll, 1981)
- **Seeding**: Linear Congruential Generator (Park & Miller, 1988)
- **Platform independence**: Pure integer arithmetic, no system-dependent calls
- **Default behavior**: Fixed seed for reproducibility

### Configuration

**Default (reproducible):**
```
seed  1
```

**Custom seed:**
```
seed  42
```

**Random seed (non-reproducible):**
```
# Comment out FIX_SEED in ica.h and recompile
# Will use time(NULL) as seed
```

## Reproducibility Test Results

### Same Platform, Same Seed
```bash
./ica_darwin < config_seed42.sc
./ica_darwin < config_seed42.sc
# Result: BIT-EXACT IDENTICAL
```

**Test output:**
```
cmp run1.wts run2.wts → IDENTICAL (byte-for-byte match)
cmp run1.sph run2.sph → IDENTICAL (byte-for-byte match)
```

### Same Platform, Different Seeds
```bash
./ica_darwin < config_seed42.sc
./ica_darwin < config_seed99.sc
# Result: DIFFERENT (as expected)
```

Different seeds produce different random initializations, leading to different ICA decompositions.

### Cross-Platform (Darwin vs Linux)

With **same seed** (seed=1):

| Matrix | Difference | Interpretation |
|--------|------------|----------------|
| Sphere | ~1e-13 | Numerical noise only (excellent) |
| Weights | TBD | Test with matching seed |

## Why Use Fixed Seed?

### Scientific Benefits
1. **Exact reproducibility**: Same data → same results
2. **Debugging**: Consistent behavior across runs
3. **Version control**: Results trackable across code changes
4. **Cross-platform**: Eliminates RNG as source of variation

### Trade-offs
- Multiple runs with same config give identical results
- For Monte Carlo studies, explicitly vary the seed parameter

## Cross-Platform Differences: RNG vs BLAS

### Source 1: Random Initialization (NOW ELIMINATED)
**Before:** `time(NULL)` gave different seeds across runs
**After:** Fixed seed=1 gives identical initialization
**Status:** ✓ Controlled

### Source 2: BLAS/LAPACK Implementations
**Issue:** Different matrix operations accumulate differently
- Darwin: Apple Accelerate framework
- Linux: OpenBLAS, Intel MKL, or ATLAS
**Impact:** Even with same initialization, iterations may diverge
**Status:** ⚠️ Platform-dependent (expected behavior)

## Testing Cross-Platform Reproducibility

### Step 1: Generate Results on Both Platforms
```bash
# On macOS (Darwin)
./ica_darwin < config.sc
mv data.wts data.wts_darwin
mv data.sph data.sph_darwin

# On Linux
./ica_linux < config.sc
mv data.wts data.wts_linux
mv data.sph data.sph_linux
```

### Step 2: Compare Results
```matlab
run('compare_matrices_simple.m')
```

### Expected Results with Same Seed

**Hypothesis 1: RNG was the issue**
- Same seed → Identical results across platforms
- Sphere: ~1e-13 difference
- Weights: ~1e-13 difference

**Hypothesis 2: BLAS differences dominate**
- Same seed → Still different results
- Sphere: ~1e-13 difference (deterministic)
- Weights: ~1e-8 to 1e-10 difference (BLAS accumulation)

## Configuration Examples

### Maximum Reproducibility
```
# ICA configuration
DataFile       data.fdt
chans          32
datalength     30504

WeightsOutFile data.wts
SphereFile     data.sph

seed           1          # Fixed seed for reproducibility
doublewrite    on         # 64-bit precision
extended       1
lrate          5.0e-4
stop           1.0e-6
maxsteps       512
```

### Monte Carlo / Sensitivity Analysis
```
# Run multiple times with different seeds
for SEED in 1 2 3 4 5; do
    cat > config_seed${SEED}.sc << EOF
DataFile       data.fdt
# ... other parameters ...
seed           ${SEED}
WeightsOutFile data_seed${SEED}.wts
SphereFile     data_seed${SEED}.sph
EOF
    ./ica_darwin < config_seed${SEED}.sc
done
```

## Implementation Code

### Seed Initialization (ica.c:710)
```c
#ifdef FIX_SEED
    SRAND(rngseed);    // Use configurable seed (default: 1)
#else
    SRAND((int)time(NULL));  // Non-reproducible (time-based)
#endif
```

### RNG Algorithm (r250.c)
```c
// R250 shift-register generator
unsigned int r250() {
    register int j;
    register unsigned int new_rand;

    if (r250_index >= 147)
        j = r250_index - 147;
    else
        j = r250_index + 103;

    new_rand = r250_buffer[r250_index] ^ r250_buffer[j];
    r250_buffer[r250_index] = new_rand;

    if (r250_index >= 249)
        r250_index = 0;
    else
        r250_index++;

    return new_rand;
}
```

### Seeding (randlcg.c)
```c
// Linear Congruential Generator (Park & Miller minimal standard)
unsigned long int randlcg() {
    if (seed_val <= quotient)
        seed_val = (seed_val * 16807L) % LONG_MAX;
    else {
        long int high_part = seed_val / quotient;
        long int low_part  = seed_val % quotient;
        long int test = 16807L * low_part - remain * high_part;

        if (test > 0)
            seed_val = test;
        else
            seed_val = test + LONG_MAX;
    }
    return seed_val;
}
```

## Recommendations

### For Publications
1. **Always specify seed**: Document seed value used
2. **Report RNG details**: "R250 generator with seed=1"
3. **Share exact configs**: Include full .sc configuration file
4. **Note BLAS library**: Document platform and BLAS used

### For Cross-Platform Validation
1. **Use same seed**: Eliminates RNG variation
2. **Compare sphere first**: Should match within 1e-12
3. **Check weights correlation**: May differ due to BLAS
4. **Document both**: Report both Darwin and Linux results

### For Production Use
1. **Default seed=1**: Maximum reproducibility
2. **64-bit output**: `doublewrite on`
3. **Version control configs**: Track .sc files in git
4. **Archive results**: Save .wts/.sph with version info

## References

- Kirkpatrick, S., and E. Stoll (1981). "A Very Fast Shift-Register Sequence Random Number Generator", Journal of Computational Physics, 40.
- Park, S.K. and K.W. Miller (1988). "Random Number Generators: Good Ones Are Hard To Find", Communications of the ACM, 31(10):1192-1201.
- Maier, W.L. (1991). "R250 Random Number Generator", Dr. Dobb's Journal, May 1991.
