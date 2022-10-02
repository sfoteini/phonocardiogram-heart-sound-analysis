function merge_pitch_files()
%MERGE_PITCH_FILES - Saves the pitch values extracted from
% the training data into a .csv file
%
%   merge_pitch_files()

    outputFolder = 'output\data';
    % Open .csv file for each databse and import the data
    % Database-a
    filePath = strcat(outputFolder,'\pitch-a.csv');
    opts = detectImportOptions(filePath);
    pitchA = readtable(filePath,opts);
    % Database-b
    filePath = strcat(outputFolder,'\pitch-b.csv');
    opts = detectImportOptions(filePath);
    pitchB = readtable(filePath,opts);
    % Database-c
    filePath = strcat(outputFolder,'\pitch-c.csv');
    opts = detectImportOptions(filePath);
    pitchC = readtable(filePath,opts);
    % Database-d
    filePath = strcat(outputFolder,'\pitch-d.csv');
    opts = detectImportOptions(filePath);
    pitchD = readtable(filePath,opts);
    % Database-e
    filePath = strcat(outputFolder,'\pitch-e.csv');
    opts = detectImportOptions(filePath);
    pitchE = readtable(filePath,opts);
    % Database-f
    filePath = strcat(outputFolder,'\pitch-f.csv');
    opts = detectImportOptions(filePath);
    pitchF = readtable(filePath,opts);
    
    % Create a table with the kurtosis test values for all PCG recordings 
    % and save it to a .csv file
    outputFileName = strcat(outputFolder,'\pitch.csv');
    pitch = [pitchA; pitchB; pitchC;
                   pitchD;pitchE; pitchF];
    % Write data to file
    writetable(pitch,outputFileName);
end