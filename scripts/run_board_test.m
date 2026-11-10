function run_board_test(tp_list, range_gates, n_transfers, test_filename, savefolder)
arguments
    tp_list
    range_gates {mustBeInteger, mustBeInRange(range_gates, 0, 140)} = 0
    n_transfers {mustBeInteger, mustBeInRange(n_transfers, 1, 1000)} = 50
    test_filename string = "adc_2_targets_1000_packets_1709.txt"
    savefolder string = fullfile("data", string(datetime('today', 'Format', 'yyyy-MM-dd')), "out")
end
fprintf('\nrun_board_test\n')
n_tests = 0;
idx_test = 0;
for tp_num = tp_list
    idx_test = idx_test + 1;
    tests_cfg(idx_test).tp = tp_num;
    switch tp_num
        case {tp.TP_BYPASS, tp.TP_CUT, tp.TP_FAPCH, tp.TP_LOU, tp.TP_SF, tp.TP_MTI}
            tests_cfg(idx_test).channels = 0:7;
            tests_cfg(idx_test).range_gates = 0;
            
        case {tp.TP_DDR, tp.TP_FFT, tp.TP_WEIGHT_OUT}
            tests_cfg(idx_test).channels = 0:7;
            tests_cfg(idx_test).range_gates = range_gates;
            
        case {tp.TP_MAX, tp.TP_FIND, tp.TP_RANK, tp.TP_APU, tp.TP_WORK}
            tests_cfg(idx_test).channels = 0;
            tests_cfg(idx_test).range_gates = 0;
            
        otherwise
            error("Unsupported test: %s", (tp_num.to_string()));
    end
    n_tests = n_tests + numel(tests_cfg(idx_test).range_gates);
end

idx_test = 0;
for test = tests_cfg
    tp_num = test.tp;
    for range_gate = test.range_gates        
        progress = 100 * idx_test / n_tests;
        idx_test = idx_test + 1;
        fprintf('== %5.1f%% | %-15s | range_gate = %3d \n', progress, tp_num.to_string(), range_gate);
        
        for ch = test.channels
            launch_ip_comm_test(tp_num, ch, range_gate, n_transfers, test_filename);
        end
        
    end
end
disp("== 100.0% | complete");
%%
get_board_data(savefolder);

end