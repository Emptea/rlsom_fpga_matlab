src_folder = "data\2026-09-17\sig";
model_folder = "data\2026-09-17\model";

for tp_num = enumeration("tp").'
    if ismember(tp_num, [tp.TP_WORK, tp.TP_APU])
        continue;
    end

    convert_model_data(src_folder, model_folder, tp_num);
end