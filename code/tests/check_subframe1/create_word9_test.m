clc; clear
load('C:\Users\levit\Desktop\studying\Technion\NinthSemester\GPS proj\GPS-Spoofer\data\bitsream.mat')
stream = bitstream{1};
frame = stream(257:556);
D30_star = frame(240);
D29_star = frame(239);
D = frame(241:270);

% getting 24 bits before encoding
d_24 = xor(D(1:24),D30_star);

% getting special params
af2 = bin2dec(num2str(d_24(1:8))) * 2^-55;
af1 = bin2dec(num2str(d_24(9:24))) * 2^-43;

% creating new word2 with create_HOW func
word9_encoded = create_word9(af2, af1, D29_star, D30_star);

% checking if arrays match
if sum(D == word9_encoded) == 30
    disp "succsses"
else
    disp "failed"
end


function word9_encoded = create_word9(af2, af1, D29_star, D30_star)
            %creates the 9th word of subframe 1
            % af2 = in units of sec/sec^2, will be assigned to the first 8
            % of the word with a scale of 2^-55 at the LSB
            % af1 =  in units of sec/sec, will be assigned to bits 9-24 of
            % the word woth a scale of 2^-43 at the LSB
            af2_bin = convert2bin(af2,2^-55,8) - '0';
            af1_bin = convert2bin(af1,2^-43,16) - '0';
            %af2_bin = convert2bin(af2,2^-55,8);
            %af1_bin = convert2bin(af1,2^-43,16);
            word9_encoded = hamming_parity(cat(2, af2_bin, af1_bin), D29_star, D30_star);
        end
