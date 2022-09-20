function bisp_features_analysis(alpha,display)
%BISP_FEATURES_ANALYSIS - Computes the mean and the standard deviation of
% the bispectral features for each heart sound (S1, S2) and for each
% class (normal, abnormal) and pathology and performs 2 statistical tests
% (Wilcoxon rank sum test, Wilcoxon Signed Rank Test) to find
% statistically significant differences in the extracted features.
%
%   bisp_features_analysis(alpha,display)
%   
%   - alpha          : significance level of the decision of a hypothesis 
%                      test (default = 0.05)
%   - display        : print or not the results on the MATLAB console
%                      (delault = 'disp')"
    
    arguments
        alpha (1,1) {mustBePositive,mustBeInRange(alpha,0,1)} = 0.05
        display (1,:) char {mustBeMember(display,{'disp','nodisp'})} = 'disp'
    end
    
    % Constants
    nOfUsefulIMFs = 4;

    % Output path for data
    outputFolder = 'output\data\';
    
    % Open hos-features.csv file and import the data
    filePath = strcat(outputFolder,'bisp-features.csv');
    opts = detectImportOptions(filePath);
    bispFeatures = readtable(filePath,opts);
    bispFeatures.Diagnosis = categorical(bispFeatures.Diagnosis);
    bispFeatures.Record = string(bispFeatures.Record);
    % Helper variables
    colvar = size(bispFeatures,2);
    ncols = colvar-3;
    
    % Calculate statistics (mean and standard deviation) for each feature 
    % of S1 and S2 for each class (normal and abnormal) and pathology (AD,
    % AS, Benign, CAD, MPC, MR, MVP, Pathologic-Other) and for each IMF
    bispFeaturesMeanByClass = groupsummary(bispFeatures, ...
        'Class','mean',4:colvar);
    bispFeaturesStdByClass = groupsummary(bispFeatures, ...
        'Class','std',4:colvar);
    bispFeaturesMeanByDiagnosis = groupsummary(bispFeatures, ...
        'Diagnosis','mean',4:colvar);
    bispFeaturesStdByDiagnosis = groupsummary(bispFeatures, ...
        'Diagnosis','std',4:colvar);

    % Print statistics
    if (strcmp(display,'disp'))
        fprintf('\n\n----- STATISTICS BY CLASS (NORMAL, ABNORMAL) -----\n');
        fprintf('Mean value of bispectral features\n\n');
        disp(bispFeaturesMeanByClass);
        fprintf('Standard deviation of bispectral features\n\n');
        disp(bispFeaturesStdByClass);
        fprintf('\n\n----- STATISTICS BY DIAGNOSIS -----\n');
        fprintf('Mean value of bispectral features\n\n');
        disp(bispFeaturesMeanByDiagnosis);
        fprintf('Standard deviation of bispectral features\n\n');
        disp(bispFeaturesStdByDiagnosis);
    end
    
    % Write data to file
    writetable(bispFeaturesMeanByClass, ...
        strcat(outputFolder,'bisp-features-mean-class.csv'));
    writetable(bispFeaturesStdByClass, ...
        strcat(outputFolder,'bisp-features-std-class.csv'));
    writetable(bispFeaturesMeanByDiagnosis, ...
        strcat(outputFolder,'bisp-features-mean-diagnosis.csv'));
    writetable(bispFeaturesStdByDiagnosis, ...
        strcat(outputFolder,'bisp-features-std-diagnosis.csv'));
    
    
    % Statistical tests to find the statistically significant differences 
    % in the variables of interest
    bispFeatures_normal = bispFeatures(bispFeatures.Class == -1,:);
    bispFeatures_abnormal = bispFeatures(bispFeatures.Class == 1,:);
    
    % Test 1 : Wilcoxon rank sum test or Mann-Whitney U-test
    % Find the differences in the bispectral features of interest
    % between normal and abnormal PCG recordings (independent samples)
    % for each heart sound (S1, S2)
    p_value1 = zeros(ncols,1);
    h_test1 = zeros(ncols,1);
    for i = 4:colvar
        x = bispFeatures_normal{:,i};
        y = bispFeatures_abnormal{:,i};
        [p_value1(i-3), h_test1(i-3)] = ranksum(x,y,'alpha',alpha);
    end
    
    % Write data to .csv file
    features = {'meanS1', 'meanS2','stdS1','stdS2','minS1','minS2', ...
                'maxS1','maxS2','skewnessS1','skewnessS2','kurtosisS1', ...
                'kurtosisS2','bispectralEntropyS1','bispectralEntropyS2', ...
                'bispectral2EntropyS1','bispectral2EntropyS2', ...
                'sumOfLogAmplDiagonal1','sumOfLogAmplDiagonal2'};
    nOfFeatures = length(features);
    varTypes = cell(1,nOfFeatures);
    varTypes(1:end) = {'double'};
    pRankSum = table('Size',[nOfUsefulIMFs nOfFeatures], ...
        'VariableTypes',varTypes,'VariableNames',features);
    for i = 1:nOfFeatures
        pRankSum{:,i} = p_value1((4*i-3):(4*i));
    end
    writetable(pRankSum, ...
        strcat(outputFolder,'bisp-features-ranksum-test.csv'));
    
    % Print the p-values
    if (strcmp(display,'disp'))
        fprintf(['\n\n----- Test 1 : Wilcoxon rank sum test or ' ...
            'Mann-Whitney U-test -----\n\n']);
        disp(pRankSum);
    end
    
    % Test 2 : Wilcoxon Signed Rank Test
    % Find the differences in the bispectral features of interest 
    % between the heart sounds S1 and S2 (paired samples) for 
    % each PCG recording class (normal and abnormal)
    p_value2 = zeros(nOfFeatures/2*nOfUsefulIMFs,1);
    h_test2 = zeros(nOfFeatures/2*nOfUsefulIMFs,1);
    p_value3 = zeros(nOfFeatures/2*nOfUsefulIMFs,1);
    h_test3 = zeros(nOfFeatures/2*nOfUsefulIMFs,1);
    index = 1;
    for i = 4:2*nOfUsefulIMFs:ncols
        for j = 1:nOfUsefulIMFs
            % Normal PCG recordings
            x = bispFeatures_normal{:,i+j-1};                   % S1
            y = bispFeatures_normal{:,i+j-1+nOfUsefulIMFs};     % S2
            [p_value2(index), h_test2(index)] = signrank(x,y,'alpha',alpha);
            % Abnormal PCG recordings
            x = bispFeatures_abnormal{:,i+j-1};                 % S1
            y = bispFeatures_abnormal{:,i+j-1+nOfUsefulIMFs};   % S2
            [p_value3(index), h_test3(index)] = signrank(x,y,'alpha',alpha);
            index = index + 1;
        end
    end
    
    % Write data to .csv file
    featuresNames = {'mean','std','min','max','skewness','kurtosis', ...
                     'bispectralEntropy','bispectral2Entropy', ...
                     'sumOfLogAmplDiagonal'};
    varTypes = cell(1,nOfFeatures/2);
    varTypes(1:end) = {'double'};
    pSignRank = table('Size',[2*nOfUsefulIMFs nOfFeatures/2], ...
        'VariableTypes',varTypes,'VariableNames',featuresNames);
    for i = 1:nOfFeatures/2
        pSignRank{1:4,i} = p_value2((4*i-3):(4*i));
        pSignRank{5:8,i} = p_value3((4*i-3):(4*i));
    end
    writetable(pSignRank, ...
        strcat(outputFolder,'bisp-features-signrank-test.csv'));
    
    % Print the p-values
    if (strcmp(display,'disp'))
        fprintf('\n\n----- Test 2 : Wilcoxon Signed Rank Test -----\n\n');
        disp(pSignRank);
    end
end