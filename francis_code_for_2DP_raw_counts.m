function francis_code_for_2DP_raw_counts()
% Main entry point - processes all feature types

NUM_FEATURES = 4000;
NUM_ORIENTATIONS = 4;
NUM_IMAGES = 68200;
ORIENTATIONS_PER_FEATURE = 24;

featureTypes = [ "od_e_s","triads_lmax"];

for featTypeIndex = 1:numel(featureTypes)
    cd("/home/margot/2DP_Pipeline")
    featureType = featureTypes(featTypeIndex);
    fprintf('Processing %s\n', featureType);

    % Step 1: Organize feature counts
    organize_feature_counts(featureType, NUM_FEATURES, NUM_ORIENTATIONS, ORIENTATIONS_PER_FEATURE);

    % Step 2: Build percentile tables
    build_percentile_tables(featureType, NUM_FEATURES, NUM_ORIENTATIONS, NUM_IMAGES);

    % Step 3: Apply percentiles
    apply_percentiles(featureType, NUM_FEATURES, NUM_ORIENTATIONS, NUM_IMAGES);
end
end

function organize_feature_counts(featureType, NUM_FEATURES, NUM_ORIENTATIONS, ORIENTATIONS_PER_FEATURE)
% Generate orientation pattern
a = zeros(4, 6);
a(1,:) = 1:6;
a(2,:) = a(1,:) + 6;
a(3,:) = a(2,:) + 6;
a(4,:) = a(3,:) + 6;

orientations = repmat(a, 1, 667);
orientations = orientations(:, 1:NUM_FEATURES);
orientations = orientations';

% Slot indices for organizing 4 orientations
slots = [1:NUM_FEATURES;
    NUM_FEATURES+1:NUM_FEATURES*2;
    (NUM_FEATURES*2+1):NUM_FEATURES*3;
    (NUM_FEATURES*3+1):NUM_FEATURES*4];

% Load images
folderOfImages = strcat('/home/mel/redo_these_features_2DP/', featureType, '/features-results-l2p2,2');
cd(folderOfImages);
disp(folderOfImages);

allImages = dir('features_*.mat');
numImages = numel(allImages);

% Preallocate storage
numToCollect = 4 * NUM_FEATURES;
storingPooledCounts0Final = zeros(numToCollect, numImages, 'uint16');
storingPooledCounts1Final = zeros(numToCollect, numImages, 'uint16');
storingPooledCounts2Final = zeros(numToCollect, numImages, 'uint16');

storingPooledCounts0 = zeros(NUM_FEATURES, 1, 'uint16');
storingPooledCounts1 = zeros(NUM_FEATURES, 1, 'uint16');
storingPooledCounts2 = zeros(NUM_FEATURES, 1, 'uint16');

movingOris = orientations';

% Process each image
for i = 1:numImages
    if mod(i, 100) == 1
        disp(i)
    end

    currentFile = load(allImages(i).name);

    try
        currentPooledFeatureCountsSub0 = uint16(currentFile.l2pool_0);
        currentPooledFeatureCountsSub1 = uint16(currentFile.l2pool_1);
        currentPooledFeatureCountsSub2 = uint16(currentFile.l2pool_2);
    catch
        currentPooledFeatureCountsSub0 = uint16(currentFile.detected_0);
        currentPooledFeatureCountsSub1 = uint16(currentFile.detected_1);
        currentPooledFeatureCountsSub2 = uint16(currentFile.detected_2);
    end

    for f = 1:4
        featureInds = sub2ind([ORIENTATIONS_PER_FEATURE, NUM_FEATURES], movingOris(f,:), 1:NUM_FEATURES);

        storingPooledCounts0(:,1) = currentPooledFeatureCountsSub0(featureInds);
        storingPooledCounts1(:,1) = currentPooledFeatureCountsSub1(featureInds);
        storingPooledCounts2(:,1) = currentPooledFeatureCountsSub2(featureInds);

        storingPooledCounts0Final(slots(f,:), i) = storingPooledCounts0;
        storingPooledCounts1Final(slots(f,:), i) = storingPooledCounts1;
        storingPooledCounts2Final(slots(f,:), i) = storingPooledCounts2;
    end
end

disp('saving');

filename0 = strcat('/home/mel/2DP_results/storingPooledCountsSub0_4ori_16_', featureType, '.mat');
filename1 = strcat('/home/mel/2DP_results/storingPooledCountsSub1_4ori_16_', featureType, '.mat');
filename2 = strcat('/home/mel/2DP_results/storingPooledCountsSub2_4ori_16_', featureType, '.mat');

storingPooledCounts0Final = uint16(storingPooledCounts0Final);
storingPooledCounts1Final = uint16(storingPooledCounts1Final);
storingPooledCounts2Final = uint16(storingPooledCounts2Final);


save(filename0, 'storingPooledCounts0Final', '-v7.3');
save(filename1, 'storingPooledCounts1Final', '-v7.3');
save(filename2, 'storingPooledCounts2Final', '-v7.3');
end

function build_percentile_tables(featureType, NUM_FEATURES, NUM_ORIENTATIONS, NUM_IMAGES)
cd('/home/margot/2DP_Pipeline');

subframes = ["0", "1", "2"];

for x = 1:3
    subframe = subframes(x);

    % Load pooled counts
    load(strcat('/home/margot/2DP_Pipeline/storedPooledCounts/storingPooledCountsSub', subframe, '_4ori_16_', featureType, '.mat'), ...
        strcat('storingPooledCounts', subframe, 'Final'));
    disp("loaded");

    % Load sum total feature counts
    if subframe == "0"
        load('sumtotalFeatureCountsSub0.mat', 'sumtotalFeatureCounts');
    else
        load(strcat('sumTotalFeatureCountsSub', subframe, '.mat'), 'sumtotalFeatureCounts');
    end

    % Define bins based on subframe
    if subframe == "0"
        binSize = 2800000;
        bins = 0:binSize:28000000;
    elseif subframe == "1"
        binSize = 2700000;
        bins = 0:binSize:27000000;
    elseif subframe == "2"
        binSize = 810000;
        bins = 0:binSize:8100000;
    end

    % Load image bins
    load(strcat('imageBinsSub', subframe, '.mat'), 'imageBins');

    % Process each feature
    for i = 1:NUM_FEATURES
        disp(i);

        indexOfOrientations = [i, i+(1*NUM_FEATURES), i+(2*NUM_FEATURES), i+(3*NUM_FEATURES)];

        if subframe == "0"
            rawCountRows = storingPooledCounts0Final(indexOfOrientations, :);
        elseif subframe == "1"
            rawCountRows = storingPooledCounts1Final(indexOfOrientations, :);
        elseif subframe == "2"
            rawCountRows = storingPooledCounts2Final(indexOfOrientations, :);
        end

        dicts = cell(1, 10);

        for p = 1:numel(bins)-1
            countsToMakeTable = rawCountRows(:, imageBins==p);
            sortedRawCounts = sort(countsToMakeTable(:));
            truncSortedRawCounts = sortedRawCounts(sortedRawCounts>0);

            if length(truncSortedRawCounts) > 0
                featureCountTempTable = [];
                [g, ia, ic] = unique(truncSortedRawCounts);

                iaDiff = diff(ia);
                finalCount = (length(truncSortedRawCounts) - ia(length(ia))) + 1;
                iaDiff = [iaDiff; finalCount];

                c = 100 * ((ia-1) + (0.5*iaDiff)) / length(truncSortedRawCounts);

                featureCountTempTable(:,1) = g';
                featureCountTempTable(:,2) = c;

                d = dictionary(featureCountTempTable(:,1), featureCountTempTable(:,2));

                counts = d.keys;
                percs = d.values;

                newx = [];
                newy = [];

                if counts(1) == 1
                    startingPoint = 1;
                    newx(1) = 1;
                    newy = percs(1);
                elseif counts(1) > 1
                    startingPoint = counts(1);
                    newx(1:startingPoint-1) = 1:startingPoint-1;
                    newy(1:startingPoint-1) = 0;
                    newx(startingPoint) = startingPoint;
                    newy(startingPoint) = percs(1);
                end

                ia = diff(counts);
                counter = startingPoint;

                for m = 1:numel(counts)-1
                    if ia(m) > 1
                        for r = 1:ia(m)
                            counter = counter + 1;
                            newx(counter) = counter;
                            newy(counter) = interp1([counts(m), counts(m+1)], [percs(m), percs(m+1)], (counts(m)+r));
                        end
                    else
                        counter = counter + 1;
                        newy(counter) = percs(m+1);
                        newx(counter) = counter;
                    end
                end

                dFilledOut = dictionary(newx, newy);
            else
                dFilledOut = dictionary(0, 0);
            end

            dicts{p} = dFilledOut;
        end

        % Save percentile table
        filePath = strcat('/home/margot/2DP_Pipeline/FeatureWiseTables/', featureType, 'FeatureWiseTablesSub', subframe, ...
            '/sub', subframe, featureType, 'PercentileTable', int2str(i), '.mat');
        [dirPath, ~, ~] = fileparts(filePath);

        if ~exist(dirPath, 'dir')
            mkdir(dirPath);
        end

        save(filePath, 'dicts');
    end
end
end

function apply_percentiles(featureType, NUM_FEATURES, NUM_ORIENTATIONS, NUM_IMAGES)
cd('/home/margot/2DP_Pipeline');

subframes = ["0", "1", "2"];

for x = 1:3
    subframe = subframes(x);

    % Load image bins
    load(strcat("imageBinsSub", subframe, ".mat"), "imageBins");

    % Load pooled counts
    load(strcat('/home/margot/2DP_Pipeline/storedPooledCounts/storingPooledCountsSub', subframe, '_4ori_16_', featureType, '.mat'), ...
        strcat('storingPooledCounts', subframe, 'Final'));

    % Preallocate based on subframe
    if subframe == "0"
        fullPercentileArray = zeros(size(storingPooledCounts0Final), 'uint16');
    elseif subframe == "1"
        fullPercentileArray = zeros(size(storingPooledCounts1Final), 'uint16');
    elseif subframe == "2"
        fullPercentileArray = zeros(size(storingPooledCounts2Final), 'uint16');
    end

    tempResults = cell(NUM_FEATURES, 1);

    for i = 1:NUM_FEATURES
        disp(i);

        % Load percentile dictionaries
        dicts = load(strcat('/home/margot/2DP_Pipeline/FeatureWiseTables/', featureType, 'FeatureWiseTablesSub', subframe, ...
            '/sub', subframe, featureType, 'PercentileTable', int2str(i), '.mat')).dicts;

        indexOfOrientations = [i, i + NUM_FEATURES, i + (2 * NUM_FEATURES), i + (3 * NUM_FEATURES)];

        % Extract raw count rows
        if subframe == "0"
            rawCountRows = storingPooledCounts0Final(indexOfOrientations, :);
        elseif subframe == "1"
            rawCountRows = storingPooledCounts1Final(indexOfOrientations, :);
        elseif subframe == "2"
            rawCountRows = storingPooledCounts2Final(indexOfOrientations, :);
        end

        % Preallocate local storage
        localPercentileData = zeros(size(rawCountRows), 'uint16');

        % Process each bin
        for p = 1:10
            dicts{p}(0) = 0;  % Map key 0 to value 0 in dictionary
            mask = (imageBins == p);
            if any(mask)
                localPercentileData(:, mask) = dicts{p}(rawCountRows(:, mask));
            end
        end

        tempResults{i} = {indexOfOrientations, localPercentileData};
    end

    % Assign values
    for i = 1:NUM_FEATURES
        fullPercentileArray(tempResults{i}{1}, :) = tempResults{i}{2};
    end

    % Save final array
    save(strcat('/home/margot/2DP_Pipeline/2DP_arrays/', featureType, '4kPercentilesNewMethodSub', subframe, '.mat'), ...
        'fullPercentileArray', '-v7.3');
end
end



