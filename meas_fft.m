function meas = meas_fft(meas)
%MEAS_FFT Summary of this function goes here
%   Detailed explanation goes here
    meas_length = length(meas.s);
    
    meas.fft = fft(meas.s);
    meas.psd = abs(meas.fft / meas_length);
    meas.psd = meas.psd(1 : meas_length / 2 + 1);
    meas.psd(2 : end - 1) = 2 * meas.psd(2 : end - 1);
    meas.f = (0 : 1 : meas_length / 2)' / (meas.Ts * meas_length);
end

