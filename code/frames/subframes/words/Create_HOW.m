function [HOW_raw, HOW_encoded] = Create_HOW(TOW, alert_flag, AS_flag, subframe_ID, D29_star, D30_star)
%CREATE_HOW creates HOW (including parity encoding)
%   TOW - time of week in seconds, valid values are integers between 0 and 604,799.
%   alert_flag - URA alert flah, 1 bit (bit 18)
%   AS_flag - anti spoofing flag, 1bit (bit 19)
%   subframe_ID - number of frame in decimal, valid values are integers
%   between 1 and 5
%   D29_star, D30_star are the 29th and 30th bits of the previous word,
%   respectively.
    
    %set defualts, comment to disable.
    TOW = 15000*6;
    alert_flag = 0;
    AS_flag = 0;
    
    %convert TOW from seconds to formatted 17 bits with LSB of 6 seconds
    TOW_LSB = 6; %seconds
    N_TOW_bits = 17;
    TOW_bin = dec2bin(round(TOW/TOW_LSB) , N_TOW_bits) - '0'; %'0' substraction to achieve array and not a string
    subframe_ID_bin = dec2bin(subframe_ID,3) - '0'; % '0' substraction to achieve array and not a string

    HOW_pre_parity = cat(2,TOW_bin, alert_flag, AS_flag, subframe_ID_bin); %concat 22 pre encoded data bits

    %calculate bits 23-24 s.t bits 29-30 will be 0 after encoding
    ind_29_ = [1 3 5 6 7 9 10 14 15 16 17 18 21 22];
    ind_30_ = [3 5 6 8 9 10 11 13 15 19 22];
    bit24 = mod(D30_star + sum(HOW_pre_parity(ind_29_)),2);
    bit23 = mod(D29_star + sum(HOW_pre_parity(ind_30_)) + bit24, 2);
    
    HOW_raw = cat(2,HOW_pre_parity, bit23, bit24); %add calculated 23-34 bits s.t parity bits 29-30 will be 0.

    HOW_encoded = hamming_parity(HOW_raw,D29_star,D30_star); %30 bits post parity encoding
end

