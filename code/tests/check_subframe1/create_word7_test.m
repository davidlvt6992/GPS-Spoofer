clc; clear
load('C:\Users\levit\Desktop\studying\Technion\NinthSemester\GPS proj\GPS-Spoofer\data\bitsream.mat')
stream = bitstream{1};
frame = stream(257:556);
D30_star = frame(180);
D29_star = frame(179);
D = frame(181:210);

% getting 24 bits before encoding
d_24 = xor(D(1:24),D30_star);


% getting special params
T_GD =  bin2dec(num2str(d_24(17:24))) * 2^-31;

% creating new word2 with create_HOW func
word7_encoded = create_word7(T_GD, D29_star, D30_star);

% checking if arrays match
if sum(D(17:24) == word7_encoded(17:24)) == 8
    disp "succsses"
else
    disp "failed"
end

function word7_encoded = create_word7(T_GD, D29_star, D30_star)
            %creates 7th word of subframe 1
            % T_GD = the group delay in seconds. should be assigned
            % to bits 17-24, signed.

            %override given value, comment to disable
            %T_GD = 0;
            
            reserved_bits_1_16 = zeros(1,16); %first 16 bits are reserve
            T_GD_bits = convert2bin(T_GD,2^-31, 8)-'0'; %8 scaled TGD signed bits
            %T_GD_bits = convert2bin(T_GD,2^-31, 8);
            word7_pre  = cat(2,reserved_bits_1_16, T_GD_bits);
            word7_encoded = hamming_parity(word7_pre, D29_star, D30_star);
        end