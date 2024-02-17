function pr_vec = get_pseudo_ranges(t, eph, x)
% get_pseudo_ranges: Getting pseudo ranges biased by SV biases as described
% in the following eq : pr_i = d(user_location, SV_i_locaction(t-tau))- DSV_i(t-tau)*C
	% Usage: pr_vec = get_pseudo_ranges(t, eph, x)
	% Input Args: 
    %             t: Time of recievd signals (need to think if UTC or GPS
	% time) 
	%             eph: Ephemeris matrix 
	%             x: User location
    
    %% definitions & loading observables data
    c = 299792458;
    omega_e = 7.2921151467e-5; %(rad/sec)
    numSV = length(eph);
    load('observables.mat');
    dsv_vec = [];
    Xs = [];
    tau_vec = [];
    
    %% loop on all SVs and creating dSV vector and SV position matrix
    for i = 1: numSV
        
            %% get SV_i broadcast time in SV clock 
                tow_index = find(TOW_at_current_symbol_s(i,:) < t & TOW_at_current_symbol_s(i,:) > 0, 1, "last");
                bsv_i = TOW_at_current_symbol_s(i, tow_index);
                
            %% get SV_i bias estimation and update dSV vec
                % To be correct, the satellite clock bias should be calculated
                % at the broadcasting time for each SV but as maxim pointed out 
                % it doesn't make much difference to do it at recieved time
                dsv_i = estimate_satellite_clock_bias(t, eph{i});
                % measured pseudoranges corrected for satellite clock bias.
                % Also apply ionospheric and tropospheric corrections if
                % available
                dsv_vec = [dsv_vec; dsv_i];
                
            %% get SV_i position and update SV position matrix
                % Get transmition time 
                tau = t - bsv_i + dsv_i;
                tau_vec = [tau_vec ; tau]; % for debugging
                
                % Get satellite position
                [xs_i, ys_i, zs_i] = get_satellite_position(eph{i}, t - tau , 1);
                
                % express satellite position in ECEF frame at time t
                theta = omega_e*tau;
                xs_vec = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1]*[xs_i; ys_i; zs_i];
                Xs = [Xs; xs_vec'];
    end
    
    %% finally calculating pseudo ranges 
        % PR = d(user_location, SV_i_locaction(t-tau))- DSV_i(t-tau)*C
        x_matrix = repmat(x, length(Xs), 1);
        norm = sqrt(sum((Xs-x_matrix).^2,2));
        pr_vec =  norm - dsv_vec*c;
        pr_vec = pr_vec - min(pr_vec);

    