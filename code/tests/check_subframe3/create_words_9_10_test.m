clc; clear
load('C:\Users\levit\Desktop\studying\Technion\NinthSemester\GPS proj\GPS-Spoofer\data\bitsream.mat')
stream = bitstream{1};
frame = stream(857:1156);
D30_star_9 = frame(240);
D29_star_9 = frame(239);
D9 = frame(241:270);
D30_star_10 = frame(270);
D29_star_10 = frame(269);
D10 = frame(271:300);

% getting 24 bits before encoding
d_24_9 = xor(D9(1:24),D30_star_9);
d_24_10 = xor(D10(1:24),D30_star_10);


% getting special params
OMEGA_dot = bin2dec(num2str(d_24_9)) * 2^-43;
IODC = bin2dec(num2str(d_24_10(1:8)));
i_dot = bin2dec(num2str(d_24_10(9:22)))* 2^-43;


% creating new word2 with create_HOW func
[word9_encoded , word10_encoded] = create_words_9_10(OMEGA_dot, IODC, i_dot, D29_star_9, D30_star_9, D29_star_10, D30_star_10);

% checking if arrays match
if sum(D9 == word9_encoded) == 30
    disp "succsses"
else
    disp "failed"
end

if sum(D10 == word10_encoded) == 30
    disp "succsses"
else
    disp "failed"
end




function [word9_encoded , word10_encoded] = create_words_9_10(OMEGA_dot, IODC, i_dot, D29_star_9, D30_star_9, D29_star_10, D30_star_10)
            %create words 9 and 10 of subframe 3
            %OMEGA_dot = Rate of Right Ascension, in units of
            %semi-circles/sec.
            %IODC = issue of data clock, contains the IODE which this
            %function uses.
            %i_dot = Rate of Inclination Angle, in units of
            %semi_circles/sec.

            OMEGA_dot_bin = convert2bin(OMEGA_dot,2^-43,24)-'0';%24 bits, LSB's weight is 2^-43
            IODC_bin = convert2bin(IODC,1,10) - '0'; %10 bits of IODC.
            IODE_bin = IODC_bin(3:end); % 8 LSBs of the IODC is the IODE.
            i_dot_bin = convert2bin(i_dot,2^-43,14) - '0'; %14 bits, LSB's weight is 2^-43
            word9_encoded = hamming_parity( OMEGA_dot_bin, D29_star_9, D30_star_9);%30 encoded bits of word 9


            MSB_22 = cat(2,IODE_bin,i_dot_bin);
            %bits 23-24 needs to be solved for bits 29-30 = 0 after parity
            ind_29_ = [1 3 5 6 7 9 10 14 15 16 17 18 21 22];
            ind_30_ = [3 5 6 8 9 10 11 13 15 19 22];

            bit24 = mod(D30_star_10 + sum(MSB_22(ind_29_)),2); %calculated 24th bit
            bit23 = mod(D29_star_10 + sum(MSB_22(ind_30_)) + bit24, 2); %calculated 23rd bit
            word10_encoded = hamming_parity(cat(2, MSB_22, bit23, bit24), D29_star_10, D30_star_10);%30 encoded bits of word 10
        end