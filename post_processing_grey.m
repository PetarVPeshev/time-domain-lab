close all;
clear;
clc;

if ~exist([pwd() '\figures'], 'dir')
    mkdir('figures');
end

dielectric_constant;

meas_directory = 'measurements';
sample_width = 525 * 1e-6;
freq_limit_loss_tangent = 3e12;

%% MEASUREMENT FILE NAMES
ref_name = 'Air-300avgs';
sample_name = 'Gray-525um-300avgs';

%% READ MEASUREMENT
ref_meas = read_meas(meas_directory, ref_name);
sample_meas = read_meas(meas_directory, sample_name);

%% SAMPLE FFT
ref_meas = meas_fft(ref_meas);
sample_meas = meas_fft(sample_meas);

%% MATERIAL CHARACTERIZATION
[sample_meas.permittivity, sample_meas.material] ...
    = charact_material(ref_meas, sample_meas, sample_width, ...
    permittivity_list);

%% LOSS TANGENT
sample.loss_tangent = charact_loss(ref_meas, sample_meas, sample_width, ...
    freq_limit_loss_tangent, 10001);

%% PLOT MEASUREMENT
figure('Position', [250 250 750 400]);
plot(ref_meas.t * 1e12, ref_meas.s, ...
    'LineWidth', 2.0, 'DisplayName', 'ref');
hold on;
plot(sample_meas.t * 1e12, sample_meas.s, ...
    'LineWidth', 2.0, 'DisplayName', 'sample');
grid on;
legend show;
legend('location', 'bestoutside');
xlabel('t / ps');
ylabel('signal / V');
title('Measurement @ 300 Samples Average');
saveas(gcf, ['figures\td_' char(sample_meas.material) '.fig']);

%% PLOT FFT
max_ref_psd = max(ref_meas.psd);
figure('Position', [250 250 750 400]);
plot(ref_meas.f * 1e-12, 10 * log10(ref_meas.psd / max_ref_psd), ...
    'LineWidth', 2.0, 'DisplayName', 'ref');
hold on;
plot(sample_meas.f * 1e-12, 10 * log10(sample_meas.psd / max_ref_psd), ...
    'LineWidth', 2.0, 'DisplayName', 'sample');
grid on;
xlim([0 10]);
legend show;
legend('location', 'bestoutside');
xlabel('f / THz');
ylabel('PSD / dB');
title('Measurement Normalized PSD @ 300 Samples Average');
saveas(gcf, ['figures\psd_' char(sample_meas.material) '.fig']);

%% PRINT MATERIAL
fprintf('Material: %s, Measured permittivity: %.2f\n', ...
    sample_meas.material, sample_meas.permittivity);

%% PLOT LOSS TANGENT
figure('Position', [250 250 750 400]);
plot(ref_meas.f(ref_meas.f <= freq_limit_loss_tangent) * 1e-12, ...
    sample.loss_tangent, 'LineWidth', 2.0, 'DisplayName', 'tan\delta');
grid on;
legend show;
legend('location', 'bestoutside');
xlabel('f / THz');
ylabel('tan\delta');
title(['Loss Tangent @ ' char(sample_meas.material) ...
    ', 300 Samples Average']);
saveas(gcf, ['figures\loss_tangent_' char(sample_meas.material) '.fig']);
