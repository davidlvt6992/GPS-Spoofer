clc; clear
load('C:\Users\levit\Desktop\studying\Technion\NinthSemester\GPS proj\GPS-Spoofer\data\bitsream.mat')
stream = bitstream{1};
frame = stream(857:1156);
D30_star_3 = frame(60);
D29_star_3 = frame(59);
D3 = frame(61:90);
D30_star_4 = frame(90);
D29_star_4 = frame(89);
D4 = frame(91:120);

% getting 24 bits before encoding
d_24_3 = xor(D3(1:24),D30_star_3);
d_24_4 = xor(D4(1:24),D30_star_4);


% getting special params
C_ic = bin2dec(num2str(d_24_3(1:16))) * 2^-29;
omg0 = bin2dec(num2str(cat(2,d_24_3(17:24), d_24_4))) * 2^-31;


% creating new word2 with create_HOW func
[word3_encoded , word4_encoded] = create_words_3_4(C_ic, omg0, D29_star_3, D30_star_3, D29_star_4, D30_star_4);

% checking if arrays match
if sum(D3 == word3_encoded) == 30
    disp "succsses"
else
    disp "failed"
end

if sum(D4 == word4_encoded) == 30
    disp "succsses"
else
    disp "failed"
end



function [word3_encoded, word4_encoded] = create_words_3_4(C_ic, omg0, D29_star_3, D30_star_3, D29_star_4, D30_star_4)
            %create words 3 and 4 of subframe 3.
            %C_ic = Amplitude of the Cosine Harmonic Correction Term to the
            % Angle of Inclination in radians, decimal.
            %omg0 = Longitude of Ascending Node of Orbit Plane at Weekly 
            % Epoch, in units of semi-circles, decimal.

            C_ic_bin = convert2bin(C_ic,2^-29,16) - '0'; %16 bits, LSB's weight is 2^-29
            omg0_bin = convert2bin(omg0,2^-31,32) - '0'; %32 bits, LSB's weight is 2^-31
            omg0_bin = omg0_bin(end-31:end);
            omg0_bin_8_MSB = omg0_bin(1:8);
            omg0_bin_24_LSB = omg0_bin(9:end);

            word3_encoded = hamming_parity(cat(2, C_ic_bin, omg0_bin_8_MSB), D29_star_3, D30_star_3);
            word4_encoded = hamming_parity(omg0_bin_24_LSB, D29_star_4, D30_star_4);

end