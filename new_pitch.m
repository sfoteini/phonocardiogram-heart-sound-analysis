clear;
clc;
close all;

startLimit=0; 
endLimit=2;

PCGrecording = 'a0023';

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

figure();
xlimsignal = S1_start(2):S1_start(8);
annotS1 = indexS1(2):4:indexS1(8);
annotS2 = (indexS1(2)+2):4:(indexS1(7)+2);
plot(xlimsignal/Fs,signal(xlimsignal));
hold on;
% xline([annot{annotS1,1}]/2000,'-','Color','#D95319','LineWidth',1);
% xline([annot{annotS2,1}]/2000,'-','Color','#77AC30','LineWidth',1);
xlim([xlimsignal(1)/Fs xlimsignal(end)/Fs]);
title('Original signal');

% Compute the real cepstrum
y = signal(xlimsignal);
hammingWindow = hamming(length(y));
y=y.*hammingWindow;
rcepstrum = rceps(y);

figure();
t = (0:length(y)-1)/Fs;
plot(t,rcepstrum);
xlabel('Quefrency (s)');

%% Compute pitch
[cepstrum,d]=cceps(y);

h_hat=zeros(length(cepstrum),1);

for n=0.1+startLimit:0.1:endLimit
    N=round(n*Fs);
    h_hat(1:N)=cepstrum(1:N);
    h_hat(length(cepstrum)-N:length(cepstrum))=cepstrum(length(cepstrum)-N:length(cepstrum));

    inputCepstrum=cepstrum-h_hat;
    convolution=conv(inputCepstrum,h_hat,'same');
    input=icceps(convolution,d);
    RMSE=sqrt(sum((input-y).^2)/length(y));

    NRMSE(round((n-startLimit)*10),1) = RMSE/(max(y)-min(y));
    NRMSE(round((n-startLimit)*10),2) = round(n*Fs);
end

[M,I] = min(NRMSE(:,1));
N=NRMSE(I,2);

h_hat_final(1:N)=cepstrum(1:N);
h_hat_final(length(cepstrum)-N:length(cepstrum))=cepstrum(length(cepstrum)-N:length(cepstrum));

inputCepstrum=cepstrum-h_hat_final';
input=icceps(inputCepstrum,d);
sound(input,Fs,16);


nceps=length(input);

%find the peaks in ceps
peaks = zeros(nceps,1);

k=3;

while(k <= nceps/2 - 1)
   y1 = input(k - 1);
   y2 = input(k);
   y3 = input(k + 1);
   if (y2 > y1 && y2 >= y3)
      peaks(k)=input(k);
   end
k=k+1;
end

%get the maximum
[maxivalue, maxi]=max(peaks);

result = 2*Fs/(maxi);
figure(5);
plot(t,input);
pitch=1/result

figure(6);
plot(icceps(h_hat_final,d));

