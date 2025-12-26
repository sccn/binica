% Simple matrix comparison without EEGLAB dependencies
% Compare Darwin vs Linux ICA matrices

nchans = 32;  % Adjust if different

%% Load Darwin matrices
fprintf('Loading Darwin matrices...\n');
fid = fopen('./data/eeglab_data.wts_darwin', 'rb');
wts_darwin = fread(fid, [nchans, nchans], 'float64')';
fclose(fid);

fid = fopen('./data/eeglab_data.sph_darwin', 'rb');
sph_darwin = fread(fid, [nchans, nchans], 'float64')';
fclose(fid);

%% Load Linux matrices
fprintf('Loading Linux matrices...\n');
fid = fopen('./data/eeglab_data.wts_expanse', 'rb');
wts_linux = fread(fid, [nchans, nchans], 'float64')';
fclose(fid);

fid = fopen('./data/eeglab_data.sph_expanse', 'rb');
sph_linux = fread(fid, [nchans, nchans], 'float64')';
fclose(fid);

%% Weights comparison
fprintf('\n=== WEIGHTS MATRIX ===\n');
diff_wts = wts_darwin - wts_linux;
fprintf('Max abs diff:      %.6e\n', max(abs(diff_wts(:))));
fprintf('Mean abs diff:     %.6e\n', mean(abs(diff_wts(:))));
fprintf('Frobenius ||W1-W2||: %.6e\n', norm(diff_wts, 'fro'));
fprintf('Relative ||W1-W2||/||W1||: %.6e\n', norm(diff_wts,'fro')/norm(wts_darwin,'fro'));
fprintf('Correlation:       %.15f\n', corr(wts_darwin(:), wts_linux(:)));

%% Sphere comparison
fprintf('\n=== SPHERE MATRIX ===\n');
diff_sph = sph_darwin - sph_linux;
fprintf('Max abs diff:      %.6e\n', max(abs(diff_sph(:))));
fprintf('Mean abs diff:     %.6e\n', mean(abs(diff_sph(:))));
fprintf('Frobenius ||S1-S2||: %.6e\n', norm(diff_sph, 'fro'));
fprintf('Relative ||S1-S2||/||S1||: %.6e\n', norm(diff_sph,'fro')/norm(sph_darwin,'fro'));
fprintf('Correlation:       %.15f\n', corr(sph_darwin(:), sph_linux(:)));

%% Mixing matrix comparison
fprintf('\n=== MIXING MATRICES (inverses) ===\n');
winv_darwin = pinv(wts_darwin * sph_darwin);
winv_linux = pinv(wts_linux * sph_linux);
diff_winv = winv_darwin - winv_linux;
fprintf('Max abs diff:      %.6e\n', max(abs(diff_winv(:))));
fprintf('Relative diff:     %.6e\n', norm(diff_winv,'fro')/norm(winv_darwin,'fro'));

% Component-wise correlations
comp_corr = zeros(nchans, 1);
for i = 1:nchans
    comp_corr(i) = corr(winv_darwin(:,i), winv_linux(:,i));
end
fprintf('Component correlations - Min: %.15f, Mean: %.15f, Max: %.15f\n', ...
    min(comp_corr), mean(comp_corr), max(comp_corr));

%% Plot matrices
figure('Position', [100 100 1400 600]);

% Weights Darwin
subplot(2,5,1);
imagesc(wts_darwin); colorbar; axis square;
title('Weights Darwin');

% Weights Linux
subplot(2,5,2);
imagesc(wts_linux); colorbar; axis square;
title('Weights Linux');

% Weights Difference
subplot(2,5,3);
imagesc(diff_wts); colorbar; axis square;
title(sprintf('Diff (max: %.2e)', max(abs(diff_wts(:)))));

% Weights scatter
subplot(2,5,4);
plot(wts_darwin(:), wts_linux(:), '.');
hold on; plot(xlim, xlim, 'r--');
xlabel('Darwin'); ylabel('Linux');
title('Weights Scatter');
grid on; axis equal;

% Weights correlation heatmap
subplot(2,5,5);
imagesc(abs(corr(wts_darwin, wts_linux))); colorbar; axis square;
title('Column Correlations');

% Sphere Darwin
subplot(2,5,6);
imagesc(sph_darwin); colorbar; axis square;
title('Sphere Darwin');

% Sphere Linux
subplot(2,5,7);
imagesc(sph_linux); colorbar; axis square;
title('Sphere Linux');

% Sphere Difference
subplot(2,5,8);
imagesc(diff_sph); colorbar; axis square;
title(sprintf('Diff (max: %.2e)', max(abs(diff_sph(:)))));

% Sphere scatter
subplot(2,5,9);
plot(sph_darwin(:), sph_linux(:), '.');
hold on; plot(xlim, xlim, 'r--');
xlabel('Darwin'); ylabel('Linux');
title('Sphere Scatter');
grid on; axis equal;

% Sphere correlation heatmap
subplot(2,5,10);
imagesc(abs(corr(sph_darwin, sph_linux))); colorbar; axis square;
title('Column Correlations');

sgtitle('Darwin vs Linux Matrix Comparison');
print(gcf, './data/matrix_comparison.png', '-dpng', '-r150');
fprintf('\nSaved: ./data/matrix_comparison.png\n');
