function [powerVariability, freqAxis, bandMask] = computeBandPowerVariability(segments, bandLimits, Fs, cfg, includeUpperEdge)
if nargin < 5
    includeUpperEdge = true;
end

segmentLen = size(segments, 2);
winLen = max(cfg.minWelchWindowSamples, floor(segmentLen * cfg.welchWindowFraction));
winLen = min(winLen, segmentLen);
win = hamming(winLen);
overlap = min(floor(winLen / 2), winLen - 1);
nfft = max(cfg.minWelchNfft, 2 ^ nextpow2(segmentLen));

powerVariability = zeros(size(segments, 1), 1);
freqAxis = [];
bandMask = [];

for idx = 1:size(segments, 1)
    x = detrend(segments(idx, :).', 0);
    [Pxx, freqAxis] = pwelch(x, win, overlap, nfft, Fs, 'psd');

    if includeUpperEdge
        bandMask = (freqAxis >= bandLimits(1)) & (freqAxis <= bandLimits(2));
    else
        bandMask = (freqAxis >= bandLimits(1)) & (freqAxis < bandLimits(2));
    end

    if ~any(bandMask)
        error('No Welch frequencies fall inside band [%.2f %.2f] Hz.', bandLimits(1), bandLimits(2));
    end

    powerVariability(idx) = trapz(freqAxis(bandMask), Pxx(bandMask));
end
end
