clc;
clear;
close all;

%% Inistalling the needed packages
addpath('functions');

%% Set values for constant variables
maxNumberOfIMF = 7;
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

%% Extract HOS features from PCG recordings
for i=1:6
    fprintf("Extracting HOS-features from database " + ...
        trainingFolder(i) + "...\n");
    HOS_features_extraction(trainingFolder(i),maxNumberOfIMF);
    fprintf("HOS-features extracted successfully from database " + ...
        trainingFolder(i) + "\n");
end
merge_HOS_features();

%% Statistical analysis of HOS features
HOS_features_analysis(alpha,maxNumberOfIMF,'disp');