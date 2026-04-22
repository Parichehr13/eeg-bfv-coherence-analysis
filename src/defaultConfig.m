function cfg = defaultConfig(repoRoot)
cfg.repoRoot = repoRoot;
cfg.dataFile = fullfile(repoRoot, 'data', 'dataset09.mat');
cfg.figuresDir = fullfile(repoRoot, 'figures');
cfg.resultsDir = fullfile(repoRoot, 'results');

cfg.segmentDurationSec = 2;
cfg.plotDurationSec = 10;
cfg.figureVisible = 'off';

cfg.welchWindowFraction = 0.5;
cfg.minWelchWindowSamples = 128;
cfg.minWelchNfft = 512;

cfg.coherenceWindowFraction = 0.25;
cfg.minCoherenceWindowSamples = 16;
cfg.minCoherenceNfft = 256;
cfg.coherenceRangeHz = [0.02 0.15];

cfg.bands = struct( ...
    'name', {'delta', 'theta', 'alpha', 'beta'}, ...
    'limits', {[0.5 4.0], [4.0 8.0], [8.0 13.0], [13.0 30.0]});
end
