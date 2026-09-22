src_folder = "data\model\sig";
model_folder = "data\model\try";

for tp_num = enumeration("tp").'
    if ismember(tp_num, [tp.TP_WORK])
        continue;
    end

    convert_model_data(src_folder, model_folder, tp_num);
end