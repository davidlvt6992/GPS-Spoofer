clc; clear
load('C:\Users\levit\Desktop\studying\Technion\NinthSemester\GPS proj\GPS-Spoofer\data\bitsream.mat')
stream = bitstream{1};
frame = stream(857:1156);
D30_star_5 = frame(120);
D29_star_5 = frame(119);
D5 = frame(121:150);
D30_star_6 = frame(150);
D29_star_6 = frame(149);
D6 = frame(151:180);

% getting 24 bits before encoding
d_24_5 = xor(D5(1:24),D30_star_5);
d_24_6 = xor(D6(1:24),D30_star_6);


% getting special params
C_is = bin2dec(num2str(d_24_5(1:16))) * 2^-29;
i_0 = bin2dec(num2str(cat(2,d_24_5(17:24), d_24_6))) * 2^-31;


% creating new word2 with create_HOW func
[word5_encoded , word6_encoded] = create_words_5_6(C_is, i_0, D29_star_5, D30_star_5, D29_star_6, D30_star_6);

% checking if arrays match
if sum(D5 == word5_encoded) == 30
    disp "succsses"
else
    disp "failed"
end

if sum(D6 == word6_encoded) == 30
    disp "succsses"
else
    disp "failed"
end


        function [word5_encoded, word6_encoded] = create_words_5_6(C_is, i_0, D29_star_5, D30_star_5, D29_star_6, D30_star_6)
            %create words 5 and 6 of subframe 3
            %C_is = Amplitude of the Sine Harmonic Correction Term to the
            % Angle of Inclination in radians, decimal.
            %i_0 = Inclination Angle at Reference Time in units of
            %semi-circles, decimal.

            C_is_bin = convert2bin(C_is,2^-29,16)-'0'; %16 bits, LBS's weight is 2^-29
            i_0_bin = convert2bin(i_0,2^-31,32)-'0';%32 bits, LSB's weight is 2^-31
            i_0_bin_8_MSB = i_0_bin(1:8); %8 MSBs of i0
            i_0_bin_24_LSB = i_0_bin(9:end); %24 LSBs of i0

            word5_encoded = hamming_parity(cat(2,C_is_bin,i_0_bin_8_MSB), D29_star_5, D30_star_5); %30 encoded bits of word 5

            word6_encoded = hamming_parity(i_0_bin_24_LSB, D29_star_6, D30_star_6);%30 encoded bits of word 6
        end