clc;clear;
load("data\bitstreams_26_05.mat")
bitstream_mat = zeros(5,5000);
for i=1:5
    bs = cell2mat(bitstream(i));
    bitstream_mat(i,:) = bs;
end
bitstream_mat(2,:) = [bitstream_mat(2,2:end) 0];
bitstream_mat(3,:) = [bitstream_mat(3,2:end) 0];
num_sv = length(svx_vec)-1;
num_bits = 100;
f_dop = [6.98e3 5.37e3 9.85e3 8.24e3];
pr = [-6.4611e5 5.9094e5 8.6535e5 -1.1592e6];
ca_rep_len = 1023*4*20;
%% create waveform for all SVs
for i = 1:num_sv
    bitstream2waveformf(bitstream_mat(i,:),svx_vec(i),f_dop(i));
end

%% combine waveforms
fid_vec = zeros(1,num_sv);

%open all SV waveform files for read
for i = 1:num_sv
    file_path =  sprintf("data\\waveform_creation\\sv%d_waveform.bin",svx_vec(i));
    [fid_vec(i),msg] = fopen(file_path,"r");
end


%create and open combined waveform file
combined_path = "data\waveform_creation\combined_waveform.bin";
[fid_comb,msg] = fopen(combined_path,"w");

%combine SV waveforms
chunk_size = ca_rep_len;
for i=1:4800
    ind_start = i*chunk_size;
    chunk = Combine_Chunk(fid_vec,pr,ind_start,chunk_size);
    chunk_real = real(chunk);
    chunk_imag = imag(chunk);
    chunk_stacked = [chunk_real ; chunk_imag];
    chunk_interleaved = chunk_stacked(:)';
    fwrite(fid_comb,chunk_interleaved,'int16');
end

fclose(fid_comb); %close combined waveform file

%close all SV waveform files
for i = 1:num_sv
    fclose(fid_vec(i));
end