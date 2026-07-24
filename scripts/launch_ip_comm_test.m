function launch_ip_comm_test(tp_num, ch_num, n_transfers, input_file, out_basename)
arguments
    tp_num double
    ch_num double
    n_transfers double = 4
    input_file string = "sig_tp1_repeat.txt";
    out_basename string = "out"
end
output_file = out_basename + "_tp" + tp_num + "_ch" + ch_num + ".hex";
prog_path = "~/drivers/ip_comm_test/build/";
executable = "./ip_comm_test";

system_cmd = sprintf('ssh -t mini "cd %s && sudo %s %d %d %d %s %s"', ...
    prog_path, executable, tp_num, ch_num, n_transfers, input_file, output_file);
disp(system_cmd)
[status, cmdout] = system(system_cmd);
disp(cmdout)