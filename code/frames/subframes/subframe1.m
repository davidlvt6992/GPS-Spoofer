classdef subframe1 < handle
    %this class handles the creation of subframe1
    %   the proper way to use this clasee is as follows:
    %1.create an object of the class ,e.g sf1.
    %2.create words by calling sf1.create_wordx where x is the number of
    %word at the subframe. each methods requires different fields. it's
    %important to create the the words by order - from first to last.
    %3.create bitstream by calling create_bitstream method.

    
    properties
        words_raw % a 10 by 30 matrix to store 10 words, 1 word for each row, before running parity coding.
        words_encoded % a 10 by 30 matrix to store 10 words, 1 word for each row, after running parity coding.
        bit_stream % 300 bits array of subframe bitstream.
    end
    properties(Constant , Access=protected)
        N_words = 10; %number of words in a subframe
        bits_word = 30; %number of bits in encoded word
        N_data_bits = 24; %number of raw data bits in a word before encoding
        subframe_id = 1;
%         Code_bits = [1 0] % code bits for word 3, 10 - C/A ; 01 - P.
    end
    methods
        function obj = subframe1()
            %SUBFRAME1 Construct an instance of this class)
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

        function create_word3(obj,week_number, code, URA_bits,sv_health_bits, iodc)
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
            
            %override given values to defaults, comment to disable
            code = [1 0];
            URA_bits = [0 0 0 0]; %small URA
            sv_health_bits = [0 0 0 0 0 0]; %all nav data are ok

            week_number_bin = convert2bin(week_number,1,10)-'0';
            iodc_bin = convert2bin(iodc,1,10)-'0';
            iodc_bin_2MSB = iodc_bin(1:2);
            obj.words_raw(3,:) = cat(2,week_number_bin, code, URA_bits, sv_health_bits, iodc_bin_2MSB); %24 raw data bits before parity.
            obj.words_encoded(3,:) = hamming_parity(obj.words_raw(3,:), obj.words_encoded(2,29), obj.words_encoded(2,30)); %parity encoding and adding 3rd word to object's word property.
        end

        function create_words_4_5_6(obj, p_code_flag)
            %create_words_4_5_6 creates words 4-6 of subframe 1 (most bits
            %are reserved and aren't important). 
            %p_code_flag - bit 1 of word 4. when 1 it says that that NAV data stream
            %was commanded off one the p-code on the in-phase component of
            %the L2 channel.
            p_code_flag = 1; %override given value, comment to disable

            obj.words_raw(4,:) = cat(2,p_code_flag,zeros(1,23)); %create word 4 raw data
            obj.words_encoded(4,:) = hamming_parity(obj.words_raw(4,:), obj.words_encoded(3,29),obj.words_encoded(3,30)); %encode word 4

            obj.words_raw(5,:) = zeros(1,24); %create word 5 raw data (all bits are reserved and aren't important for commercial use)
            obj.words_encoded(5,:) = hamming_parity(obj.words_raw(5,:), obj.words_encoded(4,29), obj.words_encoded(4,30)); %encoded word 5

            obj.words_raw(6,:) = zeros(1,24); %create word 6 raw data (all bits are reserved and aren't important for commercial use)
            obj.words_encoded(6,:) = hamming_parity(obj.words_raw(6,:), obj.words_encoded(5,29), obj.words_encoded(5,30)); %encoded word 6
        end

        function create_word7(obj, T_GD)
            %creates 7th word of subframe 1
            % T_GD = the group delay in seconds. should be assigned
            % to bits 17-24, signed.

            %override given value, comment to disable
%             T_GD = 0;
            
            reserved_bits_1_16 = zeros(1,16); %first 16 bits are reserve
            T_GD_bits = convert2bin(T_GD,2^-31, 8)-'0'; %8 scaled TGD signed bits 

            obj.words_raw(7,:) = cat(2,reserved_bits_1_16, T_GD_bits);
            obj.words_encoded(7,:) = hamming_parity(obj.words_raw(7,:), obj.words_encoded(6,29), obj.words_encoded(6,30));

        end

        function create_word8(obj, iodc, t_oc)
            %create 8th word of subframe 1
            %iodc - issue of data clock in decimal (positive integer). 
            % the 8 LSBs are assigned to the 8 MSBs of word 8.
            % t_oc - time of clock (in seconds), range 0-604,784. this
            % should match t_oe (time of ephemeris)
            iodc_bin = convert2bin(iodc,1,10)-'0'; 
            t_oc_bin_scaled = convert2bin(t_oc,2^4,16)-'0'; %scaled s.t LSB is 2^4 sec (low res)

            obj.words_raw(8,:) = cat(2,iodc_bin(3:end),t_oc_bin_scaled);
            obj.words_encoded(8,:) = hamming_parity(obj.words_raw(8,:), obj.words_encoded(7,29), obj.words_encoded(7,30));
        end

        function create_word9(obj, af2, af1)
            %creates the 9th word of subframe 1
            % af2 = in units of sec/sec^2, will be assigned to the first 8
            % of the word with a scale of 2^-55 at the LSB
            % af1 =  in units of sec/sec, will be assigned to bits 9-24 of
            % the word woth a scale of 2^-43 at the LSB
            af2_bin = convert2bin(af2,2^-55,8) - '0';
            af1_bin = convert2bin(af1,2^-43,16) - '0';
            obj.words_raw(9,:) = cat(2, af2_bin, af1_bin);
            obj.words_encoded(9,:) = hamming_parity(obj.words_raw(9,:),obj.words_encoded(8,29),obj.words_encoded(8,30));
        end

        function create_word10(obj, af0)
            %create 10th word of subframe 1
            %af0 - in seconds, will be assigned to 22 MSBs of the word, LSB
            %scale is 2^-31
            af0_bin = convert2bin(af0,2^-31,22)-'0';

            %bits 23-24 needs to be solved for bits 29-30 = 0 after parity
            ind_29_ = [1 3 5 6 7 9 10 14 15 16 17 18 21 22];
            ind_30_ = [3 5 6 8 9 10 11 13 15 19 22];

            bit24 = mod(obj.words_encoded(9,30) + sum(af0_bin(ind_29_)),2);
            bit23 = mod(obj.words_encoded(9,29) + sum(af0_bin(ind_30_)) + bit24, 2);

            obj.words_raw(10,:) = cat(2, af0_bin, bit23, bit24);
            obj.words_encoded(10,:) = hamming_parity(obj.words_raw(10,:),obj.words_encoded(9,29),obj.words_encoded(9,30));

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

