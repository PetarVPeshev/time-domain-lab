function meas = read_meas(meas_directory, file_name)
%READ_MEAS Summary of this function goes here
%   Detailed explanation goes here
    meas = struct('t', [], 's', [], 's_tg', [], 'Ts', [], 'fft', [], ...
        'f', [], 'psd', [], 'material', [], 'er', [], 'tand', [], ...
        'alpha', []);

    meas_data = importdata([meas_directory '\' file_name '.txt']);
    
    if isstruct(meas_data)
        meas.t = meas_data.data(:, 1) + abs(meas_data.data(1, 1));
        meas.t = meas.t * 1e-12;
        meas.s = meas_data.data(:, 2);
        meas.Ts = meas.t(2) - meas.t(1);
    else
        meas.t = meas_data(:, 1) + abs(meas_data(1, 1));
        meas.t = meas.t * 1e-12;
        meas.s = meas_data(:, 2);
        meas.Ts = meas.t(2) - meas.t(1);
    end
end

