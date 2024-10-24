clear; clc;
load('../eph_formatted_.mat');

%data fo encode into the frame
eph = eph_formatted_{3}; %ephemeris data

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

%create subframe 1
sf1 = subframe1();
sf1.create_word1(others_struct.TLM_msg);
sf1.create_word2(others_struct.TOW,others_struct.alert_flag,others_struct.AS_flag);
sf1.create_word3(others_struct.week_number,others_struct.code, others_struct.URA_bits,others_struct.sv_health_bits, eph.iod);
sf1.create_words_4_5_6(others_struct.p_code_flag);
sf1.create_word7(others_struct.T_GD);
sf1.create_word8(eph.iod,eph.toc);
sf1.create_word9(eph.af2,eph.af1);
sf1.create_word10(eph.af0);
sf1_bitstream = sf1.create_bitstream();

%create subframe 2
sf2 = subframe2();
sf2.create_word1(others_struct.TLM_msg);
sf2.create_word2(others_struct.TOW+6,others_struct.alert_flag,others_struct.AS_flag);
sf2.create_word3(eph.iod,eph.crc);
sf2.create_words_4_5(eph.dn,eph.m0);
sf2.create_words_6_7(eph.cuc, eph.e);
sf2.create_words_8_9(eph.cus, eph.sqrtA);
sf2.create_word10(eph.toe,others_struct.fit_flag,others_struct.AODO);
sf2_bitstream = sf2.create_bitstream();

%create subframe 3
sf3 = subframe3();
sf3.create_word1(others_struct.TLM_msg);
sf3.create_word2(others_struct.TOW+2*6,others_struct.alert_flag,others_struct.AS_flag);
sf3.create_words_3_4(eph.cic, eph.omg0);
sf3.create_words_5_6(eph.cis,eph.i0);
sf3.create_words_7_8(eph.crc, eph.w);
sf3.create_words_9_10(eph.odot,eph.iod,eph.idot);
sf3_bitstream = sf3.create_bitstream();

%create subframe 4
sf4 = subframe4();
sf4.create_word1(others_struct.TLM_msg);
sf4.create_word2(others_struct.TOW+3*6,others_struct.alert_flag,others_struct.AS_flag);
sf4_bitstream = sf4.create_bitstream();

%create subframe 5
sf5 = subframe5();
sf5.create_word1(others_struct.TLM_msg);
sf5.create_word2(others_struct.TOW+4*6,others_struct.alert_flag,others_struct.AS_flag);
sf5_bitstream = sf5.create_bitstream();
