clear all
close all
%Formerly known as: testingFastCodeFromFrancis.m

%This will turn 64000 (16000x4) lmaxQuads into percentiles with a new
%percentiling technique which involves a percentiling per feature
%{
featureTypes = ["lmax_quads","lmax_triads" , "cr_e_c", "cr_e_e", "cr_e", "cr_e_s", "cr_od_c", "cr_od_e", "cr_od",  "cr_od_od","cr_od_s","cr_s","cr_s_s","od_c_c", "od_c", "od_c_s", "od_e_c", "od_e_e_3C2", "od_e_e", "od_e", "od_e_s", "od_od_c_3C2",... 
"od_od_c", "od_od_e_3C2", "od_od_e", "od_od", "od_od_s_3C2", "od_od_s", "od_s", "od_s_s", "cr_e_c_3C2", "cr_e_s_3C2", "cr_od_od_3C2"]
%}

%pooledDir = '/home/mel/four_orientations_experimental_features_jong_orig_db_post_50';
pooledDir = '/home/margot/2DP_Pipeline/storedPooledCountsImgNet'


% Auto-discover feature types from pooled0_*.mat files
pooledFiles = dir(fullfile(pooledDir, 'storingPooledCountsSub0_*.mat'));
featureTypes = string.empty;
for f = 1:numel(pooledFiles)
    name = pooledFiles(f).name;
    % Strip 'pooled0_' prefix and '.mat' suffix
    
    ft = extractAfter(name,'imgNetsum5ori_');
    ft = extractBefore(ft,'.mat');
    featureTypes(end+1) = ft;
end
subframes = ["0","1","2"];
for a = 1:length(featureTypes)
    featureType = featureTypes(a);
    for x = 1:3
        subframe = subframes(x);
        
        %featureType = featureTypes(f)
        %load("imageBinsSub0.mat","imageBins");
        %load("imageBinsSub1.mat","imageBins");
        load(strcat("imageBinsImageNet",subframe,".mat"),"binIndex");
        
        %load('storingPooledCountsSub0_4ori_newDets_lmaxQ.mat', 'storingPooledCounts0Final');
        %load('storingPooledCountsSub1_4ori_newDets_lmaxQ.mat', 'storingPooledCounts1Final');
        %load('storingPooledCountsSub2_4ori_newDets_lmaxQ.mat', 'storingPooledCounts2Final');
        %load(strcat('storingPooledCountsSub',subframe,'_4ori_newDets_lmaxQ.mat', 'storingPooledCounts2Final')
        
        %load(strcat('/Users/margotmel/Dropbox/Deep/',featureType,'64/storingPooledCountsSub',subframe,'_4ori_64_',featureType,'.mat'),strcat('storingPooledCounts',subframe,'Final'));
        %load(strcat('/home/margot/2DP_Pipeline/storedPooledCounts/storingPooledCountsSub',subframe,'_4ori_16_',featureType,'.mat'),strcat('storingPooledCounts',subframe,'Final'));
        %load(strcat('/home/mel/four_orientations_aws_data/pooled',subframe,'_',featureType,'.mat'),strcat('storingPooled',subframe))
        %load('/Users/margotmel/Dropbox/Deep/c_c_c_sub0_storingPooledCounts4kx4.mat','storingPooledCounts4kx4');
        load(strcat(pooledDir, '/storingPooledCountsSub', subframe, '_imgNetsum5ori_', featureType, '.mat'), strcat('storingPooledCounts', subframe,'Final'))
        numImages = 99878;
        numUniqueFeatures = 4000;
        numOrientations = 1;
        %fullPercentileArray = (zeros(numUniqueFeatures*numOrientations,numImages, 'single'));
        
        % for i = 1:numUniqueFeatures
        %     disp(i)
        %     %load(strcat('/Users/margotmel/Dropbox/Deep/lmaxFeatureWiseTables/lmaxPercentileTable',int2str(i),'.mat'), 'dicts')
        %     %load(strcat('/Users/margotmel/Dropbox/Deep/lmaxFeatureWiseTablesSub1/sub1lmaxPercentileTable',int2str(i),'.mat'), 'dicts')
        %     dicts = load(strcat('/Users/margotmel/Dropbox/Deep/lmaxFeatureWiseTablesSub2/sub2lmaxPercentileTable',int2str(i),'.mat')).dicts;
        %     indexOfOrientations = [i,i+(1*numUniqueFeatures),i+(2*numUniqueFeatures),i+(3*numUniqueFeatures)];
        %     %indexOfOrientations = [i,i+1,i+2,i+3];
        %     rawCountRows = storingPooledCounts2Final(indexOfOrientations, :);
        %     for p = 1:10
        %         dicts{p}(0) = 0;
        %         percentiledRows(:,imageBins==p) =  dicts{p}(rawCountRows(:,imageBins==p));
        %     end
        % 
        %     % fullPercentileArray(i,:)= single(percentiledRows(1,:));
        %     % fullPercentileArray(i+2,:)= single(percentiledRows(2,:));
        %     % fullPercentileArray(i+3,:)= single(percentiledRows(3,:));
        %     % fullPercentileArray(i+4,:)= single(percentiledRows(4,:));
        % 
        %     fullPercentileArray(indexOfOrientations,:)= single(percentiledRows);
        % 
        % end
        
        
        
        
        % Preallocate fullPercentileArray before parfor
        if subframe == "0"
            %fullPercentileArray = zeros(size(storingPooledCounts0Final), 'uint8'); 
            fullPercentileArray = zeros(size(storingPooledCounts0Final),'uint8');
        elseif subframe== "1"
            fullPercentileArray = zeros(size(storingPooledCounts1Final), 'uint8'); 
        elseif subframe == "2"    
            fullPercentileArray = zeros(size(storingPooledCounts2Final), 'uint8'); 
        end
        
        for i = 1:numUniqueFeatures
            disp(i);
            
            % Load dicts structure
            %dicts = load(strcat('/Users/margotmel/Dropbox/Deep/',featureType,'_smallFeatureWiseTablesSub',subframe,'/sub',subframe,featureType,'_smallPercentileTable', int2str(i), '.mat')).dicts;
            %dicts = load(strcat('/home/margot/2DP_Pipeline/FeatureWiseTables/',featureType,'FeatureWiseTablesSub',subframe,'/sub',subframe,featureType,'PercentileTable', int2str(i), '.mat')).dicts;
            dicts = load(strcat('/home/margot/2DP_Pipeline/FeatureWiseTablesImgNet/',featureType,'FeatureWiseTablesSub',subframe,'/sub',subframe,featureType,'PercentileTable', int2str(i), '.mat')).dicts;
            % Define index of orientations
            %indexOfOrientations = [i, i + numUniqueFeatures, i + (2 * numUniqueFeatures), i + (3 * numUniqueFeatures)];
            
            % Extract raw count rows
                if subframe == "0"
                    rawCountRows = storingPooledCounts0Final(i, :);
                elseif subframe == "1"
                    rawCountRows = storingPooledCounts1Final(i, :);
                elseif subframe == "2"
                    rawCountRows = storingPooledCounts2Final(i, :);
                end
            
            % Preallocate local storage for this iteration
            localPercentileData = zeros(size(rawCountRows), 'uint8'); 
            
            % Process each percentile bin
            for p = 1:10
                dicts{p}(0) = 0;  % Fix indexing issue (MATLAB uses 1-based indexing)
                mask = (binIndex == p);
                if any(mask) % Avoid empty indexing issues
                    localPercentileData(:, mask) = dicts{p}(rawCountRows(:, mask));
                end
            end
            
            % Store results in a cell array to prevent indexing conflicts
            %tempResults{i} = {indexOfOrientations, localPercentileData};
            fullPercentileArray(i,:) = localPercentileData;
        end
        
        % Assign values outside of parfor (safe for indexing)
        %for i = 1:numUniqueFeatures
        %    fullPercentileArray(tempResults{i}{1}, :) = tempResults{i}{2};
       % end
        
        
        %fullPercentileArray = fullPercentileArray(1:4000,:);
        save(strcat('/home/margot/2DP_Pipeline/2DP_arrays_ImgNet/', featureType, '2DP_Sub', subframe, '.mat'), ...
            'fullPercentileArray', '-v7.3');
    
        %save('s_c_cPercentilesNewMethodSub2.mat','fullPercentileArray')
        %save('lmaxPercentilesNewMethodSub1.mat','fullPercentileArray')
        %save('TESTlmaxPercentilesNewMethodSub2.mat','fullPercentileArray')
    end
end
