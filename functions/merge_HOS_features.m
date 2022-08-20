function merge_HOS_features()
%MERGE_HOS_FEATURES - Saves the HOS-features extracted from the training
% data into a .csv file
%
%   merge_HOS_features()
    
    outputFolder = 'output\data';
    % Open .csv file for each databse and import the data
    % Database-a
    filePath = strcat(outputFolder,'\features-training-a.csv');
    opts = detectImportOptions(filePath);
    hosFeaturesA = readtable(filePath,opts);
    % Database-b
    filePath = strcat(outputFolder,'\features-training-b.csv');
    opts = detectImportOptions(filePath);
    hosFeaturesB = readtable(filePath,opts);
    % Database-c
    filePath = strcat(outputFolder,'\features-training-c.csv');
    opts = detectImportOptions(filePath);
    hosFeaturesC = readtable(filePath,opts);
    % Database-d
    filePath = strcat(outputFolder,'\features-training-d.csv');
    opts = detectImportOptions(filePath);
    hosFeaturesD = readtable(filePath,opts);
    % Database-e
    filePath = strcat(outputFolder,'\features-training-e.csv');
    opts = detectImportOptions(filePath);
    hosFeaturesE = readtable(filePath,opts);
    % Database-f
    filePath = strcat(outputFolder,'\features-training-f.csv');
    opts = detectImportOptions(filePath);
    hosFeaturesF = readtable(filePath,opts);
    
    % Create a table with the HOS-features for all PCG recordings and save it
    % to a .csv file
    outputFileName = strcat(outputFolder,'\hos-features.csv');
    hosFeatures = [hosFeaturesA; hosFeaturesB; hosFeaturesC; hosFeaturesD;
                   hosFeaturesE; hosFeaturesF];
    % Write data to file
    writetable(hosFeatures,outputFileName);
end