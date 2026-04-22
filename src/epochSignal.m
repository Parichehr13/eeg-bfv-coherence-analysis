function [segments, numSegments] = epochSignal(x, segmentLen)
x = x(:);
numSegments = floor(numel(x) / segmentLen);

if numSegments < 1
    error('Signal length %d is shorter than one full segment of %d samples.', numel(x), segmentLen);
end

x = x(1:numSegments * segmentLen);
segments = reshape(x, segmentLen, numSegments).';
end
