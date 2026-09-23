classdef tp < uint8
    enumeration
        TP_WORK             (0)
        TP_BYPASS           (1)
        TP_CUT              (2)
        TP_FAPCH            (3)
        TP_LOU              (4)
        TP_SF               (5)
        TP_DDR              (6)
        TP_FFT              (7)
        TP_MAX              (8)
        TP_FIND             (9)
        TP_RANK             (10)
        TP_APU              (11)
        TP_FAPCH_COEFFS     (12)
        TP_WEIGHT_OUT       (13)
        TP_MTI              (14)
    end
    
    methods
        function str = to_string(obj)
            str = "tp" + double(obj) + "_" + ...
                lower(extractAfter(string(obj), "TP_"));
        end
    end
end