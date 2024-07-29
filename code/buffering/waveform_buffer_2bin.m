function waveform_buffer_2bin(sv_num,sv_bitstreams,LLA_pos,RX_TOW,eph_mat,...
    f_samp,f_dop,buffer_size,path)
%waveform_buffer_2bin creates a combined modulated waveform of several SVs using
%a buffer and dumps it directly to a bin file.
%   inputs: sv_num (nX1) - SV id vector
%   sv_bitstreams nX(bitstream length) - bit stream matrix of n SVs
%   LLA_pos - user position in LLA coordinates
%   RX_TOW - receiver time at the beginning of the bitstream.
%   eph_mat - ehpemeris structure, used for pseudo-range calculations.
%   f_samp - sampling frequency (scalar)
%   f_dop - doppler frequencied vector (nX1)
%   buffer_size - size of buffer (number of cells in the array)
%   path - path to binary file

%some constants:
f_bit = 50; %bits per second
t_bit = 1/f_bit; %single bit transmition time [sec]
t_samp = 1/f_samp; %time step between samples
% f_chip = round(f_samp/(50*20*1023)); %num of samples per chip
f_chip = 4; %samples per chip
modulated_bit_length = f_chip*20*1023; %number of samples required for a single bit after modulation

ECEF_pos = lla2ecef(LLA_pos); %convert LLA to ECEF coordinates
n = length(sv_num); %number of satellites
buffer = zeros(1,buffer_size); %buffer

T = size(sv_bitstreams,2)*t_bit; %overall transimssion time

expected_size = ceil(modulated_bit_length*size(sv_bitstreams,2)/buffer_size)*buffer_size; %expected size of output array
waveform_aux = zeros(1,expected_size); %array to save all pull data from buffer

i = 1; %index of interval start
t_i = (i-1)*t_samp; %time of interval start
j = buffer_size; %index of interval end
t_j = (j-1)*t_samp; %time of interval end
PR = zeros(n,1); %pseudo-range vector
iter_num = 1;
expected_iter = expected_size/buffer_size;

%open file
[fid, message] = fopen(path,"w"); %insert path to write

if fid < 0
    disp(message)
end


while (t_j<T)
    PR = get_pseudo_ranges_itr(t_i+RX_TOW,eph_mat,ECEF_pos); %calculate PR for current interval
    buffer = get_combined_wf_interval(t_i,buffer_size,sv_num,PR,sv_bitstreams,...
        f_samp,f_dop); %fill buffer with current interval
    buffer = awgn(buffer,-80); %add white noise to signal
%     waveform_aux(i:j) = buffer; %fill auxilary array with buffer at relevant interval
    buffer_real = real(buffer);
    buffer_imag = imag(buffer);
    stacked = [buffer_real;buffer_imag];
    interleaved_buffer = stacked(:)';
    fwrite(fid,interleaved_buffer,'int16'); %write to file
%     fwrite(fid,)

    %progress massage
    prog = 100*iter_num/expected_iter;
    msg = ['Progress: ', num2str(prog), '%'];
    disp(msg)
    
    %update indexes/times for next iteration
    i = i + buffer_size; %update start time to next interval
    t_i = (i-1)*t_samp; %update start time to next interval
    j = j + buffer_size; %update end index to next interval
    t_j = (j-1)*t_samp; %update end time of next interval
    iter_num = iter_num+1;
end

fclose(fid);

end

