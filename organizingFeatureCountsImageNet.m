clear
close all
clc

numFeatures = 4000;

baseFolder = '/home/mel/master_set_of_features_copy_me_4000_5_orientations_imagenet_detections';

featureFolders = dir(baseFolder);
featureFolders = featureFolders([featureFolders.isdir]); % keep folders only
featureFolders = featureFolders(~ismember({featureFolders.name},{'.','..'})); % remove . ..

folderNames = {featureFolders.name};

% Skip folders containing '3C2' and the one you already ran
validIdx = ~contains(folderNames,'3C2') & ~strcmp(folderNames,'c_c_c');

featureFolders = featureFolders(validIdx);

featureTypesToRun = { ...
    's_c_c', ...
    's_c_c_c', ...
    's_s_c', ...
    's_s_c_c', ...
    's_s_s', ...
    's_s_s_c', ...
    's_s_s_s' ...
};

%for f = 1:length(featureFolders)
for f = 1:length(featureTypesToRun)

    featureType = featureTypesToRun{f};

    folderOfImages = fullfile(baseFolder,featureType,'features-results-l2p0,0');

    saveFolder = '/home/margot/2DP_Pipeline/storedPooledCountsImgNet';
    filename0 = strcat('storingPooledCountsSub0_imgNetsum5ori_',featureType,'.mat');

    if exist(fullfile(saveFolder,filename0),'file')
        disp(['Already done, skipping: ', featureType])
        continue
    end
    if ~isfolder(folderOfImages)
        disp(['Skipping (missing folder): ', featureType])
        continue
    end

    disp(['Processing: ', featureType])
    cd(folderOfImages)

    allImages = dir('features_*.mat');
    numImages = numel(allImages)

    storingPooledCounts0Final = zeros(numFeatures,numImages,'uint16');
    storingPooledCounts1Final = zeros(numFeatures,numImages,'uint16');
    storingPooledCounts2Final = zeros(numFeatures,numImages,'uint16');

    for i = 1:numImages

        if mod(i,100)==1
            disp(i)
        end

        currentFile = load(allImages(i).name);

        currentPooledFeatureCountsSub0 = uint16(currentFile.detected_0);
        currentPooledFeatureCountsSub1 = uint16(currentFile.detected_1);
        currentPooledFeatureCountsSub2 = uint16(currentFile.detected_2);

        % Sum across the 5 orientations
        storingPooledCounts0Final(:,i) = sum(currentPooledFeatureCountsSub0,1)';
        storingPooledCounts1Final(:,i) = sum(currentPooledFeatureCountsSub1,1)';
        storingPooledCounts2Final(:,i) = sum(currentPooledFeatureCountsSub2,1)';

    end

    disp('saving')

    filename0 = strcat('storingPooledCountsSub0_imgNetsum5ori_',featureType,'.mat');
    filename1 = strcat('storingPooledCountsSub1_imgNetsum5ori_',featureType,'.mat');
    filename2 = strcat('storingPooledCountsSub2_imgNetsum5ori_',featureType,'.mat');

    saveFolder = '/home/margot/2DP_Pipeline/storedPooledCountsImgNet';
    cd(saveFolder)

    save(filename0,'storingPooledCounts0Final','-v7.3')
    save(filename1,'storingPooledCounts1Final','-v7.3')
    save(filename2,'storingPooledCounts2Final','-v7.3')

end