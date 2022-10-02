function pitch_estimation_cepstrum(trainingFolder)
%PITCH_ESTIMATION_CEPSTRUM - Computes the real cepstrum of a segment (3 
% cardiac cycles) of the original signal and estimates the pitch from the
% cepstrum.
%
%   pitch_estimation_cepstrum(trainingFolder)
%   
%   - trainingFolder : the name of the database (a, b, c, d, e, or f)
    
    arguments
        trainingFolder (1,:) char {mustBeMember(trainingFolder,{'a','b','c','d','e','f'})}
    end

    fclose('all');
    
    % Init constants
    fc = 150; % butterworth cut-off frequency
    Fs = 2000; % sampling frequency
    
    % Output path
    outputFolder = 'output\data\';
    outputFileName = strcat(outputFolder,'pitch-', ...
                trainingFolder,'.csv');
    if isfile(outputFileName)
        delete(outputFileName);
    end
    
    % Init table for saving the extracted bispectral features
    varTypes = cell(1,6);
    varTypes(1:2) = {'string'};
    varTypes(3) = {'int8'};
    varTypes(4:end) = {'double'};
    colNames = {'Record','Diagnosis','Class','Cepstrum_Pitch', ...
        'S1_S1_interval','Relative_percentage_error'};
    pitchTable = table('Size',[1 6],'VariableTypes',varTypes, ...
        'VariableNames',colNames);
    
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

        % Load annotation file and convert it to a table
        annot = importdata(strcat(folderAnnot,PCGsignal,'_StateAns.mat'));
        annot = cell2table(annot,'VariableNames',{'Sample','Section'});
        % Convert the second column to string
        annot.Section = string(annot.Section);

        % Find the S1 sections
        indexS1 = find(annot.Section == 'S1');
        % Find the number of the sample of the beginning of each S1 section
        S1_start = table2array(annot(indexS1,1));

        % Select part of the signal
        llimit = 1;ulimit = 4;
        xlimsignal = S1_start(llimit):S1_start(ulimit);
        y = signal(xlimsignal);

        % Compute and plot the real cepstrum
        rcepstrum = rceps(y);
        
        % Compute the pitch
        % Remove the first samples that correspond to the IR and use the
        % max function to calculate the quefrency of the first maximum peak
        range = [700 round(length(rcepstrum)/2)];
        [pks,locs] = findpeaks(rcepstrum(range(1):range(2)));
        locs = locs + range(1) - 1;
        [~,qindex] = max(pks);
        qindex = locs(qindex) / Fs;

        % Calculate the time difference between two consecutive S1 peaks
        % in the time-domain
        diff = S1_start(2:end) - S1_start(1:end-1);
        avg_diff = sum(diff) / length(diff);
        avg_diff = avg_diff / Fs;
        
        % Find the error between qindex and avg_diff
        error = abs(avg_diff - qindex) / avg_diff * 100;

        % Write data to .csv file
        pitchTable.Record = PCGsignal;
        pitchTable.Diagnosis = table2array(signals(i,2));
        pitchTable.Class = table2array(signals(i,3));
        pitchTable(:,4:end) = array2table([qindex,avg_diff,error]);
        writetable(pitchTable,outputFileName,'WriteMode','append');
    end
end