close all
test_filename = "2026-10-01_sig_tp1_fd.txt";
model_folder = "data/model/2026-10-01/try";
rtl_folder = "data/2026-10-03";
n_transfers = 50; % = n_packets / 20, max 50
tp_list = [ ...
    tp.TP_BYPASS, tp.TP_CUT, tp.TP_FAPCH, tp.TP_LOU, tp.TP_SF, tp.TP_MTI, ...    
    tp.TP_DDR, tp.TP_WEIGHT_OUT, tp.TP_FFT, ...
    tp.TP_MAX, tp.TP_RANK, tp.TP_APU, ...
    tp.TP_WORK];
% tp_list = [tp.TP_MAX, tp.TP_RANK, tp.TP_APU];
range_gates = [40,120];

%%
run_board_test(tp_list, range_gates, n_transfers, test_filename);
%%
for tp_num = tp_list
    [rtl_sg, rtl_hdr] = read_board_data(rtl_folder, tp_num, range_gates);
    model_sg = read_model_data(model_folder, tp_num);
    [rtl_sg, rtl_hdr, rtl_range_gates] = read_rtl_data(rtl_folder, tp_num);
    if numel(rtl_range_gates) > 1
        model_sg = model_sg(:, rtl_range_gates + 1, :, :);
    end
    analyze_model_vs_rtl(tp_num, model_sg, rtl_sg);
end
