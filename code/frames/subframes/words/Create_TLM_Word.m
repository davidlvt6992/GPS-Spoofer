function [TLM_word_raw, TLM_word_encoded] = Create_TLM_Word(TLM_msg)
    %the functions returns 30 MSBs of the TLM word (encoded after parity) 
    %   TLM_msg is 14 bits TLM msg

    %override given value, comment to disable
    TLM_msg = zeros(1,14); 

    
    integrity_flag_bit23 = 0;
    spare_bit24 = 0;

    preamble = [1 0 0 0 1 0 1 1];
    TLM_word_raw = cat(2,preamble,TLM_msg,integrity_flag_bit23,spare_bit24); %unencoded data bits
    TLM_word_encoded = hamming_parity(TLM_word_raw,0,0); %encoded data + parity bits
end

