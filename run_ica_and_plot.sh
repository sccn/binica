#!/bin/bash
# run_ica_and_plot.sh - Run binica ICA and plot component topographies
# Usage: ./run_ica_and_plot.sh <dataset_basename> [n_channels] [n_timepoints]
#
# Example: ./run_ica_and_plot.sh ./data/eeglab_data 32 30504

set -e  # Exit on error

# Detect platform
if [[ -n "$SLURM_CLUSTER_NAME" ]]; then
    PLATFORM="$SLURM_CLUSTER_NAME"
else
    PLATFORM="$(hostname -s)"
fi

echo "$PLATFORM"
if [ "$PLATFORM" = "MacBook-Pro-10" ]; then
    SUFFIX="_darwin"
else
    if [ "$PLATFORM" = "expanse" ]; then
        SUFFIX="_expanse"
    else
        SUFFIX="_linux"
    fi
fi
ICA_BIN="./ica${SUFFIX}"
MATLAB_BIN="/usr/local/bin/matlab"
EEGLAB_PATH="~/v1/eeglab"

# Default parameters
DATASET=${1:-"./data/eeglab_data"}
NCHANS=${2:-32}
NPOINTS=${3:-30504}

# Derived paths
DATAFILE="${DATASET}.fdt"
SETFILE="${DATASET}.set"
WTSFILE="${DATASET}.wts${SUFFIX}"
SPHFILE="${DATASET}.sph${SUFFIX}"
CONFIGFILE="${DATASET}_ica.sc"
BASENAME=$(basename "$DATASET")

echo "========================================"
echo "Running binica ICA and plotting"
echo "========================================"
echo "Dataset: $DATASET"
echo "Channels: $NCHANS"
echo "Data points: $NPOINTS"
echo ""

# Check if data file exists
if [ ! -f "$DATAFILE" ]; then
    echo "Error: Data file $DATAFILE not found"
    exit 1
fi

# Create ICA configuration file
echo "Creating ICA configuration file..."
cat > "$CONFIGFILE" << EOF
# ICA configuration for $BASENAME
DataFile       $DATAFILE
chans          $NCHANS
datalength     $NPOINTS

WeightsOutFile $WTSFILE
SphereFile     $SPHFILE

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
EOF

echo "Configuration saved to: $CONFIGFILE"
echo ""

# Run binica ICA
echo "Running binica ICA..."
echo "Command: $ICA_BIN < $CONFIGFILE"
echo ""

$ICA_BIN < "$CONFIGFILE"

if [ $? -ne 0 ]; then
    echo "Error: ICA failed"
    exit 1
fi

echo ""
echo "ICA completed successfully!"
echo "  Weights: $WTSFILE"
echo "  Sphere:  $SPHFILE"
echo ""

# Only plot on Darwin
if [ "$PLATFORM" != "Darwin" ]; then
    echo "Skipping topography plotting (only available on macOS)"
    exit 0
fi

# Check if MATLAB and EEGLAB are available
if [ ! -x "$MATLAB_BIN" ]; then
    echo "Warning: MATLAB not found at $MATLAB_BIN"
    echo "Skipping topography plotting"
    exit 0
fi

if [ ! -f "$SETFILE" ]; then
    echo "Warning: EEGLAB .set file not found: $SETFILE"
    echo "Skipping topography plotting"
    echo "To create plots, ensure $SETFILE exists"
    exit 0
fi

# Create MATLAB script for plotting
MATLABSCRIPT="${DATASET}_plot.m"
DATADIR=$(cd "$(dirname "$DATASET")" && pwd)
echo "Creating MATLAB plotting script..."

cat > "$MATLABSCRIPT" << EOFMATLAB
% Auto-generated script to plot ICA topographies

addpath('$EEGLAB_PATH');
eeglab nogui;

% Load dataset
fprintf('Loading dataset...\\n');
EEG = pop_loadset('filename', '${BASENAME}.set', 'filepath', '${DATADIR}/');

% Load ICA matrices
fprintf('Loading ICA matrices...\\n');
wtsfile = fullfile('${DATADIR}', '${BASENAME}.wts_${PLATFORM}');
sphfile = fullfile('${DATADIR}', '${BASENAME}.sph_${PLATFORM}');

fid = fopen(wtsfile, 'rb');
weights = fread(fid, [${NCHANS}, ${NCHANS}], 'float64')';
fclose(fid);

fid = fopen(sphfile, 'rb');
sphere = fread(fid, [${NCHANS}, ${NCHANS}], 'float64')';
fclose(fid);

% Import into EEG structure
EEG.icaweights = weights;
EEG.icasphere = sphere;
EEG.icawinv = pinv(weights * sphere);
EEG.icaact = [];
EEG = eeg_checkset(EEG);

fprintf('Plotting component topographies...\\n');

% Plot all components
pop_topoplot(EEG, 0, [1:4], 'ICA Component Topographies (binica)', [], 0, 'electrodes', 'off');

% Save outputs
pngfile = fullfile('${DATADIR}', '${BASENAME}_topoplot.png');
pdffile = fullfile('${DATADIR}', '${BASENAME}_topoplot.pdf');

print(gcf, pngfile, '-dpng', '-r150');
print(gcf, pdffile, '-dpdf', '-bestfit');

EEG = pop_saveset(EEG, 'filename', '${BASENAME}_with_ica.set', ...
    'filepath', '${DATADIR}/');

fprintf('Done! Saved:\\n');
fprintf('  %s\\n', pngfile);
fprintf('  %s\\n', pdffile);
fprintf('  ${DATADIR}/${BASENAME}_with_ica.set\\n');
EOFMATLAB

echo "MATLAB script saved to: $MATLABSCRIPT"
echo ""

# Run MATLAB
echo "Running MATLAB to generate topography plots..."
FULLPATH=$(cd "$(dirname "${MATLABSCRIPT}")" && pwd)/$(basename "${MATLABSCRIPT}")
$MATLAB_BIN -batch "cd('$(pwd)'); run('${FULLPATH}')"

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "All done!"
    echo "========================================"
    echo "Output files:"
    echo "  ICA weights:    $WTSFILE"
    echo "  ICA sphere:     $SPHFILE"
    echo "  Topography PNG: ${DATASET}_topoplot.png"
    echo "  Topography PDF: ${DATASET}_topoplot.pdf"
    echo "  Dataset w/ICA:  $(dirname "$DATASET")/${BASENAME}_with_ica.set"
else
    echo "Warning: MATLAB plotting failed"
fi

# Cleanup temporary files
rm -f "$MATLABSCRIPT"
