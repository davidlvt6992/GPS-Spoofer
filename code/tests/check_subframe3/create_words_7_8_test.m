clc; clear
load('C:\Users\levit\Desktop\studying\Technion\NinthSemester\GPS proj\GPS-Spoofer\data\bitsream.mat')
stream = bitstream{1};
frame = stream(857:1156);
D30_star_7 = frame(180);
D29_star_7 = frame(179);
D7 = frame(181:210);
D30_star_8 = frame(210);
D29_star_8 = frame(209);
D8 = frame(211:240);

% getting 24 bits before encoding
d_24_7 = xor(D7(1:24),D30_star_7);
d_24_8 = xor(D8(1:24),D30_star_8);


% getting special params
C_rc = bin2dec(num2str(d_24_7(1:16))) * 2^-5;
omega = bin2dec(num2str(cat(2,d_24_7(17:24), d_24_8))) * 2^-31;


% creating new word2 with create_HOW func
[word7_encoded , word8_encoded] = create_words_7_8(C_rc, omega, D29_star_7, D30_star_7, D29_star_8, D30_star_8);

% checking if arrays match
if sum(D7 == word7_encoded) == 30
    disp "succsses"
else
    disp "failed"
end

if sum(D8 == word8_encoded) == 30
    disp "succsses"
else
    disp "failed"
end






function [word7_encoded, word8_encoded] = create_words_7_8(C_rc, omega, D29_star_7, D30_star_7, D29_star_8, D30_star_8)
            %create words 7 and 8 of subframe 3
            %C_rc = Amplitude of the Cosine Harmonic Correction Term to the
            % Orbit Radius in meters, decimal
            %omega = Argument of Perigee in semi-circles, decimal.

            C_rc_bin = convert2bin(C_rc,2^-5,16)-'0'; %16 bits, LBS's weight is 2^-5
            omega_bin = convert2bin(omega,2^-31,32)-'0';%32 bits, LSB's weight is 2^-31 
            omega_bin_8_MSB = omega_bin(1:8); %8 MSBs of omega
            omega_bin_24_LSB = omega_bin(9:end); %24 LSBs of omega

            word7_encoded = hamming_parity(cat(2,C_rc_bin,omega_bin_8_MSB), D29_star_7, D30_star_7); %30 encoded bits of word 7

            word8_encoded = hamming_parity(omega_bin_24_LSB, D29_star_8, D30_star_8);%30 encoded bits of word 8
        end