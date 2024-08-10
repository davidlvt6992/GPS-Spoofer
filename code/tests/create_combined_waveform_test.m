clc;clear;
%% create eph_struct
xml_path = "GNSS_files\GNSS_configs\gps_ephemeris_orig.xml";
eph_struct = eph_XML2struct(xml_path);

S = readstruct(xml_path);
num_sv = length(S.GNSS_SDR_ephemeris_map.item)-1;

%consturct a struct with additional data
others_struct = [];
sv_vec = zeros(1,num_sv);
TOW = S.GNSS_SDR_ephemeris_map.item(1).second.tow;
for i=1:num_sv


    temp = [];
    temp.TLM_msg = zeros(1,14); %TLM message, used by authorised user.
    temp.TOW = S.GNSS_SDR_ephemeris_map.item(i).second.tow; %time of week in seconds
    temp.alert_flag = S.GNSS_SDR_ephemeris_map.item(i).second.alert_flag; %URA alert flag
    temp.AS_flag = S.GNSS_SDR_ephemeris_map.item(i).second.antispoofing_flag; %anti spoof flag
    temp.week_number =  S.GNSS_SDR_ephemeris_map.item(i).second.WN;
    temp.code = [1 0]; %state that we use C/A code;
    temp.URA_bits = [0 0 0 0]; %URA range bits
    temp.sv_health_bits = [0 0 0 0 0 0]; %SV health code
    temp.p_code_flag = 1;
    temp.T_GD = S.GNSS_SDR_ephemeris_map.item(i).second.TGD; %group delay time
    temp.fit_flag = S.GNSS_SDR_ephemeris_map.item(i).second.fit_interval_flag;
    temp.AODO = convert2bin(S.GNSS_SDR_ephemeris_map.item(i).second.AODO,900,5)-'0'; %age of data offset
    
    others_struct{i}=temp;
    sv_vec(i)=S.GNSS_SDR_ephemeris_map.item(i).second.PRN;
end

%% create frames

N_frames = 2; %number of frames to concatenate

frames_mat = [];

for i=1:N_frames
    for j=1:num_sv
        frames_mat{j,i} = frame(eph_struct{j},others_struct{j});
        others_struct{j}.TOW = others_struct{j}.TOW + 30; 
    end
end

%% create bitsream matrix
bs_mat = zeros(num_sv,N_frames*1500);
for i=1:N_frames
    for j=1:num_sv
        start_ind = (i-1)*1500+1;
        end_ind = start_ind+1500-1;
        bs_mat(j,start_ind:end_ind) = frames_mat{j,i}.bit_stream;
    end
end

% choose ecef user position
ecef_madrid = [4852973 -314134 4112979];
f_dop = [6.98e3 5.37e3 9.85e3 8.24e3 3e3]; %random doppler vector

%% get bitstream from recording for testings
% load("data\bitstreams_26_05.mat")
% bitstream_mat = zeros(5,5000);
% for i=1:5
%     bs = cell2mat(bitstream(i));
%     bitstream_mat(i,:) = bs;
% end
% bitstream_mat(2,:) = [bitstream_mat(2,2:end) 0];
% bitstream_mat(3,:) = [bitstream_mat(3,2:end) 0];
% num_sv = length(svx_vec)-1;
% num_bits = 100;
% f_dop = [6.98e3 5.37e3 9.85e3 8.24e3];
% pr = [-6.4611e5 5.9094e5 8.6535e5 -1.1592e6];
% ca_rep_len = 1023*4*20;
%% create combined waveform
combined_wf_path = "data\waveform_creation\combined_waveform_PR_linearized.bin";
create_combined_waveform_linear_pr(ecef_madrid,eph_struct,f_dop,sv_vec,bs_mat,TOW,combined_wf_path);