close all
test_filename = "adc_2_targets_1000_packets_1709.txt";
model_folder = "data/2026-09-17/model";
rtl_folder = "data/2026-09-19";
n_transfers = 50; % = n_packets / 20, max 50
tp_list = [tp.TP_BYPASS, tp.TP_CUT, tp.TP_FAPCH, tp.TP_LOU, tp.TP_SF,...
    tp.TP_MAX, tp.TP_FIND, tp.TP_RANK, tp.TP_APU];
range_gates = 0:140;


%%
run_board_test(tp_list, range_gates, test_filename);
%%
[rtl_sg, rtl_hdr] = read_board_data(rtl_folder, tp_num, range_gates);
model_sg = read_model_data(model_folder, tp_num);
%%
analyze_model_vs_rtl(tp_num, model_sg, rtl_sg);
