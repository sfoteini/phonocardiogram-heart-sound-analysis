function IMF_extraction(trainingFolder)
%IMF_EXTRACTION - Decomposes a PCG recording using Empirical Mode 
% Decosmposition and extracts the IMFs containing useful information 
% concering the heart sounds (S1, S2) using a kurtosis-based Gaussianity
% test.
%
%   IMF_extraction(trainingFolder)
%   
%   - trainingFolder : the name of the database (a, b, c, d, e, or f)

    arguments
        trainingFolder (1,:) char {mustBeMember(trainingFolder,{'a','b','c','d','e','f'})}
    end

    fclose('all');
    
    % Maximum number of IMFs extracted
    maxNumberOfIMF = 6;
    % Butterworth filter cut-off frequency
    fc = 150;
    % Sampling frequency of PCG signals
    Fs = 2000;
    
    % Output paths
    outputFolder = 'output\data\';
    outputFileNameKurtosis = strcat(outputFolder,'imf-kurtosis-', ...
            trainingFolder,'.csv');
    if isfile(outputFileNameKurtosis)
        delete(outputFileNameKurtosis);
    end
    outputFileNameTest = strcat(outputFolder,'imf-kurtosis-test-', ...
            trainingFolder,'.csv');
    if isfile(outputFileNameTest)
        delete(outputFileNameTest);
    end
    
    % Init table for saving kurtosis values per IMF
    varTypesKur = cell(1,maxNumberOfIMF+1);
    varTypesKur(1) = {'string'};
    varTypesKur(2:maxNumberOfIMF+1) = {'double'};
    colNamesKur = cell(1,maxNumberOfIMF+1);
    colNamesKur(1) = {'Record'};
    for imfNum = 1:maxNumberOfIMF
        colNamesKur(imfNum+1) = {strcat('Kurtosis_IMF',int2str(imfNum))};
    end
    kurt = table('Size',[1 maxNumberOfIMF+1],'VariableTypes',varTypesKur, ...
        'VariableNames',colNamesKur);
    
    % Init table for saving kurtosis-based Gaussianity test values per IMF
    varTypesTest = cell(1,maxNumberOfIMF+1);
    varTypesTest(1) = {'string'};
    varTypesTest(2:maxNumberOfIMF+1) = {'int8'};
    colNamesTest = cell(1,maxNumberOfIMF+1);
    colNamesTest(1) = {'Record'};
    for imfNum = 1:maxNumberOfIMF
        colNamesTest(imfNum+1) = {strcat('Check_IMF',int2str(imfNum))};
    end
    kurtTest = table('Size',[1 maxNumberOfIMF+1],'VariableTypes',varTypesTest, ...
        'VariableNames',colNamesTest);
    
    % File path for PCG signals
    folder = strcat('data\training-',trainingFolder,'\');
    
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
        signal = audioread(strcat(folder,PCGsignal,'.wav'));
        % 3-rd order median filtering
        signal = medfilt1(signal,3);
        % Butterworth filter
        [b,a] = butter(10,fc/(Fs/2));
        % Data filtering
        signal = filter(b,a,signal);
        % Find the Intrinsic Mode Functions
        imf = emd(signal,'MaxNumIMF',maxNumberOfIMF);
    
        % Kurtosis-based Gaussianity test
        [imfKurtosis,test] = kurtosis_test(imf);
    
        % Write data to .csv file
        kurt.Record = PCGsignal;
        kurt(:,2:end) = array2table(imfKurtosis);
        writetable(kurt,outputFileNameKurtosis,'WriteMode','append');
    
        kurtTest.Record = PCGsignal;
        kurtTest(:,2:end) = array2table(test);
        writetable(kurtTest,outputFileNameTest,'WriteMode','append');
    end
end