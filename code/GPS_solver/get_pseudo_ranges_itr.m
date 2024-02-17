function pr_vec = get_pseudo_ranges_itr(t, eph, x)
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
    dsv_vec = [];
    Xs = [];
    x_matrix = repmat(x, length(numSV), 1);
    
    %% For each SV we get the estimated broadcasting time (in iterative fashion),
    %% After which we use it to get the SV bias and estimated broadcasting location.
    for i = 1: numSV
        broadcast_time = t;
        prev_distance = 0;
        distance_changes = inf;
        while distance_changes > 0.1 
        %% Get estimated broadcasting time 
            [xs_i, ys_i, zs_i] = get_satellite_position(eph{i}, broadcast_time , 1);
            xs_vec = [xs_i, ys_i, zs_i];
            distance = ( sqrt(sum((xs_vec-x).^2,2)) );
            tau = distance / c;
            broadcast_time = broadcast_time - tau;
            distance_changes = abs(distance - prev_distance);
            prev_distance = distance;
        end
        %% Now that we have broadcasting time we get SV_i bias estimation and update dSV vec 
        dsv_i = estimate_satellite_clock_bias(broadcast_time, eph{i});
        dsv_vec = [dsv_vec; dsv_i];
        
        %% Now that we have broadcasting time we get SV_i position and update SV position matrix
        [xs_i, ys_i, zs_i] = get_satellite_position(eph{i}, broadcast_time, 1);
        % express satellite position in ECEF frame at time t
        theta = omega_e*(t-broadcast_time);
        xs_vec = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1]*[xs_i; ys_i; zs_i];
        Xs = [Xs; xs_vec'];
    end
    
    %% Finally calculating pseudo ranges 
    norm = sqrt(sum((Xs-x_matrix).^2,2));
    pr_vec =  norm - dsv_vec*c;
    pr_vec = pr_vec - min(pr_vec);

    