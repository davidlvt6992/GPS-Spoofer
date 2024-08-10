function create_combined_waveform_linear_pr(pos_ecef,eph_struct,doppler_vec,sv_vec,bs_mat,TOW,dst_path)
%GET_COMBINED_WAVEFORM creates a combined waveform that spoofs a user to
%position pos_ecef using known ephemeris data, and given bitstream at time
%TOW. pseudoranges are estimated using linearization.
%   Inputs:
%       pos_ecef - desired user position in ecef coordinates
%       eph_struct - structure that contains the ehpemeris data for each
%       SV, used for PR calculations.
%       doppler_vec - doppler frequency of each sattelite
%       sv_vec - vector that contains number of SV corresponding to each
%       index in bitstream matrix, ephemeris structure and doppler vector.
%       bs_mat - bitstream matrix, each row corresponds to a different SV.
%       TOW - time of week at the beginning of bitstream.
%       dst_path - destination path for final combined wavefrom
%   Outputs: none, the function creates a binary file at dst_path that
%   contains combined wavefrom data.

    %define constants:
    f_samp = 50*20*1023*4; %sample frequnecy
    t_samp = 1/f_samp; %sample time interval
    c = physconst('LightSpeed'); %speed of light constant
    num_sv = length(sv_vec); %number of SVs
    ca_rep_len = 1023*4*20; %number of samples required to modulate 1 bit.
    sv_wf_length = ca_rep_len*size(bs_mat,2); %total number of sample for a single waveform

    %create waveform for all SVs
    for i = 1:num_sv
        bitstream2waveformf(bs_mat(i,:),sv_vec(i),doppler_vec(i));
    end

    %open every SV's waveform for read
    for i=1:length(sv_vec)
        file_path =  sprintf("data\\waveform_creation\\sv%d_waveform.bin",sv_vec(i));
        [fid_vec(i),msg] = fopen(file_path,"r");
    end

    %create and open combined waveform file
%     dst_path = "data\waveform_creation\combined_waveform_PR_linearized.bin";
    [fid_comb,msg] = fopen(dst_path,"w");

    %linearize pseudo ranges
    ind_end = sv_wf_length; %last index
    PR_start = get_pseudo_ranges_itr(TOW,eph_struct,pos_ecef); %PR at the start of the waveform
    PR_end = get_pseudo_ranges_itr(TOW+(ind_end-1)*t_samp,eph_struct,pos_ecef); %PR at the end of the waveform
    PR_slope = (PR_end-PR_start)/(ind_end-1); %PR slope vector (PR/ind)

    %combine SV waveforms
    chunk_size = ca_rep_len; %desired chunk size
    num_chunks = floor(sv_wf_length/chunk_size)-1; %number of chunks to calculate, (-1) is to skip last bit to avoid edges
    for i=1:num_chunks
        ind_start = (i-1)*chunk_size+1; %current chunk's first index
%         ind_end = ind_start + chunk_size-1; %end index of current chunk
%         ind_mid = round((ind_start+ind_end)/2);
%         TOW_cur_ind = TOW+(ind_start-1)*t_samp;
        PR_vec = PR_start+PR_slope*(ind_start-1); %linearized PR estimation
        PR_vec = PR_vec - min(PR_vec); %normalize smallest PR to 0
        chunk = Combine_Chunk(fid_vec,PR_vec,ind_start,chunk_size); %combine waveforms fo current chunk

        %write current chunk to combined waveform file
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
end

