clc;
clear;
close all;

%% Installing the needed packages
addpath('functions');
addpath('lib');
addpath('lib\hosa');

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
plot_IMF('a0213','Aortic disease');
% Diagnosis: AS (Aortic stenosis)
plot_IMF('c0026','Aortic stenosis');
% Diagnosis: Benign (Innocent or benign murmurs)
plot_IMF('a0004','Benign murmurs');
% Diagnosis: CAD (Coronary artery disease)
plot_IMF('b0063','Coronary artery disease');
% Diagnosis: MPC (Miscellaneous pathological conditions)
plot_IMF('a0203','Pathologic');
% Diagnosis: MR (Mitral regurgitation)
plot_IMF('c0012','Mitral regurgitation');
% Diagnosis: MVP (Mitral valve prolapse)
plot_IMF('a0040','Mitral valve prolapse');
% Diagnosis: Normal
plot_IMF('a0012','Normal');

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

%% Plot the bispectra of the fundamental heart sounds (S1, S2) for each IMF
% Diagnosis: AD (Aortic disease)
plot_bispectrum('a0213','Aortic disease');
% Diagnosis: AS (Aortic stenosis)
plot_bispectrum('c0026','Aortic stenosis');
% Diagnosis: Benign (Innocent or benign murmurs)
plot_bispectrum('a0004','Benign murmurs');
% Diagnosis: CAD (Coronary artery disease)
plot_bispectrum('b0063','Coronary artery disease');
% Diagnosis: MPC (Miscellaneous pathological conditions)
plot_bispectrum('a0203','Pathologic');
% Diagnosis: MR (Mitral regurgitation)
plot_bispectrum('c0012','Mitral regurgitation');
% Diagnosis: MVP (Mitral valve prolapse)
plot_bispectrum('a0040','Mitral valve prolapse');
% Diagnosis: Normal
plot_bispectrum('a0012','Normal');