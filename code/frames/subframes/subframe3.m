classdef subframe3 < handle
    %SUBFRAME3 Summary of this class goes here
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
        subframe_id = 3; %number of subframe
    end
    methods
        function obj = subframe3()
            %SUBFRAME3 Construct an instance of this class
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

        function create_words_3_4(obj, C_ic, omg0)
            %create words 3 and 4 of subframe 3.
            %C_ic = Amplitude of the Cosine Harmonic Correction Term to the
            % Angle of Inclination in radians, decimal.
            %omg0 = Longitude of Ascending Node of Orbit Plane at Weekly 
            % Epoch, in units of semi-circles, decimal.

            C_ic_bin = convert2bin(C_ic,2^-29,16) - '0'; %16 bits, LSB's weight is 2^-29
            omg0_bin = convert2bin(omg0,2^-31,32) - '0'; %32 bits, LSB's weight is 2^-31
            omg0_bin = omg0_bin(end-31:end);
            omg0_bin_8_MSB = omg0_bin(1:8);
            omg0_bin_24_LSB = omg0_bin(9:end);

            obj.words_raw(3,:) = cat(2, C_ic_bin, omg0_bin_8_MSB); % 24 raw data bits of word 3
            obj.words_encoded(3,:) = hamming_parity(obj.words_raw(3,:), obj.words_encoded(2,29), obj.words_encoded(2,30)); % 30 encoded bits of word 3

        end

        function create_words_5_6(obj, C_is, i_0)
            %create words 5 and 6 of subframe 3
            %C_is = Amplitude of the Sine Harmonic Correction Term to the
            % Angle of Inclination in radians, decimal.
            %i_0 = Inclination Angle at Reference Time in units of
            %semi-circles, decimal.

            C_is_bin = convert2bin(C_is,2^-29,16)-'0'; %16 bits, LBS's weight is 2^-29
            i_0_bin = convert2bin(i_0,2^-31,32)-'0';%32 bits, LSB's weight is 2^-31
            i_0_bin_8_MSB = i_0_bin(1:8); %8 MSBs of i0
            i_0_bin_24_LSB = i_0_bin(9:end); %24 LSBs of i0

            obj.words_raw(5,:) = cat(2,C_is_bin,i_0_bin_8_MSB); %24 raw data bits of word 5
            obj.words_encoded(5,:) = hamming_parity(obj.words_raw(5,:), obj.words_encoded(4,29), obj.words_encoded(4,30)); %30 encoded bits of word 5

            obj.words_raw(6,:) = i_0_bin_24_LSB;%24 raw data bits of word 6
            obj.words_encoded(6,:) = hamming_parity(obj.words_raw(6,:),obj.words_encoded(5,29), obj.words_encoded(5,30));%30 encoded bits of word 6
        end

        function create_words_7_8(obj, C_rc, omega)
            %create words 7 and 8 of subframe 3
            %C_rc = Amplitude of the Cosine Harmonic Correction Term to the
            % Orbit Radius in meters, decimal
            %omega = Argument of Perigee in semi-circles, decimal.

            C_rc_bin = convert2bin(C_rc,2^-5,16)-'0'; %16 bits, LBS's weight is 2^-5
            omega_bin = convert2bin(omega,2^-31,32)-'0';%32 bits, LSB's weight is 2^-31 
            omega_bin_8_MSB = omega_bin(1:8); %8 MSBs of omega
            omega_bin_24_LSB = omega_bin(9:end); %24 LSBs of omega

            obj.words_raw(7,:) = cat(2,C_rc_bin,omega_bin_8_MSB); %24 raw data bits of word 7
            obj.words_encoded(7,:) = hamming_parity(obj.words_raw(7,:), obj.words_encoded(6,29), obj.words_encoded(6,30)); %30 encoded bits of word 7

            obj.words_raw(8,:) = omega_bin_24_LSB;%24 raw data bits of word 8
            obj.words_encoded(8,:) = hamming_parity(obj.words_raw(8,:),obj.words_encoded(7,29), obj.words_encoded(7,30));%30 encoded bits of word 8
        end
        
        function create_words_9_10(obj, OMEGA_dot, IODC, i_dot)
            %create words 9 and 10 of subframe 3
            %OMEGA_dot = Rate of Right Ascension, in units of
            %semi-circles/sec.
            %IODC = issue of data clock, contains the IODE which this
            %function uses.
            %i_dot = Rate of Inclination Angle, in units of
            %semi_circles/sec.

            OMEGA_dot_bin = convert2bin(OMEGA_dot,2^-43,24)-'0';%24 bits, LSB's weight is 2^-43
            IODC_bin = convert2bin(IODC,1,10) - '0'; %10 bits of IODC.
            IODE_bin = IODC_bin(3:end); % 8 LSBs of the IODC is the IODE.
            i_dot_bin = convert2bin(i_dot,2^-43,14); %14 bits, LSB's weight is 2^-43
            obj.words_raw(9,:) = OMEGA_dot_bin;%24 raw data bits of word 9
            obj.words_encoded(9,:) = hamming_parity( obj.words_raw(9,:),obj.words_encoded(8,29),obj.words_encoded(8,30));%30 encoded bits of word 9


            MSB_22 = cat(2,IODE_bin,i_dot_bin);
            %bits 23-24 needs to be solved for bits 29-30 = 0 after parity
            ind_29_ = [1 3 5 6 7 9 10 14 15 16 17 18 21 22];
            ind_30_ = [3 5 6 8 9 10 11 13 15 19 22];

            bit24 = mod(obj.words_encoded(9,30) + sum(MSB_22(ind_29_)),2); %calculated 24th bit
            bit23 = mod(obj.words_encoded(9,29) + sum(MSB_22(ind_30_)) + bit24, 2); %calculated 23rd bit


            obj.words_raw(10,:) = cat(2, MSB_22, bit23, bit24); %24 raw data bits of word 10
            obj.words_encoded(10,:) = hamming_parity(obj.words_raw(10,:),obj.words_encoded(9,29),obj.words_encoded(9,30));%30 encoded bits of word 10
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

