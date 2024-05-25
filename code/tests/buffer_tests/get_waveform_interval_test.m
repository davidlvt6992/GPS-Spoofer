clear all
clc
f_samp = 50*1023*20*4;
f_bit = 50;
t_bit = 1/f_bit;
bitstream = [0 1];
f_dop = 5e3;
sv_num = 1;
t1 = 2.5*t_bit;


t2 = 3*t_bit;

interval = get_waveform_interval(t1,t2,sv_num,bitstream,f_samp,f_dop);
ca_code = cacode(1,4);

