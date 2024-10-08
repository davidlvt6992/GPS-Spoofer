classdef frame < handle
    %this class handles the creation of an entire GPS frame (1500 bits)
    
    properties
        sf1 %subframe 1 class object
        sf2 %subframe 2 class object
        sf3 %subframe 3 class object
        sf4 %subframe 4 class object
        sf5 %subframe 5 class object
        bit_stream %total bitstream of the frame, (1500 bits)
    end
    
    methods
        function obj = frame(eph,others_struct)
            %FRAME Construct an instance of this class
            % eph = ephemeris data struct.
            % others_struct = struct that contains other information needed 
            % to construct the frames.

            %convert eph parameters that are suuposed to be transmitted in
            %semi circles from rad to semi-circles.
            eph.dn = eph.dn/pi;
            eph.m0 = eph.m0/pi;
            eph.omg0 = eph.omg0/pi;
            eph.i0 = eph.i0/pi;
            eph.w = eph.w/pi;
            eph.odot = eph.odot/pi;
            eph.idot = eph.idot/pi;

            obj.create_sf1(eph,others_struct);
%             others_struct.TOW = others_struct.TOW + 6;
            obj.create_sf2(eph,others_struct);
%             others_struct.TOW = others_struct.TOW + 6;
            obj.create_sf3(eph,others_struct);
%             others_struct.TOW = others_struct.TOW + 6;
            obj.create_sf4(eph,others_struct);
%             others_struct.TOW = others_struct.TOW + 6;
            obj.create_sf5(eph,others_struct);
            obj.bit_stream = cat(2,obj.sf1.bit_stream, ...
                obj.sf2.bit_stream, obj.sf3.bit_stream, ...
                obj.sf4.bit_stream, obj.sf5.bit_stream);
        end
    end

    methods (Access = protected)
        function create_sf1(obj, eph, others_struct)
            %create subframe 1
            obj.sf1 = subframe1();
            obj.sf1.create_word1(others_struct.TLM_msg);
            obj.sf1.create_word2(others_struct.TOW,others_struct.alert_flag,others_struct.AS_flag);
            obj.sf1.create_word3(others_struct.week_number,others_struct.code, others_struct.URA_bits,others_struct.sv_health_bits, eph.iod);
            obj.sf1.create_words_4_5_6(others_struct.p_code_flag);
            obj.sf1.create_word7(others_struct.T_GD);
            obj.sf1.create_word8(eph.iod,eph.toc);
            obj.sf1.create_word9(eph.af2,eph.af1);
            obj.sf1.create_word10(eph.af0);
            obj.sf1.create_bitstream();
        end

        function create_sf2(obj, eph, others_struct)
            %create subframe 2
            obj.sf2 = subframe2();
            obj.sf2.create_word1(others_struct.TLM_msg);
            obj.sf2.create_word2(others_struct.TOW+6,others_struct.alert_flag,others_struct.AS_flag);
            obj.sf2.create_word3(eph.iod,eph.crs);
            obj.sf2.create_words_4_5(eph.dn,eph.m0);
            obj.sf2.create_words_6_7(eph.cuc, eph.e);
            obj.sf2.create_words_8_9(eph.cus, eph.sqrtA);
            obj.sf2.create_word10(eph.toe,others_struct.fit_flag,others_struct.AODO);
            obj.sf2.create_bitstream();
        end

        function create_sf3(obj, eph, others_struct)
            %create subframe 3
            obj.sf3 = subframe3();
            obj.sf3.create_word1(others_struct.TLM_msg);
            obj.sf3.create_word2(others_struct.TOW+2*6,others_struct.alert_flag,others_struct.AS_flag);
            obj.sf3.create_words_3_4(eph.cic, eph.omg0);
            obj.sf3.create_words_5_6(eph.cis,eph.i0);
            obj.sf3.create_words_7_8(eph.crc, eph.w);
            obj.sf3.create_words_9_10(eph.odot,eph.iod,eph.idot);
            obj.sf3.create_bitstream();
        end

        function create_sf4(obj, eph, others_struct)
            %create subframe 4
            obj.sf4 = subframe4();
            obj.sf4.create_word1(others_struct.TLM_msg);
            obj.sf4.create_word2(others_struct.TOW+3*6,others_struct.alert_flag,others_struct.AS_flag);
            obj.sf4.create_bitstream();
        end

        function create_sf5(obj, eph, others_struct)
            %create subframe 5
            obj.sf5 = subframe5();
            obj.sf5.create_word1(others_struct.TLM_msg);
            obj.sf5.create_word2(others_struct.TOW+4*6,others_struct.alert_flag,others_struct.AS_flag);
            obj.sf5.create_bitstream();
        end
    end
end

