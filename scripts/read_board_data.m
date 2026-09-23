function [sg, hdr] = read_board_data(out_folder, tp_num, range_gates)
arguments
    out_folder string
    tp_num
    range_gates = 0:140
end

sg = [];
hdr = [];

%% Определяем количество каналов
% TODO

switch tp_num
    case {tp.TP_BYPASS, tp.TP_CUT, tp.TP_FAPCH, tp.TP_LOU, tp.TP_SF, tp.TP_MTI}
        channels = 0:7;
        range_gates = 0;
        var_name = "rtl_" + tp_num.to_string();
    case {tp.TP_DDR, tp.TP_FFT, tp.TP_WEIGHT_OUT}
        channels = 0:7;
        if isscalar(range_gates)
            var_name = "rtl_" + tp_num.to_string() + "_rg" + range_gates;
        else
            var_name = "rtl_" + tp_num.to_string();
        end
    case {tp.TP_FIND, tp.TP_MAX, tp.TP_RANK, tp.TP_APU, tp.TP_FAPCH_COEFFS}
        channels = 0;
        range_gates = 0;
        var_name = "rtl_" + tp_num.to_string();
    otherwise
        error("Unsupported test point: TP%d", double(tp_num));
end

%% Читаем
for idx_rg = range_gates
    for ch = channels
        hexname = fullfile(out_folder, "out", ...
            "out_tp" + double(tp_num) + ...
            "_ch" + ch + ...
            "_rg" + idx_rg + ".hex");
        
        if ~isfile(hexname)
            fprintf("Файл отсутствует: %s\n", hexname);
            continue;
        end
        
        [ch_data, ch_hdr] = fpga_read_res_file_for_ch(hexname);
        sg(ch + 1, :, :, idx_rg - range_gates(1) + 1) = ch_data;
        hdr = [hdr; ch_hdr];
    end
end
sg = squeeze(sg);
if length(range_gates) > 1
    sg = permute(sg, [1,4,2,3]);
end


%% Сохраняем один MAT-файл
matname = var_name + ".mat";
matfullname = fullfile(out_folder, matname);
S = struct();
S.(var_name).data = sg;
S.(var_name).hdr  = hdr;
S.(var_name).range_gates = range_gates;
save(matfullname, "-struct", "S");
fprintf("Создан файл: %s\n", matfullname);

end