clc; clear
load('C:\Users\levit\Desktop\studying\Technion\NinthSemester\GPS proj\GPS-Spoofer\data\bitsream.mat')
stream = bitstream{1};
frame = stream(857:1156);
D30_star = 0;
D29_star = 0;
D = frame(1:30);

% getting 24 bits before encoding
d_24 = xor(D(1:24),D30_star);

% getting special params
TLM_msg = d_24(9:22);

% creating new word2 with create_HOW func
[a , TLM_word_encoded] = Create_TLM_Word(TLM_msg);

% checking if arrays match
if sum(D == TLM_word_encoded) == 30
    disp "succsses"
else
    disp "failed"
end
