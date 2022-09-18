function [bspecPrincipal,bspecDiagPrincipal] = bisp_principal_region( ...
    bispectrum,Fs,flimit)
%BISP_PRINCIPAL_REGION - Computes and returns the region of interest of the
% given bispectral matrix. We assume that the bispectrum was calculated via
% the bispecd function of the HOSA toolbox.
%
%   [bspecPrincipal,bspecDiagPrincipal] = bisp_principal_region( ...
%                                           bispectrum,Fs,flimit)
%
%   - bispectrum         : the bispectrum (the 3rd dimension corresponds
%                          to the number of the IMF)
%   - Fs                 : sampling frequncy of the signal
%   - flimit             : upper frequency limit of the region of interest,
%                          equal to Fs to extract the principal region of
%                          the bispectrum
%   - bspecPrincipal     : the principal region of the bispectrum (array)
%   - bspecDiagPrincipal : the diagonal elements of the bispectrum in the
%                          area of interest

    arguments
        bispectrum (:,:,:)
        Fs (1,1) {mustBeInteger,mustBePositive}
        flimit (1,1) {mustBeInteger,mustBePositive}
    end

    if flimit > Fs/2
        flimit = Fs/2;  % extract the principal region
    end
    % Check if the bispectrum has a 3rd dimension
    dim3 = size(bispectrum,3);
    % Length of the FFT for the bispectrum
    nfft = size(bispectrum,1);
    n = round(flimit*nfft/Fs);
    ndiag = round(n/2);
    % Create a logical array with 1s to the cells that belong to the
    % area of interest (within the principal region) and 0s elsewhere
    tr1 = triu(ones(n));tr2 = tr1(:,end:-1:1);
    region = tr1 & tr2;
    % Create a logical array with 1s to the cells that belong to the
    % diagonal elements in the area of interest and 0s elsewhere
    diagonal = logical(eye(ndiag));
    % Number of samples that belong to the area of interest
    nsamp = sum(region,'all');
    bspecPrincipal = zeros(nsamp,dim3);
    bspecDiagPrincipal = zeros(ndiag,dim3);
    for i = 1:dim3
        bspec = bispectrum((nfft/2+1):(nfft/2+n),(nfft/2+1):(nfft/2+n),i);
        bspecPrincipal(:,i) = bspec(region);
        bspec = bispectrum((nfft/2+1):(nfft/2+ndiag), ...
                           (nfft/2+1):(nfft/2+ndiag),i);
        bspecDiagPrincipal(:,i) = bspec(diagonal);
    end
end