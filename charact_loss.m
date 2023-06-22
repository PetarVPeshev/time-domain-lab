function tand = charact_loss(reference, sample, sample_width, ...
    freq_limit, tan_boundary, num_loss_tangent_points)
%CHARACT_LOSS Summary of this function goes here
%   Detailed explanation goes here
    c = physconst('LightSpeed');
    e0 = 8.8541878128 * 1e-12;
    u0 = 1.25663706212 * 1e-6;
%     fs_impedance = 376.730313668;
    Z0 = 376.730313668;

    er = sample.permittivity;
    d = sample_width;

    freq = reference.f(reference.f <= freq_limit);
    num_freq_pts = length(freq);

    loss_tangent = linspace(tan_boundary(1), tan_boundary(2), ...
        num_loss_tangent_points);

    ref_fft = reference.fft(reference.f <= freq_limit);
    sample_fft = sample.fft(reference.f <= freq_limit);

%     A = ref_fft ./ sample_fft;
%     figure('Position', [250 250 750 400]);
%     plot(freq * 1e-12, 10 * log10(abs(1 ./ A)) - max(10 * log10(abs(1 ./ A))), 'LineWidth', 2.0);
%     grid on;
%     xlim([0 2.5]);
%     xlabel('f / THz');
%     ylabel('A / dB');
%     title('A @ 300 Samples Average, Time-Gated');

    tand = NaN(1, num_freq_pts);

    for freq_idx = 2 : 1 : num_freq_pts
        w = 2 * pi * freq(freq_idx);
        lambda = c / freq(freq_idx);
        kz0 = 2 * pi / lambda;

        % Wave parameters inside dielectric
        Zd = (Z0 / sqrt(er)) * (1 + 1j * loss_tangent / 2);
        alpha_d = w * sqrt(e0 * u0 * er) * loss_tangent / 2;
        beta_d = w * sqrt(e0 * u0 * er);
        kzd = beta_d - 1j * alpha_d;

        % Interface 2, dielectric-air parameters
        gamma_B = (Z0 - Zd) ./ (Z0 + Zd);
        Vs_Vout = exp(1j * kzd * d) .* exp(- 1j * kz0 * d) ./ (1 + gamma_B);

        % Interface 1, air-dielectric parameters
        Zin_A = Zd .* (Z0 + 1j * Zd .* tan(kzd * d)) ./ (Zd + 1j * Z0 .* tan(kzd * d));
        gamma_A = (Zin_A - Z0) ./ (Zin_A + Z0);
        Vin_Vs = (1 + gamma_B .* exp(-1j * kzd * 2 * d)) ./ (1 + gamma_A);

        Vin_Vout = abs(Vin_Vs .* Vs_Vout);
        Vin_Vout_meas = abs(sample_fft(freq_idx)) / abs(ref_fft(freq_idx));
%         Vout_Vin_meas = ref_fft(freq_idx) / sample_fft(freq_idx);

        [~, tand_idx] = min(Vin_Vout - Vin_Vout_meas);
        tand(freq_idx) = loss_tangent(tand_idx);
    end
    
%     [FREQ, LOSS_TANGENT] = meshgrid(freq, loss_tangent);
%     
%     sample_impedance = fs_impedance * (1 + 0.5j * LOSS_TANGENT) ...
%         / sqrt(sample.permittivity);
%     
%     sample_beta = 2 * pi * FREQ * sqrt(sample.permittivity) / c;
%     sample_alpha = 2 * pi * FREQ .* 0.5 .* LOSS_TANGENT ...
%         * sqrt(sample.permittivity) / c;
%     sample_kz = sample_beta - 1j * sample_alpha;
%     
%     gamma_b = (fs_impedance - sample_impedance) ...
%         ./ (fs_impedance + sample_impedance);
%     
%     input_impedance_a = sample_impedance .* (fs_impedance ...
%         + 1j * sample_impedance .* tan(sample_kz * sample_width)) ...
%         ./ (sample_impedance + 1j * fs_impedance ...
%         * tan(sample_kz * sample_width));
%     gamma_a = (input_impedance_a - fs_impedance) ...
%         ./ (input_impedance_a + fs_impedance);
%     
%     vwr_calc = exp(1j * sample_kz * sample_width) ...
%         .* exp(- 1j * sample_kz * sample_width) .* (1 + gamma_b ...
%         .* exp(-1j * sample_kz * 2 * sample_width)) ...
%         ./ ((1 + gamma_b) .* (1 + gamma_a));
%     vwr_meas = reference.fft(reference.f <= freq_limit)' ...
%         ./ sample.fft(reference.f <= freq_limit)';
%     vwr_meas = vwr_meas / max(abs(vwr_meas));
%     
%     [~, loss_tangent_idx] = min(abs(vwr_calc) - abs(vwr_meas), ...
%         [], 1);
%     loss_tangent = loss_tangent(loss_tangent_idx);
end

