function plotQPC(PCGrecording,diagnosis,maxNumberOfIMF)
%PLOTQPC - Decomposes a PCG recording using Empirical Mode Decomposition 
% and plots the bispectrum of S1, S2 fundamental heart sounds
% from the extracted IMFs.
%
%   plotQPC(PCGrecording,diagnosis,maxNumberOfIMF)
%   
%   - PCGrecording   : file name of the PCG recording (based on the 
%                      database filename convention)
%   - diagnosis      : the dianosis of the PCG recording
%   - maxNumberOfIMF : maximum number of IMFs extracted (default = 6)

    arguments
        PCGrecording (1,:) char
        diagnosis (1,:) char
        maxNumberOfIMF (1,1) {mustBeInteger,mustBePositive} = 6
    end
    
    % Init constants
    nOfS1samples = 280; % number of s1 samples
    nOfS2samples = 220; % number of s2 samples
    fc = 150; % butterworth cut-off frequency
    imfs = [1 2 3 4]; % useful IMFs
    nOfUsefulIMFs = length(imfs); % number of useful IMFs
    nfft = 512; % length of fft for bispectrum
    wind = 0; % J=0 for bispectrum
    nsamp = 512; % samples per segment for bispectrum
    overlap = 50; % percentage overlap for bispectrum
    interpSamples = 4096; % samples for interpolation
    Fs = 2000;

    % Find training folder based on PCG recording's file name
    trainingFolder = char(PCGrecording);
    trainingFolder = trainingFolder(1);

    % File paths for PCG signals and annotations
    folder = strcat('data\training-',trainingFolder,'\');
    folderAnnot = strcat('annotations\hand_corrected\training-', ...
            trainingFolder,'_StateAns\');

    % Read the PCG signal
    if isfile(strcat(folder,PCGrecording,'.wav'))
        [y,Fs] = audioread(strcat(folder,PCGrecording,'.wav'));
    else
        fprintf("PCG recording filename is invalid! Exit...\n");
        return;
    end
    
    % Filtering the signal and extracting IMFs
    % 3-rd order median filtering
    signal = medfilt1(y,3);
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

    % Interpolate the S1 and S2 data
    intImf_S1 = zeros(interpSamples,nOfS1segments,nOfUsefulIMFs);
    intImf_S2 = zeros(interpSamples,nOfS2segments,nOfUsefulIMFs);
    for i = 1:nOfUsefulIMFs
        for j = 1:nOfS1segments
            % s1 interpolated data
            intImf_S1(:,j,i) = interp1(1:1:nOfS1samples,imf_S1(:,j,i), ...
                linspace(1,nOfS1samples,interpSamples),'spline');
        end
    end
    for i = 1:nOfUsefulIMFs
        for j = 1:nOfS2segments
            % s2 interpolated data
            intImf_S2(:,j,i) = interp1(1:1:nOfS2samples,imf_S2(:,j,i), ...
                linspace(1,nOfS2samples,interpSamples),'spline');
        end
    end
    
    % New sampling frequencies
    fs_S1 = interpSamples/(nOfS1samples/Fs);
    fs_S2 = interpSamples/(nOfS2samples/Fs);



    % HOS - bispectrum
    % init a table to sum the bispectrums of each cardiac cycle for s1
    bspec1 = zeros(nfft,nfft,nOfUsefulIMFs);
    % init a table to sum the bispectrums of each cardiac cycle for s2
    bspec2 = zeros(nfft,nfft,nOfUsefulIMFs);
    for i = 1:nOfUsefulIMFs
        for j = 1:nOfS1segments
            % calculating the bispectrum of s1 on i-th IMF and j-th cardiac cycle
            [Bspec1,~] = bispecd(intImf_S1(:,j,i),nfft, wind, nsamp, overlap);
            bspec1(:,:,i) = bspec1(:,:,i) + Bspec1;
        end
        for j = 1:nOfS2segments
            % calculating the bispectrum of s2 on i-th IMF and j-th cardiac cycle
            [Bspec2,~] = bispecd(intImf_S2(:,j,i),nfft, wind,nsamp,overlap);
            bspec2(:,:,i) = bspec2(:,:,i) + Bspec2;
        end
        % averaging the bispectrum of s1 for the i-th IMF
        bspec1(:,:,i) = bspec1(:,:,i)./nOfS1segments;
        % averaging the bispectrum of s2 for the i-th IMF
        bspec2(:,:,i) = bspec2(:,:,i)./nOfS2segments;

        % contour plot of magnitude bispectum
        figure();
        if (rem(nfft,2) == 0)
            waxisS1 = ((-nfft/2:(nfft/2-1))'/nfft)*fs_s1;
            waxisS2 = ((-nfft/2:(nfft/2-1))'/nfft)*fs_s2;
        else
            waxisS1 = ((-(nfft-1)/2:(nfft-1)/2)'/nfft)*fs_s1;
            waxisS2 = ((-(nfft-1)/2:(nfft-1)/2)'/nfft)*fs_s2;
        end

        subplot(1,2,1);
        contour(waxisS1,waxisS1,abs(bspec1(:,:,i)),8);
        grid on;
        title('Mean Bispectrum of S1');
        xlabel('f1');
        ylabel('f2');
        hold on;
        plot([0,0.25*fs_S1],[0,0.25*fs_S1],'Color','#D95319'); % f1=f2
        plot([0.25*fs_S1,0.5*fs_S1],[0.25*fs_S1,0],'Color','#D95319'); % f1+f2=0.5
        plot([0,0.5*fs_S1],[0,0],'Color','#D95319'); % f2=0
        legend('Bispectrum','Principal Region');

        subplot(1,2,2);
        contour(waxisS2,waxisS2,abs(bspec2(:,:,i)),8);
        grid on;
        title('Mean Bispectrum of S2');
        xlabel('f1');
        ylabel('f2');
        hold on;
        plot([0,0.25*fs_S2],[0,0.25*fs_S2],'Color','#D95319'); % f1=f2
        plot([0.25*fs_S2,0.5*fs_S2],[0.25*fs_S2,0],'Color','#D95319'); % f1+f2=0.5
        plot([0,0.5*fs_S2],[0,0],'Color','#D95319'); % f2=0
        legend('Bispectrum','Principal Region');

        sgtitle(strcat("Bispectrum of the IMF",num2str(i), ...
            " - ",diagnosis));
    end
end