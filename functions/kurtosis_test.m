function [IMFkurtosis,indexes] = kurtosis_test(imf)
%KURTOSIS_TEST - Test which IMFs are significant using kurtosis criterion
%
%   [IMFkurtosis,indexes] = kurtosis_test(imf)
%
%   - imf         : extracted IMFs
%   - IMFkurtosis : kurtosis of each IMF
%   - indexes     : a value (0 or 1) that represents whether this IMF is 
%                   significant or not
    
    % Init of basic variables
    N = size(imf,1);
    q = 0.999;
    
    % Calculating the Gaussianity test boundries
    lowI = 6/N-sqrt(24/(N*(1-q)));
    highI = 6/N+sqrt(24/(N*(1-q)));

    IMFkurtosis = kurtosis(imf) - 3;
    % Vector, whose each index represents whether this IMF is 
    % significant or not
    indexes = IMFkurtosis < lowI | IMFkurtosis > highI;
end