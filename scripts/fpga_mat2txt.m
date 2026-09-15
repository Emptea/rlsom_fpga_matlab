function fpga_mat2txt(filename)

fprintf('Обработка файла: %s\n', filename);

[folder, name, ext] = fileparts(filename);
file = name + ext;
out_filename = folder + "/" + name + ".txt";
load(filename);
% Определяем тип файла
if contains(file, "tp1-fd") || contains(file, "tp1_fd")
    % d = fpga_double2fxp(tp1_fd);    
    d = tp1_fd;    
elseif contains(file, "tp2-fap") || contains(file, "tp2_fap")
    % d = fpga_double2fxp(tp2_fap);
    d = tp2_fap;
elseif contains(file, "tp3-lou") || contains(file, "tp3_lou")
    % d = fpga_double2fxp(tp3_lou);
    d = tp3_lou;
elseif contains(file, "tp4-sf-far") || contains(file, "tp4_sf_far")
    % d = fpga_double2fxp(tp4_sf_far);
    d = tp4_sf_far;
elseif contains(file, "tp4-sf-near") || contains(file, "tp4_sf_near")
    % d = fpga_double2fxp(tp4_sf_near);
    d = tp4_sf_near;
elseif contains(file, "tp4-sf-both") || contains(file, "tp4_sf_both")
    tp4_sf_both(:,1:101,:) = tp4_sf_both(:,1:101,:);
    tp4_sf_both(:,102:end,:) = tp4_sf_both(:,102:end,:);
    % d = fpga_double2fxp(tp4_sf_both_near);
    d = tp4_sf_both
elseif contains(file, "tp5-kn-far") || contains(file, "tp5_kn_far")
    % d = fpga_double2fxp(tp5_kn_far);
    d = tp5_kn_far;
elseif contains(file, "tp5-kn-near") || contains(file, "tp5_kn_near")
    % d = fpga_double2fxp(tp5_kn_near);
    d = tp5_kn_near;
else
    return;
end

fprintf('Создание файла: %s\n', out_filename);
fpga_create_test_file(d, out_filename);

end



