test_frame; %run script to construct frames object.
load('data\observables.mat');
rcvr_tow = RX_time(1,end);

fr30 = frame(eph_formatted_{7},others_struct); %sv 30
fr16 = frame(eph_formatted_{3},others_struct); %sv 16
fr21 = frame(eph_formatted_{4},others_struct); %sv 21
fr25 = frame(eph_formatted_{5},others_struct); %sv 25

btsr30 = [];
btsr16 = [];
btsr21 = [];
btsr25 = [];

eph_mat = eph_formatted_([7,3,4,5]);
%create 3*1500 frames bit-streams
for i=1:3
    btsr30 = [btsr30 fr30.bit_stream];
    btsr16 = [btsr16 fr16.bit_stream];
    btsr21 = [btsr21 fr21.bit_stream];
    btsr25 = [btsr25 fr25.bit_stream];
    others_struct.TOW = others_struct.TOW+30;
end

%create dig waveforms using ca code
dig_wf30 = get_waveform(cacode(30,4),btsr30);
dig_wf16 = get_waveform(cacode(16,4),btsr16);
dig_wf21 = get_waveform(cacode(21,4),btsr21);
dig_wf25 = get_waveform(cacode(25,4),btsr25);

dig_wf_mat = [dig_wf30 ; dig_wf16 ; dig_wf21 ; dig_wf25];
clear dig_wf30 dig_wf16 dig_wf21 dig_wf25;
madrid_lla = [40.41524063127617, -3.6825268152573467 0];
madrid_ecef = lla2ecef(madrid_lla); %user position

%get pseudo ranges
pr = get_pseudo_ranges_itr(rcvr_tow,eph_mat,madrid_ecef);
f_samp = 50*20*1023*4; %Hz
combined_dig_wf = get_combined_waveform(dig_wf_mat,pr,f_samp);

%normalize and convert to analog wf:
analog_wf = upsample(combined_dig_wf,2);
clear combined_dig_wf;
analog_wf = (analog_wf/size(dig_wf_mat,1)); %normalize by the number of sattelites
analog_wf = (analog_wf-1/2).*(2^15);

% [fid, message] = fopen("GNSS_files\GNSS_waveforms\waveform_combined.bin","w"); %insert path to write
    
% if fid < 0
%     disp(message)
% end

% fwrite (fid, analog_wf,"int16");

% fclose(fid);
% clear;
      