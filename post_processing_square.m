close all;
clear;
clc;

if ~exist([pwd() '\figures'], 'dir')
    mkdir('figures');
end

dielectric_constant;

meas_directory = 'measurements';
% ref_name = 'Air-300avgs';
% sample_name = 'square-3080um-300avgs';
ref_name = '220228-NoSample-100avgs_nh';
sample_name = '220228-Goretex-100avgs_nh';

c = physconst('LightSpeed');
% d = 3080 * 1e-6;
d = 3 * 1e-3;

freq_lim = 2.5 * 1e12;
ref_tgate = 22 * 1e-12;
sample_tgate = 23.5 * 1e-12;

%% READ MEASUREMENT
ref = read_meas(meas_directory, ref_name);
sample = read_meas(meas_directory, sample_name);

%% TIME GATE
ref = get_time_gate(ref, ref_tgate);
sample = get_time_gate(sample, sample_tgate);

%% SAMPLE FFT
% Time-gated
ref = meas_fft(ref, 'TimeGated');
sample = meas_fft(sample, 'TimeGated');
% Non-time-gated
ref_norm = meas_fft(ref, 'Measured');
sample_norm = meas_fft(sample, 'Measured');

%% MATERIAL CHARACTERIZATION
% Time-gated
[sample.er, sample.material] = charact_material(ref, sample, d, ...
    permittivity_list);
% Non-time-gated
[sample_norm.er, sample_norm.material] = charact_material(ref, sample, ...
    d, permittivity_list);

%% LOSS TANGENT
% Time-gated
[sample.tand, sample.alpha] = charact_loss(ref, sample, d, freq_lim, ...
    [1e-12 0.007], 1e6);
% Non-time-gated
[sample_norm.tand, sample_norm.alpha] = charact_loss(ref_norm, ...
    sample_norm, d, freq_lim, [1e-12 0.007], 1e6);

%% PLOT MEASUREMENT
figure('Position', [250 250 850 500]);
subplot(2, 1, 1);
plot(ref.t * 1e12, ref.s, ...
    'LineWidth', 2.0, 'DisplayName', 'ref');
hold on;
plot(sample.t * 1e12, sample.s, ...
    'LineWidth', 2.0, 'DisplayName', 'sample');
grid on;
legend show;
legend('location', 'bestoutside');
ylabel('signal / V');
title('Non-Time-Gated');
subplot(2, 1, 2);
plot(ref.t * 1e12, ref.s_tg, ...
    'LineWidth', 2.0, 'DisplayName', 'ref');
hold on;
plot(sample.t * 1e12, sample.s_tg, ...
    'LineWidth', 2.0, 'DisplayName', 'sample');
grid on;
legend show;
legend('location', 'bestoutside');
ylabel('signal / V');
xlabel('t / ps');
title('Time-Gated');
sgtitle('Measurement @ 300 Samples Average', 'FontWeight', 'bold', ...
    'FontSize', 11);
saveas(gcf, ['figures\td_' char(sample.material) '.fig']);

%% PLOT FFT
% Time-gated
max_ref_psd = max(ref.psd);
figure('Position', [250 250 750 400]);
plot(ref.f * 1e-12, 10 * log10(ref.psd / max_ref_psd), ...
    'LineWidth', 2.0, 'DisplayName', 'ref');
hold on;
plot(sample.f * 1e-12, 10 * log10(sample.psd / max_ref_psd), ...
    'LineWidth', 2.0, 'DisplayName', 'sample');
grid on;
xlim([0 10]);
legend show;
legend('location', 'bestoutside');
xlabel('f / THz');
ylabel('PSD / dB');
title('Measurement Normalized PSD @ 300 Samples Average, Time-Gated');
saveas(gcf, ['figures\psd_' char(sample.material) '_tg.fig']);
% Non-time-gated
max_ref_norm_psd = max(ref_norm.psd);
figure('Position', [250 250 750 400]);
plot(ref_norm.f * 1e-12, 10 * log10(ref_norm.psd ...
    / max_ref_norm_psd), 'LineWidth', 2.0, 'DisplayName', 'ref');
hold on;
plot(sample_norm.f * 1e-12, 10 * log10(sample_norm.psd ...
    / max_ref_norm_psd), 'LineWidth', 2.0, 'DisplayName', 'sample');
grid on;
xlim([0 10]);
legend show;
legend('location', 'bestoutside');
xlabel('f / THz');
ylabel('PSD / dB');
title('Measurement Normalized PSD @ 300 Samples Average, Non-Time-Gated');
saveas(gcf, ['figures\psd_' char(sample.material) '_non_tg.fig']);

%% PRINT MATERIAL
fprintf('Material: %s, Measured permittivity: %.2f\n', ...
    sample.material, sample.er);

%% PLOT LOSS TANGENT
% Time-gated
figure('Position', [250 250 750 400]);
plot(ref.f(ref.f <= freq_lim) * 1e-12, sample.tand, ...
    'LineWidth', 2.0, 'DisplayName', 'tan\{\delta\}');
grid on;
legend show;
legend('location', 'bestoutside');
xlabel('f / THz');
ylabel('tan\{\delta\}');
title(['Loss Tangent @ ' char(sample.material) ...
    ', 300 Samples Average, Time-Gated']);
saveas(gcf, ['figures\tand_' char(sample.material) '_tg.fig']);
% Non-time-gated
figure('Position', [250 250 750 400]);
plot(ref_norm.f(ref.f <= freq_lim) * 1e-12, sample_norm.tand, ...
    'LineWidth', 2.0, 'DisplayName', 'tan\{\delta\}');
grid on;
legend show;
legend('location', 'bestoutside');
xlabel('f / THz');
ylabel('tan\{\delta\}');
title(['Loss Tangent @ ' char(sample.material) ...
    ', 300 Samples Average, Non-Time-Gated']);
saveas(gcf, ['figures\tand_' char(sample.material) '_non_tg.fig']);

%% PLOT ALPHA
lambda = c ./ ref.f(1 : 250);
% Time-gated
alpha = 10 * log10(sample.alpha ./ lambda');
figure('Position', [250 250 750 400]);
plot(ref.f(ref.f <= freq_lim) * 1e-12, alpha, ...
    'LineWidth', 2.0, 'DisplayName', '\alpha');
grid on;
legend show;
legend('location', 'bestoutside');
xlabel('f / THz');
ylabel('\alpha / dB/\lambda');
title(['Attenuation Constant @ ' char(sample.material) ...
    ', 300 Samples Average, Time-Gated']);
saveas(gcf, ['figures\alpha_' char(sample.material) '_tg.fig']);
% Non-time-gated
alpha_norm = 10 * log10(sample_norm.alpha ./ lambda');
figure('Position', [250 250 750 400]);
plot(ref_norm.f(ref.f <= freq_lim) * 1e-12, alpha_norm, ...
    'LineWidth', 2.0, 'DisplayName', '\alpha');
grid on;
legend show;
legend('location', 'bestoutside');
xlabel('f / THz');
ylabel('\alpha / dB/\lambda');
title(['Attenuation Constant @ ' char(sample.material) ...
    ', 300 Samples Average, Non-Time-Gated']);
saveas(gcf, ['figures\alpha_' char(sample.material) '_non_tg.fig']);
