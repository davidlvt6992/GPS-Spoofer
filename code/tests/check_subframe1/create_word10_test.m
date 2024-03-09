clc; clear
load('C:\Users\levit\Desktop\studying\Technion\NinthSemester\GPS proj\GPS-Spoofer\data\bitsream.mat')
stream = bitstream{1};
frame = stream(257:556);
D30_star = frame(270);
D29_star = frame(269);
D = frame(271:300);

% getting 24 bits before encoding
d_24 = xor(D(1:24),D30_star);

% getting special params
af0 = d_24(1:22)*2^-31;

% creating new word2 with create_HOW func
word10_encoded = create_word10(af0, D29_star, D30_star);

% checking if arrays match
if sum(D == word10_encoded) == 30
    disp "succsses"
else
    disp "failed"
end

        function word10_encoded = create_word10(af0, D29_star, D30_star)
            %create 10th word of subframe 1
            %af0 - in seconds, will be assigned to 22 MSBs of the word, LSB
            %scale is 2^-31
            %af0_bin = convert2bin(af0,2^-31,22)-'0';
            af0_bin = convert2bin(af0,2^-31,22);

            %bits 23-24 needs to be solved for bits 29-30 = 0 after parity
            ind_29_ = [1 3 5 6 7 9 10 14 15 16 17 18 21 22];
            ind_30_ = [3 5 6 8 9 10 11 13 15 19 22];

            bit24 = mod(D30_star + sum(af0_bin(ind_29_)),2);
            bit23 = mod(D29_star + sum(af0_bin(ind_30_)) + bit24, 2);
            word10_encoded = hamming_parity(cat(2, af0_bin, bit23, bit24), D29_star, D30_star);

        end