function newSignal = signal_thresholding(signal)
%SIGNAL_THREHOLDING - Applies soft thresholding on a signal.
%
%   newSignal = signal_thresholding(signal)
%
%   - signal    : 1-D array (original signal)
%   - newSignal : 1-D array (thresholded signal)

    threshold = thselect(signal, "rigrsure");
    newSignal = wthresh(signal, "s", threshold);
end