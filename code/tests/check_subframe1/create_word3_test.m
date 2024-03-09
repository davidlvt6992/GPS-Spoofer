clc; clear
load('C:\Users\levit\Desktop\studying\Technion\NinthSemester\GPS proj\GPS-Spoofer\data\bitsream.mat')
stream = bitstream{1};
frame = stream(257:556);
D30_star = frame(60);
D29_star = frame(59);
D = frame(61:90);

% getting 24 bits before encoding
d_24 = xor(D(1:24),D30_star);

% getting special params
week_number = bin2dec(num2str(d_24(1:10)));
code = d_24(11:12);
URA_bit = d_24(13:16);
sv_health_bits = d_24(17:22); 
iodc = bin2dec(num2str(d_24(23:24)));

% creating new word2 with create_HOW func
word3_encoded = create_word3(week_number, code, URA_bit, sv_health_bits, iodc, D29_star, D30_star);

% checking if arrays match
if sum(D == word3_encoded) == 30
    disp "succsses"
else
    disp "failed"
end




function word3_encoded = create_word3(week_number, code, URA_bits,sv_health_bits, iodc, D29_star, D30_star)
            %create_word3 creates the 3rd word of subframe 1, and adds it
            %to the words of the object. this function must be called after
            %creating the word 1 and 2 (which are created during initial
            %construction)
            %   week_number = number of weeks in decimal
            %   code = 2 bits (As an array), 01 - p code ; 10 - C/A code
            %   (bits 11-12)
            %   URA_bits = 4 bits (as an array) that indicated URA index.
            %   (bits 13-16)
            %   sv_health_bits = 6 bits (as an array) that indicates SV
            %   health (bits 17-22)
            %   iodc - issue of data clock, given in decimal. the 2 MSBs
            %   are mapped to bits 23-24 of word 3 in subframe 1.
            
            week_number_bin = convert2bin(week_number,1,10)-'0';
            %week_number_bin = convert2bin(week_number,1,10);
            iodc_bin = convert2bin(iodc,1,10)-'0';
            %iodc_bin = convert2bin(iodc,1,10);
            iodc_bin_2MSB = iodc_bin(1:2);
            word3_24 = cat(2,week_number_bin, code, URA_bits, sv_health_bits, iodc_bin_2MSB);
            word3_encoded = hamming_parity(word3_24, D29_star, D30_star);
        end
