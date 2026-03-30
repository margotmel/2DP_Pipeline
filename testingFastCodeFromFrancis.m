clear all
close all
%Formerly known as: testingFastCodeFromFrancis.m

%This will turn 64000 (16000x4) lmaxQuads into percentiles with a new
%percentiling technique which involves a percentiling per feature

featureTypes = ["cr_e_c_3C2"];
subframes = ["0","1","2"];
for a = 1:length(featureTypes)
    try
        featureType = featureTypes(a);
        for x = 1:3
            subframe = subframes(x);

            %featureType = featureTypes(f)
            %load("imageBinsSub0.mat","imageBins");
            %load("imageBinsSub1.mat","imageBins");
            load(strcat("imageBinsSub",subframe,".mat"),"imageBins");

            %load('storingPooledCountsSub0_4ori_newDets_lmaxQ.mat', 'storingPooledCounts0Final');
            %load('storingPooledCountsSub1_4ori_newDets_lmaxQ.mat', 'storingPooledCounts1Final');
            %load('storingPooledCountsSub2_4ori_newDets_lmaxQ.mat', 'storingPooledCounts2Final');
            %load(strcat('storingPooledCountsSub',subframe,'_4ori_newDets_lmaxQ.mat', 'storingPooledCounts2Final')

            %load(strcat('/Users/margotmel/Dropbox/Deep/',featureType,'64/storingPooledCountsSub',subframe,'_4ori_64_',featureType,'.mat'),strcat('storingPooledCounts',subframe,'Final'));
            %load(strcat('/home/margot/2DP_Pipeline/storedPooledCounts/storingPooledCountsSub',subframe,'_4ori_16_',featureType,'.mat'),strcat('storingPooledCounts',subframe,'Final'));
            load(strcat('/home/mel/four_orientations_aws_data/pooled',subframe,'_',featureType,'.mat'),strcat('storingPooled',subframe))
            %load('/Users/margotmel/Dropbox/Deep/c_c_c_sub0_storingPooledCounts4kx4.mat','storingPooledCounts4kx4');
            numImages = 68200;
            numUniqueFeatures = 4000;
            numOrientations = 4;
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
                fullPercentileArray = zeros(size(storingPooled0),'uint8');
            elseif subframe== "1"
                fullPercentileArray = zeros(size(storingPooled1), 'uint8');
            elseif subframe == "2"
                fullPercentileArray = zeros(size(storingPooled2), 'uint8');
            end

            for i = 1:numUniqueFeatures
                disp(i);

                % Load dicts structure
                %dicts = load(strcat('/Users/margotmel/Dropbox/Deep/',featureType,'_smallFeatureWiseTablesSub',subframe,'/sub',subframe,featureType,'_smallPercentileTable', int2str(i), '.mat')).dicts;
                %dicts = load(strcat('/home/margot/2DP_Pipeline/FeatureWiseTables/',featureType,'FeatureWiseTablesSub',subframe,'/sub',subframe,featureType,'PercentileTable', int2str(i), '.mat')).dicts;
                dicts = load(strcat('/home/margot/2DP_Pipeline/FeatureWiseTablesNewBatch/',featureType,'FeatureWiseTablesSub',subframe,'/sub',subframe,featureType,'PercentileTable', int2str(i), '.mat')).dicts;
                % Define index of orientations
                indexOfOrientations = [i, i + numUniqueFeatures, i + (2 * numUniqueFeatures), i + (3 * numUniqueFeatures)];

                % Extract raw count rows
                if subframe =="0"
                    rawCountRows = storingPooled0(indexOfOrientations, :);
                    %rawCountRows = storingPooledCounts4kx4(indexOfOrientations,:);
                elseif subframe == "1"
                    rawCountRows = storingPooled1(indexOfOrientations, :);
                elseif subframe == "2"
                    rawCountRows = storingPooled2(indexOfOrientations, :);
                end

                % Preallocate local storage for this iteration
                localPercentileData = zeros(size(rawCountRows), 'uint8');

                % Process each percentile bin
                for p = 1:10
                    dicts{p}(0) = 0;  % Fix indexing issue (MATLAB uses 1-based indexing)
                    mask = (imageBins == p);
                    if any(mask) % Avoid empty indexing issues
                        localPercentileData(:, mask) = dicts{p}(rawCountRows(:, mask));
                    end
                end

                % Store results in a cell array to prevent indexing conflicts
                tempResults{i} = {indexOfOrientations, localPercentileData};
            end

            % Assign values outside of parfor (safe for indexing)
            for i = 1:numUniqueFeatures
                fullPercentileArray(tempResults{i}{1}, :) = tempResults{i}{2};
            end


            fullPercentileArray = fullPercentileArray(1:4000,:);
            save(strcat('/home/mel/2DP_results_for_orig_db/', featureType, '2DP_Sub', subframe, '.mat'), ...
                'fullPercentileArray', '-v7.3');

            %save('s_c_cPercentilesNewMethodSub2.mat','fullPercentileArray')
            %save('lmaxPercentilesNewMethodSub1.mat','fullPercentileArray')
            %save('TESTlmaxPercentilesNewMethodSub2.mat','fullPercentileArray')
        end
    catch

    end
end
