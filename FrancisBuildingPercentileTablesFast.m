clear all
close all

numImages = 99878;

pooledDir = '/home/mel/four_orientations_experimental_features_jong_orig_db_post_50';
outputBaseDir = '/home/margot/2DP_Pipeline/FeatureWiseTablesNewBatch/';

% Auto-discover feature types from pooled0_*.mat files
pooledFiles = dir(fullfile(pooledDir, 'pooled0_*.mat'));
featureTypes = string.empty;
for f = 1:numel(pooledFiles)
    name = pooledFiles(f).name;
    % Strip 'pooled0_' prefix and '.mat' suffix
    
    ft = extractBetween(name, 'pooled0_', '.mat');
    featureTypes(end+1) = ft;
end

fprintf('Found %d feature types: %s\n\n', numel(featureTypes), strjoin(featureTypes, ', '));

subframes = ["0","1","2"];

for a = 1:length(featureTypes)
    featureType = featureTypes(a);
    for x = 1:length(subframes)
        subframe = subframes(x);

        % Check if already processed
        testPath = strcat(outputBaseDir, featureType, 'FeatureWiseTablesSub', subframe, '/sub', subframe, featureType, 'PercentileTable1.mat');
        if exist(testPath, 'file')
            fprintf('SKIP [already processed]: %s sub%s\n', featureType, subframe);
            continue;
        end

        fprintf('Processing: %s sub%s\n', featureType, subframe);

        load(strcat(pooledDir, '/pooled', subframe, '_', featureType, '.mat'), strcat('storingPooled', subframe))

        disp("loaded")

        if subframe == "0"
            load('sumtotalFeatureCountsSub0.mat','sumtotalFeatureCounts')
        else
            load(strcat('sumTotalFeatureCountsSub',subframe,'.mat'),'sumtotalFeatureCounts')
        end

        numUniqueFeatures = 4000;
        numOrientations = 4;
        totalFeatures  = numUniqueFeatures*numOrientations;
%{
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
%}

        load(strcat('imageBinsImageNet',subframe,'.mat'),'binIndex');

        for i = 1:numUniqueFeatures
            disp(i)
            indexOfOrientations = [i,i+(1*numUniqueFeatures),i+(2*numUniqueFeatures),i+(3*numUniqueFeatures)];

            if subframe == "0"
                rawCountRows = storingPooled0(indexOfOrientations, :);
            elseif subframe == "1"
                rawCountRows = storingPooled1(indexOfOrientations, :);
            elseif subframe == "2"
                rawCountRows = storingPooled2(indexOfOrientations, :);
            end

            dicts = cell(1, 10);

            for p = 1:numel(bins)-1

                countsToMakeTable = rawCountRows(:,imageBins==p);
                sortedRawCounts = sort(countsToMakeTable(:));
                truncSortedRawCounts = sortedRawCounts(sortedRawCounts>0);

                if length(truncSortedRawCounts)>0

                    featureCountTempTable = [];
                    [g,ia,ic] = unique(truncSortedRawCounts);

                    iaDiff = diff(ia);

                    finalCount = (length(truncSortedRawCounts) - ia(length(ia)))+1;

                    iaDiff = [iaDiff; finalCount];

                    c = 100*((ia-1)+(0.5*iaDiff))/length(truncSortedRawCounts);

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

                    elseif counts(1) >1
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
                                counter = counter+1;
                                newx(counter) = counter;
                                [counts(m),counts(m+1),percs(m),percs(m+1),(counts(m)+r)];
                                newy(counter) = interp1([counts(m),counts(m+1)],[percs(m),percs(m+1)],(counts(m)+r));

                            end

                        else
                            counter = counter+1;
                            newy(counter) = percs(m+1);
                            newx(counter) = counter;

                        end
                    end

                    dFilledOut = dictionary(newx,newy);
                else
                    dFilledOut = dictionary(0,0);
                end

                dicts{p} = dFilledOut;

            end

            filePath = strcat(outputBaseDir, featureType, 'FeatureWiseTablesSub', subframe, '/sub', subframe, featureType, 'PercentileTable', int2str(i), '.mat');

            [dirPath, ~, ~] = fileparts(filePath);

            if ~exist(dirPath, 'dir')
                mkdir(dirPath);
            end

            save(filePath,'dicts')
        end

    end

end