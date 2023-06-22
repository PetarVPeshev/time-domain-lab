function meas_struct = get_time_gate(meas_struct, min_t)
%GET_TIME_GATE Summary of this function goes here
%   Detailed explanation goes here
    time_gate = meas_struct.t <= min_t;
    meas_struct.s_tg = meas_struct.s .* time_gate;
end

