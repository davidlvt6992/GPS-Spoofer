function combined_interval_RX= get_combined_wf_interval(t1,interval_size,sv_num,PR,sv_bitstream,f_samp,f_dop)
%GET_BUFFER_WF_SINGLE_SV returns the combined modulated waveforms interval
%of svs #(sv_num) that should be received at the RX at the time interval [t1,t2],
%t1 and t2 are RX times. this means that the actual transimtion time of the
%signal recieved at time t1 is TX time t1-PR/c, same for t2.
%   t1 - RX time of interval start
%   t2 - RX time of interval end
%   sv_num - sattelites' numbers nx1
%   PR - pseudo-range corresponding to the satellite in [meters] nx1
%   sv_bitstream - raw non-modulated bitstream of sv, first bit is assumed
%   nXbs_len
%   to be transmitted at time t=0.
%   f_samp - sample-rate of the genereted waveform scalar
%   f_dop - doppler frequency of the signal. nX1

c = physconst('LightSpeed'); %speed of light in [m/s]
n = size(sv_num,1);
tau = PR/c; %pseudo-range in [sec] nX1
t1_TX = t1-tau; %transmission time of interval start nX1
% t2_TX = t2-tau; %transmission time of interval end nX1
combined_interval = get_waveform_interval(t1_TX(1),interval_size,sv_num(1),sv_bitstream(1,:),f_samp, f_dop(1));
for i=2:n
    combined_interval = combined_interval + get_waveform_interval(t1_TX(i),interval_size,sv_num(i),sv_bitstream(i,:),f_samp, f_dop(i));
end
combined_interval_RX = combined_interval;
end

