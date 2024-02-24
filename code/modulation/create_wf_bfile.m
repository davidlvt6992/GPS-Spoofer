function create_wf_bfile(sv, fs, frames_arr)
% create_wf_bfile: Creating a binary file containing the waveform
	% Usage: create_wf_bfile(sv, fs, frames)
	% Input Args: 
    %             sv, fs: params for cacode.m which creates the C/A code
    %             message
	%             frames_arr: array of frames structs 
    
    g = cacode(sv, fs); % creating C/A code matrix
    
    % creating frames bitstream matrix
    fr_bitstream_matrix = [];
    for i=1:length(frames_arr)
        fr_bitstream_matrix = [fr_bitstream_matrix ; frames_arr(i).bit_stream];
    end
    
    [fid, message] = fopen("waveform.bin", 'w');
    if fid < 0 
        disp(message) 
    else
        wf = get_waveform(g, fr_bitstream_matrix);
        fwrite (fid, wf);
        message = sprintf('Waveform binary file was created in:\n%s',pwd);
        disp(message)
        fclose(fid);
    end
end
