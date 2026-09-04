function launch_ip_comm_test(tp_num, ch_num, range_gate, n_transfers, input_file, out_basename)
arguments
    tp_num double
    ch_num double
    range_gate double = 0
    n_transfers double = 4
    input_file string = "sig_tp1_repeat.txt";
    out_basename string = "out"
end
output_file = out_basename + "_tp" + tp_num + "_ch" + ch_num + "_rg" + range_gate + ".hex";
prog_path = "~/drivers/ip_comm_test/build/";
executable = "./ip_comm_test";

system_cmd = sprintf('ssh -t mini "cd %s && sudo %s %d %d %d %d %s %s && sudo ./reload_driver.sh "', ...
    prog_path, executable, tp_num, ch_num, range_gate, n_transfers, input_file, output_file);
disp(system_cmd)
[~, cmdout] = system(system_cmd);

lines = split(cmdout, newline);
dmaLines = lines(contains(lines, 'DMA'));
dmaLines = strjoin(dmaLines, newline);
initLines = lines(contains(lines,'dma_proxy module initialized'));
initLines = strjoin(initLines, newline);

disp(dmaLines)
disp(initLines)