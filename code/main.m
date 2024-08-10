clear;clc;

xml_path = "GNSS_files\GNSS_configs\gps_ephemeris_orig.xml";
N_frames = 3;
N_sv = 5;
user_ecef = [4852973 -314134 4112979];
output_path = "data\waveform_creation\combined_waveform_PR_linearized.bin";

main_func(xml_path,N_frames,N_sv,user_ecef,output_path)