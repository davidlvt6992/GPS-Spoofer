test_frame; %run script to construct frames object.
load('data\observables.mat');
rcvr_tow = RX_time(1,end);

%some constants:
f_bit = 50; %bits per second
t_bit = 1/f_bit; %single bit transmition time [sec]
f_samp = 50*20*1023*4; %Hz
t_samp = 1/f_samp; %time step between samples
% f_chip = round(f_samp/(50*20*1023)); %num of samples per chip
f_chip = 4; %samples per chip
modulated_bit_length = f_chip*20*1023; %number of samples required for a single bit after modulation


btsr30 = [];
btsr16 = [];
btsr21 = [];
btsr25 = [];

eph_mat = eph_formatted_([7,3,4,5]);
%create 3*1500 frames bit-streams
for i=1:3
    fr30 = frame(eph_formatted_{7},others_struct); %sv 30
    fr16 = frame(eph_formatted_{3},others_struct); %sv 16
    fr21 = frame(eph_formatted_{4},others_struct); %sv 21
    fr25 = frame(eph_formatted_{5},others_struct); %sv 25
    btsr30 = [btsr30 fr30.bit_stream];
    btsr16 = [btsr16 fr16.bit_stream];
    btsr21 = [btsr21 fr21.bit_stream];
    btsr25 = [btsr25 fr25.bit_stream];
    others_struct.TOW = others_struct.TOW+30;
end

sv_num = [30;16;21;25];
sv_bitsreams = [btsr30 ; btsr16 ; btsr21 ; btsr25];
clear dig_wf30 dig_wf16 dig_wf21 dig_wf25;

madrid_lla = [40.41524063127617, -3.6825268152573467 0];
RX_TOW = rcvr_tow;

f_dop = [2e3;-4e3;6e3;-5e3]; %doppler frequencies
buffer_size = modulated_bit_length;

waveform = waveform_buffer(sv_num,sv_bitsreams,madrid_lla,RX_TOW,eph_mat,...
    f_samp,f_dop,buffer_size); %modulated combined waveform.


wf_real = real(waveform);
wf_imag = imag(waveform);
clear waveform;
stacked = [wf_real;wf_imag];
clear wf_real wf_imag;
interleaved_wf = stacked(:)';
clear stacked;

[fid, message] = fopen("GNSS_files\GNSS_waveforms\waveform_buffer.bin","w"); %insert path to write
    
if fid < 0
    disp(message)
end

fwrite (fid, interleaved_wf,"int16");

fclose(fid);
% clear;


