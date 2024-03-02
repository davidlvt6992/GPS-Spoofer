function create_wf_bfile(sv, fs, frames_arr)
% create_wf_bfile: Creating a binary file containing the waveform
	% Usage: create_wf_bfile(sv, fs, frames)
	% Input Args: 
    %             sv, fs: params for cacode.m which creates the C/A code
    %             message
	%             frames_arr: array of frames structs 
    
    g = cacode(sv, fs); % creating C/A code array
    
    % concat frames bitstream (for the same sattelite)
    fr_bitstream = [];
    for i=1:length(frames_arr)
        fr_bitstream = [fr_bitstream frames_arr(i).bit_stream];
    end
    
    [fid, message] = fopen("./shared_folder/attempt1/waveform.bin","w"); %insert path to write
    
    if fid < 0 
        disp(message) 
    else
        wf = get_waveform(g, fr_bitstream);


% %TEST SECTION
%         a = 0.5<rand(1,4500);
%         ca = cacode(5,4);
%         ca = repmat(ca,1,20);
%         
%         
%         wf = zeros(1,length(ca)*length(a));
%         for i = 1:length(a)
%             start_ind = (i-1)*length(ca)+1;
%             end_ind = start_ind+length(ca)-1;
%             wf(start_ind:end_ind) = xor(ca,a(i));
%         end
% %END TEST SECTION




        wf = upsample(wf,2); %upsample to accommodate Q channel signal (which is 0)
        wf = (wf-1/2).*(2^15); %convert wf to analog values
%         figure()
%         plot(wf(1:1000))
        fwrite (fid, wf,"int16");
%         message = sprintf('Waveform binary file was created in:\n%s',pwd);
        disp(message)
        fclose(fid);
    end 
end
