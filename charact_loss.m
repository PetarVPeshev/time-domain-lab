function [tand, alpha] = charact_loss(reference, sample, d, ...
    freq_limit, bounds, tand_pts)
%CHARACT_LOSS Summary of this function goes here
%   Detailed explanation goes here
    c = physconst('LightSpeed');
    e0 = 8.8541878128 * 1e-12;
    u0 = 1.25663706212 * 1e-6;
    Z0 = 376.730313668;

    er = sample.er;

    freq = reference.f(reference.f <= freq_limit);
    num_freq_pts = length(freq);

    loss_tangent = linspace(bounds(1), bounds(2), tand_pts);

    ref_fft = reference.fft(reference.f <= freq_limit);
    sample_fft = sample.fft(reference.f <= freq_limit);

    tand = NaN(1, num_freq_pts);
    alpha = NaN(1, num_freq_pts);

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
        Vout_Vin_meas = abs(ref_fft(freq_idx) / sample_fft(freq_idx));

        [~, tand_idx] = min(abs(Vin_Vout - Vout_Vin_meas));
        tand(freq_idx) = loss_tangent(tand_idx);
        alpha(freq_idx) = alpha_d(tand_idx);
    end
end

