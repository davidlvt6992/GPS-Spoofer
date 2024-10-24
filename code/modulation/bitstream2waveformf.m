function bitstream2waveformf(bitstream, sv_num, f_dop)
% bitstream2waveformf: Creating a binary file with analog waveform (with doppler offset) of the size -
% ca_code*samples_per_chip(4)*20*bitstream_size  
	% Usage: wf_bitstream = bitstream2waveformf(bitstream, sv_num, f_dop)
	% Input Args: 
    %             bitstream.
	%             sv_num: the sattelite(space vehicle) number. Used for
	%             getting the sv ca_code with the function cacode.m. f_dop
    %             is doppler frequency
    
    %% Params
    samples_per_chip = 4;
    c = 299792458;
    file_path =  sprintf("data\\waveform_creation\\sv%d_waveform.bin",sv_num);
    
    %% Getting CA code using sv_num
    ca_code = cacode(sv_num, samples_per_chip);
    
    %% Creating time vector
    bitstream_len = length(bitstream);
    cacode_len = length(ca_code);
    ca_rep_len = cacode_len*20;
    f_samp = 50*20*cacode_len;
    t_samp = 1/f_samp;
    time_vec = 0:t_samp:(cacode_len*20-1)*t_samp;
    
    %% Moulation phase 
    modulation_chunk = [];
    phase = exp(1j*2*pi*f_dop.*time_vec);
    phase_delta = exp(1j*2*pi*f_dop*1/50);
    [fid, message] = fopen(file_path,"w");
    ca_rep = repmat(ca_code,1,20);
    for i=1:bitstream_len
        if bitstream(i)==0
            modulation_chunk = ca_rep;
        else
            modulation_chunk = 1-ca_rep;
        end
         %% Adding doppler 
         modulation_chunk = (modulation_chunk-1/2).*(2^14).*phase;
         phase = phase * phase_delta;
         %% Interleaving chunk
         chunk_real = real(modulation_chunk);
         chunk_imag = imag(modulation_chunk);
         chunk_stacked = [chunk_real;chunk_imag];
         chunk_final = chunk_stacked(:)';
         fwrite (fid, chunk_final,"int16");
    end
    fclose(fid);
end

 
            