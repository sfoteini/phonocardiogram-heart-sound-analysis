function plot_cepstrum(PCGrecording,diagnosis)
%PLOT_CEPSTRUM - Computes and plots the real cepstrum of a segment (3 
% cardiac cycles) of the original signal and estimates the pitch from the
% cepstrum.
%
%   plot_cepstrum(PCGrecording,diagnosis)
%   
%   - PCGrecording   : file name of the PCG recording (based on the 
%                      database filename convention)
%   - diagnosis      : the dianosis of the PCG recording

    arguments
        PCGrecording (1,:) char
        diagnosis (1,:) char
    end

    % Init constants
    fc = 150; % butterworth cut-off frequency
    
    % Find training folder based on PCG recording's file name
    trainingFolder = char(PCGrecording);
    trainingFolder = trainingFolder(1);
    
    % Output path
    outputFolder = 'output\figures\';
    outputFileName = strcat(outputFolder,PCGrecording,'-cepstrum','.png');
    
    % File paths for PCG signals and annotations
    folder = strcat('data\training-',trainingFolder,'\');
    folderAnnot = strcat('annotations\hand_corrected\training-', ...
            trainingFolder,'_StateAns\');
    
    % Read the PCG signal
    if isfile(strcat(folder,PCGrecording,'.wav'))
        [signal,Fs] = audioread(strcat(folder,PCGrecording,'.wav'));
    else
        fprintf("PCG recording filename is invalid! Exit...\n");
        return;
    end
    
    % Filtering the signal
    % 3-rd order median filtering
    signal = medfilt1(signal,3);
    % Butterworth filter
    [b,a] = butter(10,fc/(Fs/2));
    % Data filtering
    signal = filter(b,a,signal);
    
    % Load annotation file and convert it to a table
    annot = importdata(strcat(folderAnnot,PCGrecording,'_StateAns.mat'));
    annot = cell2table(annot,'VariableNames',{'Sample','Section'});
    % Convert the second column to string
    annot.Section = string(annot.Section);
    
    % Find the S1 sections
    indexS1 = find(annot.Section == 'S1');
    % Find the number of the sample of the beginning of each S1 section
    S1_start = table2array(annot(indexS1,1));
    
    % Select part of the signal
    llimit = 2;ulimit = 5;
    xlimsignal = S1_start(llimit):S1_start(ulimit);
    annotS1 = indexS1(llimit):4:indexS1(ulimit);
    annotS2 = (indexS1(llimit)+2):4:(indexS1(ulimit-1)+2);
    y = signal(xlimsignal);
    
    % Compute and plot the real cepstrum
    rcepstrum = rceps(y);
    
    % Compute the pitch
    % Remove the first samples that correspond to the IR and use the max
    % function to calculate the quefrency of the first maximum peak
    range = [1350 round(length(rcepstrum)/2)];
    [pks,locs] = findpeaks(rcepstrum(range(1):range(2)), ...
        "MinPeakHeight",0.7*max(rcepstrum(range(1):range(2))));
    locs = locs + range(1) - 1;
    [~,qindex] = max(pks);
    qindex = locs(qindex) / Fs;
    
    % Calculate the time difference between two consecutive S1 peaks in the
    % time-domain
    diff = S1_start(2:end) - S1_start(1:end-1);
    avg_diff = sum(diff) / length(diff);
    avg_diff = avg_diff / Fs;
    
    % Find the error between qindex and avg_diff
    error = abs(avg_diff - qindex) / avg_diff * 100;
    
    % Print the results
    fprintf("Pitch estimated from bispectrum: %.4f\n" + ...
        "Time difference between 2 consecutive S1 peaks in " + ...
        "the time-domain: %.4f\n" + ...
        "Relative error: %.4f%",qindex,avg_diff,error);
    fprintf("\n");
    
    % Plot original signal, real cepstrum and prominent peaks
    figure();
    t = tiledlayout(2,1,'TileSpacing','tight','Padding','compact');
    % Plot the signal
    ax1 = nexttile;
    plot(xlimsignal/Fs,y);
    hold on;
    xline([annot{annotS1,1}]/Fs,'-','Color','#D95319','LineWidth',1);
    xline([annot{annotS2,1}]/Fs,'-','Color','#77AC30','LineWidth',1);
    xlim([xlimsignal(1)/Fs xlimsignal(end)/Fs]);
    xlabel('Time (s)');
    title('Original signal');
    % Plot real cepstrum
    ax2 = nexttile;
    quefrency = (0:length(y)-1)/Fs;
    plot(quefrency,rcepstrum);
    hold on;
    plot(locs/Fs,pks,'v','LineWidth',1.5);
    xlabel('Quefrency (s)');
    title('Real Cepstrum');
    % Figure title
    title(t,strcat("Pitch estimation from cepstrum (",diagnosis,")"));
    % Save figure to image file
    saveas(gcf,outputFileName);
end