function plotIMF(PCGrecording,diagnosis,maxNumberOfIMF)
%PLOTIMF - Decomposes a PCG recording using Empirical Mode Decomposition 
% and plots the extracted IMFs
%
%   plotIMF(PCGrecording,diagnosis,maxNumberOfIMF)
%   
%   - PCGrecording   : file name of the PCG recording (based on the 
%                      database filename convention)
%   - diagnosis      : the dianosis of the PCG recording
%   - maxNumberOfIMF : maximum number of IMFs extracted (default = 10)
    
    arguments
        PCGrecording (1,:) char
        diagnosis (1,:) char
        maxNumberOfIMF (1,1) {mustBeInteger,mustBePositive} = 10
    end
    
    % Find training folder based on PCG recording's file name
    trainingFolder = char(PCGrecording);
    trainingFolder = trainingFolder(1);
    
    % Output path
    outputFolder = 'output\figures\';
    outputFileName = strcat(outputFolder,'imf-',PCGrecording,'.png');
    
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
    % Load annotation file and convert it to a table
    annot = importdata(strcat(folderAnnot,PCGrecording,'_StateAns.mat'));
    annot = cell2table(annot,'VariableNames',{'Sample','Section'});
    % Convert the second column to string
    annot.Section = string(annot.Section);
    % Find the Intrinsic Mode Functions IMF1, IMF2, ..., IMF7
    imf = emd(y,'MaxNumIMF',maxNumberOfIMF);
    
    % Find the S1 sections
    indexS1 = find(annot.Section == 'S1');
    % Find the number of the sample of the beginning of each S1 section
    S1_start = table2array(annot(indexS1,1));
    
    % Plot the signal and the IMFs in the same figure
    f = figure();
    f.Position = [400 60 500 620];
    t = tiledlayout(maxNumberOfIMF+1,1,'TileSpacing','tight','Padding','compact');
    xlim = S1_start(2):S1_start(5);
    annotS1 = indexS1(2):4:indexS1(5);
    annotS2 = (indexS1(2)+2):4:(indexS1(4)+2);
    % Plot the signal
    ax = nexttile;
    plot(xlim/Fs,y(xlim));
    hold on;
    xline([annot{annotS1,1}]/2000,'-','Color','#D95319','LineWidth',1);
    xline([annot{annotS2,1}]/2000,'-','Color','#77AC30','LineWidth',1);
    ax.XLim = [xlim(1)/Fs xlim(end)/Fs];
    title('Original signal')
    % Plot the IMFs
    for i=1:maxNumberOfIMF
        ax = nexttile;
        plot(xlim/Fs,imf(xlim,i));
        hold on;
        xline([annot{annotS1,1}]/2000,'-','Color','#D95319','LineWidth',1);
        xline([annot{annotS2,1}]/2000,'-','Color','#77AC30','LineWidth',1);
        ax.XLim = [xlim(1)/Fs xlim(end)/Fs];
        title(strcat("IMF", int2str(i)));
    end
    % Figure title, legend and axis
    title(t,strcat("Decomposition of PCG signal - ",diagnosis));
    xlabel(t,'Time (s)');
    ylabel(t,'Amplitude');
    labels = {'','S1','','','','S2'};
    leg = legend(labels,'Orientation', 'Horizontal');
    leg.Layout.Tile = 'south';
    
    % Save figure to image file
    saveas(gcf,outputFileName);
end