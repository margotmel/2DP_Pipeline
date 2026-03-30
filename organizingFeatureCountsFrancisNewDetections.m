clear all
close all
clc



featureTypes = [ ...
"cr_c"
"cr_cr"
"cr_c_s"
"cr_e"
"cr_od"
"cr_od_c"
"cr_od_s"
"cr_s"
"cr_s_s"
"lmax_quads"
"lmax_triads"
"od_c"
"od_c_c"
"od_e_c"
"od_od"
"od_od_s"
"od_s"
"s_c_c"
"s_s_c"
"s_s_s"
];

for featTypeIndex = 1:20
featureType = featureTypes(featTypeIndex)
saveFolder = '/home/margot/2DP_Pipeline/storedPooledCounts';

filename0 = strcat('storingPooledCountsSub0_4ori_16_',featureType,'.mat');
filename1 = strcat('storingPooledCountsSub1_4ori_16_',featureType,'.mat');
filename2 = strcat('storingPooledCountsSub2_4ori_16_',featureType,'.mat');

fullpath0 = fullfile(saveFolder, filename0);
fullpath1 = fullfile(saveFolder, filename1);
fullpath2 = fullfile(saveFolder, filename2);

if isfile(fullpath0) || isfile(fullpath1) || isfile(fullpath2)
    disp(['Skipping (already exists): ', featureType])
    continue
end
%Formerly known as organizingFeatureCountsFrancisNewDetections.m

% These will be the orientations to cycle through for each feature
a = zeros(4, 6);



a(1,:) = 1:6;
a(2,:) = a(1,:) + 6;
a(3,:) = a(2,:) + 6;
a(4,:) = a(3, :)+ 6;


numFeatures = 4000;
%667 is 4000 (numFeatures) divided by 6 (sets of orientations)
orientations = repmat(a,1, 667);
orientations = orientations(:,1:numFeatures);

orientations = orientations';

slots = [1:numFeatures;numFeatures+1:numFeatures*2;(numFeatures*2+1):numFeatures*3;(numFeatures*3+1):numFeatures*4];


%This is the folder for the new detections

    %load in the folder which contains all of your images
    %folderOfImages = "/Users/margotmel/Deep/practice_images";
    %folderOfImages = '/home/margot/practice_images';
    %folderOfImages = '/home/mel/all_triads_and_diads_for_Jong/c_c_c/features-results-l2p2,2';
    %folderOfImages = "/home/mel/all_feature_types_1000_more_features/0S_4C/features-results-l2p2,2";
    %folderOfImages = strcat('/home/mel/all_triads_and_diads_for_Jong', '/', folderNames(x), '/', 'features-results-l2p2,2');
    %folderOfImages = strcat('/home/mel/triads3Choose2Thousand', '/', folderNames(x), '/', 'features-results-l2p2,2');
    %folderOfImages = '/home/francis/hyper_parameter_search/twelve_cases_francis_run/quadrads_k_12_L1_p1_m0/features-results-l2p2,2'
    %folderOfImages = '/home/mel/s_s_s_and_s_c_c_160000/s_c_c/features-results-l2p2,2';
    folderOfImages = strcat('/home/mel/all_triads_and_diads_for_Jong/',featureTypes(featTypeIndex),'/features-results-l2p2,2');
    %folderOfImages = '/home/mel/three_choose_two_4000/cr_e_s/features-results-l2p2,2';

    %change into the directory with the files
    
    cd(folderOfImages);
    disp(folderOfImages);
    numberOfFeatures = 4000;
    allImages = dir('features_*.mat');

    %%
    
    numImages = numel(allImages)
    numOrientations = 4;
    numToCollect= 4*numberOfFeatures;

    storingPooledCounts0Final = zeros(numToCollect,numImages, 'uint16');
    storingPooledCounts1Final = zeros(numToCollect,numImages, 'uint16');
    storingPooledCounts2Final = zeros(numToCollect,numImages, 'uint16');
    %numImages = 4; 
    

    storingPooledCounts0 = zeros(numberOfFeatures, 1, 'uint16');
    storingPooledCounts1 = zeros(numberOfFeatures, 1, 'uint16');
    storingPooledCounts2 = zeros(numberOfFeatures, 1, 'uint16');
    % 
    % storingPooledCounts0 = [];
    % storingPooledCounts1 = [];
    % storingPooledCounts2 = [];


    %randomOrientation = randi(24,1, numberOfFeatures);
    
    movingOris = orientations';

    %%
    %for i = 1:1
    i = 1
      if mod(i,100) == 1
        disp(i)
      end
        %disp(strcat(int2str(i),int2str(x)));
        currentFile = load(allImages(i).name);
        
        %currentPooledFeatureCounts = currentFile.l2pool_0;
        currentPooledFeatureCountsSub0 = uint16(currentFile.detected_0);

                % check number of features (columns)
        if size(currentPooledFeatureCountsSub0,2) == 1000
            disp('Skipping file with only 1000 features')
            disp(featureType)
            continue
        end
        currentPooledFeatureCountsSub1 = uint16(currentFile.detected_1);
        currentPooledFeatureCountsSub2 = uint16(currentFile.detected_2);
        
        
        for f = 1:4
    
        featureInds = sub2ind([24,numberOfFeatures],movingOris(f,:),1:numberOfFeatures);
            
          storingPooledCounts0(:,1) = currentPooledFeatureCountsSub0(featureInds);
          storingPooledCounts1(:,1) = currentPooledFeatureCountsSub1(featureInds);
          storingPooledCounts2(:,1) = currentPooledFeatureCountsSub2(featureInds);


          storingPooledCounts0Final(slots(f,:),i) = storingPooledCounts0;
          storingPooledCounts1Final(slots(f,:),i) = storingPooledCounts1;
          storingPooledCounts2Final(slots(f,:),i) = storingPooledCounts2;

        end


    %end

    disp('saving');
    

     filename0 = strcat('storingPooledCountsSub0_4ori_16_',featureType,'.mat');
     filename1 = strcat('storingPooledCountsSub1_4ori_16_',featureType,'.mat');
     filename2 = strcat('storingPooledCountsSub2_4ori_16_',featureType,'.mat');

    storingPooledCounts0Final = uint16(storingPooledCounts0Final);
    storingPooledCounts1Final = uint16(storingPooledCounts1Final);
    storingPooledCounts2Final = uint16 (storingPooledCounts2Final);


     cd('/home/margot/2DP_Pipeline/storedPooledCounts'); 

     save(filename0, 'storingPooledCounts0Final','-v7.3');
     save(filename1, "storingPooledCounts1Final",'-v7.3');
     save(filename2, "storingPooledCounts2Final",'-v7.3');


  end