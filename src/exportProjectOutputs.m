function exportProjectOutputs(dataset, results, comparisonTable, cfg)
if ~exist(cfg.figuresDir, 'dir')
    mkdir(cfg.figuresDir);
end

if ~exist(cfg.resultsDir, 'dir')
    mkdir(cfg.resultsDir);
end

saveExampleChannelsFigure(dataset, cfg);
savePowerVariabilityFigure(results(1), cfg);
saveCoherenceFigure(results(1), cfg);
saveStrategyComparisonFigure(results, comparisonTable, cfg);
end

function saveExampleChannelsFigure(dataset, cfg)
fig = figure('Visible', cfg.figureVisible, 'Color', 'w', 'Name', 'Example Channels');

numPlotSamplesEEG = min(round(cfg.plotDurationSec * dataset.Fs_EEG), numel(dataset.F4C4));
tEeg = (0:numPlotSamplesEEG - 1)' / dataset.Fs_EEG;

posteriorSignal = dataset.F4C4;
posteriorLabel = 'F4C4';
if isfield(dataset, 'P3O1') && ~isempty(dataset.P3O1)
    posteriorSignal = dataset.P3O1;
    posteriorLabel = 'P3O1';
elseif isfield(dataset, 'P4O2') && ~isempty(dataset.P4O2)
    posteriorSignal = dataset.P4O2;
    posteriorLabel = 'P4O2';
end

subplot(3, 1, 1)
plot(tEeg, dataset.F4C4(1:numPlotSamplesEEG), 'LineWidth', 1.0)
grid on
xlabel('Time (s)')
ylabel('mV')
title('F4C4')

subplot(3, 1, 2)
plot(tEeg, posteriorSignal(1:numPlotSamplesEEG), 'LineWidth', 1.0)
grid on
xlabel('Time (s)')
ylabel('mV')
title(sprintf('%s (posterior alpha candidate)', posteriorLabel))

subplot(3, 1, 3)
tBfv = (0:numel(dataset.BFV2) - 1)' / dataset.Fs_BFV;
plot(tBfv, dataset.BFV2, 'LineWidth', 1.0)
grid on
xlabel('Time (s)')
ylabel('BFV')
title('BFV2')

exportgraphics(fig, fullfile(cfg.figuresDir, 'fig01_example_channels.png'), 'Resolution', 200)
close(fig)
end

function savePowerVariabilityFigure(primaryResult, cfg)
fig = figure('Visible', cfg.figureVisible, 'Color', 'w', 'Name', 'Band Power Variability');

for idx = 1:numel(primaryResult.bandNames)
    subplot(numel(primaryResult.bandNames), 1, idx)
    plot(primaryResult.powerTime{idx}, primaryResult.powerVariability{idx}, 'LineWidth', 1.2)
    grid on
    xlabel('Time (s)')
    ylabel('Power')
    title(sprintf('%s power variability (%s)', upper(primaryResult.bandNames(idx)), primaryResult.channelLabels(idx)))
end

exportgraphics(fig, fullfile(cfg.figuresDir, 'fig02_band_power_variability.png'), 'Resolution', 200)
close(fig)
end

function saveCoherenceFigure(primaryResult, cfg)
fig = figure('Visible', cfg.figureVisible, 'Color', 'w', 'Name', 'Coherence with BFV2');
hold on

for idx = 1:numel(primaryResult.bandNames)
    plot(primaryResult.coherenceFreqs{idx}, primaryResult.coherenceValues{idx}, 'LineWidth', 1.4)
end

xline(cfg.coherenceRangeHz(1), '--k', '0.02 Hz', 'LineWidth', 1.0)
xline(cfg.coherenceRangeHz(2), '--k', '0.15 Hz', 'LineWidth', 1.0)
grid on
xlabel('Frequency (Hz)')
ylabel('Magnitude-squared coherence')
title('Primary strategy coherence with BFV2')
legend( ...
    sprintf('Delta (%s)', primaryResult.channelLabels(1)), ...
    sprintf('Theta (%s)', primaryResult.channelLabels(2)), ...
    sprintf('Alpha (%s)', primaryResult.channelLabels(3)), ...
    sprintf('Beta (%s)', primaryResult.channelLabels(4)), ...
    'Location', 'best')
hold off

exportgraphics(fig, fullfile(cfg.figuresDir, 'fig03_coherence_with_bfv2.png'), 'Resolution', 200)
close(fig)
end

function saveStrategyComparisonFigure(results, comparisonTable, cfg)
fig = figure('Visible', cfg.figureVisible, 'Color', 'w', 'Name', 'Strategy Comparison');
bandLabels = categorical(string(comparisonTable.Band));

subplot(3, 1, 1)
bar(bandLabels, [comparisonTable.Primary_PeakCoherence comparisonTable.Control_PeakCoherence], 'grouped')
grid on
ylabel('Peak coherence')
title('Peak coherence in the 0.02-0.15 Hz range')
legend('Primary', 'Same-channel control', 'Location', 'best')

subplot(3, 1, 2)
bar(bandLabels, [comparisonTable.Primary_MeanCoherence comparisonTable.Control_MeanCoherence], 'grouped')
grid on
ylabel('Mean coherence')
title('Mean coherence in the 0.02-0.15 Hz range')
legend('Primary', 'Same-channel control', 'Location', 'best')

subplot(3, 1, 3)
bar(bandLabels, [comparisonTable.Primary_AUC_Coherence comparisonTable.Control_AUC_Coherence], 'grouped')
grid on
ylabel('AUC coherence')
title('Area under coherence in the 0.02-0.15 Hz range')
legend('Primary', 'Same-channel control', 'Location', 'best')

annotationText = sprintf( ...
    'Primary: %s | Control: %s', ...
    results(1).strategy.description, ...
    results(2).strategy.description);
sgtitle({'Strategy comparison', annotationText})

exportgraphics(fig, fullfile(cfg.figuresDir, 'fig04_strategy_comparison.png'), 'Resolution', 200)
close(fig)
end
