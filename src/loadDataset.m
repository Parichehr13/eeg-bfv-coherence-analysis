function dataset = loadDataset(dataFile)
if ~isfile(dataFile)
    error('Dataset file not found: %s', dataFile);
end

raw = load(dataFile);
requiredFields = {'F4C4', 'BFV2', 'Fs_EEG', 'Fs_BFV'};
optionalFields = {'P3O1', 'P4O2', 'F3C3', 'BFV1'};

for idx = 1:numel(requiredFields)
    fieldName = requiredFields{idx};
    if ~isfield(raw, fieldName)
        error('Required dataset field missing: %s', fieldName);
    end
end

dataset = struct();
for idx = 1:numel(requiredFields)
    fieldName = requiredFields{idx};
    dataset.(fieldName) = raw.(fieldName);
end

for idx = 1:numel(optionalFields)
    fieldName = optionalFields{idx};
    if isfield(raw, fieldName)
        dataset.(fieldName) = raw.(fieldName);
    end
end

vectorFields = {'F4C4', 'BFV2', 'P3O1', 'P4O2', 'F3C3', 'BFV1'};
for idx = 1:numel(vectorFields)
    fieldName = vectorFields{idx};
    if isfield(dataset, fieldName)
        validateattributes(dataset.(fieldName), {'numeric'}, {'vector', 'finite'}, mfilename, fieldName);
        dataset.(fieldName) = dataset.(fieldName)(:);
    end
end

validateattributes(dataset.Fs_EEG, {'numeric'}, {'scalar', 'real', 'positive', 'finite'}, mfilename, 'Fs_EEG');
validateattributes(dataset.Fs_BFV, {'numeric'}, {'scalar', 'real', 'positive', 'finite'}, mfilename, 'Fs_BFV');
end
