classdef subframe2 < handle
    %SUBFRAME2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        words_raw % a 10 by 30 matrix to store 10 words, 1 word for each row, before running parity coding.
        words_encoded % a 10 by 30 matrix to store 10 words, 1 word for each row, after running parity coding.
        bit_stream % 300 bits array of subframe bitstream.
    end
    properties(Constant , Access=protected)
        N_words = 10; %number of words in a subframe
        bits_word = 30; %number of bits in encoded word
        N_data_bits = 24; %number of raw data bits in a word before encoding
        subframe_id = 2; %number of subframe
    end
    methods
        function obj = subframe2()
            %SUBFRAME2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.words_encoded = zeros(obj.N_words,obj.bits_word);
            obj.words_raw = zeros(obj.N_words, obj.N_data_bits);
        end
        
        function create_word1(obj, TLM_msg)
            %create_word1 creates parity encoded TLM word and sets it as
            %word 1 of subframe 1
            %TLM_msg = 14 bits TLM message
            
            [obj.words_raw(1,:), obj.words_encoded(1,:)] = Create_TLM_Word(TLM_msg);
        end

        function create_word2(obj, TOW, alert_flag, AS_flag)
            %create_word2 creates parity encoded HOW word and sets it as
            %word 2 of subframe 1
            %   TOW - time of week in seconds, valid values are integers between 0 and 604,799.
            %   alert_flag - URA alert flah, 1 bit 
            %   AS_flag - anti spoofing flag, 1 bit 

            [obj.words_raw(2,:), obj.words_encoded(2,:)] = Create_HOW(TOW, alert_flag, AS_flag, obj.subframe_id, obj.words_encoded(1,29), obj.words_encoded(1,30));
        end

        function create_word3(obj, IODC, C_rs)
            %create word 3 of subfame 2.
            % IODC - Issue of data clock, in decimal (whole positive
            % number). needs to be the same as the previous frame.
            %C_rs - Amplitude of the Cosine Harmonic Correction Term to 
            % the Orbit Radius,in meters.
            
            IODC_bin = convert2bin(IODC,1,10) - '0'; %10 bits of IODC.
            IODE_bin = IODC_bin(3:end); % 8 LSBs of the IODC is the IODE.
            C_rs_bin = convert2bin(C_rs,2^-5,16) - '0'; %16 bits with LSB's weight of 2^-5 meters.

            obj.words_raw(3,:) = cat(2,IODE_bin,C_rs_bin); %24 raw data bits before parity.
            obj.words_encoded(3,:) =  hamming_parity(obj.words_raw(3,:), obj.words_encoded(2,29), obj.words_encoded(2,30)); %parity encoding and adding 3rd word to object's word property.
        end

        function create_words_4_5(obj, delta_n, M_0)
            % create words 4 and 5 of subframe 2
            %delta_n is Mean Motion Difference From Computed Value, given
            %in decimal, units of semi-circles/sec
            %M_0 = Mean Anomaly at Reference Time, in decimal, units of
            %semi-circles. only 8 MSBs are used in this word

            delta_n_bin = convert2bin(delta_n,2^-43,16)-'0'; %16 bits of delta_n, LSBs weight is 2^-43
            M_0_bin = convert2bin(M_0,2^-31,32)-'0'; %32 bits of M_0, LSBs weight is 2^-31.
            M_0_bin_8_MSB = M_0_bin(1:8); %8 MSBs of M_0
            M_0_bin_24_LSB = M_0_bin(9:end); %24 LSBs of M0 for word 5

            obj.words_raw(4,:) = cat(2,delta_n_bin,M_0_bin_8_MSB); %24 raw data bits of word 4
            obj.words_encoded(4,:) = hamming_parity(obj.words_raw(4,:),obj.words_encoded(3,29), obj.words_encoded(3,30)); %30 encoded bits of word 4

            obj.words_raw(5,:) = M_0_bin_24_LSB; %24 raw data bits of word 5
            obj.words_encoded(5,:) = hamming_parity(obj.words_raw(5,:),obj.words_encoded(4,29), obj.words_encoded(4,30)); %30 encoded bits of word 5
        end

        function create_words_6_7(obj,C_uc, e)
            % create words 6 and 7 of subframe 2
            %C_uc = Amplitude of the Cosine Harmonic Correction Term to 
            % the Argument of Latitude in radians
            % e = Eccentricity (dimensionless)

            C_uc_bin = convert2bin(C_uc,2^-29,16)-'0'; %16 bits, LSBs weight is 2^-29
            e_bin = convert2bin(e,2^-33,32)-'0'; %32 bits, LSBs weight is 2^-33
            e_bin_8_MSB = e_bin(1:8); %8 MSBs of e (for word 6)
            e_bin_24_LSB = e_bin(9:end); %24 LSBs of e (for word 7)
            
            obj.words_raw(6,:) = cat(2,C_uc_bin,e_bin_8_MSB); % 24 raw data bits of word 6
            obj.words_encoded(6,:) = hamming_parity(obj.words_raw(6,:),obj.words_encoded(5,29),obj.words_encoded(5,30)); % 30 encoded bits of word 6
            
            obj.words_raw(7,:) = e_bin_24_LSB; % 24 raw data bits of word 7
            obj.words_encoded(7,:) = hamming_parity(obj.words_raw(7,:),obj.words_encoded(6,29),obj.words_encoded(6,30)); % 30 encoded bits of word 7
        end

        function create_words_8_9(obj, C_us, sqrtA)
            %create words 8 and 9 of subframe 2
            %C_us = Amplitude of the Sine Harmonic Correction Term to the 
            % Argument of Latitude, in radians.
            %sqrtA = Square Root of the Semi-Major Axis, in meters^0.5

            C_us_bin = convert2bin(C_us,2^-29,16)-'0'; %16 bits, LSBs weight is 2^-29
            sqrtA_bin = convert2bin(sqrtA,2^-19,32)-'0'; %32 bits, LSB's weight us 2^-19
            sqrtA_bin_8_MSB = sqrtA_bin(1:8); %8 MSBs of sqrtA (for word 8)
            sqrtA_bin_24_LSB = sqrtA_bin(9:end); %24 LSBs of sqrtA (for word 9)

            obj.words_raw(8,:) = cat(2,C_us_bin,sqrtA_bin_8_MSB); %24 raw data bits of word 8
            obj.words_encoded(8,:) = hamming_parity(obj.words_raw(8,:), obj.words_encoded(7,29), obj.words_encoded(7,30)); %30 endcoded bits of word 8

            obj.words_raw(9,:) = sqrtA_bin_24_LSB; %24 raw data bits of word 9
            obj.words_encoded(9,:) = hamming_parity(obj.words_raw(9,:),obj.words_encoded(8,29),obj.words_encoded(8,30));% 30 encoded bits of word 9
        end

        function create_word10(obj, t_oe, fit_int_flag, AODO)
            %t_oe = Reference Time Ephemeris, devimal in seconds.
            % fit_int_flag = fir interval flag. determines the fit interval
            % used by the CS in determining the ephemeris as follows:
            %0 = 4 hours, 1 = greater than 4 hours.
            %AODO age of data offset in units of 900 seconds (5 bits)
            AODO = [0 0 0 0 0]; %override given AODO value
            fit_int_flag = 0; %override given flag value
            
            t_oe_bin = convert2bin(t_oe,2^4,16)-'0'; %16 bits, LSBs weight is 2^4

            MSB_22 = cat(2, t_oe_bin, fit_int_flag, AODO);

            %bits 23-24 needs to be solved for bits 29-30 = 0 after parity
            ind_29_ = [1 3 5 6 7 9 10 14 15 16 17 18 21 22];
            ind_30_ = [3 5 6 8 9 10 11 13 15 19 22];

            bit24 = mod(obj.words_encoded(9,30) + sum(MSB_22(ind_29_)),2); %calculated 24th bit
            bit23 = mod(obj.words_encoded(9,29) + sum(MSB_22(ind_30_)) + bit24, 2); %calculated 23rd bit

            obj.words_raw(10,:) = cat(2, MSB_22, bit23, bit24); %24 raw data bits of word 10
            obj.words_encoded(10,:) = hamming_parity(obj.words_raw(10,:),obj.words_encoded(9,29),obj.words_encoded(9,30)); %30 encoded bits of word 10
        end

        function subframe_bitstream = create_bitstream(obj)
            %creates a 1 by 300 array of entire subframe bitstream and
            %returns it, also assigns it to bit_stream property of the
            %object
            obj.bit_stream = reshape(obj.words_encoded',1,[]);
            subframe_bitstream = obj.bit_stream;
        end
    end
end

