classdef subframe4 < handle
    %SUBFRAME4 Summary of this class goes here
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
        subframe_id = 4; %number of subframe
    end
    methods
        function obj = subframe4()
            %SUBFRAME4 Construct an instance of this class
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

        function subframe_bitstream = create_bitstream(obj)
            %creates a 1 by 300 array of entire subframe bitstream and
            %returns it, also assigns it to bit_stream property of the
            %object
            obj.bit_stream = reshape(obj.words_encoded',1,[]);
            subframe_bitstream = obj.bit_stream;
        end

    end
end

