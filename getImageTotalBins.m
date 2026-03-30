close all
clear
clc

numFeatures = 4000;

featureTypes = [ ...
"c_c_c" "c_c_c_c" "cr_c" "cr_c_c" "cr_cr" "cr_c_s" "cr_e" "cr_e_c" ...
"cr_e_e" "cr_e_s" "cr_od" "cr_od_c" "cr_od_e" "cr_od_od" "cr_od_s" ...
"cr_s" "cr_s_s" "lmax_quads" "lmax_triads" "od_c" "od_c_c" "od_c_s" ...
"od_e" "od_e_c" "od_e_e" "od_e_s" "od_od" "od_od_c" "od_od_e" "od_od_s" ...
"od_s" "od_s_s" "s_c_c" "s_c_c_c" "s_s_c" "s_s_c_c" "s_s_s" "s_s_s_c" "s_s_s_s" ...
];

baseFolder = '/home/margot/2DP_Pipeline/storedPooledCounts';

orientationData = load('/home/mel/master_set_of_features_copy_me_4000_5_orientations_imagenet_detections/orientation_selection_record.mat', ...
                       'whichOrientationChosen');

whichOrientationBlockChosen = orientationData.whichOrientationChosen;
% loads:
% whichOrientationBlockChosen (4000×1 values 1–4)

% build index mapping from 4000 → 16000 space
featureNumbers = (1:numFeatures)';

selectedFeatureInds = (whichOrientationBlockChosen(:)-1)*numFeatures + featureNumbers;

% --- determine number of images ---
firstFile = strcat(baseFolder,"/storingPooledCountsSub0_4ori_",featureTypes(1),".mat");

tmp = load(firstFile);

numImages = size(tmp.storingPooledCounts0Final,2);

% --- initialize totals ---
sumTotalFeatureCounts0 = zeros(1,numImages);
sumTotalFeatureCounts1 = zeros(1,numImages);
sumTotalFeatureCounts2 = zeros(1,numImages);

% --- loop across feature types ---
for f = 1:length(featureTypes)

    featureType = featureTypes(f)

    filePath0 = strcat(baseFolder,"/storingPooledCountsSub0_4ori_",featureType,".mat");
    filePath1 = strcat(baseFolder,"/storingPooledCountsSub1_4ori_",featureType,".mat");
    filePath2 = strcat(baseFolder,"/storingPooledCountsSub2_4ori_",featureType,".mat");

    data0 = load(filePath0);
    data1 = load(filePath1);
    data2 = load(filePath2);

    counts0 = uint16(data0.storingPooledCounts0Final);
    counts1 = uint16(data1.storingPooledCounts1Final);
    counts2 = uint16(data2.storingPooledCounts2Final);

    % select correct orientation block for each feature
    selectedCounts0 = counts0(selectedFeatureInds,:);
    selectedCounts1 = counts1(selectedFeatureInds,:);
    selectedCounts2 = counts2(selectedFeatureInds,:);

    % sum across 4000 features
    sumTotalFeatureCounts0 = sumTotalFeatureCounts0 + sum(selectedCounts0,1);
    sumTotalFeatureCounts1 = sumTotalFeatureCounts1 + sum(selectedCounts1,1);
    sumTotalFeatureCounts2 = sumTotalFeatureCounts2 + sum(selectedCounts2,1);

end

saveFolder = '/home/margot/2DP_Pipeline';

save(fullfile(saveFolder,'sumTotalFeatureCounts_Sub0_selectedOriJong.mat'),'sumTotalFeatureCounts0')
save(fullfile(saveFolder,'sumTotalFeatureCounts_Sub1_selectedOriJong.mat'),'sumTotalFeatureCounts1')
save(fullfile(saveFolder,'sumTotalFeatureCounts_Sub2_selectedOriJong.mat'),'sumTotalFeatureCounts2')