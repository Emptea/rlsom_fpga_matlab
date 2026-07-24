function sg = fpga_txt2mat(filename)

fprintf('Обработка файла: %s\n', filename);

[folder, name, ext] = fileparts(filename);
file = name + ext;
out_filename = folder + "/" + name + ".mat";
% Определяем тип файла
if contains(file, "tp1")
    sg = fpga_read_test_file(filename, [232, 1]);
    tp1_fd = fpga_fxp2double(sg);
    save(out_filename, "tp1_fd");
elseif contains(file, "tp2-fap")
    sg = fpga_read_test_file(filename, [141, 1]);
    tp2_fap = fpga_fxp2double(sg);
    save(out_filename, "tp2_fap");
elseif contains(file, "tp3-lou")
    sg = fpga_read_test_file(filename, [141, 1]);
    tp3_lou = fpga_fxp2double(sg);
    save(out_filename, "tp3_lou");
elseif contains(file, "tp4-sf-far")
    n_sf = 40;
    sg = fpga_read_test_file(filename, [n_sf, 1]);
    tp4_sf_far = fpga_fxp2double(sg) * n_sf;
    save(out_filename, "tp4_sf_far");    
elseif contains(file, "tp4-sf-near")
    n_sf = 6;
    sg = fpga_read_test_file(filename, [n_sf, 1]);
    tp4_sf_near = fpga_fxp2double(sg) * n_sf;
    save(out_filename, "tp4_sf_near"); 
elseif contains(file, "tp5-kn-far")
    n_sf = 40;
    n_fft = 512;
    sg = fpga_read_test_file(filename, [n_sf, n_fft]);
    tp5_kn_far = fpga_fxp2double(sg) * n_sf * n_fft;
    save(out_filename, "tp5_kn_far"); 
elseif contains(file, "tp5-kn-near")
    n_sf = 6;
    n_fft = 512;
    sg = fpga_read_test_file(filename, [n_sf, n_fft]);
    tp5_kn_near = fpga_fxp2double(sg) * n_sf * n_fft;
    save(out_filename, "tp5_kn_near");    
else
    return;
end

fprintf('Создание файла: %s\n', out_filename);
end



