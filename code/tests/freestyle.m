%% build waveform
clc;clear;
load("data\bitstreams_26_05.mat")

num_bits = 10;

sv_ind = [1 2 3 4];
num_sv = size(sv_ind,2);
ca_rep_len = 1023*4*20;

bs_mat = zeros(num_sv,num_bits);
f_dop = [2e3 4e3 -5e3 3e3 -3e3];
wf_mat = zeros(num_sv,num_bits*ca_rep_len);
f_samp = 50*20*1023*4;
t_samp = 1/f_samp;
time_vec = 0:t_samp:(num_bits*ca_rep_len-1)*t_samp;
%build individual waveforms
for i=1:num_sv
     bs = cell2mat(bitstream(sv_ind(i)));
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
end

wf_combined = sum(wf_mat,1);
white_noise = wgn(1,size(wf_combined,2),95,'complex');
wf_combined = wf_combined + white_noise;

wf_real = real(wf_combined);
wf_imag = imag(wf_combined);
wf_stacked = [wf_real;wf_imag];
wf_final = wf_stacked(:)';

[fid, message] = fopen("GNSS_files\GNSS_waveforms\waveform_freestyle_1sv.bin","w"); %insert path to write
fwrite (fid, wf_final,"int16");
fclose(fid);
bs_mat
%% check waveform correlation
close
figure(1)
cnt =1;


for i=1:num_sv
    de_dopp = exp(-1j*2*pi*f_dop(sv_ind(i)).*time_vec);
    wf_new = wf_combined.*de_dopp;
    ca_ = cacode(svx_vec(sv_ind(i)),4);

    cor = filter(fliplr(ca_),1,wf_new);
    ind = find(abs(cor)>1e7);
    cor_ = cor(ind);
    subplot(2,size(sv_ind,2),cnt)
    plot(abs(angle(cor_)),'.');
    title(sprintf('SV #%d correlation phase',svx_vec(sv_ind(i))))
    subplot(2,size(sv_ind,2),cnt+size(sv_ind,2))
    plot(abs(cor));
    title('correlation amplitude')
    cnt=cnt+1;

end
