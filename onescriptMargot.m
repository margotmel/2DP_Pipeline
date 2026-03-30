
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

    %Formerly known as organizingFeatureCountsFrancisNewDetections.m

    % These will be the orientations to cycle through for each feature
    a = zeros(4, 6);



    a(1,:) = 1:6;
    a(2,:) = a(1,:) + 6;
    a(3,:) = a(2,:) + 6;
    a(4,:) = a(3, :)+ 6;


    numFeatures = 1000;
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
        %featureType = 'od_od_e'
        featureType = featureTypes(featTypeIndex)
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
        for i = 1:numImages
        if mod(i,100) == 1
            disp(i)
        end
            %disp(strcat(int2str(i),int2str(x)));
            currentFile = load(allImages(i).name);
            
            %currentPooledFeatureCounts = currentFile.l2pool_0;
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
        
            featureInds = sub2ind([24,numberOfFeatures],movingOris(f,:),1:numberOfFeatures);
                
            storingPooledCounts0(:,1) = currentPooledFeatureCountsSub0(featureInds);
            storingPooledCounts1(:,1) = currentPooledFeatureCountsSub1(featureInds);
            storingPooledCounts2(:,1) = currentPooledFeatureCountsSub2(featureInds);


            storingPooledCounts0Final(slots(f,:),i) = storingPooledCounts0;
            storingPooledCounts1Final(slots(f,:),i) = storingPooledCounts1;
            storingPooledCounts2Final(slots(f,:),i) = storingPooledCounts2;

            end


        end

        disp('saving');
        

        filename0 = strcat('storingPooledCountsSub0_4ori_16_',featureTypes(featTypeIndex),'.mat');
        filename1 = strcat('storingPooledCountsSub1_4ori_16_',featureTypes(featTypeIndex),'.mat');
        filename2 = strcat('storingPooledCountsSub2_4ori_16_',featureTypes(featTypeIndex),'.mat');

        storingPooledCounts0Final = uint16(storingPooledCounts0Final);
        storingPooledCounts1Final = uint16(storingPooledCounts1Final);
        storingPooledCounts2Final = uint16 (storingPooledCounts2Final);


        cd('/home/margot/2DP_Pipeline/storedPooledCounts'); 

        save(filename0, 'storingPooledCounts0Final','-v7.3');
        save(filename1, "storingPooledCounts1Final",'-v7.3');
        save(filename2, "storingPooledCounts2Final",'-v7.3');


        %next step
        cd('/home/margot/2DP_Pipeline')
        
        %Formerly known as FrancisBuildingPercentileTablesFast.m
        %making featurewise percentile tables for 16000 lmax quads
        
        numImages = 68200;
        %subframe = "2";
        
        %featureType = "od_e_s";
        subframes = ["0","1","2"];
        
        for x = 1:3
            
            %load('storingPooledCountsSub0_4ori_newDets_lmaxQ.mat', 'storingPooledCounts0Final');
            %load('storingPooledCountsSub1_4ori_newDets_lmaxQ.mat', 'storingPooledCounts1Final');
            %load('storingPooledCountsSub2_4ori_newDets_lmaxQ.mat', 'storingPooledCounts2Final');
            
            subframe = subframes(x);
            %load(strcat('/Users/margotmel/Dropbox/Deep/',featureType,'64/storingPooledCountsSub',subframe,'_4ori_64_',featureType,'.mat'),strcat('storingPooledCounts',subframe,'Final'))
            load(strcat('/home/margot/2DP_Pipeline/storedPooledCounts/storingPooledCountsSub',subframe,'_4ori_16_',featureTypes(featTypeIndex),'.mat'),strcat('storingPooledCounts',subframe,'Final'))
            %load('Users/margotmel/Dropbox/Deep/c_c_c_sub0_storingPooledCounts4kx4.mat','storingPooledCounts4kx4')
            disp("loaded")
            
            if subframe == "0"
                load('sumtotalFeatureCountsSub0.mat','sumtotalFeatureCounts')
            else
                load(strcat('sumTotalFeatureCountsSub',subframe,'.mat'),'sumtotalFeatureCounts')
                %load('sumTotalFeatureCountsSub2.mat','sumtotalFeatureCounts')
            end
            
            numUniqueFeatures = 4000;
            numOrientations = 4;
            totalFeatures  = numUniqueFeatures*numOrientations;
            
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
            % 
            % imageBins = zeros(1,numImages);
            % for b = 1:numel(bins)-1
            %     imageBins((sumtotalFeatureCounts>bins(b))&(sumtotalFeatureCounts<bins(b+1))) = b;
            % end
            
            %save('imageBinsSub0.mat','imageBins')
            %save('imageBinsSub1.mat','imageBins')
            %save('imageBinsSub2.mat','imageBins')
            
            load(strcat('imageBinsSub',subframe,'.mat'),'imageBins');
            
            %1555
            for i = 1:numUniqueFeatures
                disp(i)
                indexOfOrientations = [i,i+(1*numUniqueFeatures),i+(2*numUniqueFeatures),i+(3*numUniqueFeatures)];
                %rawCountRows = storingPooledCounts0Final(indexOfOrientations, :);
                %rawCountRows = storingPooledCounts1Final(indexOfOrientations, :);
                %rawCountRows = storingPooledCounts2Final(indexOfOrientations, :);
                if subframe == "0"
                    rawCountRows = storingPooledCounts0Final(indexOfOrientations, :);
                    %rawCountRows = storingPooledCounts4kx4(indexOfOrientations, :);
                elseif subframe == "1"
                    rawCountRows = storingPooledCounts1Final(indexOfOrientations, :);
                elseif subframe == "2"
                    rawCountRows = storingPooledCounts2Final(indexOfOrientations, :);
                end
                
                dicts = cell(1, 10);
                
            
                for p = 1:numel(bins)-1
            
                
                    countsToMakeTable = rawCountRows(:,imageBins==p);
                    sortedRawCounts = sort(countsToMakeTable(:));
                    truncSortedRawCounts = sortedRawCounts(sortedRawCounts>0);
                    
                    if length(truncSortedRawCounts)>0
                    
                        featureCountTempTable = [];
                        [g,ia,ic] = unique(truncSortedRawCounts);
                    
                        %this corresponds to the number of occurences of each count
                        iaDiff = diff(ia);
                    
                        %dealing with the last count manually
                        finalCount = (length(truncSortedRawCounts) - ia(length(ia)))+1;
                    
                        iaDiff = [iaDiff; finalCount];
                        
                        %these are the percentiles all calculated at once
                        c = 100*((ia-1)+(0.5*iaDiff))/length(truncSortedRawCounts);
                        
                        featureCountTempTable(:,1) = g';
                        featureCountTempTable(:,2) = c;
                    
                        d = dictionary(featureCountTempTable(:,1), featureCountTempTable(:,2));
                        
                        
                        counts = d.keys;
                        percs = d.values;
                        
                
                        %need to reinstantiate newy - check other programs for this
                        %mistake
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
                        
                        %need to deal with last case and first case separately
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
                
                %fileName = strcat('/Users/margotmel/Dropbox/Deep/',featureType,'FeatureWiseTablesSub',subframe,'/sub',subframe,featureType,'PercentileTable',int2str(i),'.mat');
                %save(fileName, 'dicts')
        
                %save(strcat('/Users/margotmel/Dropbox/Deep/',featureType,'FeatureWiseTablesSub',subframe,'/sub',subframe,featureType,'PercentileTable',int2str(i),'.mat'),'dicts')
                %save(strcat('/Users/margotmel/Dropbox/Deep/lmaxFeatureWiseTables/lmaxPercentileTable',int2str(i), '.mat'),'dicts')
                %save(strcat('/Users/margotmel/Dropbox/Deep/lmaxFeatureWiseTablesSub1/sub1lmaxPercentileTable',int2str(i), '.mat'),'dicts')
                %save(strcat('/Users/margotmel/Dropbox/Deep/lmaxFeatureWiseTablesSub2/sub2lmaxPercentileTable',int2str(i), '.mat'),'dicts')
        
                % Define the full file path
                filePath = strcat('/home/margot/2DP_Pipeline/FeatureWiseTables/',featureTypes(featTypeIndex),'FeatureWiseTablesSub',subframe,'/sub',subframe,featureType,'PercentileTable',int2str(i),'.mat');
        
                % Extract the directory from the file path
                [dirPath, ~, ~] = fileparts(filePath);
        
                % Create directory if it doesn't exist
                if ~exist(dirPath, 'dir')
                    mkdir(dirPath);
                end
        
                % Save the file
                save(filePath,'dicts')
            end
        
        end
        
        
        cd('/home/margot/2DP_Pipeline')
        %Formerly known as: testingFastCodeFromFrancis.m
        
        %This will turn 64000 (16000x4) lmaxQuads into percentiles with a new
        %percentiling technique which involves a percentiling per feature
        
        subframes = ["0","1","2"];
        
        for x = 1:3
            subframe = subframes(x);
            %featureType = "od_od_c";
            %load("imageBinsSub0.mat","imageBins");
            %load("imageBinsSub1.mat","imageBins");
            load(strcat("imageBinsSub",subframe,".mat"),"imageBins");
            
            %load('storingPooledCountsSub0_4ori_newDets_lmaxQ.mat', 'storingPooledCounts0Final');
            %load('storingPooledCountsSub1_4ori_newDets_lmaxQ.mat', 'storingPooledCounts1Final');
            %load('storingPooledCountsSub2_4ori_newDets_lmaxQ.mat', 'storingPooledCounts2Final');
            %load(strcat('storingPooledCountsSub',subframe,'_4ori_newDets_lmaxQ.mat', 'storingPooledCounts2Final')
            
            %load(strcat('/Users/margotmel/Dropbox/Deep/',featureType,'64/storingPooledCountsSub',subframe,'_4ori_64_',featureType,'.mat'),strcat('storingPooledCounts',subframe,'Final'));
            load(strcat('/home/margot/2DP_Pipeline/storedPooledCounts/storingPooledCountsSub',subframe,'_4ori_16_',featureType,'.mat'),strcat('storingPooledCounts',subframe,'Final'));
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
                %fullPercentileArray = zeros(size(storingPooledCounts0Final), 'uint16'); 
                fullPercentileArray = zeros(size(storingPooledCounts0Final),'uint16');
            elseif subframe== "1"
                fullPercentileArray = zeros(size(storingPooledCounts1Final), 'uint16'); 
            elseif subframe == "2"    
                fullPercentileArray = zeros(size(storingPooledCounts2Final), 'uint16'); 
            end
            
            for i = 1:numUniqueFeatures
                disp(i);
                
                % Load dicts structure
                %dicts = load(strcat('/Users/margotmel/Dropbox/Deep/',featureType,'_smallFeatureWiseTablesSub',subframe,'/sub',subframe,featureType,'_smallPercentileTable', int2str(i), '.mat')).dicts;
                dicts = load(strcat('/home/margot/2DP_Pipeline/FeatureWiseTables/',featureType,'FeatureWiseTablesSub',subframe,'/sub',subframe,featureType,'PercentileTable', int2str(i), '.mat')).dicts;
                % Define index of orientations
                indexOfOrientations = [i, i + numUniqueFeatures, i + (2 * numUniqueFeatures), i + (3 * numUniqueFeatures)];
                
                % Extract raw count rows
                if subframe =="0"
                    rawCountRows = storingPooledCounts0Final(indexOfOrientations, :);
                    %rawCountRows = storingPooledCounts4kx4(indexOfOrientations,:);
                elseif subframe == "1"
                    rawCountRows = storingPooledCounts1Final(indexOfOrientations, :);
                elseif subframe == "2"
                    rawCountRows = storingPooledCounts2Final(indexOfOrientations, :);
                end
                
                % Preallocate local storage for this iteration
                localPercentileData = zeros(size(rawCountRows), 'uint16'); 
                
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
            
            
            save(strcat('/home/margot/2DP_Pipeline/2DP_arrays/', featureType, '4kPercentilesNewMethodSub', subframe, '.mat'), ...
                'fullPercentileArray', '-v7.3');
            
            %save('s_c_cPercentilesNewMethodSub2.mat','fullPercentileArray')
            %save('lmaxPercentilesNewMethodSub1.mat','fullPercentileArray')
            %save('TESTlmaxPercentilesNewMethodSub2.mat','fullPercentileArray')
        end
    end