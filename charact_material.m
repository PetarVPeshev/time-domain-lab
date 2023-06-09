function [sample_permittivity, material] ...
    = charact_material(reference, sample, sample_width, permittivity_list)
%CHARACT_MATERIAL Summary of this function goes here
%   Detailed explanation goes here
    c = physconst('LightSpeed');

    [ref_pks, ref_idx_pks] = findpeaks(reference.s);
    [~, ref_idx_max_pk] = max(ref_pks);
    ref_loc_pk = ref_idx_pks(ref_idx_max_pk);

    [sample_pks, sample_idx_pks] = findpeaks(sample.s);
    [~, sample_idx_max_pk] = max(sample_pks);
    sample_loc_pk = sample_idx_pks(sample_idx_max_pk);
    
    time_diff = sample.t(sample_loc_pk) - reference.t(ref_loc_pk);
    time_air = sample_width / c;
    sample_permittivity = (c * (time_diff + time_air) / sample_width) ^ 2;
    
    [~, idx] = min(abs(permittivity_list.permittivity - sample_permittivity));
    material = permittivity_list.material(idx);
end
