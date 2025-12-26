% Compare binica ICA results between Darwin (macOS) and Linux platforms
% Analyzes numerical differences and visualizes topography differences

addpath('~/eeglab');
eeglab nogui;

%% Load EEGLAB dataset
fprintf('Loading EEGLAB dataset...\n');
EEG = pop_loadset('filename', 'eeglab_data.set', 'filepath', './data/');
nchans = EEG.nbchan;
fprintf('Dataset: %d channels\n\n', nchans);

%% Load Darwin (macOS) matrices
fprintf('Loading Darwin (macOS) matrices...\n');
fid = fopen('./data/eeglab_data.wts_darwin', 'rb');
wts_darwin = fread(fid, [nchans, nchans], 'float64')';
fclose(fid);

fid = fopen('./data/eeglab_data.sph_darwin', 'rb');
sph_darwin = fread(fid, [nchans, nchans], 'float64')';
fclose(fid);

%% Load Linux matrices
fprintf('Loading Linux matrices...\n');
fid = fopen('./data/eeglab_data.wts_linux', 'rb');
wts_linux = fread(fid, [nchans, nchans], 'float64')';
fclose(fid);

fid = fopen('./data/eeglab_data.sph_linux', 'rb');
sph_linux = fread(fid, [nchans, nchans], 'float64')';
fclose(fid);

fprintf('Matrices loaded successfully\n\n');

%% Compute numerical differences - Weights
fprintf('============================================\n');
fprintf('WEIGHTS MATRIX COMPARISON\n');
fprintf('============================================\n');

% Absolute differences
diff_wts = wts_darwin - wts_linux;
max_abs_diff_wts = max(abs(diff_wts(:)));
mean_abs_diff_wts = mean(abs(diff_wts(:)));
frobenius_diff_wts = norm(diff_wts, 'fro');

% Relative differences
frobenius_darwin_wts = norm(wts_darwin, 'fro');
rel_diff_wts = frobenius_diff_wts / frobenius_darwin_wts;

% Element-wise correlation
corr_wts = corr(wts_darwin(:), wts_linux(:));

fprintf('Max absolute difference:     %.6e\n', max_abs_diff_wts);
fprintf('Mean absolute difference:    %.6e\n', mean_abs_diff_wts);
fprintf('Frobenius norm of diff:      %.6e\n', frobenius_diff_wts);
fprintf('Relative difference:         %.6e\n', rel_diff_wts);
fprintf('Element correlation:         %.15f\n', corr_wts);
fprintf('\n');

%% Compute numerical differences - Sphere
fprintf('============================================\n');
fprintf('SPHERE MATRIX COMPARISON\n');
fprintf('============================================\n');

% Absolute differences
diff_sph = sph_darwin - sph_linux;
max_abs_diff_sph = max(abs(diff_sph(:)));
mean_abs_diff_sph = mean(abs(diff_sph(:)));
frobenius_diff_sph = norm(diff_sph, 'fro');

% Relative differences
frobenius_darwin_sph = norm(sph_darwin, 'fro');
rel_diff_sph = frobenius_diff_sph / frobenius_darwin_sph;

% Element-wise correlation
corr_sph = corr(sph_darwin(:), sph_linux(:));

fprintf('Max absolute difference:     %.6e\n', max_abs_diff_sph);
fprintf('Mean absolute difference:    %.6e\n', mean_abs_diff_sph);
fprintf('Frobenius norm of diff:      %.6e\n', frobenius_diff_sph);
fprintf('Relative difference:         %.6e\n', rel_diff_sph);
fprintf('Element correlation:         %.15f\n', corr_sph);
fprintf('\n');

%% Component-wise analysis
fprintf('============================================\n');
fprintf('COMPONENT TOPOGRAPHY COMPARISON\n');
fprintf('============================================\n');

% Compute mixing matrices (inverse of weights * sphere)
winv_darwin = pinv(wts_darwin * sph_darwin);
winv_linux = pinv(wts_linux * sph_linux);

% Component correlations
comp_corr = zeros(nchans, 1);
for i = 1:nchans
    comp_corr(i) = corr(winv_darwin(:,i), winv_linux(:,i));
end

fprintf('Component topography correlations:\n');
fprintf('  Min:  %.15f (component %d)\n', min(comp_corr), find(comp_corr == min(comp_corr), 1));
fprintf('  Mean: %.15f\n', mean(comp_corr));
fprintf('  Max:  %.15f (component %d)\n', max(comp_corr), find(comp_corr == max(comp_corr), 1));
fprintf('\n');

%% Plot topographies for first 4 components
fprintf('Generating topography plots...\n');

% Darwin topographies
EEG.icaweights = wts_darwin;
EEG.icasphere = sph_darwin;
EEG.icawinv = winv_darwin;
EEG = eeg_checkset(EEG);

figure('Position', [100 100 1200 800]);
for i = 1:4
    subplot(4, 3, (i-1)*3 + 1);
    topoplot(EEG.icawinv(:,i), EEG.chanlocs, 'electrodes', 'off');
    title(sprintf('Darwin IC%d', i));
    colorbar;
end

% Linux topographies
EEG.icaweights = wts_linux;
EEG.icasphere = sph_linux;
EEG.icawinv = winv_linux;
EEG = eeg_checkset(EEG);

for i = 1:4
    subplot(4, 3, (i-1)*3 + 2);
    topoplot(EEG.icawinv(:,i), EEG.chanlocs, 'electrodes', 'off');
    title(sprintf('Linux IC%d', i));
    colorbar;
end

% Difference topographies
for i = 1:4
    subplot(4, 3, (i-1)*3 + 3);
    diff_topo = winv_darwin(:,i) - winv_linux(:,i);
    topoplot(diff_topo, EEG.chanlocs, 'electrodes', 'off');
    title(sprintf('Diff IC%d (max: %.2e)', i, max(abs(diff_topo))));
    colorbar;
end

sgtitle('Component Topography Comparison: Darwin vs Linux');

% Save figure
print(gcf, './data/darwin_linux_comparison.png', '-dpng', '-r150');
fprintf('Saved: ./data/darwin_linux_comparison.png\n');

%% Plot correlation scatter
figure('Position', [100 100 1000 400]);

subplot(1, 2, 1);
plot(wts_darwin(:), wts_linux(:), '.', 'MarkerSize', 2);
hold on;
plot(xlim, xlim, 'r--', 'LineWidth', 1.5);
xlabel('Darwin Weights');
ylabel('Linux Weights');
title(sprintf('Weights Correlation: %.15f', corr_wts));
grid on;
axis equal;

subplot(1, 2, 2);
plot(sph_darwin(:), sph_linux(:), '.', 'MarkerSize', 2);
hold on;
plot(xlim, xlim, 'r--', 'LineWidth', 1.5);
xlabel('Darwin Sphere');
ylabel('Linux Sphere');
title(sprintf('Sphere Correlation: %.15f', corr_sph));
grid on;
axis equal;

sgtitle('Element-wise Correlation Plots');

% Save figure
print(gcf, './data/darwin_linux_correlation.png', '-dpng', '-r150');
fprintf('Saved: ./data/darwin_linux_correlation.png\n\n');

%% Summary
fprintf('============================================\n');
fprintf('SUMMARY\n');
fprintf('============================================\n');
fprintf('Weights:\n');
fprintf('  Relative diff: %.6e\n', rel_diff_wts);
fprintf('  Correlation:   %.15f\n', corr_wts);
fprintf('\nSphere:\n');
fprintf('  Relative diff: %.6e\n', rel_diff_sph);
fprintf('  Correlation:   %.15f\n', corr_sph);
fprintf('\nTopographies:\n');
fprintf('  Mean corr:     %.15f\n', mean(comp_corr));
fprintf('  Min corr:      %.15f\n', min(comp_corr));
fprintf('\nInterpretation:\n');
if rel_diff_wts < 1e-12 && rel_diff_sph < 1e-12
    fprintf('  Excellent: Differences are numerical noise only\n');
elseif rel_diff_wts < 1e-8 && rel_diff_sph < 1e-8
    fprintf('  Good: Acceptable differences for ICA\n');
elseif rel_diff_wts < 1e-5 && rel_diff_sph < 1e-5
    fprintf('  Moderate: Some platform differences present\n');
else
    fprintf('  Significant: Check for precision or algorithm differences\n');
end
fprintf('============================================\n');
