clear; clc;
load('eph_formatted_.mat');

%% Creating 2 frames using Yuval class
%data fo encode into the frame 1 & frame 2
eph1 = eph_formatted_{3} ; %ephemeris data
eph2 = eph_formatted_{4}; %ephemeris data

%create structure for additional parameters
others_struct = struct;
others_struct.TLM_msg = zeros(1,14); %TLM message, used by authorised user.
others_struct.TOW = 15000*6; %time of week in seconds
others_struct.alert_flag = 0; %URA alert flag
others_struct.AS_flag = 0; %anti spoof flag
others_struct.week_number = 252;
others_struct.code = [1 0]; %state that we use C/A code;
others_struct.URA_bits = [0 0 0 0]; %URA range bits
others_struct.sv_health_bits = [0 0 0 0 0 0]; %SV health code
others_struct.p_code_flag = 1;
others_struct.T_GD = 2^-31+2^-27; %group delay time
others_struct.fit_flag = 0;
others_struct.AODO = [0 0 0 0 0]; %age of data offset

fr_arr = [frame(eph1, others_struct) frame(eph2, others_struct)];

%% creating new wf_bfile 
% we will use C/A code of a single SV and sampling of 4
create_wf_bfile([1], 4, fr_arr);