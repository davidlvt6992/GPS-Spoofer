function combined_waveform = get_combined_waveform(waveform_matrix, pseudo_ranges_arr, samp_freq)
% get_pseudo_ranges: Getting pseudo ranges biased by SV biases as described
% in the following eq : pr_i = d(user_location, SV_i_locaction(t-tau))- DSV_i(t-tau)*C
	% Usage: pr_vec = get_pseudo_ranges(t, eph, x)
	% Input Args: 
    %             t: Time of recievd signals (need to think if UTC or GPS
	% time) 
	%             eph: Ephemeris matrix 
	%             x: User location
    c = 299792458;
    waveform_num = size(waveform_matrix, 1);
    base_size = size(waveform_matrix, 2);
    
    pseudo_ranges_arr = pseudo_ranges_arr / c;
    shift_arr = ceil(pseudo_ranges_arr * samp_freq);
    max_shift = max(shift_arr);
    new_waveform_matrix = zeros(waveform_num, max_shift + base_size);
    for i=1:waveform_num
        new_waveform_matrix(i,:) = [zeros(1, shift_arr(i)) waveform_matrix(i,:) zeros(1, max_shift - shift_arr(i))];
    end
    combined_waveform = sum(waveform_matrix, 1);

