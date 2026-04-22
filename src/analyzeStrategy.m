function result = analyzeStrategy(dataset, cfg, strategy)
FsPV = 1 / cfg.segmentDurationSec;
segmentLenEEG = round(cfg.segmentDurationSec * dataset.Fs_EEG);
segmentLenBFV = max(1, round(cfg.segmentDurationSec * dataset.Fs_BFV));

[bfvSegments, numBfvSegments] = epochSignal(dataset.BFV2, segmentLenBFV);
bfvEpoch = mean(bfvSegments, 2);

nBands = numel(cfg.bands);
bandNames = strings(nBands, 1);
channelLabels = strings(nBands, 1);

powerVariability = cell(nBands, 1);
powerTime = cell(nBands, 1);
coherenceValues = cell(nBands, 1);
coherenceFreqs = cell(nBands, 1);
epochCounts = zeros(nBands, 1);

peakCoherence = nan(nBands, 1);
peakFreq = nan(nBands, 1);
meanCoherence = nan(nBands, 1);
aucCoherence = nan(nBands, 1);

for idx = 1:nBands
    band = cfg.bands(idx);
    bandNames(idx) = string(band.name);

    [eegSignal, channelLabel] = selectBandSignal(dataset, band.name, strategy);
    channelLabels(idx) = channelLabel;

    [segmentsEEG, numEegSegments] = epochSignal(eegSignal, segmentLenEEG);
    numCommon = min(numEegSegments, numBfvSegments);

    includeUpperEdge = idx == nBands;
    pv = computeBandPowerVariability( ...
        segmentsEEG(1:numCommon, :), ...
        band.limits, ...
        dataset.Fs_EEG, ...
        cfg, ...
        includeUpperEdge);

    powerVariability{idx} = pv;
    powerTime{idx} = ((0:numCommon - 1)' + 0.5) * cfg.segmentDurationSec;
    epochCounts(idx) = numCommon;

    xCoh = detrend(pv, 0);
    yCoh = detrend(bfvEpoch(1:numCommon), 0);

    cohWinLen = max(cfg.minCoherenceWindowSamples, floor(numCommon * cfg.coherenceWindowFraction));
    cohWinLen = min(cohWinLen, numCommon);
    cohWin = hamming(cohWinLen);
    cohOverlap = min(floor(cohWinLen / 2), cohWinLen - 1);
    cohNfft = max(cfg.minCoherenceNfft, 2 ^ nextpow2(numCommon));

    [coherenceValues{idx}, coherenceFreqs{idx}] = mscohere( ...
        xCoh, yCoh, cohWin, cohOverlap, cohNfft, FsPV);

    inRange = (coherenceFreqs{idx} >= cfg.coherenceRangeHz(1)) & ...
              (coherenceFreqs{idx} <= min(cfg.coherenceRangeHz(2), FsPV / 2));

    if any(inRange)
        selectedCoherence = coherenceValues{idx}(inRange);
        selectedFreqs = coherenceFreqs{idx}(inRange);
        [peakCoherence(idx), maxIdx] = max(selectedCoherence);
        peakFreq(idx) = selectedFreqs(maxIdx);
        meanCoherence(idx) = mean(selectedCoherence);
        aucCoherence(idx) = trapz(selectedFreqs, selectedCoherence);
    end
end

result = struct();
result.strategy = strategy;
result.bandNames = bandNames;
result.channelLabels = channelLabels;
result.powerVariability = powerVariability;
result.powerTime = powerTime;
result.coherenceValues = coherenceValues;
result.coherenceFreqs = coherenceFreqs;
result.bfvEpoch = bfvEpoch;
result.FsPV = FsPV;

result.summaryTable = table( ...
    repmat(string(strategy.name), nBands, 1), ...
    repmat(string(strategy.description), nBands, 1), ...
    bandNames, ...
    channelLabels, ...
    reshape([cfg.bands.limits], 2, []).', ...
    epochCounts, ...
    peakCoherence, ...
    peakFreq, ...
    meanCoherence, ...
    aucCoherence, ...
    'VariableNames', { ...
        'Strategy', ...
        'Strategy_Description', ...
        'Band', ...
        'EEG_Channel', ...
        'Band_Limits_Hz', ...
        'NumEpochs', ...
        'PeakCoherence', ...
        'PeakFreq_Hz', ...
        'MeanCoherence', ...
        'AUC_Coherence'});
end

function [signal, label] = selectBandSignal(dataset, bandName, strategy)
if strcmpi(bandName, 'alpha')
    preferences = strategy.alphaPreferences;
else
    preferences = {char(strategy.defaultChannel)};
end

for idx = 1:numel(preferences)
    candidate = preferences{idx};
    if isfield(dataset, candidate) && ~isempty(dataset.(candidate))
        signal = dataset.(candidate);
        label = string(candidate);
        return
    end
end

error('No valid EEG channel found for band %s under strategy %s.', bandName, strategy.name);
end
