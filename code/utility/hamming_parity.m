function D = hamming_parity(d,D29_star,D30_star)
%HAMMING_PARITY calculates paity encoding
%   d - 24 MSB bits of a word
%   D29_star - 29th bit of last word
%   D30_star - 30th bit of last word
%   D - 30 encoded bits
D = zeros(1,30);
D(1:24) = xor(d,D30_star);

%indices of bits in the original data which participate in XOR operations.
ind_25 = [1 2 3 5 6 10 11 12 13 14 17 18 20 23];
ind_26 = [2 3 4 6 7 11 12 13 14 15 18 19 21 24];
ind_27 = [1 3 4 5 7 8 12 13 14 15 16 19 20 22];
ind_28 = [2 4 5 6 8 9 13 14 15 16 17 20 21 23];
ind_29 = [1 3 5 6 7 9 10 14 15 16 17 18 21 22 24];
ind_30 = [3 5 6 8 9 10 11 13 15 19 22 23 24];

D(25) = mod(D29_star+sum(d(ind_25)),2);
D(26) = mod(D30_star+sum(d(ind_26)),2);
D(27) = mod(D29_star+sum(d(ind_27)),2);
D(28) = mod(D30_star+sum(d(ind_28)),2);
D(29) = mod(D30_star+sum(d(ind_29)),2);
D(30) = mod(D29_star+sum(d(ind_30)),2);

end

