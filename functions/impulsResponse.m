function [pitch] = impulsResponse(PCGrecording)

startLimit = 50; % min number of samples for the IR
endLimit = 1000; % max number of samples for the IR
step = 10;

% Init constants
fc = 150; % butterworth cut-off frequency

% Find training folder based on PCG recording's file name
trainingFolder = char(PCGrecording);
trainingFolder = trainingFolder(1);

% Output path
outputFolder = 'output\impulse_response\';
outputFileName = strcat(outputFolder,PCGrecording,'-ImpulseResponse','.png');

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

figure(1);
xlimsignal = S1_start(2):S1_start(8);
annotS1 = indexS1(2):4:indexS1(8);
annotS2 = (indexS1(2)+2):4:(indexS1(7)+2);
plot(xlimsignal/Fs,signal(xlimsignal));
hold on;
% xline([annot{annotS1,1}]/2000,'-','Color','#D95319','LineWidth',1);
% xline([annot{annotS2,1}]/2000,'-','Color','#77AC30','LineWidth',1);
xlim([xlimsignal(1)/Fs xlimsignal(end)/Fs]);
title('Original signal');
saveas(gcf,strcat(outputFolder,PCGrecording,'-Original','.png'));

% Compute the real cepstrum
y = signal(xlimsignal);
hammingWindow = hamming(length(y));
%y=y.*hammingWindow;
rcepstrum = rceps(y);

figure(2);
t = (0:length(y)-1)/Fs;
plot(t,rcepstrum);
title("Real Cepstrum");
xlabel('Quefrency (s)');
saveas(gcf,strcat(outputFolder,PCGrecording,'-Real_Cepstrum','.png'));

figure(3);
[pks, locs] = findpeaks(rcepstrum(1400:2600));
locs=locs+(1400-1);
findpeaks(rcepstrum,t,"MinPeakHeight",0.01);
title("Peaks of Real Cepstrum");
xlabel("Time (s)");
saveas(gcf,strcat(outputFolder,PCGrecording,'-Peaks_Real_Cepstrum','.png'));

[maximum,pos]=max(pks);
pitch=locs(pos)/Fs;

[cepstrum,d]=cceps(y);

h_hat=zeros(length(cepstrum),1);
t=xlimsignal/Fs;

for n=50:10:1000
    h_hat(1:n)=cepstrum(1:n);
    h_hat(length(cepstrum)-n:length(cepstrum))=cepstrum(length(cepstrum)-n:length(cepstrum));

    inputCepstrum=cepstrum-h_hat;
    input=conv(icceps(inputCepstrum,d),icceps(h_hat,d),'same');
    RMSE=sqrt(sum((input-y).^2)/length(y));

    NRMSE(round(n-startLimit)/step+1,1) = RMSE/(max(y)-min(y));
    NRMSE(round(n-startLimit)/step+1,2) = n;
end

[M,I] = min(NRMSE(:,1));
N=NRMSE(I,2);

h_hat_final(1:N)=cepstrum(1:N);
h_hat_final(length(cepstrum):-1:length(cepstrum)-N)=cepstrum(length(cepstrum):-1:length(cepstrum)-N);

inputCepstrum=cepstrum-h_hat_final';
input=icceps(inputCepstrum,d);

figure(4);
plot(t,cepstrum);
xlabel('Quefrency (s)');
title("Cepstrum");
saveas(gcf,strcat(outputFolder,PCGrecording,'-Complex_Cepstrum','.png'));

figure(5);
plot(t,input);
xlabel('Time (s)');
title("Input");
saveas(gcf,strcat(outputFolder,PCGrecording,'-Input','.png'));

figure(6);
plot((1:length(nonzeros(h_hat_final)))/Fs, icceps(nonzeros(h_hat_final),d));
xlabel('Time (s)');
title("Impulse response");
saveas(gcf,strcat(outputFolder,PCGrecording,'-ImpulseResponse','.png'));

figure(7);
y1=conv(input,icceps((h_hat_final),d),'same');
plot(y1);
hold on;
plot(y);
sound(y1,Fs,16);
legend('Reconstracted Signal', 'Original Signal');
saveas(gcf,strcat(outputFolder,PCGrecording,'-Reconstracted','.png'));

end

