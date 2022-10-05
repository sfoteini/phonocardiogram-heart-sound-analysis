function find_impulse_response(PCGrecording,diagnosis)
%FIND_IMPULSE_RESPONSE - Computes the impulse response and reconstructs the
% signal using Cepstrum.
%
%   find_impulse_response(PCGrecording,diagnosis)
%   
%   - PCGrecording   : file name of the PCG recording (based on the 
%                      database filename convention)
%   - diagnosis      : the dianosis of the PCG recording
    
    arguments
        PCGrecording (1,:) char
        diagnosis (1,:) char
    end

    % Init constants
    startLimit = 50; % min number of samples for the IR
    endLimit = 1000; % max number of samples for the IR
    step = 10;
    iterations = length(startLimit:step:endLimit);
    fc = 150; % butterworth cut-off frequency
    
    % Find training folder based on PCG recording's file name
    trainingFolder = char(PCGrecording);
    trainingFolder = trainingFolder(1);
    
    % Output path
    outputFolder = 'output\figures\';
    outputFileNameIR = strcat(outputFolder,PCGrecording, ...
        '-impulse-response','.png');
    outputFileNameReconstructed = strcat(outputFolder,PCGrecording, ...
        '-reconstructed','.png');
    
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
    y = signal(xlimsignal);
    
    % Compute the cepstrum
    % y = y .* hamming(length(y));
    [cepstrum,d] = cceps(y);
    nceps = length(cepstrum);
    
    % Compute the impulse response
    NRMSE = zeros(iterations,2);
    h_hat = zeros(nceps,1);
    
    for n = startLimit:step:endLimit
        h_hat(1:n) = cepstrum(1:n);
        h_hat(nceps-n+1:nceps) = cepstrum(nceps-n+1:nceps);
        inputCepstrum = cepstrum - h_hat;
        y_hat = conv(icceps(inputCepstrum,d),icceps(h_hat,d),'same');
        RMSE = sqrt(sum((y_hat-y).^2)/length(y));
        NRMSE((n-startLimit)/step+1,1) = RMSE/(max(y)-min(y));
        NRMSE((n-startLimit)/step+1,2) = n;
    end
    
    % Find the number of samples for the impulse response
    [~,i] = min(NRMSE(:,1));
    N = NRMSE(i,2);
    h_hat = zeros(nceps,1);
    h_hat(1:N) = cepstrum(1:N);
    h_hat(nceps-N+1:nceps) = cepstrum(nceps-N+1:nceps);
    inputCepstrum = cepstrum - h_hat;
    
    % Plot the impulse response and the reconstructed signal
    figure();
    plot((1:(2*N))/Fs, icceps(nonzeros(h_hat),d));
    xlabel('Time (s)');
    title(strcat('Impulse response (',diagnosis,')'));
    saveas(gcf,outputFileNameIR);
    
    figure();
    y_hat = conv(icceps(inputCepstrum,d),icceps((h_hat),d),'same');
    plot(xlimsignal/Fs,y_hat);
    hold on;
    plot(xlimsignal/Fs,y);
    xlim([xlimsignal(1)/Fs xlimsignal(end)/Fs])
    legend('Reconstructed Signal', 'Original Signal');
    xlabel('Time (s)');
    title(strcat('Signal synthesis using Cepstrum (',diagnosis,')'));
    saveas(gcf,outputFileNameReconstructed);
end