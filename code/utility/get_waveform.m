function wf_bitstream = get_waveform(g, fr_bitstream_matrix)
% get_waveform: Getting the waveform as bit stream of the size -
% size(g)*20*size*frame*num_of_frames.
	% Usage: wf_bitstream = get_waveform(g, frames)
	% Input Args: 
    %             g: C/A code generated by cacode.m script
	%             fr_bitstream_matrix: a matrix containing the frames bitstream 
    
    %% g_ is C/A code message concatenated 1000/50 = 20 to match a single NAV message bit 
    g_ = [];
    for i = 1: 20
        g_ = [g_ g];
    end
    
    %% init empty waveform bitstream
    wf_matrix = [];
    
    %% for each frame, we will run on all message bits and for each bit we  
    % will preform xor(g_, current_bit. Finally, we will concate result to wf
    [frames_num, frame_length] = size(fr_bitstream_matrix);
    for i=1:frames_num
        for j = 1:frame_length
            curr_bit = fr_bitstream_matrix(j);
            xor_res = xor(g_, curr_bit);
            wf_matrix = [wf_matrix  xor_res];
        end
    end
    size(wf_matrix)
    
    %% collapsing wf to a single bit stream
    wf_bitstream = transpose(wf_matrix(:));
    size(wf_bitstream)
end