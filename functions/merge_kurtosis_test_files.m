function merge_kurtosis_test_files()
%MERGE_KURTOSIS_TEST_FILES - Saves the output of the kurtosis-based 
% Gaussianity test of each database into a .csv file
%
%   merge_kurtosis_test_files()

    outputFolder = 'output\data';
    % Open .csv file for each databse and import the data
    % Database-a
    filePath = strcat(outputFolder,'\imf-kurtosis-test-a.csv');
    opts = detectImportOptions(filePath);
    kurtosisTestA = readtable(filePath,opts);
    % Database-b
    filePath = strcat(outputFolder,'\imf-kurtosis-test-b.csv');
    opts = detectImportOptions(filePath);
    kurtosisTestB = readtable(filePath,opts);
    % Database-c
    filePath = strcat(outputFolder,'\imf-kurtosis-test-c.csv');
    opts = detectImportOptions(filePath);
    kurtosisTestC = readtable(filePath,opts);
    % Database-d
    filePath = strcat(outputFolder,'\imf-kurtosis-test-d.csv');
    opts = detectImportOptions(filePath);
    kurtosisTestD = readtable(filePath,opts);
    % Database-e
    filePath = strcat(outputFolder,'\imf-kurtosis-test-e.csv');
    opts = detectImportOptions(filePath);
    kurtosisTestE = readtable(filePath,opts);
    % Database-f
    filePath = strcat(outputFolder,'\imf-kurtosis-test-f.csv');
    opts = detectImportOptions(filePath);
    kurtosisTestF = readtable(filePath,opts);
    
    % Create a table with the kurtosis test values for all PCG recordings 
    % and save it to a .csv file
    outputFileName = strcat(outputFolder,'\imf-kurtosis-test.csv');
    kurtosisTest = [kurtosisTestA; kurtosisTestB; kurtosisTestC;
                   kurtosisTestD;kurtosisTestE; kurtosisTestF];
    % Write data to file
    writetable(kurtosisTest,outputFileName);
end