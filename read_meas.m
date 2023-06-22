function meas = read_meas(meas_directory, file_name)
%READ_MEAS Summary of this function goes here
%   Detailed explanation goes here
    meas = struct('t', [], 's', [], 's_tg', [], 'Ts', [], 'fft', [], ...
        'f', [], 'psd', [], 'material', [], 'permittivity', [], ...
        'loss_tangent', []);

    meas_data = importdata([meas_directory '\' file_name '.txt']);
    
    meas.t = meas_data.data(:, 1) + abs(meas_data.data(1, 1));
    meas.t = meas.t * 1e-12;
    meas.s = meas_data.data(:, 2);
    meas.Ts = meas.t(2) - meas.t(1);
end

