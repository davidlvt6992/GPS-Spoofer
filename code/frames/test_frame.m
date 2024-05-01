clear; clc;
load('eph_formatted_.mat');

%data fo encode into the frame
% eph = eph_formatted_{3}; %ephemeris data

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
% 
% fr5 = frame(eph_formatted_{2},others_struct); %sv 5
% fr16 = frame(eph_formatted_{3},others_struct); %sv 16
% fr21 = frame(eph_formatted_{4},others_struct); %sv 21
% fr25 = frame(eph_formatted_{5},others_struct); %sv 25

