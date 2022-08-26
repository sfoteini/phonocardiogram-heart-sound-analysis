function [percentages] = check_kurtosis_test()
%CHECK_KURTOSIS_TEST - Calculates the percentage of 1s in each IMF for all
% the PCG recordings.
%
%   [percentages] = check_kurtosis_test()
%
%   - percentages : percentage of 1s in each IMF
    
    % Merge csv output files per database into one csv file
    merge_kurtosis_test_files()

    % Maximum number of IMFs extracted
    maxNumberOfIMF = 6;
    % Output path for data
    outputFolder = 'output\data\';
    
    % Open imf-kurtosis-test.csv file and import the data
    filePath = strcat(outputFolder,'imf-kurtosis-test.csv');
    opts = detectImportOptions(filePath);
    kurtosisTest = readtable(filePath,opts);
    kurtosisTest.Record = string(kurtosisTest.Record);
    
    % Calculate percentage of 1s in each IMF
    numOfRecords = size(kurtosisTest,1);
    percentages = zeros(maxNumberOfIMF,1);
    for i=1:maxNumberOfIMF
        percentages(i) = sum(table2array(kurtosisTest(:,i+1)))/numOfRecords*100;
    end
end

