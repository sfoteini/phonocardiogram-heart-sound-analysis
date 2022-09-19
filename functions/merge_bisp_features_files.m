function merge_bisp_features_files()
%MERGE_BISP_FEATURES_FILES - Saves the bispectral features extracted from
% the training data into a .csv file
%
%   merge_bisp_features_files()

    outputFolder = 'output\data';
    % Open .csv file for each databse and import the data
    % Database-a
    filePath = strcat(outputFolder,'\bisp-features-a.csv');
    opts = detectImportOptions(filePath);
    bispFeaturesA = readtable(filePath,opts);
    % Database-b
    filePath = strcat(outputFolder,'\bisp-features-b.csv');
    opts = detectImportOptions(filePath);
    bispFeaturesB = readtable(filePath,opts);
    % Database-c
    filePath = strcat(outputFolder,'\bisp-features-c.csv');
    opts = detectImportOptions(filePath);
    bispFeaturesC = readtable(filePath,opts);
    % Database-d
    filePath = strcat(outputFolder,'\bisp-features-d.csv');
    opts = detectImportOptions(filePath);
    bispFeaturesD = readtable(filePath,opts);
    % Database-e
    filePath = strcat(outputFolder,'\bisp-features-e.csv');
    opts = detectImportOptions(filePath);
    bispFeaturesE = readtable(filePath,opts);
    % Database-f
    filePath = strcat(outputFolder,'\bisp-features-f.csv');
    opts = detectImportOptions(filePath);
    bispFeaturesF = readtable(filePath,opts);
    
    % Create a table with the kurtosis test values for all PCG recordings 
    % and save it to a .csv file
    outputFileName = strcat(outputFolder,'\bisp-features.csv');
    bispFeatures = [bispFeaturesA; bispFeaturesB; bispFeaturesC;
                   bispFeaturesD;bispFeaturesE; bispFeaturesF];
    % Write data to file
    writetable(bispFeatures,outputFileName);
end