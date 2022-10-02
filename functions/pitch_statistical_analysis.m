function pitch_statistical_analysis()
%PITCH_STATISTICAL_ANALYSIS - Computes the mean and the standard deviation
% of the pitch values.
%
%   pitch_statistical_analysis() 

    % Output path for data
    outputFolder = 'output\data\';
    
    % Open pitch.csv file and import the data
    filePath = strcat(outputFolder,'pitch.csv');
    opts = detectImportOptions(filePath);
    pitch = readtable(filePath,opts);
    pitch.Diagnosis = categorical(pitch.Diagnosis);
    pitch.Record = string(pitch.Record);
    % Helper variables
    colvar = size(pitch,2);
    
    % Calculate statistics (mean and standard deviation) of each pitch
    % value for each class (normal and abnormal) and pathology (AD,
    % AS, Benign, CAD, MPC, MR, MVP, Pathologic-Other)
    pitchMeanByClass = groupsummary(pitch, ...
        'Class','mean',4:colvar);
    pitchStdByClass = groupsummary(pitch, ...
        'Class','std',4:colvar);
    pitchMeanByDiagnosis = groupsummary(pitch, ...
        'Diagnosis','mean',4:colvar);
    pitchStdByDiagnosis = groupsummary(pitch, ...
        'Diagnosis','std',4:colvar);

    % Print statistics
    fprintf('\n\n----- STATISTICS BY CLASS (NORMAL, ABNORMAL) -----\n');
    fprintf('Mean value of pitch\n\n');
    disp(pitchMeanByClass);
    fprintf('Standard deviation of pitch\n\n');
    disp(pitchStdByClass);
    fprintf('\n\n----- STATISTICS BY DIAGNOSIS -----\n');
    fprintf('Mean value of pitch\n\n');
    disp(pitchMeanByDiagnosis);
    fprintf('Standard deviation of pitch\n\n');
    disp(pitchStdByDiagnosis);
    
    % Write data to file
    writetable(pitchMeanByClass, ...
        strcat(outputFolder,'pitch-mean-class.csv'));
    writetable(pitchStdByClass, ...
        strcat(outputFolder,'pitch-std-class.csv'));
    writetable(pitchMeanByDiagnosis, ...
        strcat(outputFolder,'pitch-mean-diagnosis.csv'));
    writetable(pitchStdByDiagnosis, ...
        strcat(outputFolder,'pitch-std-diagnosis.csv'));
end