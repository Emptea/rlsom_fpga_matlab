function get_board_data(savefolder, basename, date)
arguments
    savefolder string
    basename string = "out";
    date string = string(datetime('today', 'Format', 'yyyy-MM-dd'));
end

prog_path = "~/drivers/ip_comm_test/build/";
board_files = fullfile(prog_path, date, basename + "*");
if ~exist(savefolder, 'dir')
    mkdir(savefolder)
end

system_cmd = "scp ""mini:" + board_files + """ """ + savefolder + "/""";

[status, cmdout] = system(system_cmd + " 2>&1");

save_files = fullfile(savefolder, basename + "*");
if status == 0
    fprintf('✓ Files copied successfully from %s%s/%s/ to %s\n', ...
        prog_path, date, basename, savefolder);
    % List copied files
    fprintf('%s\n', dir(save_files).name);
else
    fprintf('✗ scp failed with status: %d\n', status);
    disp(cmdout);
end