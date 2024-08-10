function eph_struct = eph_XML2struct(xml_path)
%EPH_XML2STRUCT Summary of this function goes here
%   Detailed explanation goes here
    S = readstruct(xml_path);
    N = length(S.GNSS_SDR_ephemeris_map.item);
    eph_formatted_ = [];

    for i = 1:N
        eph = [];
        eph.svid = S.GNSS_SDR_ephemeris_map.item(i).second.PRN;
        eph.toc = S.GNSS_SDR_ephemeris_map.item(i).second.toc;
        eph.toe = S.GNSS_SDR_ephemeris_map.item(i).second.toe;
        eph.af0 = S.GNSS_SDR_ephemeris_map.item(i).second.af0;
        eph.af1 = S.GNSS_SDR_ephemeris_map.item(i).second.af1;
        eph.af2 = S.GNSS_SDR_ephemeris_map.item(i).second.af2;
    
    %     eph.ura = S.GNSS_SDR_ephemeris_map.item(i).second.af2;   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        eph.e = S.GNSS_SDR_ephemeris_map.item(i).second.ecc; %%%%%%%%%%%%%%%%%%%%%%%%
        eph.sqrtA = S.GNSS_SDR_ephemeris_map.item(i).second.sqrtA;
        eph.dn = S.GNSS_SDR_ephemeris_map.item(i).second.delta_n;
        eph.m0 = S.GNSS_SDR_ephemeris_map.item(i).second.M_0;
    
        eph.w = S.GNSS_SDR_ephemeris_map.item(i).second.omega;
        eph.omg0 = S.GNSS_SDR_ephemeris_map.item(i).second.OMEGA_0;
        eph.i0 = S.GNSS_SDR_ephemeris_map.item(i).second.i_0;
        eph.odot = S.GNSS_SDR_ephemeris_map.item(i).second.OMEGAdot;
        eph.idot = S.GNSS_SDR_ephemeris_map.item(i).second.idot;
        eph.cus = S.GNSS_SDR_ephemeris_map.item(i).second.Cus;
        eph.cuc = S.GNSS_SDR_ephemeris_map.item(i).second.Cuc;
        eph.cis = S.GNSS_SDR_ephemeris_map.item(i).second.Cis;
        eph.cic = S.GNSS_SDR_ephemeris_map.item(i).second.Cic;
        eph.crs = S.GNSS_SDR_ephemeris_map.item(i).second.Crs;
        eph.crc = S.GNSS_SDR_ephemeris_map.item(i).second.Crc;
        eph.iod = S.GNSS_SDR_ephemeris_map.item(i).second.IODC; %%%%%%%%%%%%%%%%%%%%%
        eph.GPSWeek = S.GNSS_SDR_ephemeris_map.item(i).second.M_0; %%%%%%%%%%%%%%%%%%%%
    
    
        eph_formatted_{i} = eph;

    end

    eph_struct = eph_formatted_;
end

