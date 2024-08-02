%% Test env for bitstream2waveformf
load("data\bitstreams_26_05.mat")
bitstream_sv_1 = cell2mat(bitstream(1));
sv_num = 1;
f_dop = 6.98e3;

bitstream2waveformf(bitstream_sv_1 , sv_num, f_dop);