function get_board_data(savefolder, basename, date)
arguments
    savefolder string
    basename string = "out";
    date string = string(datetime('today', 'Format', 'yyyy-MM-dd'));
end
prog_path = "~/drivers/ip_comm_test/build/";
if ~exist(savefolder, 'dir')
    mkdir(savefolder)
end
system_cmd = "scp " + " mini:" + prog_path ...
    + date + "/" + basename + "* " + savefolder;
[status, cmdout] = system(system_cmd);

if status == 0
    fprintf('✓ Files copied successfully from %s%s/%s/ to %s\n', ...
        prog_path, date, basename, savefolder);
    % List copied files
    ls(savefolder + basename + "*");
else
    fprintf('✗ SCP failed with status: %d\n', status);
    % Try to get error message with stderr redirection
    [~, errout] = system(system_cmd + " 2>&1");
    disp(errout);
end