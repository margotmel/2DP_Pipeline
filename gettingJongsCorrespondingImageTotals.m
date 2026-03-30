close all
clear
clc


orientationsMappingPath = '/home/mel/master_set_of_features_copy_me_4000_5_orientations_imagenet_detections/orientation_selection_record.mat';
data = load(orientationsMappingPath);
whichOrientationBlockChosen = data.whichOrientationChosen;

numFeatures = 4000;
featureNumbers = (1:numFeatures)';

selectedFeatureInds = (whichOrientationBlockChosen(:)-1)*numFeatures + featureNumbers;

featureTypes = [ ...
    "c_c_c" "c_c_c_c" "cr_c" "cr_c_c" "cr_cr" "cr_c_s" "cr_e" "cr_e_c" ...
    "cr_e_e" "cr_e_s" "cr_od" "cr_od_c" "cr_od_e" "cr_od_od" "cr_od_s" ...
    "cr_s" "cr_s_s" "lmax_quads" "lmax_triads" "od_c" "od_c_c" "od_c_s" ...
    "od_e" "od_e_c" "od_e_e" "od_e_s" "od_od" "od_od_c" "od_od_e" "od_od_s" ...
    "od_s" "od_s_s" "s_c_c" "s_c_c_c" "s_s_c" "s_s_c_c" "s_s_s" "s_s_s_c" "s_s_s_s" ...
];

% --- Step 1: Determine number of images from the first available file ---
firstFile = strcat("/home/mel/four_orientations_aws_data/pooled0_", featureTypes(1), ".mat");
firstFileData = load(firstFile);
numImages = size(firstFileData.storingPooled0, 2);

% --- Step 2: Initialize accumulators for all three subs ---
sumTotalFeatureCounts0 = zeros(1, numImages);
sumTotalFeatureCounts1 = zeros(1, numImages);
sumTotalFeatureCounts2 = zeros(1, numImages);

for f = 1:length(featureTypes)
    featureType = featureTypes(f)

    filePath0 = strcat("/home/mel/four_orientations_aws_data/pooled0_", featureTypes(f), ".mat");
    filePath1 = strcat("/home/mel/four_orientations_aws_data/pooled1_", featureTypes(f), ".mat");
    filePath2 = strcat("/home/mel/four_orientations_aws_data/pooled2_", featureTypes(f), ".mat");

    data0 = load(filePath0);
    data1 = load(filePath1);
    data2 = load(filePath2);

    counts0 = uint16(data0.storingPooled0);
    counts1 = uint16(data1.storingPooled1);
    counts2 = uint16(data2.storingPooled2);

    % select correct orientation block for each feature
    selectedCounts0 = counts0(selectedFeatureInds,:);
    selectedCounts1 = counts1(selectedFeatureInds,:);
    selectedCounts2 = counts2(selectedFeatureInds,:);


    sumTotalFeatureCounts0 = sumTotalFeatureCounts0 + sum(selectedCounts0, 1);
    sumTotalFeatureCounts1 = sumTotalFeatureCounts1 + sum(selectedCounts1, 1);
    sumTotalFeatureCounts2 = sumTotalFeatureCounts2 + sum(selectedCounts2, 1);

end

saveFolder = '/home/margot/2DP_Pipeline';
save(fullfile(saveFolder, 'sumTotalFeatureCountsJongSelectedOri_Sub0.mat'), 'sumTotalFeatureCounts0')
save(fullfile(saveFolder, 'sumTotalFeatureCountsJongSelectedOri_Sub1.mat'), 'sumTotalFeatureCounts1')
save(fullfile(saveFolder, 'sumTotalFeatureCountsJongSelectedOri_Sub2.mat'), 'sumTotalFeatureCounts2')