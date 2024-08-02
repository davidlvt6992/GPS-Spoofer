%% build waveform
clc;clear;
load("data\bitstreams_26_05.mat")
bitstream_mat = zeros(5,5000);
for i=1:5
    bs = cell2mat(bitstream(i));
    bitstream_mat(i,:) = bs;
end
bitstream_mat(2,:) = [bitstream_mat(2,2:end) 0];
bitstream_mat(3,:) = [bitstream_mat(3,2:end) 0];
num_bits = 5000;

sv_ind = [1];
num_sv = size(sv_ind,2);
ca_rep_len = 1023*4*20;


bs_mat = zeros(num_sv,num_bits);
% f_dop = [2e3 4e3 -5e3 3e3 -3e3];
f_dop = [6.98e3 5.37e3 9.85e3 8.24e3 6.35e3];
wf_mat = zeros(num_sv,num_bits*ca_rep_len);
f_samp = 50*20*1023*4;
t_samp = 1/f_samp;
pr = [-6.4611e5 5.9094e5 8.6535e5 -1.1592e6];
pr_ = pr-min(pr);
c = 299792458;
shift_arr = round((pr_/c)/t_samp);
time_vec = 0:t_samp:(num_bits*ca_rep_len-1)*t_samp;
%build individual waveforms
for i=1:num_sv
     bs = bitstream_mat(i,:);
     bs_mat(i,:) = bs(1:num_bits);
%      wf_mat(i,:) = get_waveform(cacode(svx_vec(i)),bs_mat(i,:),f_dop(i),0);
     ca_code = cacode(svx_vec(sv_ind(i)),4);
     ca_rep = repmat(ca_code,1,20);
     temp = zeros(size(ca_rep,2),num_bits);
     for j=1:num_bits
         if(bs_mat(i,j)==0)
             temp(:,j) = ca_rep;
         else
             temp(:,j) = 1-ca_rep;
         end
     end
     wf_mat(i,:)=(temp(:)'-1/2).*(2^14).*exp(1j*2*pi*f_dop(sv_ind(i)).*time_vec); %destack, convert to analog and add doppler
     wf_mat(i,:) = [zeros(1,shift_arr(i)) wf_mat(i,1:end-shift_arr(i))];
end


% wf_combined = get_combined_waveform(wf_mat,pr_,f_samp);

wf_combined = sum(wf_mat,1);
clear wf_mat;

% white_noise = wgn(1,size(wf_combined,2),92,'complex');
% wf_combined = wf_combined + white_noise;

wf_real = real(wf_combined);
wf_imag = imag(wf_combined);
wf_stacked = [wf_real;wf_imag];
wf_final = wf_stacked(:)';
file_path =  sprintf("data\\waveform_creation\\sv%d_verification.bin",svx_vec(sv_ind(1))); 
[fid, message] = fopen(file_path,"w"); %insert path to write
fwrite (fid, wf_final,"int16");
fclose(fid);

%% check waveform correlation
close
figure(1)
cnt =1;

[fid,msg] = fopen("GNSS_files\GNSS_waveforms\waveform_freestyle_4sv_wPR.bin");
num_bits_read = 10;
wf = fread(fid,1023*4*20*2*num_bits_read,'int16')';
wf_real = wf(1:2:end);
wf_imag = wf(2:2:end);
wf_comp = wf_real + wf_imag*1j;
fclose(fid)
time_vec = 0:t_samp:(length(wf_comp)-1)*t_samp;
for i=1:num_sv
    de_dopp = exp(-1j*2*pi*f_dop(sv_ind(i)).*time_vec);
    wf_new = wf_comp.*de_dopp;
    ca_ = cacode(svx_vec(sv_ind(i)),4);

    cor = filter(fliplr(ca_),1,wf_new);
    ind = find(abs(cor)>1e7);
    cor_ = cor(ind);
    subplot(2,size(sv_ind,2),cnt)
    plot((angle(cor_)),'.');
    title(sprintf('SV #%d correlation phase',svx_vec(sv_ind(i))))
    subplot(2,size(sv_ind,2),cnt+size(sv_ind,2))
    plot(abs(cor));
    title('correlation amplitude')
    cnt=cnt+1;

end
%%
[fid,msg] = fopen(file_path,'r');

sample_size = 4; %size of a single sample in byte (single sample in interleaved format which means real + imaginary)
bit_size = ca_rep_len*4 %single bit of the original bitstream size in bytes

wf_interleaved = fread(file_path,ca_rep_len,'int16',bit_size)
wf_real = wf_interleaved(1:2:end);
wf_imag = wf_interleaved(2:2:end);


fclose(fid);