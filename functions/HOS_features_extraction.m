function HOS_features_extraction(trainingFolder,maxNumberOfIMF)
%HOS_FEATURES_EXTRACTION - Decomposes a PCG recording using Empirical Mode 
% Decomposition, calculates the skewness and kurtosis of the fundamental
% heart sounds (S1 and S2) and saves the extracted HOS-features in a .csv
% file
%
%   HOS_features_extraction(trainingFolder,maxNumberOfIMF)
%   
%   - trainingFolder : the name of the database (a, b, c, d, e, or f)
%   - maxNumberOfIMF : maximum number of IMFs extracted (default = 10)
    
    arguments
        trainingFolder (1,:) char {mustBeMember(trainingFolder,{'a','b','c','d','e','f'})}
        maxNumberOfIMF (1,1) {mustBeInteger,mustBePositive} = 10
    end

    fclose('all');
    
    % Constants
    nOfS1samples = 280;
    nOfS2samples = 220;
    
    % Output path
    outputFolder = 'output\data\';
    outputFileName = strcat(outputFolder,'features-training-', ...
            trainingFolder,'.csv');
    if isfile(outputFileName)
        delete(outputFileName);
    end
    
    % File paths for PCG signals and annotations
    folder = strcat('data\training-',trainingFolder,'\');
    folderAnnot = strcat('annotations\hand_corrected\training-', ...
            trainingFolder,'_StateAns\');
    
    % Open updated_appendix.csv file and import the data
    filePath = 'processed_data\updated_appendix.csv';
    opts = detectImportOptions(filePath);
    appendix = readtable(filePath,opts);
    appendix.Diagnosis = categorical(appendix.Diagnosis);
    appendix.Record = string(appendix.Record);
    
    % Get record names for the specified training folder
    TF = startsWith(appendix.Record,trainingFolder);
    lengthA = sum(TF);
    signals = appendix(TF,:);
    
    for i=1:lengthA
        % Read the PCG signal
        PCGsignal = table2array(signals(i,1));
        y = audioread(strcat(folder,PCGsignal,'.wav'));
        % Load annotation file and convert it to a table for easier access
        annot = importdata(strcat(folderAnnot,PCGsignal,'_StateAns.mat'));
        annot = cell2table(annot,'VariableNames',{'Sample','Section'});
        % Convert the second column to string
        annot.Section = string(annot.Section);
        % Find the Intrinsic Mode Functions IMF1, IMF2, ..., IMF7
        imf = emd(y,'MaxNumIMF',maxNumberOfIMF);
        
        % Find the S1 sections
        indexS1 = find(annot.Section == 'S1');
        % Find the diastole sections
        indexDiastole = find(annot.Section == 'diastole');
        % Keep only completed cardiac cycles
        if indexDiastole(1) < indexS1(1)
            indexDiastole = indexDiastole(2:end);
        end
        if indexS1(end) > indexDiastole(end)
            indexS1 = indexS1(1:end-1);
        end
        % Find the S2 sections
        indexS2 = find(annot.Section == 'S2');
        % Keep S2 sections inside the extracted cardiac cycles
        if indexS2(1) < indexS1(1)
            indexS2 = indexS2(2:end);
        end
        if indexS2(end) > indexDiastole(end)
            indexS2 = indexS2(1:end-1);
        end
        % Check if the last S2 section is complete
        if table2array(annot(indexS2(end),1))+nOfS2samples-1 > length(y)
            % Remove the last cardiac cycle
            indexS1 = indexS1(1:end-1);
            indexS2 = indexS2(1:end-1);
            indexDiastole = indexDiastole(1:end-1);
        end
        % Check if the number of S1 sections is different from the number
        % of S2 sections
        if length(indexS1) > length(indexS2)
            diff = length(indexS1) - length(indexS2);
            indexS1 = indexS1(1:end-diff);
        elseif length(indexS1) < length(indexS2)
            diff = length(indexS2) - length(indexS1);
            indexS2 = indexS2(1:end-diff);
        end

        % Find the number of the sample of the beginning of each S1 section
        S1_start = table2array(annot(indexS1,1));
        % Find the number of the sample of the beginning of each S2 section
        S2_start = table2array(annot(indexS2,1));
        % Find the number of the sample of the end of each cardiac cycle
        cc_end = zeros(length(S1_start),1);
        cc_end(1:end-1) = S1_start(2:end)-1;
        if indexDiastole(end) == size(annot,1)
            cc_end(end) = length(y);
        else
            cc_end(end) = table2array(annot(indexDiastole(end)+1,1))-1;
        end
        nOfCardiacCycles = length(cc_end);
        % Save the number of the sample of the beginning and the end of each
        % S1 section on an array
        % We assume that the duration of the S1 sound is 140ms (280 samples)
        S1 = [S1_start, S1_start+nOfS1samples-1];
        % Save the number of the sample of the beginning and the end of each
        % S2 section on an array
        % We assume that the duration of the S2 sound is 110ms (220 samples)
        S2 = [S2_start, S2_start+nOfS2samples-1];
        % Save the number of the sample of the beginning and the end of each
        % cardiac cycle section on an array
        %cardiac_cycle = [S1_start, cc_end];
    
        % Cut S1 sections from each IMF
        imf_S1 = zeros(nOfS1samples,nOfCardiacCycles,maxNumberOfIMF);
        for j=1:maxNumberOfIMF
            imf_j = imf(:,j);
            for k=1:nOfCardiacCycles
                imf_S1(:,k,j) = imf_j(S1(k,1):S1(k,2));
            end
        end
    
        % Cut S2 sections from each IMF
        imf_S2 = zeros(nOfS2samples,nOfCardiacCycles,maxNumberOfIMF);
        for j=1:maxNumberOfIMF
            imf_j = imf(:,j);
            for k=1:nOfCardiacCycles
                imf_S2(:,k,j) = imf_j(S2(k,1):S2(k,2));
            end
        end
    
        % Calculate skewness and kurtosis of S1 and S2
        % Allocate variables
        S1_skewness = zeros(nOfCardiacCycles,maxNumberOfIMF);
        S2_skewness = zeros(nOfCardiacCycles,maxNumberOfIMF);
        S1_kurtosis = zeros(nOfCardiacCycles,maxNumberOfIMF);
        S2_kurtosis = zeros(nOfCardiacCycles,maxNumberOfIMF);
    
        % Skewness and kurtosis
        for j=1:maxNumberOfIMF
            S1_skewness(:,j) = (skewness(imf_S1(:,:,j),0))';
            S2_skewness(:,j) = (skewness(imf_S2(:,:,j),0))';
            S1_kurtosis(:,j) = (kurtosis(imf_S1(:,:,j),0))';
            S2_kurtosis(:,j) = (kurtosis(imf_S2(:,:,j),0))';
        end
    
        % Create table from file
        features = array2table(S1_skewness);
        features = [features,array2table(S2_skewness)];
        features = [features,array2table(S1_kurtosis)];
        features = [features,array2table(S2_kurtosis)];
        features.Record(:) = PCGsignal;
        features.Diagnosis(:) = table2array(signals(i,2));
        features.Class(:) = table2array(signals(i,3));
    
        % Write data to file
        writetable(features,outputFileName,'WriteMode','append');
        clear features;
    end
end