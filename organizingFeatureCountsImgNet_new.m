clear
close all
clc

numFeatures = 4000;

baseFolder = '/home/mel/master_set_of_features_copy_me_4000_5_orientations_imagenet_detections';

% --- Read filenames from intersection.txt once ---
intersectionFile = fullfile(baseFolder, 'intersection.txt');
fid = fopen(intersectionFile, 'r');
imageNames = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
imageNames = imageNames{1};
numImages = numel(imageNames)

featureTypesToRun = { ...
    'c_c_c', 'c_c_c_c', 'cr_c', 'cr_c_c', 'cr_cr', 'cr_c_s', 'cr_e', 'cr_e_c', ...
    'cr_e_e', 'cr_e_s', 'cr_od', 'cr_od_c', 'cr_od_e', 'cr_od_od', 'cr_od_s', ...
    'cr_s', 'cr_s_s', 'lmax_quads', 'lmax_triads', 'od_c', 'od_c_c', 'od_c_s', ...
    'od_e', 'od_e_c', 'od_e_e', 'od_e_s', 'od_od', 'od_od_c', 'od_od_e', 'od_od_s', ...
    'od_s', 'od_s_s', 's_c_c', 's_c_c_c', 's_s_c', 's_s_c_c', 's_s_s', 's_s_s_c', 's_s_s_s' ...
};

for f = 1:length(featureTypesToRun)

    featureType = featureTypesToRun{f}

    % --- Use l2p0,0 if it exists, otherwise fall back to l2p1,1 ---
    folderOfImages_l2p0 = fullfile(baseFolder, featureType, 'features-results-l2p0,0');
    folderOfImages_l2p1 = fullfile(baseFolder, featureType, 'features-results-l2p1,1');

    if isfolder(folderOfImages_l2p0)
        folderOfImages = folderOfImages_l2p0;
    elseif isfolder(folderOfImages_l2p1)
        folderOfImages = folderOfImages_l2p1;
        disp(['Using l2p1,1 for: ', featureType])
    else
        disp(['Skipping (no valid folder found): ', featureType])
        continue
    end

    saveFolder = '/home/margot/2DP_Pipeline/storedPooledCountsImgNet';
    filename0 = strcat('storingPooledCountsSub0_imgNetsum5ori_', featureType, '.mat');

    if exist(fullfile(saveFolder, filename0), 'file')
        disp(['Already done, skipping: ', featureType])
        continue
    end

    disp(['Processing: ', featureType])

    storingPooledCounts0Final = zeros(numFeatures, numImages, 'uint16');
    storingPooledCounts1Final = zeros(numFeatures, numImages, 'uint16');
    storingPooledCounts2Final = zeros(numFeatures, numImages, 'uint16');

    for i = 1:numImages

        if mod(i, 100) == 1
            disp(i)
            disp(featureType)
        end

        currentFile = load(fullfile(folderOfImages, imageNames{i}));

        currentPooledFeatureCountsSub0 = uint16(currentFile.detected_0);
        currentPooledFeatureCountsSub1 = uint16(currentFile.detected_1);
        currentPooledFeatureCountsSub2 = uint16(currentFile.detected_2);

        % Sum across the 5 orientations
        storingPooledCounts0Final(:,i) = sum(currentPooledFeatureCountsSub0, 1)';
        storingPooledCounts1Final(:,i) = sum(currentPooledFeatureCountsSub1, 1)';
        storingPooledCounts2Final(:,i) = sum(currentPooledFeatureCountsSub2, 1)';

    end

    disp('saving')

    filename0 = strcat('storingPooledCountsSub0_imgNetsum5ori_', featureType, '.mat');
    filename1 = strcat('storingPooledCountsSub1_imgNetsum5ori_', featureType, '.mat');
    filename2 = strcat('storingPooledCountsSub2_imgNetsum5ori_', featureType, '.mat');

    save(fullfile(saveFolder, filename0), 'storingPooledCounts0Final', '-v7.3')
    save(fullfile(saveFolder, filename1), 'storingPooledCounts1Final', '-v7.3')
    save(fullfile(saveFolder, filename2), 'storingPooledCounts2Final', '-v7.3')

end