function bin = convert2bin(dec,LSB_weight,N)
    %CONVERT2BIN converts the decimal number dec to a binary number bin
    %with LSB's weight of LSB_weight. comp_flag indicates whether 2's
    %complement is needed of not. comp_flag = 0 - no 2's complement ;
    %comp_flag = 1 - use 2's complement
    %bin is an array
    %N is the number of bits to use.
    dec_weight = dec/LSB_weight;
    sgn = sign(dec_weight);
    bin_string = dec2bin(dec_weight,N);
    bin_string = bin_string(end-N+1:end);
    bin = bin_string;
end

