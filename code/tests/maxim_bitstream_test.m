clear;
load("data\bitstreams_maxim.mat")

bs_mat = zeros(6,4091);
for i=1:2
    a = cell2mat(bitstream(i));
    bs_mat(i,:)=[cell2mat(bitstream(i)) zeros(1,4091-size(a,2))];
end

dig_wf1 = get_waveform(cacode(1,4),bs_mat(1,:),2e3);
dig_wf21 = get_waveform(cacode(21,4),bs_mat(2,:),4e3);
% dig_wf25 = get_waveform(cacode(25,4),bs_mat(3,:));
% dig_wf29 = get_waveform(cacode(29,4),bs_mat(4,:));
% dig_wf30 = get_waveform(cacode(30,4),bs_mat(5,:));
% dig_wf31 = get_waveform(cacode(31,4),bs_mat(6,:));

% 
dig_wf_mat = [dig_wf1 ; dig_wf21];% ; dig_wf25 ; dig_wf29; dig_wf30;dig_wf31];
clear dig_wf1 dig_wf21% dig_wf25 dig_wf29 dig_wf30 dig_wf31

% 
% madrid_lla = [40.41524063127617, -3.6825268152573467 0];
% madrid_ecef = lla2ecef(madrid_lla); %user position

% %get pseudo ranges
% pr = get_pseudo_ranges_itr(rcvr_tow,eph_mat,madrid_ecef);
f_samp = 50*20*1023*4; %Hz
pr=[0 0];
combined_dig_wf = get_combined_waveform(dig_wf_mat,pr,f_samp);
white_noise = wgn(1,size(combined_dig_wf,2),40,'complex');

combined_dig_wf = combined_dig_wf + white_noise;
clear white_noise;

% combined_dig_wf =  sum(dig_wf_mat,1);

% analog_wf = upsample(combined_dig_wf,2);
% clear combined_dig_wf;
% analog_wf = (analog_wf/6); %normalize by the number of sattelites
% analog_wf = (analog_wf-1/2).*(2^15);

wf_real = real(combined_dig_wf);
wf_imag = imag(combined_dig_wf);
clear combined_dig_wf;
stacked = [wf_real;wf_imag];
clear wf_real wf_imag;
interleaved_wf = stacked(:)';
clear stacked

[fid, message] = fopen("GNSS_files\GNSS_waveforms\waveform_2sv_maxim_noised.bin","w"); %insert path to write
    
if fid < 0
    disp(message)
end

fwrite (fid, interleaved_wf,"int16");

fclose(fid);
% clear;