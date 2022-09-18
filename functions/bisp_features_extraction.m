function bisp_features_extraction(trainingFolder)
%BISP_FEATURES_EXTRACTION - Decomposes a PCG recording using EMD, uses
% only the IMFs containing useful information concering the heart sounds 
% (S1, S2), computes the bispectrum of S1, S2 at each IMF and extracts the
% following features from the magnitude of the bispectrum in the region of
% interest: mean, standard deviation, minimum and maximum value, skewness,
% kurtosis, bispectral entropy and bispectral squared entropy.
%
%   bisp_features_extraction(trainingFolder)
%   
%   - trainingFolder : the name of the database (a, b, c, d, e, or f)
    
    arguments
        trainingFolder (1,:) char {mustBeMember(trainingFolder,{'a','b','c','d','e','f'})}
    end

    fclose('all');
    
    % Init constants
    nOfS1samples = 280; % number of s1 samples
    nOfS2samples = 220; % number of s2 samples
    fc = 150; % butterworth cut-off frequency
    Fs = 2000; % sampling frequency
    imfs = [1 2 3 4]; % useful IMFs
    maxNumberOfIMF = 6; %maximum number of IMFs extracted
    nOfUsefulIMFs = length(imfs); % number of useful IMFs
    nfft = 512; % length of fft for bispectrum
    wind = 0; % J=0 for bispectrum
    
    % Output path
    outputFolder = 'output\data\';
    outputFileName = strcat(outputFolder,'bisp-features-', ...
                trainingFolder,'.csv');
    if isfile(outputFileName)
        delete(outputFileName);
    end
    
    % Init table for saving the extracted bispectral features
    features = {'meanS1', 'meanS2','stdS1','stdS2','minS1','minS2', ...
                'maxS1','maxS2','skewnessS1','skewnessS2','kurtosisS1', ...
                'kurtosisS2','bispectralEntropyS1','bispectralEntropyS2', ...
                'bispectral2EntropyS1','bispectral2EntropyS2', ...
                'sumOfLogAmplDiagonal1','sumOfLogAmplDiagonal2'};
    nOfFeatures = length(features);
    varTypes = cell(1,nOfFeatures*nOfUsefulIMFs+3);
    varTypes(1:2) = {'string'};
    varTypes(3) = {'int8'};
    varTypes(4:end) = {'double'};
    colNames = cell(1,nOfFeatures*nOfUsefulIMFs+3);
    colNames(1:3) = {'Record','Diagnosis','Class'};
    for i = 1:nOfFeatures
        for j = 1:nOfUsefulIMFs
            colNames(4*i+j-1) = strcat(features(i),'_',int2str(imfs(j)));
        end
    end
    bispFeatures = table('Size',[1 nOfFeatures*nOfUsefulIMFs+3], ...
        'VariableTypes',varTypes,'VariableNames',colNames);
    
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
    
    for i = 1:lengthA
        % Read the PCG signal
        PCGsignal = table2array(signals(i,1));
        signal = audioread(strcat(folder,PCGsignal,'.wav'));
        % 3-rd order median filtering
        signal = medfilt1(signal,3);
        % Butterworth filter
        [b,a] = butter(10,fc/(Fs/2));
        % Data filtering
        signal = filter(b,a,signal);
        % Find the Intrinsic Mode Functions
        imf = emd(signal,'MaxNumIMF',maxNumberOfIMF);
    
        % Picking the first four IMFs, as the most significant
        imf = imf(:,imfs);
    
        % Load annotation file and convert it to a table
        annot = importdata(strcat(folderAnnot,PCGsignal,'_StateAns.mat'));
        annot = cell2table(annot,'VariableNames',{'Sample','Section'});
        % Convert the second column to string
        annot.Section = string(annot.Section);
    
        % Find the S1 sections
        indexS1 = find(annot.Section == 'S1');
        % Check if the last S1 section is complete
        if table2array(annot(indexS1(end),1))+nOfS1samples-1 > length(signal)
            % Remove the last S1 segment
            indexS1 = indexS1(1:end-1);
        end
        % Find the S2 sections
        indexS2 = find(annot.Section == 'S2');
        % Check if the last S2 section is complete
        if table2array(annot(indexS2(end),1))+nOfS2samples-1 > length(signal)
            % Remove the last S2 segment
            indexS2 = indexS2(1:end-1);
        end
    
        % Find the number of the sample of the beginning of each S1 section
        S1_start = table2array(annot(indexS1,1));
        % Find the number of the sample of the beginning of each S2 section
        S2_start = table2array(annot(indexS2,1));
    
        % Save the number of the sample of the beginning and the end of each
        % S1 section on an array
        % We assume that the duration of the S1 sound is 140ms (280 samples)
        S1 = [S1_start, S1_start+nOfS1samples-1];
        nOfS1segments = length(S1);
        % Save the number of the sample of the beginning and the end of each
        % S2 section on an array
        % We assume that the duration of the S2 sound is 110ms (220 samples)
        S2 = [S2_start, S2_start+nOfS2samples-1];
        nOfS2segments = length(S2);
    
        % Cut S1 sections from each IMF
        imf_S1 = zeros(nOfS1samples,nOfS1segments,nOfUsefulIMFs);
        for j=1:nOfUsefulIMFs
            imf_j = imf(:,j);
            for k=1:nOfS1segments
                imf_S1(:,k,j) = imf_j(S1(k,1):S1(k,2));
            end
        end
    
        % Cut S2 sections from each IMF
        imf_S2 = zeros(nOfS2samples,nOfS2segments,nOfUsefulIMFs);
        for j=1:nOfUsefulIMFs
            imf_j = imf(:,j);
            for k=1:nOfS2segments
                imf_S2(:,k,j) = imf_j(S2(k,1):S2(k,2));
            end
        end
    
        % HOS - Bispectrum
        % Init a table to sum the bispectra of each cardiac cycle for S1
        bspec1 = zeros(nfft,nfft,nOfUsefulIMFs);
        % Init a table to sum the bispectra of each cardiac cycle for S2
        bspec2 = zeros(nfft,nfft,nOfUsefulIMFs);
        for imfNum = 1:nOfUsefulIMFs
            % Bispectrum of S1 and S2
            bspec1(:,:,imfNum) = bispecd(imf_S1(:,:,imfNum),nfft, ...
                wind,nOfS1samples,0);
            bspec2(:,:,imfNum) = bispecd(imf_S2(:,:,imfNum),nfft, ...
                wind,nOfS2samples,0);
        end
        
        % Compute the region of interest of the bispectrum
        [bspec1Principal,bspec1DiagPrincipal] = bisp_principal_region( ...
            bspec1,Fs,fc);
        [bspec2Principal,bspec2DiagPrincipal] = bisp_principal_region( ...
            bspec2,Fs,fc);
    
        % Compute the magnitude of the bispectrum
        bspec1Principal = abs(bspec1Principal);
        bspec2Principal = abs(bspec2Principal);
        bspec1DiagPrincipal = abs(bspec1DiagPrincipal);
        bspec2DiagPrincipal = abs(bspec2DiagPrincipal);
    
        % Bispectral features extraction
        meanS1 = mean(bspec1Principal);
        meanS2 = mean(bspec2Principal);
        stdS1 = std(bspec1Principal);
        stdS2 = std(bspec2Principal);
        minS1 = min(bspec1Principal);
        minS2 = min(bspec2Principal);
        maxS1 = max(bspec1Principal);
        maxS2 = max(bspec2Principal);
        skewnessS1 = skewness(bspec1Principal);
        skewnessS2 = skewness(bspec2Principal);
        kurtosisS1 = kurtosis(bspec1Principal)-3;
        kurtosisS2 = kurtosis(bspec2Principal)-3;
        be1S1 = bispectral_entropy(bspec1Principal,1);
        be1S2 = bispectral_entropy(bspec2Principal,1);
        be2S1 = bispectral_entropy(bspec1Principal,2);
        be2S2 = bispectral_entropy(bspec2Principal,2);
        sumlogDiag1 = sum(log(bspec1DiagPrincipal));
        sumlogDiag2 = sum(log(bspec2DiagPrincipal));
    
        % Write data to .csv file
        bispFeatures.Record = PCGsignal;
        bispFeatures.Diagnosis = table2array(signals(i,2));
        bispFeatures.Class = table2array(signals(i,3));
        bispFeatures(:,4:end) = array2table([meanS1,meanS2,stdS1,stdS2, ...
            minS1,minS2,maxS1,maxS2,skewnessS1,skewnessS2,kurtosisS1, ...
            kurtosisS2,be1S1,be1S2,be2S1,be2S2,sumlogDiag1,sumlogDiag2]);
        writetable(bispFeatures,outputFileName,'WriteMode','append');
    end
end