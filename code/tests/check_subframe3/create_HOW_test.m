clc; clear
load('C:\Users\levit\Desktop\studying\Technion\NinthSemester\GPS proj\GPS-Spoofer\data\bitsream.mat')
stream = bitstream{1};
frame = stream(857:1156);
D30_star = frame(30);
D29_star = frame(29);
D = frame(31:60);


% getting 24 bits before encoding
d_24 = xor(D(1:24),D30_star);

% getting special params
TOW = bin2dec(num2str(d_24(1:17)))*6;
alert_flag = d_24(18);
AS_flag = d_24(19);
subframe_ID = bin2dec(num2str(d_24(20:22)));

% creating new word2 with create_HOW func
[a HOW_encoded] = Create_HOW(TOW, alert_flag, AS_flag, subframe_ID, D29_star, D30_star);

% checking if arrays match
if sum(D == HOW_encoded) == 30
    disp "succsses"
else
    disp "failed"
end
