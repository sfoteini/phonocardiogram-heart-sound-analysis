clc;
clear;
close all;

%% Installing the needed packages
addpath('functions');

%% Set values for constant variables
maxNumberOfIMF = 6;
alpha = 0.05;
trainingFolder = ['a', 'b', 'c', 'd', 'e', 'f'];

%% Create a folder for output data and figures
if not(isfolder('output\data'))
    mkdir('output\data')
end
if not(isfolder('output\figures'))
    mkdir('output\figures')
end

%% Plot IMFs for PCG recordings
% Diagnosis: AD (Aortic disease)
plotIMF('a0213','Aortic disease',maxNumberOfIMF);
% Diagnosis: AS (Aortic stenosis)
plotIMF('c0026','Aortic stenosis',maxNumberOfIMF);
% Diagnosis: Benign (Innocent or benign murmurs)
plotIMF('a0004','Benign murmurs',maxNumberOfIMF);
% Diagnosis: CAD (Coronary artery disease)
plotIMF('b0063','Coronary artery disease',maxNumberOfIMF);
% Diagnosis: MPC (Miscellaneous pathological conditions)
plotIMF('a0203','Pathologic',maxNumberOfIMF);
% Diagnosis: MR (Mitral regurgitation)
plotIMF('c0012','Mitral regurgitation',maxNumberOfIMF);
% Diagnosis: MVP (Mitral valve prolapse)
plotIMF('a0040','Mitral valve prolapse',maxNumberOfIMF);
% Diagnosis: Normal
plotIMF('a0012','Normal',maxNumberOfIMF);

%% Extract the useful IMFs
for i=1:6
    fprintf("Extracting IMFs from database " + ...
        trainingFolder(i) + "...\n");
    IMF_extraction(trainingFolder(i));
    fprintf("IMFs extracted successfully from database " + ...
        trainingFolder(i) + "\n");
end

%% Identify the useful IMFs
percentages = check_kurtosis_test();
fprintf("\n---- Percentage of 1s in each IMF ----\n");
for i=1:maxNumberOfIMF
    fprintf("\tIMF%d: %.3f%%\n",i,percentages(i));
end