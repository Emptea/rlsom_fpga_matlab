function sg = fpga_txt2mat_for_ch(filename, ch_num)

fprintf('Обработка файла: %s\n', filename);

[folder, name, ext] = fileparts(filename);
file = string(name) + string(ext);
out_filename = folder + "/" + name + "_ch" + ch_num + ".mat";
hdr_sz = 6;
% Определяем тип файла
if contains(file, "tp1")
    sg = fpga_read_res_file_for_ch(filename, [232 + hdr_sz, 1]);
    tp1_fd = fpga_fxp2double(sg);
    save(out_filename, "tp1_fd");
elseif contains(file, "tp2")
    sg = fpga_read_res_file_for_ch(filename, [141 + hdr_sz, 1]);
    tp2_cut = fpga_fxp2double(sg);
    save(out_filename, "tp2_cut");
elseif contains(file, "tp3")
    sg = fpga_read_res_file_for_ch(filename, [141 + hdr_sz, 1]);
    tp3_fap = fpga_fxp2double(sg);
    save(out_filename, "tp3_fap");
elseif contains(file, "tp4")
    n_sf = 40;
    sg = fpga_read_res_file_for_ch(filename, [141 + hdr_sz, 1]);
    tp4_lou = fpga_fxp2double(sg) * n_sf;
    save(out_filename, "tp4_lou");    
% elseif contains(file, "tp4-sf-near") || contains(file, "tp4_sf_near")
%     n_sf = 6;
%     sg = fpga_read_res_file_for_ch(filename, [n_sf, 1]);
%     tp4_sf_near = fpga_fxp2double(sg) * n_sf;
%     save(out_filename, "tp4_sf_near"); 
elseif contains(file, "tp5")
    n_sf = 40;
    n_fft = 512;
    sg = fpga_read_res_file_for_ch(filename, [n_sf, n_fft]);
    tp5_kn_far = fpga_fxp2double(sg) * n_sf * n_fft;
    save(out_filename, "tp5_kn_far"); 
% elseif contains(file, "tp5-kn-near") || contains(file, "tp5_kn_near")
%     n_sf = 6;
%     n_fft = 512;
%     sg = fpga_read_res_file_for_ch(filename, [n_sf, n_fft]);
%     tp5_kn_near = fpga_fxp2double(sg) * n_sf * n_fft;
%     save(out_filename, "tp5_kn_near");    
else
    return;
end

fprintf('Создание файла: %s\n', out_filename);
end



