function combined_waveform = get_combined_waveform(waveform_matrix, pseudo_ranges_arr, samp_freq)
% get_pseudo_ranges: Getting pseudo ranges biased by SV biases as described
% in the following eq : pr_i = d(user_location, SV_i_locaction(t-tau))- DSV_i(t-tau)*C
	% Usage: pr_vec = get_pseudo_ranges(t, eph, x)
	% Input Args: 
    %             waveform_matrix: each row is a SV's waveform
	%             pseudo_ranges_arr: pseudo ranges array foreach SV
	%             samp_freq: Sampling frequency of the data
    
    % constants defenitions 
    c = 299792458;
    waveform_num = size(waveform_matrix, 1);
    base_size = size(waveform_matrix, 2);
    
    % getting amount of shifts for each bitstream 
    shift_arr = ceil(pseudo_ranges_arr / c * samp_freq);
    
    % getting maximum amount of shifts that is required
    max_shift = max(shift_arr);
    
    % creating the new_waveform matrix of dim [waveform_num, base_size+max_shift]
    new_waveform_matrix = zeros(waveform_num, max_shift + base_size);
    
    % for each bitstream , we will make a new row in new_waveform_matrix
    % which has the appropriate shift, then the data and then the shifts
    % required to complete the dimensions 
    for i=1:waveform_num
        new_waveform_matrix(i,:) = [zeros(1, shift_arr(i)) waveform_matrix(i,:) zeros(1, max_shift - shift_arr(i))];
    end
    
    % the combined_waveform would be the summation of all rows in new_waveform_matrix
    combined_waveform = sum(new_waveform_matrix, 1);

