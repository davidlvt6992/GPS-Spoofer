function main_func(xml_path,N_frames,N_sv,user_ecef,output_path)
%MAIN_FUNC the function takes a known ephemris data, and creates a wavefrom
%that spoofs a user into a desired position.
%   Inputs:
%       xml_paht - file path for ephemeris xml.
%       N_frames - number of desired frames
%       N_sv - number of SVs to be taken from XML file. if the file has
%       less, this parameter is ignored, and all the SVs in the file are
%       taken.
%       user_ecef - desired user spoofing position in ecef coordinates
%       ouput_path - final combined waveform output path
    %% create eph_struct
    eph_struct = eph_XML2struct(xml_path); %create ehpemeris structure.
    
    S = readstruct(xml_path);
    num_sv = min([length(S.GNSS_SDR_ephemeris_map.item) N_sv]);%if there is less than N_sv SVs in the XML, take the number of SVs in the XML file.
    
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
        sv_vec(i)=S.GNSS_SDR_ephemeris_map.item(i).second.PRN; %create SV number vector
    end
    
    %% create frames
    
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
    amp = 8e3;
%     f_dop = randn(1,num_sv)*amp; %random doppler vector
    f_dop = [6.98e3 -5.37e3 9.85e3 8.24e3 3e3 -6.58e3 7.32e3];

    %% create combined waveform
    create_combined_waveform_linear_pr(user_ecef,eph_struct,f_dop,sv_vec,bs_mat,TOW,output_path);
end

