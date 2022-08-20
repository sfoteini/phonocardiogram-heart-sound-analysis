function HOS_features_analysis(alpha,maxNumberOfIMF,display)
%HOS_FEATURES_ANALYSIS - Computes the mean and the standard deviation of
% the HOS-features (skewness and kurtosis) for each heart sound (S1, S2)
% and for each class (normal, abnormal) and pathology and performs 2
% statistical tests (Wilcoxon rank sum test, Wilcoxon Signed Rank Test) to
% find statistically significant differences in the extracted HOS-features.
%
%   HOS_features_analysis(alpha,maxNumberOfIMF,display)
%   
%   - alpha          : significance level of the decision of a hypothesis 
%                      test (default = 0.05)
%   - maxNumberOfIMF : maximum number of IMFs extracted (default = 10)
%   - display        : print or not the results on the MATLAB console
%                      (delault = 'disp')
    
    arguments
        alpha (1,1) {mustBePositive,mustBeInRange(alpha,0,1)} = 0.05
        maxNumberOfIMF (1,1) {mustBeInteger,mustBePositive} = 10
        display (1,:) char {mustBeMember(display,{'disp','nodisp'})} = 'disp'
    end
    
    % Output path for data
    outputFolder = 'output\data\';
    
    % Open hos-features.csv file and import the data
    filePath = strcat(outputFolder,'features-training.csv');
    opts = detectImportOptions(filePath);
    hosFeatures = readtable(filePath,opts);
    hosFeatures.Diagnosis = categorical(hosFeatures.Diagnosis);
    hosFeatures.Record = string(hosFeatures.Record);
    
    % Calculate statistics (mean and variance) of each feature (skewness,
    % kurtosis) of S1 and S2 for each class (normal and abnormal) and 
    % pathology (AD, AS, Benign, CAD, MPC, MR, MVP, Pathologic-Other) and 
    % for each IMF
    colvar = maxNumberOfIMF*4;
    hosFeaturesMeanByClass = groupsummary(hosFeatures, ...
        'Class','mean',1:colvar);
    hosFeaturesStdByClass = groupsummary(hosFeatures, ...
        'Class','std',1:colvar);
    hosFeaturesMeanByDiagnosis = groupsummary(hosFeatures, ...
        'Diagnosis','mean',1:colvar);
    hosFeaturesStdByDiagnosis = groupsummary(hosFeatures, ...
        'Diagnosis','std',1:colvar);
    
    % Print statistics
    if (strcmp(display,'disp'))
        fprintf('\n\n----- STATISTICS BY CLASS (NORMAL, ABNORMAL) -----\n');
        fprintf('Count : Normal (%d), Abnormal (%d)\n', ...
            hosFeaturesMeanByClass.GroupCount);
        fprintf('\n-- Normal PCG Recordings --\n\n');
        fprintf('IMF    S1 skewness    S2 skewness    S1 kurtosis    S2 kurtosis\n');
        for i=1:maxNumberOfIMF
            fprintf(['%d     %.2f \x00B1 %.2f    %.2f \x00B1 %.2f    ' ...
            '%.2f \x00B1 %.2f    %.2f \x00B1 %.2f\n'],i, ...
            hosFeaturesMeanByClass{1,i+2}, ...
            hosFeaturesStdByClass{1,i+2}, ...
            hosFeaturesMeanByClass{1,i+2+maxNumberOfIMF}, ...
            hosFeaturesStdByClass{1,i+2+maxNumberOfIMF}, ...
            hosFeaturesMeanByClass{1,i+2+2*maxNumberOfIMF}, ...
            hosFeaturesStdByClass{1,i+2+2*maxNumberOfIMF}, ...
            hosFeaturesMeanByClass{1,i+2+3*maxNumberOfIMF}, ...
            hosFeaturesStdByClass{1,i+2+3*maxNumberOfIMF});
        end
        fprintf('\n-- Abnormal PCG Recordings --\n\n');
        fprintf('IMF    S1 skewness    S2 skewness    S1 kurtosis    S2 kurtosis\n');
        for i=1:maxNumberOfIMF
            fprintf(['%d     %.2f \x00B1 %.2f    %.2f \x00B1 %.2f    ' ...
            '%.2f \x00B1 %.2f    %.2f \x00B1 %.2f\n'],i, ...
            hosFeaturesMeanByClass{2,i+2}, ...
            hosFeaturesStdByClass{2,i+2}, ...
            hosFeaturesMeanByClass{2,i+2+maxNumberOfIMF}, ...
            hosFeaturesStdByClass{2,i+2+maxNumberOfIMF}, ...
            hosFeaturesMeanByClass{2,i+2+2*maxNumberOfIMF}, ...
            hosFeaturesStdByClass{2,i+2+2*maxNumberOfIMF}, ...
            hosFeaturesMeanByClass{2,i+2+3*maxNumberOfIMF}, ...
            hosFeaturesStdByClass{2,i+2+3*maxNumberOfIMF});
        end
        
        fprintf('\n\n----- STATISTICS BY DIAGNOSIS -----\n');
        for j=1:size(hosFeaturesMeanByDiagnosis,1)
            fprintf('\n-- Diagnosis : %s --\n\n',hosFeaturesMeanByDiagnosis{j,1});
            fprintf('IMF    S1 skewness    S2 skewness    S1 kurtosis    S2 kurtosis\n');
            for i=1:maxNumberOfIMF
                fprintf(['%d     %.2f \x00B1 %.2f    %.2f \x00B1 %.2f    ' ...
                '%.2f \x00B1 %.2f    %.2f \x00B1 %.2f\n'],i, ...
                hosFeaturesMeanByDiagnosis{j,i+2}, ...
                hosFeaturesStdByDiagnosis{j,i+2}, ...
                hosFeaturesMeanByDiagnosis{j,i+2+maxNumberOfIMF}, ...
                hosFeaturesStdByDiagnosis{j,i+2+maxNumberOfIMF}, ...
                hosFeaturesMeanByDiagnosis{j,i+2+2*maxNumberOfIMF}, ...
                hosFeaturesStdByDiagnosis{j,i+2+2*maxNumberOfIMF}, ...
                hosFeaturesMeanByDiagnosis{j,i+2+3*maxNumberOfIMF}, ...
                hosFeaturesStdByDiagnosis{j,i+2+3*maxNumberOfIMF});
            end
        end
    end
    
    % Write data to file
    writetable(hosFeaturesMeanByClass, ...
        strcat(outputFolder,'hos-features-mean-class.csv'));
    writetable(hosFeaturesStdByClass, ...
        strcat(outputFolder,'hos-features-std-class.csv'));
    writetable(hosFeaturesMeanByDiagnosis, ...
        strcat(outputFolder,'hos-features-mean-diagnosis.csv'));
    writetable(hosFeaturesStdByDiagnosis, ...
        strcat(outputFolder,'hos-features-std-diagnosis.csv'));
    
    % Statistical tests to find the statistically significant differences 
    % in the variables of interest
    hosFeatures_normal = hosFeatures(hosFeatures.Class == -1,:);
    hosFeatures_abnormal = hosFeatures(hosFeatures.Class == 1,:);
    
    % Test 1 : Wilcoxon rank sum test or Mann-Whitney U-test
    % Find the differences in the HOS-features of interest (skewness, 
    % kurtosis) between normal and abnormal PCG recordings (independent 
    % samples) for each  heart sound (S1, S2)
    p_value1 = zeros(colvar,1);
    h_test1 = zeros(colvar,1);
    for i=1:colvar
        x = hosFeatures_normal{:,i};
        y = hosFeatures_abnormal{:,i};
        [p_value1(i), h_test1(i)] = ranksum(x,y,'alpha',alpha);
    end
    
    % Write data to .csv file
    varTypes = {'double','double','double','double'};
    colNames = {'S1_skewness','S2_skewness','S1_kurtosis','S2_kurtosis'};
    pRankSum = table('Size',[maxNumberOfIMF 4],'VariableTypes',varTypes, ...
        'VariableNames',colNames);
    pRankSum.S1_skewness = p_value1(1:7);
    pRankSum.S2_skewness = p_value1(8:14);
    pRankSum.S1_kurtosis = p_value1(15:21);
    pRankSum.S2_kurtosis = p_value1(22:28);
    writetable(pRankSum, ...
        strcat(outputFolder,'hos-features-ranksum-test.csv'));
    
    % Print the p-values
    if (strcmp(display,'disp'))
        fprintf(['\n\n----- Test 1 : Wilcoxon rank sum test or ' ...
            'Mann-Whitney U-test -----\n\n']);
        fprintf('IMF    S1 skewness    S2 skewness    S1 kurtosis    S2 kurtosis\n');
        for i=1:maxNumberOfIMF
            fprintf(' %d      %.5f        %.5f        %.5f        %.5f\n', ...
                i,pRankSum{i,1},pRankSum{i,2},pRankSum{i,3},pRankSum{i,4});
        end
    end
    
    % Test 2 : Wilcoxon Signed Rank Test
    % Find the differences in the HOS-features of interest (skewness, 
    % kurtosis) between the heart sounds S1 and S2 (paired samples) for 
    % each PCG recording class (normal and abnormal)
    p_value2 = zeros(colvar,1);
    h_test2 = zeros(colvar,1);
    % Normal PCG recordings
    for i=1:maxNumberOfIMF
        % Skewness
        x = hosFeatures_normal{:,i};                    % S1
        y = hosFeatures_normal{:,i+maxNumberOfIMF};     % S2
        [p_value2(i), h_test2(i)] = signrank(x,y,'alpha',alpha);
        % Kurtosis
        x = hosFeatures_normal{:,maxNumberOfIMF*2+i};                 % S1
        y = hosFeatures_normal{:,maxNumberOfIMF*2+i+maxNumberOfIMF};  % S2
        [p_value2(i+maxNumberOfIMF), ...
            h_test2(i+maxNumberOfIMF)] = signrank(x,y,'alpha',alpha);
    end
    
    % Abnormal PCG recordings
    for i=1:maxNumberOfIMF
        % Skewness
        x = hosFeatures_abnormal{:,i};                    % S1
        y = hosFeatures_abnormal{:,i+maxNumberOfIMF};     % S2
        [p_value2(maxNumberOfIMF*2+i), ...
            h_test2(maxNumberOfIMF*2+i)] = signrank(x,y,'alpha',alpha);
        % Kurtosis
        x = hosFeatures_abnormal{:,maxNumberOfIMF*2+i};                % S1
        y = hosFeatures_abnormal{:,maxNumberOfIMF*2+i+maxNumberOfIMF}; % S2
        [p_value2(maxNumberOfIMF*3+i), ...
            h_test2(maxNumberOfIMF*3+i)] = signrank(x,y,'alpha',alpha);
    end
    
    % Write data to .csv file
    varTypes = {'double','double','double','double'};
    colNames = {'skewness_normal','kurtosis_normal','skewness_abnormal','kurtosis_abnormal'};
    pSignRank = table('Size',[maxNumberOfIMF 4],'VariableTypes',varTypes, ...
        'VariableNames',colNames);
    pSignRank.skewness_normal = p_value2(1:7);
    pSignRank.kurtosis_normal = p_value2(8:14);
    pSignRank.skewness_abnormal = p_value2(15:21);
    pSignRank.kurtosis_abnormal = p_value2(22:28);
    writetable(pSignRank, ...
        strcat(outputFolder,'hos-features-signrank-test.csv'));
    
    % Print the p-values
    if (strcmp(display,'disp'))
        fprintf('\n\n----- Test 2 : Wilcoxon Signed Rank Test -----\n\n');
        fprintf('              Normal                 Abnormal\n')
        fprintf('IMF    Skewness    Kurtosis    Skewness    Kurtosis\n');
        for i=1:maxNumberOfIMF
            fprintf(' %d     %.5f     %.5f     %.5f     %.5f\n',i, ...
                pSignRank{i,1},pSignRank{i,2},pSignRank{i,3},pSignRank{i,4});
        end
    end
end