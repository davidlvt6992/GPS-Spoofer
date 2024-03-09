clc; clear
load('C:\Users\levit\Desktop\studying\Technion\NinthSemester\GPS proj\GPS-Spoofer\data\bitsream.mat')
stream = bitstream{1};
frame = stream(257:556);
D30_star = frame(210);
D29_star = frame(209);
D = frame(211:240);

% getting 24 bits before encoding
d_24 = xor(D(1:24),D30_star);


% getting special params
iodc = bin2dec(num2str(d_24(1:8)));
t_oc = bin2dec(num2str(d_24(9:24)))*2^4;

% creating new word2 with create_HOW func
word8_encoded = create_word8(iodc, t_oc, D29_star, D30_star);

% checking if arrays match
if sum(D == word8_encoded) == 30
    disp "succsses"
else
    disp "failed"
end



function word8_encoded = create_word8(iodc, t_oc, D29_star, D30_star)
            %create 8th word of subframe 1
            %iodc - issue of data clock in decimal (positive integer). 
            % the 8 LSBs are assigned to the 8 MSBs of word 8.
            % t_oc - time of clock (in seconds), range 0-604,784. this
            % should match t_oe (time of ephemeris)
            iodc_bin = convert2bin(iodc,1,10)-'0';
            %iodc_bin = convert2bin(iodc, 1, 10);
            t_oc_bin_scaled = convert2bin(t_oc,2^4,16)-'0'; %scaled s.t LSB is 2^4 sec (low res)
            %t_oc_bin_scaled = convert2bin(t_oc, 2^4, 16);
            word8_encoded = hamming_parity(cat(2,iodc_bin(3:end),t_oc_bin_scaled), D29_star, D30_star);
        end