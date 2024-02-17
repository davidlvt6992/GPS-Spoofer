clc; clear all;	

    % Constants that we will need
	% Speed of light
	c = 299792458;
	% Earth's rotation rate
	omega_e = 7.2921151467e-5; %(rad/sec)

	% load out data
	load('eph_formatted_.mat')
    eph_formatted_(1) = [];
    load('observables.mat');
    [~, order] = sort(PRN(:,end));
    Pseudorange_m = Pseudorange_m(order,:);
    Pseudorange_m = Pseudorange_m(2:end, :);
    Pseudorange_m = Pseudorange_m - min(Pseudorange_m);
     
    rcvr_tow = RX_time(1,end);%466728.880214+57.6;
	% Arrays to store various outputs of the position estimation algorithm
	user_position_arr = [];
	HDOP_arr = [];
	VDOP_arr = [];
	user_clock_bias_arr = [];

	% initial position of the user
	xu = [0 0 0];
	% initial clock bias
	b =  0;
    cb = 0;
    
    tau = 0;

    numSV = length(eph_formatted_); %number of sattelites used
    % The minimum number of satellites needed is 4, let's go for more than
    % that to be more robust
    if (numSV > 4)
        % Now lets calculate the satellite positions and construct the G
        % matrix. Then we'll run the least squares optimization to
        % calculate corrected user position and clock bias. We'll iterate
        % until change in user position and clock bias is less than a
        % threhold. In practice, the optimization converges very quickly,
        % usually in 2-3 iterations even when the starting point for the
        % user position and clock bias is far away from the true values.

        dx = 100*ones(1,3); db = 100;
        while(norm(dx) > 0.1 && norm(db) > 1)
            
            pr_ = []; %array for corrected sv clock bias pseudo ranges
            dsv_vec = []; %array for sattelite clock bias
            % Correct for satellite clock bias and find the best ephemeris data
            % for each satellite. Note that satellite ephemeris data (1019) is sent
            % far less frequently than pseudorange info (1002). So for every
            % epoch, we find the closest (in time) ephemeris data.
            for i = 1: numSV
                % To be correct, the satellite clock bias should be calculated
                % at rcvr_tow - tau, however it doesn't make much difference to
                % do it at rcvr_tow
                dsv = estimate_satellite_clock_bias(rcvr_tow, eph_formatted_{i});
                dsv_vec = [dsv_vec dsv]; %add calculated bias to array
                % measured pseudoranges corrected for satellite clock bias.
                % Also apply ionospheric and tropospheric corrections if
                % available
                pr_raw = Pseudorange_m(i,end);%get the most recent PR of the i'th SV
                pr_(end+1) = pr_raw + c*dsv; %correct PR due to SV clock bias.
            end

            
            Xs = []; % concatenated satellite positions
            pr = []; % pseudoranges corrected for user clock bias

            for i = 1: numSV
                % correct for our estimate of user clock bias. Note that
                % the clock bias is in units of distance
                cpr = pr_(i) - cb*c;
                pr = [pr; cpr];
                % Signal transmission time
                tau = cpr/c;
                % Get satellite position
                [xs_, ys_, zs_] = get_satellite_position(eph_formatted_{i}, rcvr_tow-tau, 1);
                
                % express satellite position in ECEF frame at time t
                theta = omega_e*tau;
                xs_vec = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1]*[xs_; ys_; zs_];
                Xs = [Xs; xs_vec'];
                
            end

            % Run least squares to calculate new user position and bias
            [x_, b_, norm_dp, G] = estimate_position(Xs, pr, numSV, xu, b, 3);
            % Change in the position and bias to determine when to quit
            % the iteration
            dx = x_ - xu;
            db = b_ - b;
            xu = x_;
            b = b_;
            cb = b/c;
            rcvr_tow = rcvr_tow - cb;
        end


        % Convert from ECEF to lat/lng
        [lambda, phi, h] = WGStoEllipsoid(xu(1), xu(2), xu(3));
        % Calculate Rotation Matrix to Convert ECEF to local ENU reference
        % frame
        lat = phi*180/pi;
        lon = lambda*180/pi;
        
        R1=rot(90+lon, 3);
        R2=rot(90-lat, 1);
        R=R2*R1;
        G_ = [G(:,1:3)*R' G(:,4)];
        H = inv(G_'*G_);
        HDOP = sqrt(H(1,1) + H(2,2));
        VDOP = sqrt(H(3,3));
        % Record various quantities for saving and plotting
        HDOP_arr(end+1,:) = HDOP;
        VDOP_arr(end+1,:) = VDOP;
        user_position_arr(end+1,:) = [lat lon h]
        user_clock_bias_arr(end+1,:) = b/c
    end

HDOP_arr;