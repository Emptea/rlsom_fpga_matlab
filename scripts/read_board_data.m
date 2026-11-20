function [sg, hdr, work_packet] = read_board_data(out_folder, tp_num, range_gates)
arguments
    out_folder string
    tp_num
    range_gates = 0:140
end

sg = [];
hdr = [];
work_packet = struct([]);

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
    case {tp.TP_FIND, tp.TP_MAX, tp.TP_RANK, tp.TP_APU, tp.TP_FAPCH_COEFFS, tp.TP_WORK, tp.TP_PU_IN}
        channels = 0;
        range_gates = 0;
        var_name = "rtl_" + tp_num.to_string();
    otherwise
        error("Unsupported test point: TP%d", double(tp_num));
end

%% Читаем
idx_rg = 1;
for rg = range_gates
    for ch = channels
        hexname = fullfile(out_folder, "out", ...
            "out_tp" + double(tp_num) + ...
            "_ch" + ch + ...
            "_rg" + rg + ".hex");
        
        if ~isfile(hexname)
            fprintf("Файл отсутствует: %s\n", hexname);
            continue;
        end
        
        [ch_data, ch_hdr, ch_work_packet] = fpga_read_res_file_for_ch(hexname);
        if isempty(ch_hdr)
            fprintf("Файл пуст: %s\n", hexname);
            continue;
        end
        sg(ch + 1, :, :, idx_rg) = ch_data;
        hdr = [hdr; ch_hdr];
        if tp_num == 0
            work_packet = [work_packet; ch_work_packet(:)];
        end
    end
    idx_rg = idx_rg + 1;
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
S.(var_name).work_packet = work_packet;
save(matfullname, "-struct", "S");
fprintf("Создан файл: %s\n", matfullname);

end
