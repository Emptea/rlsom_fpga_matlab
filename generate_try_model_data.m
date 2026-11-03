src_folder = "data\model\2026-10-30\sig";
model_folder = "data\model\2026-10-30\try";

for tp_num = enumeration("tp").'
    % if ismember(tp_num, [tp.TP_WORK])
    %     continue;
    % end

    convert_model_data(src_folder, model_folder, tp_num);
end