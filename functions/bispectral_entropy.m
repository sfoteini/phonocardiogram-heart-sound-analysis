function bspecEntropy = bispectral_entropy(bispectrum,rank)
%BISPECTRAL_ENTROPY - Computes the bispectral entropy or the bispectral
% squared entropy of the given bispectral array.
%
%   bspecEntropy = bispectral_entropy(bispectrum,rank)
%
%   - bispectrum   : array that contains the values of the bispectrum in
%                    the region of interest (if bispectrum is a matrix,
%                    the 2nd dimension corresponts to the number of IMFs)
%   - rank         : 1 for bispectral entropy or 2 for bispectral squared
%                    entropy
%   - bspecEntropy : the bispectral entropy 

    bispectrum = bispectrum.^rank;
    sum(bispectrum);
    p = bispectrum./sum(bispectrum);
    % add a small number to ensure that there are no zero values
    p = p + 10e-10;
    bspecEntropy = -sum(p.*log(p));
end