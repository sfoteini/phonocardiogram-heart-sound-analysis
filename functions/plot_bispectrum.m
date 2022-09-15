function plot_bispectrum(PCGrecording,diagnosis)
%PLOT_BISPECTRUM - Decomposes a PCG recording using Empirical Mode 
% Decomposition and plots the bispectrum of S1, S2 fundamental heart sounds
% from the extracted IMFs.
%
%   plot_bispectrum(PCGrecording,diagnosis)
%   
%   - PCGrecording   : file name of the PCG recording (based on the 
%                      database filename convention)
%   - diagnosis      : the dianosis of the PCG recording

    arguments
        PCGrecording (1,:) char
        diagnosis (1,:) char
    end

    % Init constants
    nOfS1samples = 280; % number of s1 samples
    nOfS2samples = 220; % number of s2 samples
    fc = 150; % butterworth cut-off frequency
    imfs = [1 2 3 4]; % useful IMFs
    maxNumberOfIMF = 6; %maximum number of IMFs extracted
    nOfUsefulIMFs = length(imfs); % number of useful IMFs
    nfft = 512; % length of fft for bispectrum
    wind = 0; % J=0 for bispectrum

    % Output path
    outputFolder = 'output\figures\';
    outputFileName = strcat(outputFolder,PCGrecording,'-bispectrum-imf');
    outputExt = '.png';

    % Find training folder based on PCG recording's file name
    trainingFolder = char(PCGrecording);
    trainingFolder = trainingFolder(1);

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

    % Filtering the signal and extracting IMFs
    % 3-rd order median filtering
    signal = medfilt1(signal,3);
    % Butterworth filter
    [b,a] = butter(10,fc/(Fs/2));
    % Data filtering
    signal = filter(b,a,signal);

    % Find the Intrinsic Mode Functions
    imf = emd(signal,'MaxNumIMF',maxNumberOfIMF);
    
    % Picking the first four IMFs, as the most significant
    imf = imf(:,imfs);
    
    %{
    % Apply soft-thresholding
    for i=1:nOfUsefulIMFs
        imf(:,i) = signal_thresholding(imf(:,i));
    end
    %}

    % Load annotation file and convert it to a table
    annot = importdata(strcat(folderAnnot,PCGrecording,'_StateAns.mat'));
    annot = cell2table(annot,'VariableNames',{'Sample','Section'});
    % Convert the second column to string
    annot.Section = string(annot.Section);
    
    % Find the S1 sections
    indexS1 = find(annot.Section == 'S1');
    % Check if the last S1 section is complete
    if table2array(annot(indexS1(end),1))+nOfS1samples-1 > length(signal)
        % Remove the last S1 segment
        indexS1 = indexS1(1:end-1);
    end
    % Find the S2 sections
    indexS2 = find(annot.Section == 'S2');
    % Check if the last S2 section is complete
    if table2array(annot(indexS2(end),1))+nOfS2samples-1 > length(signal)
        % Remove the last S2 segment
        indexS2 = indexS2(1:end-1);
    end

    % Find the number of the sample of the beginning of each S1 section
    S1_start = table2array(annot(indexS1,1));
    % Find the number of the sample of the beginning of each S2 section
    S2_start = table2array(annot(indexS2,1));

    % Save the number of the sample of the beginning and the end of each
    % S1 section on an array
    % We assume that the duration of the S1 sound is 140ms (280 samples)
    S1 = [S1_start, S1_start+nOfS1samples-1];
    nOfS1segments = length(S1);
    % Save the number of the sample of the beginning and the end of each
    % S2 section on an array
    % We assume that the duration of the S2 sound is 110ms (220 samples)
    S2 = [S2_start, S2_start+nOfS2samples-1];
    nOfS2segments = length(S2);

    % Cut S1 sections from each IMF
    imf_S1 = zeros(nOfS1samples,nOfS1segments,nOfUsefulIMFs);
    for j=1:nOfUsefulIMFs
        imf_j = imf(:,j);
        for k=1:nOfS1segments
            imf_S1(:,k,j) = imf_j(S1(k,1):S1(k,2));
        end
    end

    % Cut S2 sections from each IMF
    imf_S2 = zeros(nOfS2samples,nOfS2segments,nOfUsefulIMFs);
    for j=1:nOfUsefulIMFs
        imf_j = imf(:,j);
        for k=1:nOfS2segments
            imf_S2(:,k,j) = imf_j(S2(k,1):S2(k,2));
        end
    end

    % HOS - Bispectrum
    % Init a table to sum the bispectra of each cardiac cycle for S1
    bspec1 = zeros(nfft,nfft,nOfUsefulIMFs);
    % Init a table to sum the bispectra of each cardiac cycle for S2
    bspec2 = zeros(nfft,nfft,nOfUsefulIMFs);
    % Init waxis for bispectrum
    if (rem(nfft,2) == 0)
        waxis = ((-nfft/2:(nfft/2-1))'/nfft)*Fs;
    else
        waxis = ((-(nfft-1)/2:(nfft-1)/2)'/nfft)*Fs;
    end

    for i = 1:nOfUsefulIMFs
        % Bispectrum of S1 and S2 at the i-th IMF
        bspec1(:,:,i) = bispecd(imf_S1(:,:,i),nfft,wind,nOfS1samples,0);
        bspec2(:,:,i) = bispecd(imf_S2(:,:,i),nfft,wind,nOfS2samples,0);
        % Plots
        figure();
        t = tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

        % Bispectrum of S1
        ax1 = nexttile;
        contour(waxis,waxis,abs(bspec1(:,:,i)),8);
        grid on;hold on;
        plot([0,0.25*Fs],[0,0.25*Fs],'Color','#D95319'); % f1=f2
        plot([0.25*Fs,0.5*Fs],[0.25*Fs,0],'Color','#D95319'); % f1+f2=0.5
        plot([0,0.5*Fs],[0,0],'Color','#D95319'); % f2=0
        title(strcat('Bispectrum of S1 at IMF',int2str(imfs(i))));
        legend('Bispectrum','Principal Region');

        % Bispectrum of S2
        ax2 = nexttile;
        contour(waxis,waxis,abs(bspec2(:,:,i)),8);
        grid on;hold on;
        plot([0,0.25*Fs],[0,0.25*Fs],'Color','#D95319'); % f1=f2
        plot([0.25*Fs,0.5*Fs],[0.25*Fs,0],'Color','#D95319'); % f1+f2=0.5
        plot([0,0.5*Fs],[0,0],'Color','#D95319'); % f2=0
        title(strcat('Bispectrum of S2 at IMF',int2str(imfs(i))));
        legend('Bispectrum','Principal Region');

        % Figure properties
        linkaxes([ax1 ax2],'xy');
        ax1.XLim = [-fc fc];
        ax1.YLim = [-fc fc];
        title(t,strcat("Diagnosis: ",diagnosis));
        xlabel(t,'f1');
        ylabel(t,'f2');
        % Save figure to image file
        saveas(gcf,strcat(outputFileName,int2str(imfs(i)),outputExt));
    end
end