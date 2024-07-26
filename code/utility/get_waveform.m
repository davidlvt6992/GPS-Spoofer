function waveform = get_waveform(g, bitstream, f_dop,t0)
% get_waveform: Getting the waveform as analog waveform (with doppler offset) of the size -
% size(g)*20*bitstream_size
%this function assume smapling frequency of fs=4092000
	% Usage: wf_bitstream = get_waveform(g, frames, f_dop)
	% Input Args: 
    %             g: C/A code generated by cacode.m script
	%             fr_bitstream_matrix: a matrix containing the frames bitstream 
    %             f_dop - doppler frequency in [Hz]
    %             t0 - time at the first bit
    
    %% g_ is C/A code message concatenated 1000/50 = 20 to match a single NAV message bit 
    g_ = repmat(g,1,20);
    g_anti = 1-g_;
    
    %% init empty waveform bitstream
    wf = zeros(1, length(g_)*length(bitstream));
%     wf = [];
    
    %% for each frame, we will run on all message bits and for each bit we  
    % will preform xor(g_, current_bit) and concat to wf
    for i = 1:length(bitstream)
        start_ind = (i-1)*length(g_)+1;
        end_ind = start_ind+length(g_)-1;
%         wf(start_ind:end_ind) = xor(g_,bitstream(i));
        if(bitstream(i)==0)
%             wf = [wf g_];
            wf(start_ind:end_ind) = g_;
        else
%             wf = [wf g_anti];
            wf(start_ind:end_ind) = g_anti;
        end
    end
    
    %% convert to analog waveform
    analog_wf = (wf-1/2).*(2^15); %center and normalize to analog values.
%     clear wf;
    fs = 4092000; % sampling frequency in Hz
    time_vec = 0:1/fs:(size(analog_wf,2)-1)/fs;
    time_vec = time_vec+t0; %offset to t0 time
    exp_dop = exp(1j*2*pi*f_dop*time_vec); %doppler exponential to multiply waveform
    waveform = analog_wf.*exp_dop; %return analog wavform with doppler frequenct offset
end
