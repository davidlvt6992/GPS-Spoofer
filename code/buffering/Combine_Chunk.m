function waveform_chunk = Combine_Chunk(fid_vec, PRs, i_start, chunk_length)
%COMBINE_CHUNK The function gets a list of SVs, time interval [t_1,t_2], 
% list of PRs, and calculates the combined waveform of the SVs at the given
% time-interval with PRs offsets. The function assumes that the waveform of
% the SVs has been created in a dedicated folder, "sv#_waveform.bin".
%   inputs:
%       SVs - vector containning the SVs' numbers whose waveform needs to
%       be combined.
%       PRs - vector of pseudoranges, PR for each SV, in [meters].
%       t_start - time of start of the chunck in seconds.
%       t_end - time of the chunk's end (last sample's time) in seconds
%   output:
%       waveform_chunk - combined waveform of the given satellites at time 
%       interval [t_Start,t_end] with PRs taken into consideration

    %define constants
    f_samp = 50*20*1023*4; %sampling frequency [Hz]
    t_samp = 1/f_samp; %sample time interval [sec]
    c = physconst('LightSpeed'); %speed of light [m/s]

    %calculate indexes corresponding to t_Start and t_end in
    %non-interleaved format
%     ind_start = round(i_start/t_samp)+1;
%     ind_end = round(i_end/t_samp)+1;

    %calculate corresponding index in interleaved int16 format
    %remember that each index represents a byte in the file, int16 is 2
    %bytes.
    ind_start_inter = 4*(ind_start-1)+1; %interleaved int16 format start index
    ind_end_inter = 4*(ind_end-1)+1; %interleaved int16 format end index

    %normalize smallest PR to 0
    PRs_norm = PRs-min(PRs);

    %calculate shift for each SV
    shift_vec = round((PRs_norm./c)./t_samp); %PRs in index sample index shift units

    %convert sample shift to interleaved int16 shift (1 sample = 4 bytes)
    shift_vec_inter = 4*shift_vec;

    for i=1:length(SVs)
        file_path =  sprintf("data\\waveform_creation\\sv%d_waveform.bin",SVs(i));
        [fid,msg] = fopen(file_path,'r');

        fclose(fid);

    end
end

