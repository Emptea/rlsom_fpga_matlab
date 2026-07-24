function fpga_mat2txt(filename)

fprintf('Обработка файла: %s\n', filename);

[folder, name, ext] = fileparts(filename);
file = name + ext;
out_filename = folder + "/" + name + ".txt";
load(filename);
% Определяем тип файла
if contains(file, "tp1-fd") || contains(file, "tp1_fd")
    d = fpga_double2fxp(tp1_fd);    
elseif contains(file, "tp2-fap") || contains(file, "tp2_fap")
    d = fpga_double2fxp(tp2_fap);
elseif contains(file, "tp3-lou") || contains(file, "tp3_lou")
    d = fpga_double2fxp(tp3_lou);
elseif contains(file, "tp4-sf-far") || contains(file, "tp4_sf_far")
    n_sf = 40;
    d = fpga_double2fxp(tp4_sf_far / n_sf);
elseif contains(file, "tp4-sf-near") || contains(file, "tp4_sf_near")
    n_sf = 6;
    d = fpga_double2fxp(tp4_sf_near / n_sf);
elseif contains(file, "tp4-sf-both") || contains(file, "tp4_sf_both")
    n_sf_far = 40;
    tp4_sf_both(:,1:101,:) = tp4_sf_both(:,1:101,:) ./ n_sf_far;
    n_sf_near = 6;
    tp4_sf_both(:,102:end,:) = tp4_sf_both(:,102:end,:) ./ n_sf_near;
    d = fpga_double2fxp(tp4_sf_both / n_sf_near);
elseif contains(file, "tp5-kn-far") || contains(file, "tp5_kn_far")
    n_sf = 40;
    n_fft = 512;
    d = fpga_double2fxp(tp5_kn_far / n_sf / n_fft);
elseif contains(file, "tp5-kn-near") || contains(file, "tp5_kn_near")
    n_sf = 6;
    n_fft = 512;
    d = fpga_double2fxp(tp5_kn_near / n_sf / n_fft);
else
    return;
end

fprintf('Создание файла: %s\n', out_filename);
fpga_create_test_file(d, out_filename);

end



