clear all
clc
f_samp = 50*1023*20*4;
f_bit = 50;
t_bit = 1/f_bit;
bitstream = [0 1 0 1 1 0 0 1 1];
f_dop = 0;
sv_num = 1;
t1 = -2*t_bit;


t2 = t_bit;

interval = get_waveform_interval(t1,t2,sv_num,bitstream,f_samp,f_dop);
ca_code = cacode(1,4);

