# ICA configuration for eeglab_data
DataFile       ./data/eeglab_data.fdt
chans          32
datalength     30504

WeightsOutFile ./data/eeglab_data.wts_darwin
SphereFile     ./data/eeglab_data.sph_darwin

# Reproducibility
seed           1

# Precision
doublewrite    on

# Extended ICA options:
# extended 0   = Standard logistic ICA (no extended)
# extended 1   = Extended ICA, auto-detect sub/super-Gaussian (recommended)
# extended N   = Extended ICA, calculate PDF every N blocks
# extended -N  = Extended ICA, assume exactly N sub-Gaussian components
extended       1

# Learning parameters
lrate          5.0e-4
stop           1.0e-6
maxsteps       512
