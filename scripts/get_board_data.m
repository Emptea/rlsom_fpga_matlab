function get_board_data(savefolder, basename, date)
arguments
    savefolder string
    basename string = "out";
    date string = string(datetime('today', 'Format', 'yyyy-MM-dd'));
end

prog_path = "~/drivers/ip_comm_test/build/";
remote_folder = prog_path + date + "/";
if ~exist(savefolder, 'dir')
    mkdir(savefolder)
end

system_cmd = ...
    "rsync -av --include='" + basename + "*' --exclude='*' " + ...
    "mini:" + remote_folder + " """ + savefolder + "/""";
[status, cmdout] = system(system_cmd);

if status == 0
    fprintf('✓ Files copied successfully from %s%s/%s/ to %s\n', ...
        prog_path, date, basename, savefolder);
    % List copied files
    ls(savefolder + basename + "*");
else
    fprintf('✗ rsync failed with status: %d\n', status);
    disp(cmdout);
end