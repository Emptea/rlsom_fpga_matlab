close all
test_filename = "adc_2_targets_1000_packets_1709.txt";
model_folder = "data/model/try";
rtl_folder = "data/2026-09-25";
n_transfers = 50; % = n_packets / 20, max 50
tp_list = [ ...
    tp.TP_BYPASS, tp.TP_CUT, tp.TP_FAPCH, tp.TP_LOU, tp.TP_SF,...
    tp.TP_DDR, tp.TP_FFT, tp.TP_WEIGHT_OUT, ...
    tp.TP_MAX, tp.TP_FIND, tp.TP_RANK, tp.TP_APU ...
    ];
% tp_list = [tp.TP_MAX, tp.TP_RANK, tp.TP_APU];
range_gates = 0:140;

%%
run_board_test(tp_list, range_gates, n_transfers, test_filename);
%%
for tp_num = tp_list
    [rtl_sg, rtl_hdr] = read_board_data(rtl_folder, tp_num, range_gates);
    % model_sg = read_model_data(model_folder, tp_num);
    % if numel(rtl_hdr.range) > 1
    %     model_sg = model_sg(:, rtl_hdr.range, :, :);
    % end
    % analyze_model_vs_rtl(tp_num, model_sg, rtl_sg);
end
