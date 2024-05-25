function waveform_interval = get_waveform_interval(t1,interval_size,sv_num,sv_bitsream,f_samp, f_dop)
%GET_WAVEFORM_INTERVAL calculates and returns modulated waveform
%transmitted by SV #(sv_num) at TX time interval [t1,t2] (end time t2 is not included), with sample
%rate f_samp and doppler frequency f_dop.
%   t1 - start of time interval.
%   t2 - end of time interval.
%   sv_num - number of satellite
%   sv_bitstream - pre-modulated bitstream of sattelite (assume first bit
%   TX time is 0)
%   f_samp - sample frequency of the output waveform (our default is 4
%   samples per chip = 50*20*1023*4 Hz)
%   f_dop - doppler frequency to be added to the wavform.

%some constants:
f_bit = 50; %bits per second
t_bit = 1/f_bit; %single bit transmition time [sec]
t_samp = 1/f_samp; %time step between samples
% f_chip = round(f_samp/(50*20*1023)); %num of samples per chip
f_chip = 4; %samples per chip
modulated_bit_length = f_chip*20*1023; %number of samples required for a single bit after modulation

t2 = t1 + (interval_size-1)*t_samp;

%calculate relevant bit numbers in sv_bitstream
n = floor(t1/t_bit)+1; %bit number at time t1
m = floor(t2/t_bit)+1; %bit number at time t2

interval_start = (n-1)*t_bit; %TX start time of first bit in the interval
% interval_end = m*t_bit-t_samp; %TX end time of last bit in the interval
ca_code = cacode(sv_num,f_chip); %CA code of sattelite

n_inbound = (1<=n) && (n<=length(sv_bitsream));
m_inbound = (1<=m) && (m<=length(sv_bitsream));

if(and(n_inbound,m_inbound)) %both indexes are inbound
    relevant_bs = sv_bitsream(n:m); %relevant interval of bit stream for waveform calculations
    relevant_wf = get_waveform(ca_code,relevant_bs,f_dop, interval_start); %create wf of relevant bit stream
elseif(n_inbound==1 && m_inbound==0)%index n is inbound m is out of bounds
    relevant_bs = sv_bitsream(n:end); %inbound part of the bitstream
    pre_wf = get_waveform(ca_code,relevant_bs,f_dop,interval_start); %modulated waveform of inbound bitstream
    post_wf = zeros(1,modulated_bit_length*(m-length(sv_bitsream))); %no signal for out of bounds indexes
    relevant_wf = [pre_wf,post_wf]; %concat the 2 waveforms
elseif(n_inbound==0 && m_inbound==1)%index n is out of bounds, m is inboound
    relevant_bs = sv_bitsream(1:m); %relevant interval of bit stream for waveform calculations
    pre_wf = zeros(1,modulated_bit_length*(1-n)); %sv didn't start broadcast (negative TX time)
    post_wf = get_waveform(ca_code,relevant_bs,f_dop, 0);%get modulated waveform for inbound bits
    relevant_wf = [pre_wf , post_wf]; %concat the 2 waveforms
else %both indexes are out of bounds.
    relevant_wf = zeros(1,modulated_bit_length*(m-n+1)); %no indexes are inbound, no signal.
end

% if(n>length(sv_bitsream))
%     relevant_wf = zeros(1,modulated_bit_length*(m-n+1));
% elseif(m>length(sv_bitsream))
%     relevant
%     pre_wf = 
% elseif(n>=1)
%     relevant_bs = sv_bitsream(n:m); %relevant interval of bit stream for waveform calculations
%     relevant_wf = get_waveform(ca_code,relevant_bs,f_dop, interval_start);
% elseif(m>=1)
%     relevant_bs = sv_bitsream(1:m); %relevant interval of bit stream for waveform calculations
%     pre_wf = zeros(1,modulated_bit_length*(1-n)); %sv didn't start broadcast (negative TX time)
%     post_wf = get_waveform(ca_code,relevant_bs,f_dop, 0);
%     relevant_wf = [pre_wf , post_wf];
% else
%     relevant_wf = zeros(1,modulated_bit_length*(m-n+1));
% end

i = round((t1-interval_start)/t_samp)+1; %waveform index corresponding to t1
% j = floor((t2-interval_start)/t_samp)+1; %waveform index corresponding to t2
j = i + interval_size-1;
waveform_interval = relevant_wf(i:j);

end

