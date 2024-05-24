clear;
clc;

%constants:
f_samp = 50*1023*20*4;
f_bit = 50;
t_bit = 1/f_bit;
c = physconst('Lightspeed');

%funtction's parameters
t1 = 0;
t2 = 0.5*t_bit;
sv_num = [1;21];
PR = c*[0;t_bit/100];
bitstream = [0 1 0 ; 1 0 1];
f_dop = [0;4e3];

interval = get_combined_wf_interval(t1,t2,sv_num,PR,bitstream,f_samp,f_dop);


