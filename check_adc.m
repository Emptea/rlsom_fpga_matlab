close all
test_filename = "2026-10-30_sig_tp1_fd.txt";
model_folder = "data/model/2026-10-30/try";
rtl_folder = "data/2026-11-03";
n_transfers = 150; % = n_packets / 20, max 50
tp_list = [ tp.TP_CUT...
    % tp.TP_BYPASS, tp.TP_CUT, tp.TP_FAPCH, tp.TP_LOU, tp.TP_SF, tp.TP_MTI, ...    
    % tp.TP_DDR, tp.TP_WEIGHT_OUT, tp.TP_FFT, ...
    % tp.TP_MAX, tp.TP_RANK, tp.TP_APU, ...
    % tp.TP_WORK, ...
    ];
range_gates = [25 26 27 33 34 35];

%%
run_board_test(tp_list, range_gates, n_transfers, test_filename);
%%
model_formulars = [];
for tp_num = tp_list
    [~, ~, rtl_formular, noise_formular, work_posthdr] = read_board_data(rtl_folder, tp_num, range_gates);
    if (tp_num == tp.TP_WORK)
        rtl_tp3_fap = read_rtl_data(rtl_folder, tp.TP_FAPCH);
        rtl_tp4_lou = read_rtl_data(rtl_folder, tp.TP_LOU);
        % model_sg = read_model_data(model_folder, tp.TP_NOISE,noise_formular);
        noise_fap = calc_noise_zone(rtl_tp3_fap, noise_formular);
        noise_lou = calc_noise_zone(rtl_tp4_lou, noise_formular);
        model_sg = [noise_fap; noise_lou];
        model_formulars = read_model_data(model_folder, tp_num, noise_formular);
    else
        model_sg = read_model_data(model_folder, tp_num,noise_formular);
    end
    [rtl_sg, rtl_hdr, rtl_range_gates] = read_rtl_data(rtl_folder, tp_num);
    if numel(rtl_range_gates) > 1
        model_sg = model_sg(:, rtl_range_gates + 1, :, :);
    end
    analyze_model_vs_rtl(tp_num, model_sg, rtl_sg, rtl_formular, true);
end
