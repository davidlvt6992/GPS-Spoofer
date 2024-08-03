function waveform_chunk = Combine_Chunk(fid_vec, PRs, ind_start, chunk_length)
%COMBINE_CHUNK The function gets a list of SVs, time interval [t_1,t_2], 
% list of PRs, and calculates the combined waveform of the SVs at the given
% time-interval with PRs offsets. The function assumes that fileIDs in
% fid_vec relates to opened file for read.
%   inputs:
%       fid_vec - vector containning the fileID of the waveforms which
%       needs to be combined. it's assumed that the files has been opened
%       for reading.
%       PRs - vector of pseudoranges, PR for each SV. the index correspond to the
%       fileIDs ind fid_vec.
%       ind_start - index of start of the chunck (in non interleaved
%       format)
%       chunk_length - length of the chunk
%   output:
%       waveform_chunk - combined waveform of the given satellites at index 
%       interval [ind_start,ind_start+chunk_length-1] with PRs taken into
%       consideration, and added noise.

    %define constants
    f_samp = 50*20*1023*4; %sampling frequency [Hz]
    t_samp = 1/f_samp; %sample time interval [sec]
    c = physconst('LightSpeed'); %speed of light [m/s]

%     ind_end = ind_start+chunk_length-1; %index corresponding to the end of the chunk

    %calculate corresponding index in interleaved int16 format
    %remember that each index represents a byte in the file, int16 is 2
    %bytes.
%     ind_start_inter = 4*(ind_start-1)+1; %interleaved int16 format start index
%     ind_end_inter = 4*(ind_end-1)+1; %interleaved int16 format end index

    %normalize smallest PR to 0
    PRs_norm = PRs-min(PRs);

    %calculate shift for each SV
    shift_vec = round((PRs_norm./c)./t_samp); %PRs in index sample index shift units
    ind_start_PR = ind_start - shift_vec; %start index for each SV with PR taken into account.

    %convert sample shift to interleaved int16 shift (1 sample = 4 bytes)
    ind_start_PR_interleaved = 4*(ind_start_PR-1); %start index in int16 interleaved format
    chunk_length_interleaved = 2*chunk_length; %length in int16 format

    chunk_mat = zeros(length(fid_vec),chunk_length); %matix to keep relevent chunk of each SV
    for i=1:length(fid_vec)
        fseek(fid_vec(i),ind_start_PR_interleaved(i),"bof"); %move pointer to the beginning of the chunk
        chunk_interleaved = fread(fid_vec(i),chunk_length_interleaved,'int16')'; %read chunk in int16 interleaved format
        %convert to non-interleaved format
        chunk_real = chunk_interleaved(1:2:end);
        chunk_imag = chunk_interleaved(2:2:end);
        chunk_mat(i,:) = chunk_real+1j*chunk_imag;
    end
    white_noise = wgn(1,chunk_length,92,'complex'); %create noise vector
    waveform_chunk = sum(chunk_mat,1) + white_noise; %sum over all chunks and add noise
end

